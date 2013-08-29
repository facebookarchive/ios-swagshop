//
//  AppDelegate.h
//  SwagStore
//
//  Created by Luz Caballero on 8/5/13.
//  Copyright (c) 2013 Facebook Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UINavigationController* navigationController;

- (void)openFacebookSession;
- (void)showFacebookLoginView;
- (void)facebookSessionStateChanged:(FBSession *)session
                              state:(FBSessionState) state
                              error:(NSError *)error;
- (void)userLoggedOut;
- (void)userLoggedIn;
@end
