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

@interface SettingsViewController ()
@property (strong, nonatomic) IBOutlet FBLoginView *loginView;
@property (strong, nonatomic) IBOutlet UILabel *loggedInMessage;
@property (weak, nonatomic) IBOutlet UILabel *labelUserName;
@property (strong, nonatomic) IBOutlet FBProfilePictureView *imageProfilePicture;
@property (strong, nonatomic) IBOutlet UIButton *buttonWishlist;

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
  WishlistViewController *wishlistViewController = [[WishlistViewController alloc] init];
  [[self navigationController] pushViewController:wishlistViewController animated:YES];
}

@end
