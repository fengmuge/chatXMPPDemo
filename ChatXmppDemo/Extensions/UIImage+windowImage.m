//
//  UIImage+windowImage.m
//  赛事平台
//
//  Created by 喵小仲 on 16/10/19.
//  Copyright © 2016年 ytgame. All rights reserved.
//

#import "UIImage+windowImage.h"
#import <AVFoundation/AVFoundation.h>
#import "globalDefine.h"
@implementation UIImage (windowImage)

+ (UIImage *)getWindowImage
{
    return [UIImage getViewImageWithView:[[UIApplication sharedApplication] keyWindow] rect:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
}

+ (UIImage *)getImageWithImage1:(UIImage *)image1 image2:(UIImage *)image2
{
    CGFloat image2Heihgt = image2.size.height*image1.size.width/image2.size.width;
    CGSize size = CGSizeMake(image1.size.width,image1.size.height+image2Heihgt);
    UIGraphicsBeginImageContext(size);
    [image1 drawInRect:CGRectMake(0, 0, image1.size.width, image1.size.height)];
    [image2 drawInRect:CGRectMake(0, image1.size.height, image1.size.width, image2Heihgt)];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

+ (UIImage *)getViewImageWithView:(UIView *)view rect:(CGRect)rect
{
    UIGraphicsBeginImageContext(view.frame.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    UIRectClip(rect);
    [view.layer renderInContext:context];
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return viewImage;
}

+ (UIImage *)setImageFromImage:(UIImage *)fromImage toImage:(UIImage *)toImage inRect:(CGRect)rect
{
    UIGraphicsBeginImageContext(toImage.size);
    [toImage drawInRect:CGRectMake(0, 0, toImage.size.width, toImage.size.height)];
    [fromImage drawInRect:rect];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

+ (UIImage *)createImageWithColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

+ (UIImage *)createAImageWithColor:(UIColor *)color alpha:(CGFloat)alpha{
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextSetAlpha(context, alpha);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

+ (UIImage*)imageFromColors:(NSArray*)colors withSize:(CGSize)size
{
    NSMutableArray *ar = [NSMutableArray array];
    for(UIColor *c in colors) {
        [ar addObject:(id)c.CGColor];
    }
    UIGraphicsBeginImageContextWithOptions(size, YES, 1);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    CGColorSpaceRef colorSpace = CGColorGetColorSpace([[colors lastObject] CGColor]);
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (CFArrayRef)ar, NULL);
    
    CGPoint start;
    CGPoint end;
    start = CGPointMake(0.0, size.height/2);
    end = CGPointMake(size.width, size.height/2);
    
    CGContextDrawLinearGradient(context, gradient, start, end,kCGGradientDrawsBeforeStartLocation | kCGGradientDrawsAfterEndLocation);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    CGGradientRelease(gradient);
    CGContextRestoreGState(context);
    CGColorSpaceRelease(colorSpace);
    UIGraphicsEndImageContext();
    
    return image;
}

+ (UIImage *)placeholderImageWithSize:(CGSize)size
{
    
    UIColor *backgroundColor = [UIColor colorWithRed:180/255.0 green:180/255.0 blue:180/255.0 alpha:1];
    UIImage *image = [UIImage imageNamed:@"Common_placeholderImage_common"];
    CGFloat viewWH = size.width > size.height ? size.height : size.width;
    CGSize logoSize = CGSizeMake(viewWH, viewWH);
    
    UIGraphicsBeginImageContextWithOptions(size,0, [UIScreen mainScreen].scale);
    [backgroundColor set];
    UIRectFill(CGRectMake(0,0, size.width, size.height));
    CGFloat imageX = (size.width / 2) - (logoSize.width / 2);
    CGFloat imageY = (size.height / 2) - (logoSize.height / 2);
    [image drawInRect:CGRectMake(imageX, imageY, logoSize.width, logoSize.height)];
    UIImage *resImage =UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return resImage;
}

+ (UIImage *)imageWithColor:(UIColor *)color {
    
    CGRect rect = CGRectMake(0.0f,0.0f, 1.0f,1.0f);
    
    UIGraphicsBeginImageContext(rect.size);
    
    CGContextRef context =UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    
    CGContextFillRect(context, rect);
    
    UIImage *image =UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return image;
    
}

+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size {
    
    if (!color || size.width <=0 || size.height <=0) return nil;
    
    CGRect rect = CGRectMake(0.0f, 0.0f, size.width, size.height);
    
    UIGraphicsBeginImageContextWithOptions(rect.size,NO, 0);
    
    CGContextRef context =UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, color.CGColor);
    
    CGContextFillRect(context, rect);
    
    UIImage *image =UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return image;
    
}


+ (NSData *)getResultImage:(UIImage *)image {
    
    CGSize size = image.size;
    NSData *data = data = UIImageJPEGRepresentation(image, 1);
    if (data.length > 1024 * 1024 * 4) {
        data = UIImageJPEGRepresentation(image, 0.5);
        CGFloat scale = SCREEN_WIDTH / SCREEN_HEIGHT;
        UIGraphicsBeginImageContext(size);
        [[UIImage imageWithData:data] drawInRect:CGRectMake(0,0, size.width * scale, size.height * scale)];
        UIImage *getImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return [self getResultImage:getImage];
    } else if (data.length > 1024 * 1024 * 2) {
        return UIImageJPEGRepresentation(image, 0.05);
    } else if (data.length > 1024 * 1024) {
        return UIImageJPEGRepresentation(image, 0.1);
    } else if (data.length > 1024 * 1024 * 0.5) {
        return UIImageJPEGRepresentation(image, 0.2);
    } else if (data.length > 1024 * 1024 * 0.2) {
        return UIImageJPEGRepresentation(image, 0.4);
    } else {
        return data;
    }
}

-(UIImage *)scaledImageFormImage:(UIImage *)image toSize:(CGSize)size
{
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0,0, size.width, size.height)];
    UIImage *getImage=UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return getImage;
}

// 获取网络视频第一帧
+ (UIImage *)getVideoPreViewImage:(NSURL *)path {
    if (path) {
        AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:path options:nil];
        AVAssetImageGenerator *assetGen = [[AVAssetImageGenerator alloc] initWithAsset:asset];
        
        assetGen.appliesPreferredTrackTransform = YES;
        CMTime time = CMTimeMakeWithSeconds(0.0, 600);
        NSError *error = nil;
        CMTime actualTime;
        CGImageRef image = [assetGen copyCGImageAtTime:time actualTime:&actualTime error:&error];
        UIImage *videoImage = [[UIImage alloc] initWithCGImage:image];
        CGImageRelease(image);
        return videoImage;
    } else {
        return nil;
    }
}
+ (NSArray *)getGifImages:(NSString *)fileName {
    
    NSString *path = [[NSBundle mainBundle] pathForResource:fileName ofType:@"gif"];
    NSURL *url = [NSURL fileURLWithPath:path];
    //通过文件的url来将gif文件读取为图片数据引用
    CGImageSourceRef source = CGImageSourceCreateWithURL((CFURLRef)url, NULL);
    //获取gif文件中图片的个数
    size_t count = CGImageSourceGetCount(source);
    //定义一个变量记录gif播放一轮的时间
//    float allTime=0;
    //存放所有图片
    NSMutableArray * imageArray = [[NSMutableArray alloc]init];
//    //存放每一帧播放的时间
//    NSMutableArray * timeArray = [[NSMutableArray alloc]init];
//    //存放每张图片的宽度 （一般在一个gif文件中，所有图片尺寸都会一样）
//    NSMutableArray * widthArray = [[NSMutableArray alloc]init];
//    //存放每张图片的高度
//    NSMutableArray * heightArray = [[NSMutableArray alloc]init];

    //遍历
    for (size_t i = 0; i < count; i++) {
        CGImageRef image = CGImageSourceCreateImageAtIndex(source, i, NULL);
        [imageArray addObject:[UIImage imageWithCGImage:image]];
        CGImageRelease(image);
        //获取图片信息
//        NSDictionary * info = (__bridge NSDictionary*)CGImageSourceCopyPropertiesAtIndex(source, i, NULL);
//        CGFloat width = [[info objectForKey:(__bridge NSString *)kCGImagePropertyPixelWidth] floatValue];
//        CGFloat height = [[info objectForKey:(__bridge NSString *)kCGImagePropertyPixelHeight] floatValue];
//        [widthArray addObject:[NSNumber numberWithFloat:width]];
//        [heightArray addObject:[NSNumber numberWithFloat:height]];
//        NSDictionary * timeDic = [info objectForKey:(__bridge NSString *)kCGImagePropertyGIFDictionary];
//        CGFloat time = [[timeDic objectForKey:(__bridge NSString *)kCGImagePropertyGIFDelayTime]floatValue];
//        allTime+=time;
//        [timeArray addObject:[NSNumber numberWithFloat:time]];
    }
    return imageArray;
}

+ (UIImage *)makeButtonGrayImage:(UIImage *)image {
    
    CIImage *beginImage = [CIImage imageWithCGImage:image.CGImage];
    CIFilter * filter = [CIFilter filterWithName:@"CIColorControls"];
    [filter setValue:beginImage forKey:kCIInputImageKey];
    //饱和度 0---2 默认为1
    [filter setValue:0 forKey:@"inputSaturation"];
    
    // 得到过滤后的图片
    CIImage *outputImage = [filter outputImage];
    // 转换图片, 创建基于GPU的CIContext对象
    CIContext *context = [CIContext contextWithOptions: nil];
    CGImageRef cgimg = [context createCGImage:outputImage fromRect:[outputImage extent]];
    UIImage *newImg = [UIImage imageWithCGImage:cgimg];
    // 释放C对象
    CGImageRelease(cgimg);
    return newImg;
}

+ (UIImage *)makeGrayImage:(UIImage *)image {
    
    int width = image.size.width;
    int height = image.size.height;
    //第一步:创建颜色空间(说白了就是 开辟一块颜色内存空间)
    //图片灰度处理(创建灰度空间)
 
    CGColorSpaceRef colorRef = CGColorSpaceCreateDeviceGray();
    
    //第二步:颜色空间的上下文(保存图像数据信息)
    //参数1:内存大小(指向这块内存区域的地址)(内存地址)
    //参数2:图片宽
    //参数3:图片高
    //参数4:像素位数(颜色空间,例如:32位像素格式和RGB颜色空间,8位)
    //参数5:图片每一行占用的内存比特数
    //参数6:颜色空间
    //参数7:图片是否包含A通道(ARGB通道)
    CGContextRef context = CGBitmapContextCreate(nil, width, height, 8, 0, colorRef, kCGImageAlphaNone);
    
    //释放内存
    CGColorSpaceRelease(colorRef);
    if (context == nil) {
        return nil;
    }
    //第三步:渲染图片(绘制图片)
    //参数1:上下文
    //参数2:渲染区域
    //参数3:源文件(原图片)(说白了现在是一个C/C++的内存区域)
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), image.CGImage);
    
    //第四步:将绘制颜色空间转成CGImage(转成可识别图片类型)
    CGImageRef grayImageRef = CGBitmapContextCreateImage(context);
    
    //第五步:将C/C++ 的图片CGImage转成面向对象的UIImage(转成iOS程序认识的图片类型)
    UIImage* dstImage = [UIImage imageWithCGImage:grayImageRef];
    
    //释放内存
    CGContextRelease(context);
    CGImageRelease(grayImageRef);
    
    return dstImage;
}

@end
