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

@end
