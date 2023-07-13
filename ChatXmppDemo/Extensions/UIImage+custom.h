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

// 将图片添加到另一个图片上
- (UIImage *)addImage:(UIImage *)image1 toImage:(UIImage *)image2;
// 将图片s添加到另一个图片上
// size是大小,宽高一致
+ (UIImage *)addImages:(NSArray <UIImage *> *)subImages withSize:(CGFloat)value;

@end

NS_ASSUME_NONNULL_END
