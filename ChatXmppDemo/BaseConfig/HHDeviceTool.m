//
//  HHDeviceTool.m
//  iOSDevelopSDK
//
//  Created by Hayder on 2019/6/13.
//  Copyright © 2019 Hayder. All rights reserved.
//

#import "HHDeviceTool.h"
#import <sys/sysctl.h>
#import <sys/utsname.h>
#import "NSString+custom.h"
@implementation HHDeviceTool

/** appstore download url */
+ (NSString *)getAppStoreUrl
{
    return [NSString stringWithFormat:@"https://itunes.apple.com/app/id%@",@"111"];
}

/** 客户端类型 */
+ (NSString *)getClientType
{
    return @"iOS";
}

/** 设备名 */
+ (NSString *)getDeviceName
{
    return [[UIDevice currentDevice] name];
}

/** 设备类型 */
+ (NSString *)getDeviceType
{
    int mib[] = {CTL_HW, HW_MACHINE};
    size_t len;
    sysctl(mib, 2, NULL, &len, NULL, 0);
    char *machine = malloc(len);
    sysctl(mib, 2, machine, &len, NULL, 0);
    NSString *deviceType = [NSString stringWithCString:machine encoding:NSASCIIStringEncoding];
    free(machine);
    return deviceType;
}

/** 获取应用名 */
+ (NSString *)getAppName
{
    NSDictionary *infoDictionary = [[NSBundle mainBundle]infoDictionary];
    NSString *appName = infoDictionary[@"CFBundleDisplayName"];
    if ([NSString isNone:appName])
    {
        appName = infoDictionary[@"CFBundleName"];
    }
    return appName;
}

/** 获取安装的version，包含buildId */
+ (NSString *)getInstallIncludeBuildVersion
{
    NSDictionary *infoDictionary = [[NSBundle mainBundle]infoDictionary];
    NSString *version = infoDictionary[@"CFBundleShortVersionString"];
    NSString *build = infoDictionary[(NSString *)kCFBundleVersionKey];
    return [NSString stringWithFormat:@"%@.%@", version, build];
}

/** 获取安装的version，不包含buildId */
+ (NSString *)getInstallVersion
{
    NSDictionary *infoDictionary = [[NSBundle mainBundle]infoDictionary];
    NSString *version = infoDictionary[@"CFBundleShortVersionString"];
    return version;
}

/** 设备系统类型 */
+ (NSString *)getDeviceOSType
{
    return @"ios";
}

/** 设备系统版本号 */
+ (NSString *)getDeviceOSVersion
{
    return [[UIDevice currentDevice] systemVersion];
}

/** 渠道 */
+ (NSString *)getAppSourceChannel
{
    NSString *type = @"";
#if (SFDEBUG == 1)
    type = @"dev";
#else
    type = @"AppStore";
#endif
    return type;
}

/** build Identifier */
+ (NSString *)getBoundleId
{
    NSString* boundleID = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
    
    return boundleID;
}

+ (BOOL)isFullScreenIphone {
    NSArray *all = @[@"iPhone X global", @"iPhone X GSM", @"iPhone XS", @"iPhone XS Max China", @"iPhone XS Max", @"iPhone XR", @"iPhone 11", @"iPhone 11 pro", @"iPhone 11 pro Max", @"iPhone 12 mini", @"iPhone 12", @"iPhone 12 Pro", @"iPhone 12 Pro Max"];
    NSString *current = [self getCurrentDevice];
    return [all containsObject:current];
}

+ (NSString *)getCurrentDevice {
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString * deviceString = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];

    if ([deviceString isEqualToString:@"iPhone3,1"])    return @"iPhone 4";
    if ([deviceString isEqualToString:@"iPhone3,2"])    return @"iPhone 4";
    if ([deviceString isEqualToString:@"iPhone3,3"])    return @"iPhone 4";
    if ([deviceString isEqualToString:@"iPhone4,1"])    return @"iPhone 4s";
    
    if ([deviceString isEqualToString:@"iPhone5,1"])    return @"iPhone 5";
    if ([deviceString isEqualToString:@"iPhone5,2"])    return @"iPhone 5";
    if ([deviceString isEqualToString:@"iPhone5,3"])    return @"iPhone 5c";
    if ([deviceString isEqualToString:@"iPhone5,4"])    return @"iPhone 5c";
    
    if ([deviceString isEqualToString:@"iPhone6,1"])    return @"iPhone 5s";
    if ([deviceString isEqualToString:@"iPhone6,2"])    return @"iPhone 5s";
    
    if ([deviceString isEqualToString:@"iPhone7,1"])    return @"iPhone 6 Plus";
    if ([deviceString isEqualToString:@"iPhone7,2"])    return @"iPhone 6";
    if ([deviceString isEqualToString:@"iPhone8,1"])    return @"iPhone 6s";
    if ([deviceString isEqualToString:@"iPhone8,2"])    return @"iPhone 6s Plus";
    if ([deviceString isEqualToString:@"iPhone8,4"])    return @"iPhone SE";
    
    if ([deviceString isEqualToString:@"iPhone9,1"])    return @"iPhone 7";
    if ([deviceString isEqualToString:@"iPhone9,2"])    return @"iPhone 7 Plus";
    if ([deviceString isEqualToString:@"iPhone9,3"])    return @"iPhone 7";
    if ([deviceString isEqualToString:@"iPhone9,4"])    return @"iPhone Plus";
    
    if ([deviceString isEqualToString:@"iPhone10,1"])    return @"iPhone 8";
    if ([deviceString isEqualToString:@"iPhone10,2"])    return @"iPhone 8 Plus";
    if ([deviceString isEqualToString:@"iPhone10,3"])    return @"iPhone X global";
    if ([deviceString isEqualToString:@"iPhone10,4"])    return @"iPhone 8";
    if ([deviceString isEqualToString:@"iPhone10,5"])    return @"iPhone 8 Plus";
    if ([deviceString isEqualToString:@"iPhone10,6"])    return @"iPhone X GSM";
    
    if ([deviceString isEqualToString:@"iPhone11,2"])    return @"iPhone XS";
    if ([deviceString isEqualToString:@"iPhone11,4"])    return @"iPhone XS Max China";
    if ([deviceString isEqualToString:@"iPhone11,6"])    return @"iPhone XS Max";
    if ([deviceString isEqualToString:@"iPhone11,8"])    return @"iPhone XR";
    
    if ([deviceString isEqualToString:@"iPhone12,1"])    return @"iPhone 11";
    if ([deviceString isEqualToString:@"iPhone12,2"])    return @"iPhone 11 pro";
    if ([deviceString isEqualToString:@"iPhone12,5"])    return @"iPhone 11 pro Max";
    if([deviceString  isEqualToString:@"iPhone13,1"]) return @"iPhone 12 mini";
    if([deviceString  isEqualToString:@"iPhone13,2"]) return @"iPhone 12";
    if([deviceString isEqualToString:@"iPhone13,3"]) return @"iPhone 12 Pro";
    if([deviceString isEqualToString:@"iPhone13,4"]) return @"iPhone 12 Pro Max";
    return deviceString;
}

+ (CGFloat)safeBottom {
    if (@available(iOS 11.0, *)) {
        
        UIEdgeInsets temp = [[UIApplication sharedApplication].delegate.window safeAreaInsets];
        return temp.bottom;
    } else {
        return 0;
    }
}

+ (CGFloat)safeTop {
    if (@available(iOS 11.0, *)) {
        CGFloat temp = [[UIApplication sharedApplication].delegate.window safeAreaInsets].top;
        return (temp > 20) ? temp : 20;
    } else {
        return 20;
    }
}

+ (CGFloat)tabbarHeight {

    UIViewController *temp = [UIApplication sharedApplication].keyWindow.rootViewController;
    if ([temp isKindOfClass:[UITabBarController classForCoder]]) {
        UITabBarController *tab = (UITabBarController *)temp;
        return tab.tabBar.bounds.size.height;
    } else {
        return 49 + [self safeBottom];
    }
}
+ (UIUserInterfaceStyle)currentTraitCollectionStyle  API_AVAILABLE(ios(13.0)){
    return [UITraitCollection currentTraitCollection].userInterfaceStyle;
}

+ (BOOL)isPortrait {
    
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    return orientation == UIInterfaceOrientationPortrait;
}

+ (CGAffineTransform)getMBProgressHUDTransform {
    
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (orientation == UIInterfaceOrientationPortrait) {
        return CGAffineTransformMakeRotation(0);
    } else if (orientation == UIInterfaceOrientationLandscapeLeft) {
        return CGAffineTransformMakeRotation(M_PI * 3);
    } else if (orientation == UIInterfaceOrientationLandscapeRight) {
        return CGAffineTransformMakeRotation(M_PI);
    } else {
        return CGAffineTransformMakeRotation(0);
    }
}

@end
