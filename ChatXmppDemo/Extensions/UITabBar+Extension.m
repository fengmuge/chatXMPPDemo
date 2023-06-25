//
//  UITabBar+Extension.m
//  iOSDevelopSDK
//
//  Created by 苗培根 on 2023/1/13.
//  Copyright © 2023 zhifengh. All rights reserved.
//

#import "UITabBar+Extension.h"

@implementation UITabBar (Extension)

- (void)setIsAnimating:(BOOL)isAnimating {
    NSNumber *isAnimatingNumber = [NSNumber numberWithBool:isAnimating];
    objc_setAssociatedObject(self, @selector(isAnimating), isAnimatingNumber, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (BOOL)isAnimating {
    NSNumber *isAnimatingNumber = objc_getAssociatedObject(self, @selector(isAnimating));
    return isAnimatingNumber.boolValue;
}

// 修复在Tabbar隐藏的情况下，旋转屏幕动画错乱的BUG
- (CGRect)sortTabbarFrame {
    CGRect barFrame = self.frame;
    if (self.isHidden) {
        // 强行修改Tabbar的frame
        self.frame = CGRectMake(CGRectGetMinX(barFrame),
                                SCREEN_HEIGHT,
                                CGRectGetWidth(barFrame),
                                CGRectGetHeight(barFrame));
    }
    barFrame = self.frame;
    return barFrame;
}

- (void)setTabbarHidden:(BOOL)isHidden animation:(BOOL)isAnimation {
    if (self.isAnimating) { // 如果正在动画中，不执行
        return;
    }
    // 修复在Tabbar隐藏的情况下，旋转屏幕动画错乱的BUG
    CGRect barFrame = [self sortTabbarFrame];
    // 是否在屏幕外，这个是判断动画方向的依据
    BOOL isOutScreen = (int)(SCREEN_HEIGHT - CGRectGetMinY(barFrame)) == 0;
    CGFloat direction = isOutScreen ? -1 : 1; // 定义动画方向 -1 下 ： 上
    CGFloat offset = direction * CGRectGetHeight(barFrame); // 动画偏移量
    NSTimeInterval duration = isAnimation ? 0.5 : 0.0; // 动画时间
    
    [self setHidden:NO]; // 动画开始前，设置tabbar非隐藏
    self.isAnimating = YES; // 标记动画正在执行
    
    [UIView animateWithDuration:duration animations:^{
        self.centerY += offset; // 修改中心点偏移量
    } completion:^(BOOL finished) {
        [self setHidden:!isOutScreen]; // 设置tabbar显示状态
        self.isAnimating = NO; // 取消动画标记状态
    }];
}

// 根据scale比例，设置tabbar垂直方向frame变化 direction -1 : 1; // 定义动画方向 上下
- (CGFloat)setTabbarFrameChange:(CGFloat)scale {
    if (self.isAnimating) { // 如果动画中，不执行
        return 0;
    }
    // 修复在Tabbar隐藏的情况下，旋转屏幕动画错乱的BUG
    CGRect barFrame = [self sortTabbarFrame];
    CGFloat offset = CGRectGetHeight(barFrame) * scale; // 动画偏移量
    self.top = SCREEN_HEIGHT - CGRectGetHeight(barFrame)  + offset;
    return offset;
}

@end
