//
//  LXViewController.m
//  ChatXmppDemo
//
//  Created by 苗培根 on 2023/6/6.
//

#import "LXViewController.h"
#import <FDFullscreenPopGesture/UINavigationController+FDFullscreenPopGesture.h>
#import <MBProgressHUD/MBProgressHUD.h>

typedef enum : NSUInteger {
    LXNavgationBarItemLeft,
    LXNavgationBarItemRight,
} LXNavgationBarItemPoistion;

@interface LXViewController () {
    bool _isHubDisplaying;
}

@end

@implementation LXViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)backBtnClicked {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -- setter/getter
- (BOOL)prefersNavgationBarHidden {
    return self.fd_prefersNavigationBarHidden;
}

#pragma mark -- Alert
- (void)alertAutoDisappearWithTitle:(NSString *)title message:(NSString *)message {
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:title
                                                                     message:message
                                                              preferredStyle:UIAlertControllerStyleAlert];
    [self presentViewController:alertVC
                       animated:YES
                     completion:nil];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW,
                                 (int64_t)(1.5 * NSEC_PER_SEC)),
                   dispatch_get_main_queue(), ^{
        [alertVC dismissViewControllerAnimated:NO
                                    completion:nil];
    });
}

- (void)alertWithTitle:(NSString *)title message:(NSString *)message actionHandler:(void(^)(bool))handler {
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:title
                                                                     message:message
                                                              preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (handler) {
            handler(YES);
        }
    }];
    [action setValue:[UIColor blueColor] forKey:@"titleTextColor"];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        if (handler) {
            handler(NO);
        }
    }];
    [cancelAction setValue:[UIColor grayColor] forKey:@"titleTextColor"];
    
    [alertVC addAction:action];
    [alertVC addAction:cancelAction];
    
    [self presentViewController:alertVC animated:YES completion:nil];
}

#pragma mark -- toast

- (void)showHud:(NSTimeInterval)afterDelay {
    if (afterDelay == 0.0f) {
        [self showHudInView];
    } else {
        [self performSelector:@selector(showHudInView)
                   withObject:nil
                   afterDelay:afterDelay];
    }
}

- (void)hideHud:(bool)animated {
    if (!_isHubDisplaying) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self
                                                 selector:@selector(showHudInView)
                                                   object:nil];
    } else {
        [MBProgressHUD hideHUDForView:self.view animated:animated];
    }
    @synchronized (self) {
        _isHubDisplaying = NO;
    }
}

- (void)showHudInView {
    @synchronized (self) {
        _isHubDisplaying = YES;
    }
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
}

#pragma mark -- navgationBar item

- (void)setLeftNavgationBarItem {
    [self setLeftNavgationBarItemWithTarget:nil
                                   selector:nil
                                      title:nil
                                 titleColor:nil
                                normalImage:[UIImage imageNamed:@"back_black"]
                              selectedImage:[UIImage imageNamed:@"back_black"]];
}

- (void)setLeftNavgationBarItemWithTarget:(id)target
                                 selector:(SEL)selector
                                    title:(NSString *)title
                               titleColor:(UIColor *)titleColor
                              normalImage:(UIImage *)normalImage
                            selectedImage:(UIImage *)selectedImage {
    [self setNavgationBarItemWithTarget:target
                               selector:selector
                                  title:title
                             titleColor:titleColor
                            normalImage:normalImage
                          selectedImage:selectedImage
                               poistion:LXNavgationBarItemLeft];
}

- (void)setRightNavgationBarItemWithTarget:(id)target
                                  selector:(SEL)selector
                                     title:(NSString *)title
                                titleColor:(UIColor *)titleColor
                               normalImage:(UIImage *)normalImage
                             selectedImage:(UIImage *)selectedImage {
    [self setNavgationBarItemWithTarget:target
                               selector:selector
                                  title:title
                             titleColor:titleColor
                            normalImage:normalImage
                          selectedImage:selectedImage
                               poistion:LXNavgationBarItemRight];
}

- (void)setNavgationBarItemWithTarget:(id _Nullable)target
                             selector:(SEL _Nullable)selector
                                title:(NSString * _Nullable)title
                           titleColor:(UIColor * _Nullable)titleColor
                          normalImage:(UIImage * _Nullable)normalImage
                        selectedImage:(UIImage * _Nullable)selectedImage
                             poistion:(LXNavgationBarItemPoistion)poistion {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.adjustsImageWhenHighlighted = NO;
    btn.frame = CGRectMake(0.0f, 0.0f, 40.0f, 40.0f);
    [btn setImage:normalImage forState:UIControlStateNormal];
    [btn setImage:selectedImage forState:UIControlStateSelected];
    btn = [self setNavgationBarCustomButton:btn
                                      title:title
                                 titleColor:titleColor];
    btn.contentHorizontalAlignment = poistion == LXNavgationBarItemLeft ? UIControlContentHorizontalAlignmentLeft : UIControlContentHorizontalAlignmentRight;
    UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    if (poistion == LXNavgationBarItemLeft) {
        self.navigationItem.leftBarButtonItem = buttonItem;
    } else {
        self.navigationItem.rightBarButtonItem = buttonItem;
    }
    if (selector && target) {
        [btn addTarget:target
                action:selector
      forControlEvents:UIControlEventTouchUpInside];
    } else if (self.navigationController != nil) {
        [btn addTarget:self
                action:@selector(backBtnClicked)
      forControlEvents:UIControlEventTouchUpInside];
    }
}

- (UIButton *)setNavgationBarCustomButton:(UIButton * _Nullable)button
                                    title:(NSString * _Nullable)title
                               titleColor:(UIColor * _Nullable)titleColor {
    if (!button || !title) {
        return button;
    }
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:titleColor forState:UIControlStateNormal];
    UIColor *selectedColor = !titleColor ? [[UIColor blueColor] colorWithAlphaComponent:0.7] : [titleColor colorWithAlphaComponent:0.7];
    [button setTitleColor:selectedColor forState:UIControlStateSelected];
    
    [button.titleLabel setFont:[UIFont systemFontOfSize:15]];
    [button sizeToFit];
    
    return button;
}

- (void)setPrefersNavgationBarHidden:(BOOL)prefersNavgationBarHidden {
    self.fd_prefersNavigationBarHidden = prefersNavgationBarHidden;
}

- (BOOL)interactivePopDisable {
    return self.fd_interactivePopDisabled;
}

- (void)setInteractivePopDisable:(BOOL)interactivePopDisable {
    self.fd_interactivePopDisabled = interactivePopDisable;
}
 
- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (BOOL)prefersStatusBarHidden {
    return _stateBarHidden;
}


@end
