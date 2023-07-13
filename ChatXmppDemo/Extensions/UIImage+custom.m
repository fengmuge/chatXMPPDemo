//
//  UIImage+custom.m
//  ChatXmppDemo
//
//  Created by 苗培根 on 2023/6/13.
//

#import "UIImage+custom.h"

@implementation UIImage (custom)

- (NSData *)toData {
    if (UIImagePNGRepresentation(self) != nil) {
        return UIImagePNGRepresentation(self);
    }
    return UIImageJPEGRepresentation(self, 1);
}

- (UIImage *)reSize:(CGSize)reSize {
    UIGraphicsBeginImageContext(reSize);
    [self drawInRect:CGRectMake(0, 0, reSize.width, reSize.height)];
    UIImage *reSizeImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return reSizeImage;
}

// 感觉这个方法并不实用，我的想法是将多个图片绘制到一个view上，实现微信群聊的icon效果
- (UIImage *)addImage:(UIImage *)image1 toImage:(UIImage *)image2 {
    UIGraphicsBeginImageContext(image2.size);
    // Draw image1
    [image1 drawInRect:CGRectMake(image2.size.width*0.01, image2.size.height*0.01, image2.size.width*0.97, image2.size.height*0.97)];
    // Draw image2
    [image2 drawInRect:CGRectMake(0, 0, image2.size.width, image2.size.height)];
    UIImage *resultingImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return resultingImage;
}

// 将多个image绘制到同一个image中
+ (UIImage *)addImages:(NSArray<UIImage *> *)subImages withSize:(CGFloat)value {
    CGSize totalSize = CGSizeMake(value, value);
    UIGraphicsBeginImageContext(totalSize);
    // 获取每个subImage的rect
    NSArray *subRects = [UIImage calculateSubImageRectWith:totalSize andCount:subImages.count];
    for (int i = 0; i < subImages.count; i++) {
        NSString *subRectValue = subRects[i];
        CGRect subRect = CGRectFromString(subRectValue);
        UIImage *subImg = subImages[i];
                
        [subImg drawInRect:subRect];
    }
    
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return result;
}

// 根据总的size和子image计算子image.size
// 可以根据需求计算，Demo中简单设置
+ (NSArray <NSString *> *)calculateSubImageRectWith:(CGSize)size andCount:(NSInteger)count {
    CGFloat space = 5;
    // 除去边框的可操作空间
    CGSize pointSize = CGSizeMake(size.width - space * 2, size.height - space * 2);
    if (count <= 1) {
        NSString *pointSizeValue = NSStringFromCGRect(CGRectMake(space, space, pointSize.width, pointSize.height));
        return @[pointSizeValue];
    }
    
    CGFloat imgWidth = (pointSize.width - space * 2) / 3;
    NSMutableArray *result = [[NSMutableArray alloc] init];
    CGFloat left = space;
    CGFloat top = space;
    for (int i = 0; i < count; i++) {
        if (i % 3 == 0) {
            left = space;
            top += (imgWidth + space) * (i / 3);
        } else {
            left += (imgWidth + space);
        }
        CGRect imgRect = CGRectMake(left, top, imgWidth, imgWidth);
        [result addObject:NSStringFromCGRect(imgRect)];
    }
    return result;
}

@end
