//
//  LXTabbarViewController.m
//  ChatXmppDemo
//
//  Created by 苗培根 on 2023/6/6.
//

#import "LXTabbarViewController.h"
#import "RoomViewController.h"
#import "SettingViewController.h"
#import "ConversationViewController.h"
#import "FriendsViewController.h"
#import "LoginViewController.h"
#import "LXNavgationViewController.h"

#import "UIImage+windowImage.h"

@interface LXTabbarViewController () <UITabBarControllerDelegate>
{
    
}
@end

@implementation LXTabbarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.tabBar.backgroundColor = [UIColor whiteColor];
    // 系统默认tabbarItem颜色修改
    [[UITabBar appearance] setTintColor:[UIColor blueColor]];
    [[UITabBar appearance] setUnselectedItemTintColor:[UIColor grayColor]];
    if (@available(iOS 13.0, *)) {
        UITabBarAppearance *apperaance = [self.tabBar.standardAppearance copy];
        apperaance.backgroundImage = [UIImage createImageWithColor:[UIColor whiteColor]];
        apperaance.shadowImage = [UIImage createImageWithColor:[UIColor whiteColor]];
        [apperaance configureWithTransparentBackground];
        self.tabBar.standardAppearance = apperaance;
    } else {
        [self.tabBar setBackgroundImage:[UIImage createImageWithColor:[UIColor whiteColor]]];
        self.tabBar.translucent = YES;
    }
    
    [self setViewControllers:[self makeViewControllers]];
    self.tabBarController.delegate = self;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self presentLoginViewController];
}

- (NSArray<UIViewController *> *)makeViewControllers {
    LXNavgationViewController *conversationNav = [LXNavgationViewController initWithRootViewController:[[ConversationViewController alloc] init] itemTitle:@"会话"];
    LXNavgationViewController *roomsNav = [LXNavgationViewController initWithRootViewController:[[RoomViewController alloc] init] itemTitle:@"群聊"];
    LXNavgationViewController *friendsNav = [LXNavgationViewController initWithRootViewController:[[FriendsViewController alloc] init] itemTitle:@"好友"];
    LXNavgationViewController *settingNav = [LXNavgationViewController initWithRootViewController:[[SettingViewController alloc] init] itemTitle:@"设置"];
    
    return @[conversationNav, roomsNav, friendsNav, settingNav];
}

- (void)presentLoginViewController {
    if ([UserManager sharedInstance].isLogin) {
        return;
    }
    LoginViewController *loginVC = [[LoginViewController alloc] init];
    LXNavgationViewController *loginNav = [[LXNavgationViewController alloc] initWithRootViewController:loginVC];
    [self presentViewController:loginNav animated:NO completion:nil];
}

- (BOOL)shouldAutorotate {
    return [self.selectedViewController shouldAutorotate];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return [self.selectedViewController preferredStatusBarStyle];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return [self.selectedViewController supportedInterfaceOrientations];
}

#pragma mark -- UITabBarControllerDelegate
- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {
    return YES;
}
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
    NSLog(@"tabbar didSelectViewController %@", [viewController description]);
}

- (void)tabBarController:(UITabBarController *)tabBarController willBeginCustomizingViewControllers:(NSArray<__kindof UIViewController *> *)viewControllers {
    
}

- (void)tabBarController:(UITabBarController *)tabBarController willEndCustomizingViewControllers:(NSArray<__kindof UIViewController *> *)viewControllers changed:(BOOL)changed {
    
}

//- (UIInterfaceOrientationMask)tabBarControllerSupportedInterfaceOrientations:(UITabBarController *)tabBarController {
//
//}
//
//- (UIInterfaceOrientation)tabBarControllerPreferredInterfaceOrientationForPresentation:(UITabBarController *)tabBarController {
//
//}

//- (nullable id <UIViewControllerInteractiveTransitioning>)tabBarController:(UITabBarController *)tabBarController
//                               interactionControllerForAnimationController: (id <UIViewControllerAnimatedTransitioning>)animationController {
//
//}
//
//- (nullable id <UIViewControllerAnimatedTransitioning>)tabBarController:(UITabBarController *)tabBarController
//            animationControllerForTransitionFromViewController:(UIViewController *)fromVC
//                                                       toViewController:(UIViewController *)toVC  {
//
//}

@end
