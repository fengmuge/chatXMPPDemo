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
    
    [self configureSJNetwork];
    
    return YES;
}

- (void)configureSJNetwork {
//    [SJNetworkConfig sharedConfig].baseUrl = @"";
    [SJNetworkConfig sharedConfig].defailtParameters = @{@"app_version": [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"], @"platform": @"iOS"};
    [SJNetworkConfig sharedConfig].timeoutSeconds = 30;
    [SJNetworkConfig sharedConfig].debugMode = YES;
    
    [[SJNetworkConfig sharedConfig] addCustomHeader:@{@"token": @""}];
}

@end
