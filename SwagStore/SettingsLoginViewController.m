//
//  SettingsLoginViewController.m
//  SwagStore
//
//  Created by Luz Caballero on 8/9/13.
//  Copyright (c) 2013 Facebook Inc. All rights reserved.
//

#import "SettingsLoginViewController.h"
#import "SettingsViewController.h"
#import "AppDelegate.h"

@interface SettingsLoginViewController ()
@property (weak, nonatomic) IBOutlet UIButton *buttonFacebookLogin;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (weak, nonatomic) IBOutlet UIButton *buttonCancelLogin;

@end

@implementation SettingsLoginViewController

@synthesize spinner;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self){
    [[self buttonFacebookLogin] addTarget:self
                                   action:@selector(loginWithFacebook:)
                         forControlEvents:UIControlEventTouchUpInside];
  }
  return self;
}

- (IBAction)loginWithFacebook:(id)sender {
  [self.spinner startAnimating];
  
  AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
  [appDelegate openFacebookSession];
}

- (IBAction)cancelLogin:(id)sender {
  [self.spinner startAnimating];
  
  // Dismiss the modal login dialog
  AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
  UIViewController *topViewController = [[appDelegate navigationController] topViewController];
  [topViewController dismissViewControllerAnimated:YES completion:nil];
  if ([topViewController isKindOfClass:[SettingsViewController class]]) {
    [[appDelegate navigationController] popViewControllerAnimated:NO];
  }
}

- (void)loginFailed
{
  // User switched back to the app without authorizing. Stay here, but
  // stop the spinner.
  [self.spinner stopAnimating];
}

@end

