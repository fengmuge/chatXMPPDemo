//
//  UIImage+windowImage.h
//  WCA赛事平台
//
//  Created by 喵小仲 on 16/10/19.
//  Copyright © 2016年 ytgame. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (windowImage)

+ (UIImage *)getWindowImage;

+ (UIImage *)getImageWithImage1:(UIImage *)image1 image2:(UIImage *)image2;

+ (UIImage *)getViewImageWithView:(UIView *)view rect:(CGRect)rect;

+ (UIImage *)setImageFromImage:(UIImage *)fromImage toImage:(UIImage *)toImage inRect:(CGRect)rect;

+ (UIImage *)createImageWithColor:(UIColor *)color;

+ (UIImage*)imageFromColors:(NSArray*)colors withSize:(CGSize)size;

+ (UIImage *)placeholderImageWithSize:(CGSize)size;

+ (UIImage *)createAImageWithColor:(UIColor *)color alpha:(CGFloat)alpha;

+ (UIImage *)imageWithColor:(UIColor *)color;

+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size;

+ (NSData *)getResultImage:(UIImage *)image;
/**获取视频第一帧*/
+ (UIImage *)getVideoPreViewImage:(NSURL *)path;
/**获取gif中的图片数组*/
+ (NSArray *)getGifImages:(NSString *)fileName;
/**特殊节日灰色图片*/
+ (UIImage *)makeGrayImage:(UIImage *)image;
+ (UIImage *)makeButtonGrayImage:(UIImage *)image;
@end
