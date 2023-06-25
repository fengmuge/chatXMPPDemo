//
//  UIImage+custom.h
//  ChatXmppDemo
//
//  Created by 苗培根 on 2023/6/13.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (custom)
// 转化为data数据
- (NSData *)toData;
// 重新设置size
- (UIImage *)reSize:(CGSize)reSize;

@end

NS_ASSUME_NONNULL_END
