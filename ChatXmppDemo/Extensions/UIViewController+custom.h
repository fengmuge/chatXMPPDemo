//
//  UIViewController+custom.h
//  ChatXmppDemo
//
//  Created by 苗培根 on 2023/6/8.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    LXNavgationBarItemCenter = 0,
    LXNavgationBarItemLeft = 1,
    LXNavgationBarItemRight = 2,
} LXNavgationBarItemPoistion;

NS_ASSUME_NONNULL_BEGIN

typedef void(^kInputAlertActionHandler)(bool result, UITextField * __nullable textField);
typedef void (^kInputAlertTextFieldHandler)(UITextField *textField);

@interface UIViewController (custom)

@property (nonatomic, assign) BOOL isPopViewControllerAnimated;

+ (UIViewController *)currentVC;

- (BOOL)isCurrentVC;

- (void)showHud:(NSTimeInterval)afterDelay;

- (void)hideHud:(bool)animated;

- (void)alertAutoDisappearWithTitle:(NSString *)title
                            message:(NSString * _Nullable)message;

- (void)alertWithTitle:(NSString *)title
               message:(NSString * _Nullable)message
         actionHandler:(void(^)(bool))handler;

// 带有输入框的alert
- (void)inputAlertWithTitle:(NSString *)title
           textFieldHandler:(kInputAlertTextFieldHandler)tfHandler
              actionHandler:(kInputAlertActionHandler)aHandler;

// 设置导航栏左侧baritem
- (void)setLeftNavgationBarItem;
// 设置导航栏左侧barItem
- (void)setLeftNavgationBarItemWithTitle:(NSString *)title
                              titleColor:(UIColor *)titleColor;
// 设置导航栏左侧barItem
- (void)setLeftNavgationBarItemWithNormalImage:(UIImage *)normalImage
                                 selectedImage:(UIImage *)selectedImage;
// 设置导航栏左侧barItem
- (void)setLeftNavgationBarItemWithTarget:(id)target
                                 selector:(SEL)selector
                                    title:(NSString *)title
                               titleColor:(UIColor *)titleColor;
// 设置导航栏左侧barItem
- (void)setLeftNavgationBarItemWithTarget:(id)target
                                 selector:(SEL)selector
                              normalImage:(UIImage *)normalImage
                            selectedImage:(UIImage *)selectedImage;
// 设置导航栏左侧barItem
- (void)setLeftNavgationBarItemWithTarget:(id _Nullable)target
                                 selector:(SEL _Nullable)selector
                                    title:(NSString * _Nullable)title
                               titleColor:(UIColor * _Nullable)titleColor
                              normalImage:(UIImage * _Nullable)normalImage
                            selectedImage:(UIImage * _Nullable)selectedImage;

// 设置导航栏右侧barItem
- (void)setRightNavgationBarItemWithTarget:(id _Nullable)target
                                  selector:(SEL _Nullable)selector
                                     title:(NSString * _Nullable)title
                                titleColor:(UIColor * _Nullable)titleColor;
// 设置导航栏右侧barItem
- (void)setRightNavgationBarItemWithTarget:(id _Nullable)target
                                  selector:(SEL _Nullable)selector
                               normalImage:(UIImage * _Nullable)normalImage
                             selectedImage:(UIImage * _Nullable)selectedImage;
// 设置导航栏右侧barItem
- (void)setRightNavgationBarItemWithTarget:(id _Nullable)target
                                  selector:(SEL _Nullable)selector
                                     title:(NSString * _Nullable)title
                                titleColor:(UIColor * _Nullable)titleColor
                               normalImage:(UIImage * _Nullable)normalImage
                             selectedImage:(UIImage * _Nullable)selectedImage;

// 获取导航栏barButtonItem with image
- (UIBarButtonItem *)makeNavgationBarButtonItemWithNormalImage:(UIImage * _Nullable)normalImage
                                           selectedImage:(UIImage * _Nullable)selectedImage
                                                      poistion:(LXNavgationBarItemPoistion)poistion;
// 获取导航栏barButtonItem with title
- (UIBarButtonItem *)makeNavgationBarButtonItemWithTitle:(NSString * _Nullable)title
                                              titleColor:(UIColor * _Nullable)titleColor
                                                poistion:(LXNavgationBarItemPoistion)poistion;

// 获取导航栏barButtonItem with image & selector
- (UIBarButtonItem *)makeNavgationBarButtonItemWithTarget:(id _Nullable)target
                                                selector:(SEL _Nullable)selector
                                             normalImage:(UIImage * _Nullable)normalImage
                                           selectedImage:(UIImage * _Nullable)selectedImage
                                                poistion:(LXNavgationBarItemPoistion)poistion;
// 获取导航栏barButtonItem with title & selector
- (UIBarButtonItem *)makeNavgationBarButtonItemWithTarget:(id _Nullable)target
                                                selector:(SEL _Nullable)selector
                                                   title:(NSString * _Nullable)title
                                              titleColor:(UIColor * _Nullable)titleColor
                                                poistion:(LXNavgationBarItemPoistion)poistion;
// 获取导航栏barButtonItem with image & title & selector
- (UIBarButtonItem *)makeNavgationBarButtonItemWithTarget:(id _Nullable)target
                                                selector:(SEL _Nullable)selector
                                                   title:(NSString * _Nullable)title
                                              titleColor:(UIColor * _Nullable)titleColor
                                             normalImage:(UIImage * _Nullable)normalImage
                                           selectedImage:(UIImage * _Nullable)selectedImage
                                                poistion:(LXNavgationBarItemPoistion)poistion;


@end

NS_ASSUME_NONNULL_END
