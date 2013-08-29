//
//  AppDelegate.m
//  SwagStore
//
//  Created by Luz Caballero on 8/5/13.
//  Copyright (c) 2013 Facebook Inc. All rights reserved.
//

#import "AppDelegate.h"
#import "ItemListViewController.h"

@interface AppDelegate ()

@property ItemListViewController *itemListViewController;

@end

@implementation AppDelegate

@synthesize navigationController = _navigationController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
  
    // Whenever a person opens the app, check for a cached session
    if (FBSession.activeSession.state == FBSessionStateCreatedTokenLoaded) {
      // If there's one, just open the session silently
      [self openFacebookSession];
    }
  
    // Create the ItemListViewController
    _itemListViewController = [[ItemListViewController alloc] init];
  
    // Create a UINavigationController
    _navigationController = [[UINavigationController alloc]
                                                    initWithRootViewController:_itemListViewController];
  
    // Add empty footer to prevent empty rows from showing
    UIView *tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    _itemListViewController.tableView.tableFooterView = tableFooterView;
  
    //Place ItemListViewController's table view in the window hierarchy
    [[self window] setRootViewController:_navigationController];
  
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];

    return YES;
}

- (void)userLoggedOut
{
  // If the user is logged in the right button in the nav controller should read "Log In"
  [_itemListViewController setAccountSettingsButtonWithTitle:@"Log in"];
}

- (void)userLoggedIn
{
  // If the user is logged in the right button in the nav controller should read "Account"
  [_itemListViewController setAccountSettingsButtonWithTitle:@"Account"];
}

// Open a session only if it can be done without the loginUI (if there's an active token)
- (void)openFacebookSession
{
  NSLog(@"opening session");
  
  [FBSession openActiveSessionWithReadPermissions:@[]
                                     allowLoginUI:NO
                                completionHandler:^(FBSession *session, FBSessionState state, NSError *error) {
                                  if (!error && state == FBSessionStateOpen){
                                      NSLog(@"session opened");
                                      [self userLoggedIn];
                                  } else {
                                    // If failed, clear this token
                                    NSLog(@"opening session failed");
                                    [FBSession.activeSession closeAndClearTokenInformation];
                                    [self userLoggedOut];
                                  }
                                }];
  //NSLog([NSString stringWithFormat:@"session opened? %@", fbsession]);
}

// Call the Facebook session object that handles the incoming URL, after control is returned to Swag Shop by the Facebook app
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
  BOOL wasHandled = [FBAppCall handleOpenURL:url sourceApplication:sourceApplication];
  
  return wasHandled;
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
  // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
  
  // We need to properly handle activation of the application with regards to Facebook Login
  // (e.g., returning from iOS 6.0 Login Dialog or from fast app switching).
  [FBAppCall handleDidBecomeActive];
}

@end
