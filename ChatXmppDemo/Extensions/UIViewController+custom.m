//
//  UIViewController+custom.m
//  ChatXmppDemo
//
//  Created by 苗培根 on 2023/6/8.
//

#import "UIViewController+custom.h"
#import "LXNavgationViewController.h"
#import <MBProgressHUD.h>
#import <objc/runtime.h>

@interface UIViewController()

@property (nonatomic, assign) bool isHubDisplaying;

@end

@implementation UIViewController (custom)

- (void)setIsHubDisplaying:(bool)isHubDisplaying {
    NSNumber *valueNumber = [NSNumber numberWithBool:isHubDisplaying];
    objc_setAssociatedObject(self, @selector(isHubDisplaying), valueNumber, OBJC_ASSOCIATION_ASSIGN);
}

- (bool)isHubDisplaying {
    NSNumber *valueNumber = objc_getAssociatedObject(self,  @selector(isHubDisplaying));
    return [valueNumber boolValue];
}

- (void)setIsPopViewControllerAnimated:(BOOL)isPopViewControllerAnimated {
    NSNumber *valueNumber = [NSNumber numberWithBool:isPopViewControllerAnimated];
    objc_setAssociatedObject(self, @selector(isPopViewControllerAnimated), valueNumber, OBJC_ASSOCIATION_ASSIGN);
}

- (BOOL)isPopViewControllerAnimated {
    NSNumber *valueNumber = objc_getAssociatedObject(self, @selector(isPopViewControllerAnimated));
    if (!valueNumber) {
        return YES;
    }
    return [valueNumber boolValue];
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
        [self dismissViewControllerAnimated:alertVC completion:nil];
    }];
    [cancelAction setValue:[UIColor grayColor] forKey:@"titleTextColor"];
    
    [alertVC addAction:action];
    [alertVC addAction:cancelAction];
    
    [self presentViewController:alertVC animated:YES completion:nil];
}

- (void)inputAlertWithTitle:(NSString *)title
           textFieldHandler:(kInputAlertTextFieldHandler)tfHandler
              actionHandler:(kInputAlertActionHandler)aHandler {
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:title
                                                                     message:nil
                                                              preferredStyle:UIAlertControllerStyleAlert];
    [alertVC addTextFieldWithConfigurationHandler:tfHandler];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (aHandler) {
            aHandler(YES, alertVC.textFields[0]);
        }
    }];
    [action setValue:[UIColor blueColor] forKey:@"titleTextColor"];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        if (aHandler) {
            aHandler(NO, nil);
        }
        [self dismissViewControllerAnimated:alertVC completion:nil];
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
    if (!self.isHubDisplaying) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self
                                                 selector:@selector(showHudInView)
                                                   object:nil];
    } else {
        [MBProgressHUD hideHUDForView:self.view animated:animated];
    }
    @synchronized (self) {
        self.isHubDisplaying = NO;
    }
}

- (void)showHudInView {
    @synchronized (self) {
        self.isHubDisplaying = YES;
    }
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
}

#pragma mark -- currentVC--
+ (UIViewController *)currentVC {
    UIViewController *rootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
    return [self getCurrentVCFrom:rootVC];
}

+ (UIViewController *)getCurrentVCFrom:(UIViewController *)viewController {
    UIViewController *currentVC = viewController;
    
    if ([currentVC presentedViewController]) {
        currentVC = [currentVC presentedViewController];
    }
    
    if ([currentVC isKindOfClass:[UITabBarController class]]) {
        currentVC = [self getCurrentVCFrom:[(UITabBarController *)currentVC selectedViewController]];
    } else if ([currentVC isKindOfClass:[UINavigationController class]]) {
        currentVC = [self getCurrentVCFrom:[(UINavigationController *)currentVC visibleViewController]];
    }
    return currentVC;
}

#pragma mark -- navgationBar item

- (void)backBtnClicked {
    [self.navigationController popViewControllerAnimated:self.isPopViewControllerAnimated];
}

- (void)setLeftNavgationBarItem {
    [self setLeftNavgationBarItemWithTarget:nil
                                   selector:nil
                                      title:nil
                                 titleColor:nil
                                normalImage:[UIImage imageNamed:@"back_black"]
                              selectedImage:[UIImage imageNamed:@"back_black"]];
}

- (void)setLeftNavgationBarItemWithTitle:(NSString *)title
                               titleColor:(UIColor *)titleColor {
    [self setNavgationBarItemWithTarget:nil
                               selector:nil
                                  title:title
                             titleColor:titleColor
                            normalImage:nil
                          selectedImage:nil
                               poistion:LXNavgationBarItemLeft];
}

- (void)setLeftNavgationBarItemWithNormalImage:(UIImage *)normalImage
                            selectedImage:(UIImage *)selectedImage {
    [self setNavgationBarItemWithTarget:nil
                               selector:nil
                                  title:nil
                             titleColor:nil
                            normalImage:normalImage
                          selectedImage:selectedImage
                               poistion:LXNavgationBarItemLeft];
}

- (void)setLeftNavgationBarItemWithTarget:(id)target
                                 selector:(SEL)selector
                                    title:(NSString *)title
                               titleColor:(UIColor *)titleColor {
    [self setNavgationBarItemWithTarget:target
                               selector:selector
                                  title:title
                             titleColor:titleColor
                            normalImage:nil
                          selectedImage:nil
                               poistion:LXNavgationBarItemLeft];
}

- (void)setLeftNavgationBarItemWithTarget:(id)target
                                 selector:(SEL)selector
                              normalImage:(UIImage *)normalImage
                            selectedImage:(UIImage *)selectedImage {
    [self setNavgationBarItemWithTarget:target
                               selector:selector
                                  title:nil
                             titleColor:nil
                            normalImage:normalImage
                          selectedImage:selectedImage
                               poistion:LXNavgationBarItemLeft];
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
                                titleColor:(UIColor *)titleColor {
    [self setNavgationBarItemWithTarget:target
                               selector:selector
                                  title:title
                             titleColor:titleColor
                            normalImage:nil
                          selectedImage:nil
                               poistion:LXNavgationBarItemRight];
}

- (void)setRightNavgationBarItemWithTarget:(id)target
                                  selector:(SEL)selector
                               normalImage:(UIImage *)normalImage
                             selectedImage:(UIImage *)selectedImage {
    [self setNavgationBarItemWithTarget:target
                               selector:selector
                                  title:nil
                             titleColor:nil
                            normalImage:normalImage
                          selectedImage:selectedImage
                               poistion:LXNavgationBarItemRight];
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
    
    UIBarButtonItem *buttonItem = [self makeNavgationBarButtonItemWithTarget:target
                                                                    selector:selector
                                                                       title:title
                                                                  titleColor:titleColor
                                                                 normalImage:normalImage
                                                               selectedImage:selectedImage
                                                                    poistion:poistion];
    if (poistion == LXNavgationBarItemLeft) {
        self.navigationItem.leftBarButtonItem = buttonItem;
    } else {
        self.navigationItem.rightBarButtonItem = buttonItem;
    }
}

- (UIBarButtonItem *)makeNavgationBarButtonItemWithNormalImage:(UIImage *)normalImage
                                           selectedImage:(UIImage *)selectedImage
                                                poistion:(LXNavgationBarItemPoistion)poistion {
    return [self makeNavgationBarButtonItemWithTarget:nil
                                             selector:nil
                                                title:nil
                                           titleColor:nil
                                          normalImage:normalImage
                                        selectedImage:selectedImage
                                             poistion:poistion];
}

- (UIBarButtonItem *)makeNavgationBarButtonItemWithTitle:(NSString *)title
                                              titleColor:(UIColor *)titleColor
                                                poistion:(LXNavgationBarItemPoistion)poistion {
    return [self makeNavgationBarButtonItemWithTarget:nil
                                             selector:nil
                                                title:title
                                           titleColor:titleColor
                                          normalImage:nil
                                        selectedImage:nil
                                             poistion:poistion];
}


- (UIBarButtonItem *)makeNavgationBarButtonItemWithTarget:(id)target
                                                selector:(SEL)selector
                                             normalImage:(UIImage *)normalImage
                                           selectedImage:(UIImage *)selectedImage
                                                poistion:(LXNavgationBarItemPoistion)poistion {
    return [self makeNavgationBarButtonItemWithTarget:target
                                             selector:selector
                                                title:nil
                                           titleColor:nil
                                          normalImage:normalImage
                                        selectedImage:selectedImage
                                             poistion:poistion];
}

- (UIBarButtonItem *)makeNavgationBarButtonItemWithTarget:(id)target
                                                selector:(SEL)selector
                                                   title:(NSString *)title
                                              titleColor:(UIColor *)titleColor
                                                poistion:(LXNavgationBarItemPoistion)poistion {
    return [self makeNavgationBarButtonItemWithTarget:target
                                             selector:selector
                                                title:title
                                           titleColor:titleColor
                                          normalImage:nil
                                        selectedImage:nil
                                             poistion:poistion];
}

- (UIBarButtonItem *)makeNavgationBarButtonItemWithTarget:(id)target
                                                selector:(SEL)selector
                                                   title:(NSString *)title
                                              titleColor:(UIColor *)titleColor
                                             normalImage:(UIImage *)normalImage
                                           selectedImage:(UIImage *)selectedImage
                                                poistion:(LXNavgationBarItemPoistion)poistion {
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.adjustsImageWhenHighlighted = NO;
    btn.frame = CGRectMake(0.0f, 0.0f, 40.0f, 40.0f);
    
    btn = [self setNavgationBarCustomButton:btn
                                normalImage:normalImage
                              selectedImage:selectedImage];
    btn = [self setNavgationBarCustomButton:btn
                                      title:title
                                 titleColor:titleColor];
    btn.contentHorizontalAlignment = (UIControlContentHorizontalAlignment)poistion; // ? UIControlContentHorizontalAlignmentLeft : UIControlContentHorizontalAlignmentRight;
    
    if (selector && target) {
        [btn addTarget:target
                action:selector
      forControlEvents:UIControlEventTouchUpInside];
    } else if (self.navigationController != nil) {
        [btn addTarget:self
                action:@selector(backBtnClicked)
      forControlEvents:UIControlEventTouchUpInside];
    }
    
    UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    return buttonItem;
}

- (UIButton *)setNavgationBarCustomButton:(UIButton * _Nullable)button
                              normalImage:(UIImage * _Nullable)normalImage
                            selectedImage:(UIImage * _Nullable)selectedImage {
    if (!normalImage || !button) {
        return button;
    }
    [button setImage:normalImage forState:UIControlStateNormal];
    if (!selectedImage) {
        return button;
    }
    [button setImage:selectedImage forState:UIControlStateSelected];
    
    return button;
}

- (UIButton *)setNavgationBarCustomButton:(UIButton * _Nullable)button
                                    title:(NSString * _Nullable)title
                               titleColor:(UIColor * _Nullable)titleColor {
    if (!button || !title) {
        return button;
    }
    [button setTitle:title forState:UIControlStateNormal];
    UIColor *normalColor = titleColor ?: [UIColor blueColor];
    [button setTitleColor:normalColor forState:UIControlStateNormal];
    UIColor *selectedColor = !titleColor ? [[UIColor blueColor] colorWithAlphaComponent:0.7] : [titleColor colorWithAlphaComponent:0.7];
    [button setTitleColor:selectedColor forState:UIControlStateSelected];
    
    [button.titleLabel setFont:[UIFont systemFontOfSize:15]];
    [button sizeToFit];
    
    return button;
}

@end
