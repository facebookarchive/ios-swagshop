//
//  AppDelegate.m
//  SwagStore
//
//  Created by Luz Caballero on 8/5/13.
//  Copyright (c) 2013 Facebook Inc. All rights reserved.
//

#import <Parse/Parse.h>
#import <FacebookSDK/FacebookSDK.h>

#import "AppDelegate.h"
#import "ItemListViewController.h"
#import "SettingsLoginViewController.h"

@interface AppDelegate ()

@property ItemListViewController *itemListViewController;

@end

@implementation AppDelegate

@synthesize navigationController = _navigationController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
  
    // Horrible hack to solve a cocoa bug
    [FBProfilePictureView class];
  
    // Parse app id and client key
    [Parse setApplicationId:@"8pkaJk7q67ZcOFzQR0RUlmSBIgUKgu2K1nDpNul5"
                  clientKey:@"lMBgSO5KUqvSlWB6EdeveDkuCXTaAW0oKTqxWqy7"];
  
    // Whenever a person opens the app, check for a cached session
    if (FBSession.activeSession.state == FBSessionStateCreatedTokenLoaded) {
      // If there's one, just open the session
      [self openFacebookSession];
    }
  
    // Create the ItemListViewController
    _itemListViewController = [[ItemListViewController alloc] init];
  
    // Create a UINavigationController
    _navigationController = [[UINavigationController alloc]
                                                    initWithRootViewController:_itemListViewController];
  
    //Place ItemListViewController's table view in the window hierarchy
    [[self window] setRootViewController:_navigationController];
  
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)facebookSessionStateChanged:(FBSession *)session
                      state:(FBSessionState) state
                      error:(NSError *)error
{
  switch (state) {
    case FBSessionStateOpen:
    {
      NSLog(@"session opened");
      
      // Dismiss the modal login dialog
      UIViewController *topViewController = [_navigationController topViewController];
      if ([[topViewController presentedViewController] isKindOfClass:[SettingsLoginViewController class]]) {
        [topViewController dismissViewControllerAnimated:YES completion:nil];
      }
    
      // If the user is logged in the right button in the nav controller should read "Account"
      [_itemListViewController setAccountSettingsButtonWithTitle:@"Account"];
    }
      break;
    case FBSessionStateClosed:
      NSLog(@"logged out");
      [FBSession.activeSession closeAndClearTokenInformation];
      // If the user is logged in the right button in the nav controller should read "Log In"
      [_itemListViewController setAccountSettingsButtonWithTitle:@"Log in"];
      break;
    case FBSessionStateClosedLoginFailed:
      {
        NSLog(@"login failed");
        [FBSession.activeSession closeAndClearTokenInformation];
        //stop the settings login view controller's spinner
        UIViewController *topViewController = [_navigationController topViewController];
        if ([[topViewController presentedViewController] isKindOfClass:[SettingsLoginViewController class]]) {
          SettingsLoginViewController *settingsLoginViewController = (SettingsLoginViewController *)[topViewController presentedViewController];
          [settingsLoginViewController loginFailed];
        }
      }
      break;
    default:
      NSLog(@"default");
      break;
  }
  
  if (error) {
    UIAlertView *alertView = [[UIAlertView alloc]
                              initWithTitle:@"Error"
                              message:error.localizedDescription
                              delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
    [alertView show];
  }
}

- (void)openFacebookSession
{
  NSLog(@"opening session");
  [FBSession openActiveSessionWithReadPermissions:nil
                                     allowLoginUI:YES
                                completionHandler:
   ^(FBSession *session, FBSessionState state, NSError *error) {
     [self facebookSessionStateChanged:session state:state error:error];
   }];
}

/*During the Facebook login flow, your app passes control to the Facebook iOS app or Facebook in a mobile browser. After authentication, your app will be called back with the session information. In the app delegate, implement the application:openURL:sourceApplication:annotation: delegate method to call the Facebook session object that handles the incoming URL */
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
  return [FBSession.activeSession handleOpenURL:url];
}

- (void)showFacebookLoginView
{
  NSLog(@"show facebook login view");
  UIViewController *topViewController = [_navigationController topViewController];
  
  SettingsLoginViewController* loginViewController =
  [[SettingsLoginViewController alloc] initWithNibName:@"SettingsLoginViewController" bundle:nil];
  [topViewController presentViewController:loginViewController animated:NO completion:nil];
}

//- (void)applicationWillResignActive:(UIApplication *)application
//{
//  // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
//  // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
//}
//
//- (void)applicationDidEnterBackground:(UIApplication *)application
//{
//  // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
//  // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
//}
//
//- (void)applicationWillEnterForeground:(UIApplication *)application
//{
//  // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
//}
//
- (void)applicationDidBecomeActive:(UIApplication *)application
{
  // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
  
  // We need to properly handle activation of the application with regards to Facebook Login
  // (e.g., returning from iOS 6.0 Login Dialog or from fast app switching).
  [FBSession.activeSession handleDidBecomeActive];
}

//- (void)applicationWillTerminate:(UIApplication *)application
//{
//  // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
//}

@end
