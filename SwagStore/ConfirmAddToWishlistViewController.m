//
//  ConfirmAddToWishlistViewController.m
//  SwagStore
//
//  Created by Luz Caballero on 8/21/13.
//  Copyright (c) 2013 Facebook Inc. All rights reserved.
//

#import <FacebookSDK/FacebookSDK.h>

#import "ConfirmAddToWishlistViewController.h"
#import "AppDelegate.h"

@interface ConfirmAddToWishlistViewController ()
@property (strong, nonatomic) IBOutlet UILabel *confirmMessageLabel;
@property (strong, nonatomic) IBOutlet UITextField *userCustomMessageTextField;
@property (strong, nonatomic) IBOutlet UIButton *cancelButton;
@property (strong, nonatomic) IBOutlet UIButton *acceptButton;
@property (strong, nonatomic) id<OGProductObject> productObject;

@end

@implementation ConfirmAddToWishlistViewController

- (instancetype)initWithObject:(id<OGProductObject>)object
{
  self = [self initWithNibName:@"ConfirmAddToWishlistViewController" bundle:nil];
  if (self){
    // The object on which the action is performed
    _productObject = object;
  }
  return self;
}

- (IBAction)userAccepted:(id)sender
{
  if (FBSession.activeSession.isOpen) {
    [self checkPublishPermissionsAndPublish];
  } else {
    // There's no open session, open one
    [FBSession openActiveSessionWithReadPermissions:@[@"user_actions:fbswagshop",@"friends_actions:fbswagshop"]
                                       allowLoginUI:YES
                                  completionHandler:
     ^(FBSession *session, FBSessionState state, NSError *error) {
       __block NSString *alertText;
       __block NSString *alertTitle;
       if (!error){
         // If the session was opened successfully...
         
         // Go through the general session handling process
         AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
         [appDelegate facebookSessionStateChanged:session state:state error:error];
         
         // Then, check for permissions to publish the action
         [self checkPublishPermissionsAndPublish];
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

- (void)checkPublishPermissionsAndPublish
{
  // Check for publish permissions
  [FBRequestConnection startWithGraphPath:@"/me/permissions"
                        completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                          __block NSString *alertText;
                          __block NSString *alertTitle;
                          if (!error){
                            NSDictionary *permissions= [(NSArray *)[result data] objectAtIndex:0];
                            if (![permissions objectForKey:@"publish_actions"]){
                              // Permission hasn't been granted, so ask for publish_actions
                              [FBSession.activeSession requestNewPublishPermissions:[NSArray arrayWithObject:@"publish_actions"]
                                                                    defaultAudience:FBSessionDefaultAudienceFriends
                                                                  completionHandler:^(FBSession *session, NSError *error) {
                                                                    if (!error) {
                                                                      if ([FBSession.activeSession.permissions indexOfObject:@"publish_actions"] == NSNotFound){
                                                                        // Permission not granted, tell the user we will not add the item to their wishlist
                                                                        alertTitle = @"Permission not granted";
                                                                        alertText = @"The item will not be saved to your wishlist.";
                                                                        [self showMessage:alertText withTitle:alertTitle];
                                                                      } else {
                                                                        // Permission granted, publish the OG story
                                                                        [self publishStory];
                                                                      }
                                                                      
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
                                                                          alertText = @"The item will not be saved to your wishlist.";
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
                              // Permissions present, publish the OG story
                              [self publishStory];
                            }
                            
                          }
                        }];
  
}

- (void)showMessage:(NSString *)text withTitle:(NSString *)title
{
  [[[UIAlertView alloc] initWithTitle:title
                              message:text
                             delegate:self
                    cancelButtonTitle:@"OK!"
                    otherButtonTitles:nil] show];
  [self goBackToItemDetail];
}

- (void)publishStory
{
  // Create an OG wishlist action with the product object
  id<OGWishlistAction> action = (id<OGWishlistAction>)[FBGraphObject graphObject];
  action.product = _productObject;
  
  // Post the action to Facebook
  [FBRequestConnection startForPostWithGraphPath:@"me/fbswagshop:wishlist"
                                     graphObject:action
                               completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                                 __block NSString *alertText;
                                 __block NSString *alertTitle;
                                 if (!error) {
                                   // Item added to wishlist and OG action posted to Facebook
                                   //alertText = [NSString stringWithFormat:@"Posted OG action, id: %@", [result objectForKey:@"id"]];
                                   alertText = @"The item has been successfully added to your wishlist!";
                                   alertTitle = @"";
                                   [self showMessage:alertText withTitle:alertTitle];
                                 } else {
                                   // An error occurred
                                   if (error.fberrorShouldNotifyUser == YES){
                                     // Error requires people using an app to make an out-of-band action to recover
                                     alertTitle = @"Something went wrong :S";
                                     alertText = [NSString stringWithString:error.fberrorUserMessage];
                                     [self showMessage:alertText withTitle:alertTitle];
                                   } else {
                                     // We need to handle the error
                                     //Get more error information from the error
                                     int errorCode = error.code;
                                     NSDictionary *errorInformation = [[[error.userInfo objectForKey:@"com.facebook.sdk:ParsedJSONResponseKey"] objectForKey:@"body"] objectForKey:@"error"];
                                     int errorSubcode = 0;
                                     if ([errorInformation objectForKey:@"code"]){
                                       errorSubcode = [[errorInformation objectForKey:@"code"] integerValue];
                                     }
                                     /* We allow the user to add a particular item to their wishlist only once,
                                      trying to add an item twice will throw an error */
                                     if (errorCode == 5 && errorSubcode == 3501) {
                                       // Show the user an error message
                                       alertTitle = @"";
                                       alertText = @"This item is already in your wishlist. You cannot add an item more than once.";
                                       [self showMessage:alertText withTitle:alertTitle];
                                     } else {
                                       // Diplay message for generic error
                                       alertTitle = @"Something went wrong :S";
                                       alertText = [NSString stringWithFormat:@"Please retry. \n\n If the problem persists contact us and mention this error code: %@", [errorInformation objectForKey:@"message"]];
                                       [self showMessage:alertText withTitle:alertTitle];
                                     }
                                     
                                     // IMPORTANT:
                                     /* We don't need to handle session closures that happen outside the app because
                                      we're only calling publishStory immediately after checking the session is open, if you're
                                      not doing this, you'll need to handle FBErrorCategoryAuthenticationReopenSession */
                                     
                                     /* Similarly, we don't need to handle permissions revoked outside the app because
                                      we're only calling publishStory after checking that we have the publish_actions permission
                                      if not, we'd need to handle FBErrorCategoryPermissions */
                                     
                                     /* Depending on your app, you may need to do some extra error handling */
                                     
                                   }
                                 }
                               }];
}

- (void)goBackToItemDetail
{
  AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
  UIViewController *topViewController = [[appDelegate navigationController] topViewController];
  [topViewController dismissViewControllerAnimated:NO completion:nil];
}

@end
