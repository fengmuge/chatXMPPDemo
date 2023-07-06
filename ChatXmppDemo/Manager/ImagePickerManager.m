//
//  ImagePickerManager.m
//  ChatXmppDemo
//
//  Created by 苗培根 on 2023/7/6.
//

#import "ImagePickerManager.h"
#import <TZImagePickerController.h>

@implementation ImagePickerManager

static ImagePickerManager *_sharedInstance;

+ (ImagePickerManager *)sharedInstance {
    return [[self alloc] init];
}

- (instancetype)init {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [super init];
    });
    return _sharedInstance;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [super allocWithZone:zone];
    });
    return _sharedInstance;
}

- (nonnull id)copyWithZone:(nullable NSZone *)zone {
    return _sharedInstance;
}

- (nonnull id)mutableCopyWithZone:(nullable NSZone *)zone {
    return _sharedInstance;
}

@end
