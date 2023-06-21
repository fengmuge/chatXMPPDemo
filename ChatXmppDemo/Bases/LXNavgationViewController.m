//
//  LXNavgationViewController.m
//  ChatXmppDemo
//
//  Created by 苗培根 on 2023/6/6.
//

#import "LXNavgationViewController.h"
#import "UITabBarItem+custom.h"
#import "UIImage+windowImage.h"

@interface LXNavgationViewController () <UIGestureRecognizerDelegate, UINavigationControllerDelegate> {
}

@end

@implementation LXNavgationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    // 导航栏不透明
    [self.navigationBar setTranslucent:NO];
    // 设置导航栏颜色
    [self.navigationBar setBarTintColor:[UIColor whiteColor]];
    [self.navigationBar setBackgroundColor:[UIColor whiteColor]];
    
    self.interactivePopGestureRecognizer.delegate = self;
    
    NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
    attributes[NSForegroundColorAttributeName] = [UIColor blackColor];
    attributes[NSFontAttributeName] = [UIFont systemFontOfSize:17];
    if (@available(iOS 13.0, *)) {
        UINavigationBarAppearance *appearance = [[UINavigationBarAppearance alloc] init];
        [appearance configureWithOpaqueBackground];
        [appearance setTitleTextAttributes:attributes];
        appearance.backgroundColor = [UIColor whiteColor];
        self.navigationBar.standardAppearance = appearance;
        self.navigationBar.scrollEdgeAppearance = appearance;
    } else {
        UIImage *shadowImage = [UIImage imageWithColor:[UIColor whiteColor]];
        self.navigationBar.shadowImage = shadowImage;
        [self.navigationBar setTitleTextAttributes:attributes];
    }
}

+ (void)initialize {
    // 设置背景图片可以避免专场时顶部的黑色阴影
    UINavigationBar *navgationBar = [UINavigationBar appearanceWhenContainedInInstancesOfClasses:@[[self class]]];
//    [navgationBar setBackgroundImage:[UIImage imageWithCGImage:[UIColor whiteColor].c] forBarMetrics:UIBarMetricsDefault];
    
    // 设置项目中item主题样式
    UIBarButtonItem *item = [UIBarButtonItem appearance];
    // normal
    NSMutableDictionary *textAttributes = [NSMutableDictionary dictionary];
    textAttributes[NSForegroundColorAttributeName] = [UIColor blackColor];
    textAttributes[NSFontAttributeName] = [UIFont systemFontOfSize:16];
    [item setTitleTextAttributes:textAttributes forState:UIControlStateNormal];
    // disable
    NSMutableDictionary *disableAttributes = [NSMutableDictionary dictionary];
    disableAttributes[NSForegroundColorAttributeName] = [UIColor grayColor];
    disableAttributes[NSFontAttributeName] = [UIFont systemFontOfSize:14];
    [item setTitleTextAttributes:disableAttributes forState:UIControlStateDisabled];
}

- (void)setBackgroundImage:(UIImage *)backgroundImage {
    
}

+ (LXNavgationViewController *)initWithRootViewController:(UIViewController *)viewController {
    return  [LXNavgationViewController initWithRootViewController:viewController
                                                        itemTitle:nil
                                                    itemImageName:nil];
}

+ (LXNavgationViewController *)initWithRootViewController:(UIViewController *)viewController
                                                itemTitle:(NSString *)itemTitle {
    return  [LXNavgationViewController initWithRootViewController:viewController
                                                        itemTitle:itemTitle
                                                    itemImageName:nil];
}

+ (LXNavgationViewController *)initWithRootViewController:(UIViewController *)viewController
                                                itemTitle:(NSString *)title
                                            itemImageName:(NSString *)imageName {
    LXNavgationViewController *nav = [[LXNavgationViewController alloc] initWithRootViewController:viewController];
//    nav.tabBarItem = [UITabBarItem makeItemWithTitle:title
//                                                        imageName:imageName];
    nav.tabBarItem = [UITabBarItem makeItemWithTitle:title
                                           imageName:imageName
                                         normalColor:[UIColor grayColor]
                                       selectedColor:[UIColor blueColor]
                                          normalFont:14.0f
                                        selectedFont:16.0f];
    return nav;
}

- (void)setTitleTextAttributesWith:(UIColor *)color font:(CGFloat)font {
    self.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: color, NSFontAttributeName: [UIFont systemFontOfSize:font]};
}

//- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
//    if (self.viewControllers.count > 0) {
//        viewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:<#(nonnull UIView *)#>];
//    }
//}
//
//
//- (void)backButtonPop {
//    [self popViewControllerAnimated:YES];
//}

- (BOOL)shouldAutorotate {
    return [self.visibleViewController shouldAutorotate];
}

- (BOOL)prefersStatusBarHidden {
    return [self.visibleViewController prefersStatusBarHidden];
}

- (UIViewController *)childViewControllerForStatusBarStyle {
    return self.topViewController;
}

- (UIViewController *)childViewControllerForStatusBarHidden {
    return self.topViewController;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return [self.visibleViewController preferredStatusBarStyle];
}
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return [self.visibleViewController supportedInterfaceOrientations];
}
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return [self.visibleViewController preferredInterfaceOrientationForPresentation];
}

@end
