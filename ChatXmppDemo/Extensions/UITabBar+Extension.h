//
//  UITabBar+Extension.h
//  iOSDevelopSDK
//
//  Created by 苗培根 on 2023/1/13.
//  Copyright © 2023 zhifengh. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UITabBar (Extension)

@property (nonatomic, assign) BOOL isAnimating;
//@property (nonatomic, assign)

- (void)setTabbarHidden:(BOOL)isHidden animation:(BOOL)isAnimation;

- (CGFloat)setTabbarFrameChange:(CGFloat)scale;

@end

NS_ASSUME_NONNULL_END
