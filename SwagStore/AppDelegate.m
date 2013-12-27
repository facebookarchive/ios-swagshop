//
//  AppDelegate.m
//  SwagStore
//
//  Created by Luz Caballero on 8/5/13.
//  Copyright (c) 2013 Facebook Inc. All rights reserved.
//

#import "AppDelegate.h"
#import "ItemListViewController.h"
#import "DetailPageViewController.h"
#import "DataStore.h"
#import "Item.h"

@interface AppDelegate ()

@property ItemListViewController *itemListViewController;

@end

/* If there is a valid session token when the app is launched, the app delegate logs the user in with Facebook using that token. Also, the app delegate handles incoming links passed when the Facebook for iOS app makes a cross app call to Swag Shop. */

@implementation AppDelegate

@synthesize navigationController = _navigationController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
  
    //Load the SDK classes so we can use it later
    [FBLoginView class];
    [FBProfilePictureView class];
  
    // Whenever a person opens the app, check for a cached session
    if (FBSession.activeSession.state == FBSessionStateCreatedTokenLoaded) {
      // If there's one, just open the session silently
      [FBSession openActiveSessionWithReadPermissions:@[@"basic_info"]
                                         allowLoginUI:NO
                                    completionHandler:^(FBSession *session, FBSessionState state, NSError *error) {
                                      if (!error && state == FBSessionStateOpen){
                                        NSLog(@"session opened");
                                        //Call a function that makes changes depending on session state
                                        [self userLoggedIn];
                                      } else if (error){
                                        NSLog(@"session opening error");
                                        // If failed, clear this token
                                        [FBSession.activeSession closeAndClearTokenInformation];
                                        //Call a function that makes changes depending on session state
                                        [self userLoggedOut];
                                      }
                                    }];
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

// Add deep linking handling here
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
  // Call the FBAppCall method that handles the incoming URL
  BOOL wasHandled = [FBAppCall handleOpenURL:url
                           sourceApplication:sourceApplication
                             fallbackHandler:^(FBAppCall *call) {
                               // Handle deep links to direct user who click on posts about a product on Facebook to that product's page on the app
                               
                               // We first retrieve the link associated with the post
                               // The link will be in the target_url parameter
                               NSString *targetURL = [[[call appLinkData] targetURL] absoluteString];
                               
                               // Get an array with all the products
                               NSArray *items = [[ItemStore sharedStore] allItems];
                               
                               //Check in which position in the array there's a product whose url is the targetURL we received
                               for (int i = 0; i < [items count]; i++) {
                                 if ([[items objectAtIndex:i] itemURL] == targetURL){
                                   // Create a detailPageViewController and point it to the page containing the item
                                   DetailPageViewController *detailPageViewController = [[DetailPageViewController alloc]
                                                                                         initWithPage:i];
                                   
                                   // Push the detailPageViewController to the navigationController
                                   [[self navigationController] pushViewController:detailPageViewController animated:YES];
                                   break;
                                 }
                               }
                               
                               
                             }];
  
  return wasHandled;
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
  // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
  
  /* Handle re-activation of the application if the user left the application while the Login Dialog was being shown
     For example, the user tapped the Login button, but then pressed the iOS "home" button while the Facebook for iOS app
     was in the foreground showing the login dialog (during the fast-app switch) */
  [FBAppCall handleDidBecomeActive];
}

@end
