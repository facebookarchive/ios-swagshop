//
//  SettingsViewController.m
//  SwagStore
//
//  Created by Luz Caballero on 8/6/13.
//  Copyright (c) 2013 Facebook Inc. All rights reserved.
//

#import "SettingsViewController.h"
#import "WishlistViewController.h"
#import "ItemListViewController.h"
#import "AppDelegate.h"
#import "Item.h"

@interface SettingsViewController ()
@property (strong, nonatomic) IBOutlet FBLoginView *loginView;
@property (strong, nonatomic) IBOutlet UILabel *loggedInMessage;
@property (weak, nonatomic) IBOutlet UILabel *labelUserName;
@property (strong, nonatomic) IBOutlet FBProfilePictureView *imageProfilePicture;
@property (strong, nonatomic) IBOutlet UIButton *buttonWishlist;

@property NSMutableArray *wishlistItemsArray;
@property WishlistViewController *wishlistViewController;

@end

@implementation SettingsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self){
    [[self labelUserName] setText:nil];
    [[self imageProfilePicture] setProfileID:nil];
    
    // Adding the wishlist button
    [[self buttonWishlist] addTarget:self
                              action:@selector(goToWishlist:)
                    forControlEvents:UIControlEventTouchUpInside];
  }
  return self;
}

// FBLoginView delegate method called when the user is logged in
- (void)loginViewShowingLoggedInUser:(FBLoginView *)loginView {
  [[self buttonWishlist] setHidden:NO];
  [[self loggedInMessage] setHidden:NO];
  
  // Call userLoggedOut in the app delegate to make sure we progapate the logged in state throught the app
  // Any changes related to session state that need to be made throughout the app will me made there
  AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
  [appDelegate userLoggedIn];
}

// FBLoginView delegate method called when the user is logged out
- (void)loginViewShowingLoggedOutUser:(FBLoginView *)loginView {
  [[self labelUserName] setText:nil];
  [[self imageProfilePicture] setProfileID:nil];
  [[self buttonWishlist] setHidden:YES];
  [[self loggedInMessage] setHidden:YES];
  
  // Call userLoggedOut in the app delegate to make sure we progapate the logged out state throught the app
  // Any changes related to session state that need to be made throughout the app will me made there
  AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
  [appDelegate userLoggedOut];

}

// FBLoginView delegate method called when the FBLoginView has fetched the user details (after user login)
- (void)loginViewFetchedUserInfo:(FBLoginView *)loginView user:(id<FBGraphUser>)user {
  [[self labelUserName] setText:[user name]];
  [[self imageProfilePicture] setProfileID:[user id]];
}

// Detect and respond to login errors
- (void)loginView:(FBLoginView *)loginView handleError:(NSError *)error {
  NSString *alertMessage, *alertTitle;
  if (error.fberrorShouldNotifyUser) {
    // If the SDK has a message for the user, surface it. This conveniently
    // handles cases like password change or iOS6 app slider state.
    alertTitle = @"Facebook Error";
    alertMessage = error.fberrorUserMessage;
  } else if (error.fberrorCategory == FBErrorCategoryAuthenticationReopenSession) {
    // It is important to handle session closures since they can happen
    // outside of the app. You can inspect the error for more context
    // but this sample generically notifies the user.
    alertTitle = @"Session Error";
    alertMessage = @"Your current session is no longer valid. Please log in again.";
  } else if (error.fberrorCategory == FBErrorCategoryUserCancelled) {
    // The user has cancelled a login. You can inspect the error
    // for more context. For this sample, we will simply ignore it.
    NSLog(@"user cancelled login");
  } else {
    // For simplicity, this sample treats other errors blindly.
    NSDictionary *errorInformation = [[[error.userInfo objectForKey:@"com.facebook.sdk:ParsedJSONResponseKey"] objectForKey:@"body"] objectForKey:@"error"];
    alertTitle  = @"Something went wrong";
    alertMessage = [NSString stringWithFormat:@"Please retry. \n\n If the problem persists contact us and mention this error code: %@", [errorInformation objectForKey:@"message"]];
    NSLog(@"Unexpected error:%@", error);
  }
  
  if (alertMessage) {
    [[[UIAlertView alloc] initWithTitle:alertTitle
                                message:alertMessage
                               delegate:nil
                      cancelButtonTitle:@"OK"
                      otherButtonTitles:nil] show];
  }
}

- (IBAction)goToWishlist:(id)sender
{
  [self allWishlistItems];
}

- (void)allWishlistItems
{
  _wishlistItemsArray = [[NSMutableArray alloc] initWithArray:@[]];
  if (FBSession.activeSession.isOpen) {
    // If there's a session open, check the permissions and then read the user's OG action history
    [self checkPermissionsAndReadActions];
  } else {
    // There's no open session, open one
    [FBSession openActiveSessionWithReadPermissions:@[@"user_actions:fbswagshop"]
                                       allowLoginUI:YES
                                  completionHandler:
     ^(FBSession *session, FBSessionState state, NSError *error) {
       __block NSString *alertText;
       __block NSString *alertTitle;
       // If the session was opened successfully...
       if (!error && state == FBSessionStateOpen){
         // Go through the general session handling process
         AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
         [appDelegate userLoggedIn];
         
         // We can read the actions because we've just opened the session with the right permissions
         [self readActions];
       } else {
         // Handle errors
         if (error.fberrorShouldNotifyUser == YES){
           // Error requires people using an app to make an out-of-band action to recover
           alertTitle = @"Something went wrong :S";
           alertText = [NSString stringWithString:error.fberrorUserMessage];
           [self showMessage:alertText withTitle:alertTitle];
         } else {
           // We need to handle the error
           if (error.fberrorCategory == FBErrorCategoryUserCancelled) {
             alertTitle = @"Login cancelled";
             alertText = @"You need to login to be able to save to your wishlist.";
             [self showMessage:alertText withTitle:alertTitle];
           } else {
             // All other errors that can happen need retries
             // more info: https://github.com/facebook/facebook-ios-sdk/blob/master/src/FBError.h#L163
             
             //Get more error information from the error and
             NSDictionary *errorInformation = [[[error.userInfo objectForKey:@"com.facebook.sdk:ParsedJSONResponseKey"] objectForKey:@"body"] objectForKey:@"error"];
             
             // Show the user an error message
             alertTitle = @"Something went wrong :S";
             alertText = [NSString stringWithFormat:@"Please retry. \n\n If the problem persists contact us and mention this error code: %@", [errorInformation objectForKey:@"message"]];
             [self showMessage:alertText withTitle:alertTitle];
           }
         }
       }
     }];
  }
}

- (void)checkPermissionsAndReadActions
{
  [FBRequestConnection startWithGraphPath:@"/me/permissions"
                        completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                          __block NSString *alertText;
                          __block NSString *alertTitle;
                          if (!error){
                            NSDictionary *permissions= [(NSArray *)[result data] objectAtIndex:0];
                            if (![permissions objectForKey:@"user_actions:fbswagshop"]){
                              // Permission hasn't been granted, so ask for publish_actions
                              [FBSession.activeSession requestNewReadPermissions:[NSArray arrayWithObject:@"user_actions:fbswagshop"]
                                                               completionHandler:^(FBSession *session, NSError *error) {
                                                                 if (!error) {
                                                                   // Permission granted
                                                                   [self readActions];
                                                                 } else {
                                                                   // An error occurred
                                                                   if (error.fberrorShouldNotifyUser == YES){
                                                                     // Error requires people using an app to make an out-of-band action to recover
                                                                     alertTitle = @"Something went wrong :S";
                                                                     alertText = [NSString stringWithString:error.fberrorUserMessage];
                                                                     [self showMessage:alertText withTitle:alertTitle];
                                                                   } else {
                                                                     // We need to handle the error
                                                                     if (error.fberrorCategory == FBErrorCategoryUserCancelled) {
                                                                       alertTitle = @"Permission not granted";
                                                                       alertText = @"You need to let Swag Shop access your past actions on Swag Shop in order to see your wishlist.";
                                                                       [self showMessage:alertText withTitle:alertTitle];
                                                                     } else {
                                                                       // All other errors that can happen need retries
                                                                       // more info: https://github.com/facebook/facebook-ios-sdk/blob/master/src/FBError.h#L163
                                                                       
                                                                       //Get more error information from the error and
                                                                       NSDictionary *errorInformation = [[[error.userInfo objectForKey:@"com.facebook.sdk:ParsedJSONResponseKey"] objectForKey:@"body"] objectForKey:@"error"];
                                                                       
                                                                       // Show the user an error message
                                                                       alertTitle = @"Something went wrong :S";
                                                                       alertText = [NSString stringWithFormat:@"Please retry. \n\n If the problem persists contact us and mention this error code: %@", [errorInformation objectForKey:@"message"]];
                                                                       [self showMessage:alertText withTitle:alertTitle];
                                                                     }
                                                                     
                                                                   }
                                                                 }
                                                               }];
                            } else {
                              // Permissions present, read the user's OG action history
                              [self readActions];
                            }
                            
                          }
                        }];
}

- (void)readActions
{
  // Retrieve all the OG actions ("add to wishlist" actions the user performed within this app)
  NSLog(@"making request #1");
  
  FBRequestConnection *connection = [[FBRequestConnection alloc] init];
  
  // First request gets the wishlist actions
  FBRequest *request1 =
  [FBRequest requestForGraphPath:@"me/fbswagshop:wishlist"];
  [connection addRequest:request1
       completionHandler:
   ^(FBRequestConnection *connection, id result, NSError *error) {
     if (error) {
       NSString *alertText;
       NSString *alertTitle;
       if (error.fberrorShouldNotifyUser == YES){
         // Error requires people using an app to make an out-of-band action to recover
         alertTitle = @"Something went wrong :S";
         alertText = [NSString stringWithString:error.fberrorUserMessage];
         [self showMessage:alertText withTitle:alertTitle];
       } else {
         NSDictionary *errorInformation = [[[error.userInfo objectForKey:@"com.facebook.sdk:ParsedJSONResponseKey"] objectForKey:@"body"] objectForKey:@"error"];
         
         // Show the user an error message
         alertTitle = @"Something went wrong #1";
         alertText = [NSString stringWithFormat:@"Please retry. \n\n If the problem persists contact us and mention this error code: %@", [errorInformation objectForKey:@"message"]];
         [self showMessage:alertText withTitle:alertTitle];
       }
     } else {
       NSMutableArray *pastOGActions = [[NSMutableArray alloc] initWithArray:@[]];
       for (id action in [result objectForKey:@"data"]){
         [pastOGActions addObject:[[[action objectForKey:@"data"] objectForKey:@"product"] objectForKey:@"id"]];
       }
       
       if ([pastOGActions count] > 0){
         // Second request gets the product details
         
         NSLog(@"making request #2");
         FBRequestConnection *connection = [[FBRequestConnection alloc] init];
         
         NSString *idString = [NSString stringWithFormat:@"?ids=%@", [pastOGActions componentsJoinedByString:@","]];
         FBRequest *request2 = [FBRequest requestForGraphPath:idString];
         [connection addRequest:request2
              completionHandler:
          ^(FBRequestConnection *connection, id result, NSError *error) {
            if (error){
              NSString *alertText;
              NSString *alertTitle;
              if (error.fberrorShouldNotifyUser == YES){
                // Error requires people using an app to make an out-of-band action to recover
                alertTitle = @"Something went wrong";
                alertText = [NSString stringWithString:error.fberrorUserMessage];
                [self showMessage:alertText withTitle:alertTitle];
              } else {
                NSDictionary *errorInformation = [[[error.userInfo objectForKey:@"com.facebook.sdk:ParsedJSONResponseKey"] objectForKey:@"body"] objectForKey:@"error"];
                
                // Show the user an error message
                alertTitle = @"Something went wrong";
                alertText = [NSString stringWithFormat:@"Please retry. \n\n If the problem persists contact us and mention this error code: %@", [errorInformation objectForKey:@"message"]];
                [self showMessage:alertText withTitle:alertTitle];;
              }
            } else {
              NSLog(@"it went ok");
              for (id key in result){
                id object = [result objectForKey:key];
                Item *item = [[Item alloc] initWithFBObject:object];
                [_wishlistItemsArray addObject:item];
              }
              NSLog([NSString stringWithFormat:@"wishlistItemArray when done with the call %@", _wishlistItemsArray]);
              _wishlistViewController = [[WishlistViewController alloc] initWithWishlistItemsArray:_wishlistItemsArray];
              [[self navigationController] pushViewController:_wishlistViewController animated:YES];
            }
          }
          ];
         [connection start];
       } else {
         _wishlistViewController = [[WishlistViewController alloc] initWithWishlistItemsArray:@[]];
         [[self navigationController] pushViewController:_wishlistViewController animated:YES];
       }
     }
   }
   ];
  
  [connection start];
  
}

- (void)showMessage:(NSString *)text withTitle:(NSString *)title
{
  [[[UIAlertView alloc] initWithTitle:title
                              message:text
                             delegate:self
                    cancelButtonTitle:@"OK!"
                    otherButtonTitles:nil] show];
}

// What's this code for???
- (void)request:(FBRequest *)request didLoad:(id)result {
  NSArray *allResponses = result;
  for ( int i=0; i < [allResponses count]; i++ ) {
    NSDictionary *response = [allResponses objectAtIndex:i];
    int httpCode = [[response objectForKey:@"code"] intValue];
    NSString *jsonResponse = [response objectForKey:@"body"];
    if ( httpCode != 200 ) {
      NSLog( @"Facebook request error: code: %d  message: %@", httpCode, jsonResponse );
    } else {
      NSLog( @"Facebook response: %@", jsonResponse );
    }
  }
}

@end
