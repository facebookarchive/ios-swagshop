//
//  SettingsViewController.m
//  SwagStore
//
//  Created by Luz Caballero on 8/6/13.
//  Copyright (c) 2013 Facebook Inc. All rights reserved.
//

#import "SettingsViewController.h"
#import "SettingsLoginViewController.h"
#import "AppDelegate.h"
#import "WishlistViewController.h"

@interface SettingsViewController ()
@property (weak, nonatomic) IBOutlet UIButton *buttonFacebookLogout;
@property (weak, nonatomic) IBOutlet UILabel *labelUserName;
@property (strong, nonatomic) IBOutlet FBProfilePictureView *imageProfilePicture;
@property (strong, nonatomic) IBOutlet UIButton *buttonWishlist;

@end

@implementation SettingsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self){
    if (FBSession.activeSession.isOpen) {
      [[self buttonFacebookLogout] addTarget:self
                                      action:@selector(logoutFromFacebook:)
                            forControlEvents:UIControlEventTouchUpInside];
      [[self buttonWishlist] addTarget:self
                                      action:@selector(goToWishlist:)
                            forControlEvents:UIControlEventTouchUpInside];
    } else {
      AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
      [appDelegate showFacebookLoginView];
    }
    
  }
  return self;
}

-(void)viewWillAppear:(BOOL)animated{
  [super viewWillAppear:animated];
  
  if (FBSession.activeSession.isOpen) {
    [self populateUserDetails];
  }
}

// Make Graph API call to populate user details
- (void)populateUserDetails
{
  if (FBSession.activeSession.isOpen) {
    [[FBRequest requestForMe] startWithCompletionHandler:
     ^(FBRequestConnection *connection,
       NSDictionary<FBGraphUser> *user,
       NSError *error) {
       if (!error) {
         self.labelUserName.text = user.name;
         self.imageProfilePicture.profileID = user.id;
       }
     }];
  }
}

- (IBAction)logoutFromFacebook:(id)sender
{
  [FBSession.activeSession closeAndClearTokenInformation];
  [[self navigationController] popToRootViewControllerAnimated:NO];
}

- (IBAction)goToWishlist:(id)sender
{
  WishlistViewController *wishlistViewController = [[WishlistViewController alloc] init];
  [[self navigationController] pushViewController:wishlistViewController animated:YES];
}

@end
