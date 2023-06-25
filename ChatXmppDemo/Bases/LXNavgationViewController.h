//
//  LXNavgationViewController.h
//  ChatXmppDemo
//
//  Created by 苗培根 on 2023/6/6.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    LXNavgationBarItemLeft,
    LXNavgationBarItemRight,
} LXNavgationBarItemPoistion;

NS_ASSUME_NONNULL_BEGIN

@interface LXNavgationViewController : UINavigationController

@property (nonatomic, strong) UIImage *backgroundImage;

+ (LXNavgationViewController *)initWithRootViewController:(UIViewController *)viewController;

+ (LXNavgationViewController *)initWithRootViewController:(UIViewController *)viewController
                                                itemTitle:(NSString *)itemTitle;

+ (LXNavgationViewController *)initWithRootViewController:(UIViewController *)viewController
                                                itemTitle:(NSString *_Nullable)title
                                            itemImageName:(NSString *_Nullable)imageName;

@end

NS_ASSUME_NONNULL_END
