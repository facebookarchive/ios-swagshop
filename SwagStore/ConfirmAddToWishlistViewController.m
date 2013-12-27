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
@property (strong, nonatomic) IBOutlet UITextView *userCustomMessageTextView;
@property (strong, nonatomic) NSString *placeholderMessage;
@property (strong, nonatomic) IBOutlet UIButton *cancelButton;
@property (strong, nonatomic) IBOutlet UIButton *acceptButton;
@property (strong, nonatomic) id<OGProductObject> productObject;
@property (strong, nonatomic) Item *item;

@end

/* In this view, the user can write a message that will be posted alongside the Open Graph story on Facebook. When the user taps an "accept" button confirming they want to share to Facebook, a Graph API call is made to post the Open Graph story to Facebook. To do so, if the user is not logged in, they are taken to the login dialog to log in. Similarly, if the user hasn't granted publish permissions to Swag Shop, they are asked to do so. When an item is added to the wishlist, an App Event is used to log this user action. */

@implementation ConfirmAddToWishlistViewController

- (instancetype)initWithObject:(id<OGProductObject>)object item:(Item *)item
{
  self = [self initWithNibName:@"ConfirmAddToWishlistViewController" bundle:nil];
  if (self){
    // The object on which the action is performed, in its OG object and Item form
    _productObject = object;
    _item = item;
  }
  return self;
}

- (void)viewWillAppear:(BOOL)animated
{
  // Tell the user we will post his action to Facebook
  [[self confirmMessageLabel]
   setText:[NSString stringWithFormat:@"%@ will be added to your wishlist and posted to Facebook", [_item itemName]]];
  
  // Prompt them to add a message
  _placeholderMessage = @"Add a message to your Facebook post";
  [_userCustomMessageTextView setText:_placeholderMessage];
  _userCustomMessageTextView.delegate = self;
}

// When the user beings editing the custom message, make the placeholder text disappear
- (void)textViewDidBeginEditing:(UITextView *)textView
{
  if ([[textView text] isEqual:_placeholderMessage]){
    [textView setText:@""];
  }
}

// Hide the keyboard when the user touches outside the UITextView
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  
  UITouch *touch = [[event allTouches] anyObject];
  if ([_userCustomMessageTextView isFirstResponder] && [touch view] != _userCustomMessageTextView) {
    [_userCustomMessageTextView resignFirstResponder];
  }
  [super touchesBegan:touches withEvent:event];
}

- (IBAction)userCanceled:(id)sender
{
  [self goBackToItemDetail];
}

- (IBAction)userAccepted:(id)sender
{
  // Check if the user is logged in with Facebook
  if (FBSession.activeSession.isOpen) {
    [self checkPublishPermissionsAndPublish];
  } else {
    // There's no open session, open one
    [FBSession openActiveSessionWithReadPermissions:@[@"basic_info"]
                                       allowLoginUI:YES
                                  completionHandler:
     ^(FBSession *session, FBSessionState state, NSError *error) {
       if (!error){
         // If the session was opened successfully
         if (state == FBSessionStateOpen){
         // Go through the general session handling process
         AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
         [appDelegate userLoggedIn];
         }
         // Then, check for permissions to publish the action
         [self checkPublishPermissionsAndPublish];
       } else {
         // Handle errors: https://developers.facebook.com/docs/ios/errors
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
                                                                      // Handle errors: https://developers.facebook.com/docs/ios/errors
                                                                    }
                                                                  }];
                            } else {
                              // Permissions present, publish the OG story
                              [self publishStory];
                            }
                          } else {
                            // Handle errors: https://developers.facebook.com/docs/ios/errors
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
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
  if(buttonIndex==0)
  {
    [self goBackToItemDetail];
  }
}

- (void)publishStory
{
  // Create an OG wishlist action with the product object
  id<OGWishlistAction> action = (id<OGWishlistAction>)[FBGraphObject graphObject];
  action.product = _productObject;
  // If the user added a custom message using the textview, we add that message to the action
  if (![[_userCustomMessageTextView text] isEqual:_placeholderMessage]){
    action.message = [_userCustomMessageTextView text];
  }
  
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
                                   // This line logs an App Event when the user has added a product to their wishlist
                                   // more info: http://developers.facebook.com/docs/ios/app-events
                                   [FBAppEvents logEvent:FBAppEventNameAddedToWishlist
                                              parameters:@{FBAppEventParameterNameContentID:[_item itemSKU]}];
                                 } else {
                                   // Handle errors: https://developers.facebook.com/docs/ios/errors
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
