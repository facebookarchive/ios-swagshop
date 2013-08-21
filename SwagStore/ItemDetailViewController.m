//
//  ItemDetailViewController.m
//  SwagStore
//
//  Created by Luz Caballero on 8/5/13.
//  Copyright (c) 2013 Facebook Inc. All rights reserved.
//

#import <FacebookSDK/FacebookSDK.h>

#import "ItemDetailViewController.h"
#import "Item.h"
#import "OGProtocols.h"
#import "AppDelegate.h"

@interface ItemDetailViewController ()

@property (weak, nonatomic) IBOutlet UILabel *nameField;
@property (weak, nonatomic) IBOutlet UILabel *descriptionField;
@property (weak, nonatomic) IBOutlet UILabel *valueField;
@property (weak, nonatomic) IBOutlet UILabel *friendsField;
@property (weak, nonatomic) IBOutlet UIButton *addToWishlist;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation ItemDetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self){
    [[self addToWishlist] addTarget:self
                             action:@selector(addToWishlist:)
                   forControlEvents:UIControlEventTouchDown];
  }
  return self;
}

- (void) viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:(BOOL)animated];
  Item *item = [self item];
  [self descriptionField].numberOfLines = 0;
  [[self descriptionField] sizeToFit];
  [[self nameField] setText:[item itemName]];
  [[self descriptionField] setText:[item itemDescription]];
  [self valueField].textAlignment = NSTextAlignmentCenter;
  [[self valueField] setText:[NSString stringWithFormat:@"$%d", [item itemPrice]]];
  UIImage *image = [UIImage imageWithData:[item itemImage]];
  [[self imageView] setImage:image];
    
  _friendsAdded = 0;
    
  id<OGProductObject> productObject = [self productObjectForItem:[self item]];
    
  // Graph API request for friends' wishlist data
  [FBRequestConnection startWithGraphPath:@"/me/friends?fields=fbswagshop:wishlist"
                        completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
    NSArray* friends_wishlists = (NSArray*)[result data];
                            
    // Iterate over friends' wishlist and only add if has matching object.
    for (int i = 0; i < [friends_wishlists count]; i++) {
      NSArray* friend_wishlist_objects = [[[friends_wishlists objectAtIndex:i] objectForKey:@"fbswagshop:wishlist"] objectForKey:@"data"];
      for (int i  = 0; i < [friend_wishlist_objects count]; i++) {
        NSString* friend_wishlist_object_url =
          [[[[friend_wishlist_objects objectAtIndex:i] objectForKey:@"data"] objectForKey:@"product"] objectForKey:@"url"];
        if ([friend_wishlist_object_url isEqualToString:productObject.url]) {
          _friendsAdded++;
          continue;
        }
      }
    }
           
    [[self friendsField] setText:[NSString stringWithFormat:@"%d of your friends wishlisted this.", _friendsAdded]];
                            
  }];
  
}

- (void) setItem:(Item *)item
{
  _item = item;
  [[self navigationItem] setTitle:[[self item] itemName]];
}

- (IBAction)addToWishlist:(id)sender
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
}

- (void)publishStory
{
  // Create the OG product object for the item
  id<OGProductObject> productObject = [self productObjectForItem:[self item]];
  
  // Now create an OG wishlist action with the product object
  id<OGWishlistAction> action = (id<OGWishlistAction>)[FBGraphObject graphObject];
  action.product = productObject;
  
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

// Create a product UG object from an item
- (id<OGProductObject>)productObjectForItem:(Item*)item
{
  // We create an FBGraphObject object, but we can treat it as an OGProductObject with typed properties, etc.
  // See <FacebookSDK/FBGraphObject.h> for more details.
  id<OGProductObject> product = (id<OGProductObject>)[FBGraphObject graphObject];
  
  // Give it the URL where the object is hosted, which will echo back the name of the item as its title, description, and body.
  product.url = [[self item] itemURL];
  
  return product;
}

@end
