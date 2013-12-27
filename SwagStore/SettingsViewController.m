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
@property NSMutableArray *pastOGActions;
@property NSMutableArray *pastOGObjects;

@end

/* If the user is logged out, this view displays a button to log in with Facebook. If the user is logged in, this view displays a button to log out and a button to "Go to wishlist" that takes the user to the `WishlistViewController`. To display the user's wishlist, a Graph API call is made to retrieve all the past actions made by the user on the Swag Shop app (the user's past additions of products to their wishlist). To do this, if the user hasn't granted permission to Swag Shop to read their past actions on the app, they will be prompted to do so. */

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
  if ([FBErrorUtility shouldNotifyUserForError:error]) {
    // If the SDK has a message for the user, surface it. This conveniently
    // handles cases like password change or iOS6 app slider state.
    alertTitle = @"Error";
    alertMessage = [FBErrorUtility userMessageForError:error];
  } else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryAuthenticationReopenSession) {
    // It is important to handle session closures since they can happen
    // outside of the app. You can inspect the error for more context
    // but this sample generically notifies the user.
    alertTitle = @"Session Error";
    alertMessage = @"Your current session is no longer valid. Please log in again.";
  } else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryUserCancelled) {
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
  _wishlistItemsArray = [[NSMutableArray alloc] initWithArray:@[]];
  if (FBSession.activeSession.isOpen) {
    // If there's a session open, check the permissions and then read the user's OG action history
    [self checkPermissionsAndReadActions];
  } else {
    // There's no open session, open one
    [FBSession openActiveSessionWithReadPermissions:@[@"basic_info", @"user_actions:fbswagshop"]
                                       allowLoginUI:YES
                                  completionHandler:
     ^(FBSession *session, FBSessionState state, NSError *error) {
       // If the session was opened successfully
       if (!error && (state == FBSessionStateOpen || state == FBSessionStateOpenTokenExtended)){
         // Go through the general session handling process
         AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
         [appDelegate userLoggedIn];
         
         // Now we can read the actions because we've just opened the session with the right permissions
         [self readActions];
       } else {
         // An error occurred, we don't handle the error here but you should
         // more info: http://developers.facebook.com/docs/ios/errors
         NSLog(@"Error requesting the fbswagshop:wishlist actions: %@", error);
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
                              NSLog([NSString stringWithFormat:@"permissions %@", permissions]);
                              [FBSession.activeSession requestNewReadPermissions:[NSArray arrayWithObject:@"user_actions:fbswagshop"]
                                                               completionHandler:^(FBSession *session, NSError *error) {
                                                                 if (!error) {
                                                                   // Permission granted, read the user's OG action history
                                                                   [self readActions];
                                                                 } else {
                                                                   // An error occurred, we don't handle the error here but you should
                                                                   // more info: http://developers.facebook.com/docs/ios/errors
                                                                   NSLog(@"Error requesting permissions: %@", error);
                                                                 }
                                                               }];
                            } else {
                              // Permissions present, read the user's OG action history
                              [self readActions];
                            }
                            
                          } else {
                            // An error occurred, we don't handle the error here but you should
                            // more info: http://developers.facebook.com/docs/ios/errors
                            NSLog(@"Error retrieving permissions: %@", error);
                          }
                        }];
}

- (void)readActions
{
  // Retrieve all the OG actions ("add to wishlist" actions the user performed within this app)
  FBRequestConnection *connection = [[FBRequestConnection alloc] init];
  
  // First request gets the wishlist actions
  FBRequest *request1 =
  [FBRequest requestForGraphPath:@"me/fbswagshop:wishlist"];
  [connection addRequest:request1
       completionHandler:
   ^(FBRequestConnection *connection, id result, NSError *error) {
     if (error) {
       // An error occurred, we don't handle the error here but you should
       // more info: http://developers.facebook.com/docs/ios/errors
       NSLog(@"Error requesting the fbswagshop:wishlist actions: %@", error);
     } else {
       // We retrieved the actions
       _pastOGActions = [[NSMutableArray alloc] initWithArray:@[]];
       _pastOGObjects = [[NSMutableArray alloc] initWithArray:@[]];
       // Add all the actions retrieved to the _pastOGActions array.
       // Each action will carry the object's id, add all these ids to the _pastOGObjects,
       // (we will later use these ids to retrieve the objects' properties and display these properties in the wishlist)
       for (id action in [result objectForKey:@"data"]){
         [_pastOGActions addObject:action];
         [_pastOGObjects addObject:[[[action objectForKey:@"data"] objectForKey:@"product"] objectForKey:@"id"]];
       }
       // If there were any actions:
       if ([_pastOGActions count] > 0){
         // A second request gets the product details
         FBRequestConnection *connection = [[FBRequestConnection alloc] init];
         NSString *idString = [NSString stringWithFormat:@"?ids=%@", [_pastOGObjects componentsJoinedByString:@","]];
         FBRequest *request2 = [FBRequest requestForGraphPath:idString];
         [connection addRequest:request2
              completionHandler:
          ^(FBRequestConnection *connection, id result, NSError *error) {
            if (error){
              // An error occurred, we don't handle the error here but you should
              // more info: http://developers.facebook.com/docs/ios/errors
              NSLog(@"Error requesting the products: %@", error);
            } else {
              // We retrieved the objects
              // For each object retrieved we reformat it by creating an "item" object, and put it in an array
              // (we need it in this "item" format to be able to display it later using our ItemCells)
              for (id key in result){
                id object = [result objectForKey:key];
                Item *item = [[Item alloc] initWithFBObject:object];
                [_wishlistItemsArray addObject:item];
              }
              NSLog(@"wishlistItemArray: %@", _wishlistItemsArray);
              // We create a WishlistViewController
              // and we pass it the past OG objects (_wishlistItemsArray) and actions (_pastOGActions)
              _wishlistViewController = [[WishlistViewController alloc] initWithWishlistItemsArray:_wishlistItemsArray WishlistActionsArray:_pastOGActions];
              [[self navigationController] pushViewController:_wishlistViewController animated:YES];
            }
          }
          ];
         // We start the connection for the products request
         [connection start];
       } else {
         // If there weren't any actions, we show an empty list
         // We create a WishlistViewController
         // and we pass it the past it two empty arrays for OG objects and actions
         _wishlistViewController = [[WishlistViewController alloc] initWithWishlistItemsArray:@[] WishlistActionsArray:@[]];
         [[self navigationController] pushViewController:_wishlistViewController animated:YES];
       }
     }
   }
   ];
  // We start the connection for the actions request
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

@end
