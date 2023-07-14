//
//  AppDelegate.m
//  ChatXmppDemo
//
//  Created by 苗培根 on 2023/6/5.
//

#import "AppDelegate.h"
#import "LXNavgationViewController.h"
#import "LXTabbarViewController.h"
@interface AppDelegate ()


@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    self.window.rootViewController = [[LXTabbarViewController alloc] init];
    [self.window makeKeyAndVisible];
    
    return YES;
}

@end
