//
//  UIView+custom.m
//  ChatXmppDemo
//
//  Created by 苗培根 on 2023/7/21.
//

#import "UIView+custom.h"

@implementation UIView (custom)

- (UIView *)snapshotView {
    UIView *result;
    if (@available(iOS 7.0, *)) {
        result = [self snapshotViewAfterScreenUpdates:YES];
    } else {
        result = [[UIView alloc] initWithFrame:self.frame];
        // 获取上下文
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, YES, 1);
        // 将view的涂层渲染到上下文
        [self.layer renderInContext:UIGraphicsGetCurrentContext()];
        //取出图片
        UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
        // 结束上下文
        UIGraphicsEndImageContext();
        
        UIImageView *resultImageView = [[UIImageView alloc] initWithImage:resultImage];
        resultImageView.frame = result.bounds;
        [result addSubview:resultImageView];
    }
    
    return result;
}

@end
