//
//  HHDeviceTool.h
//  iOSDevelopSDK
//
//  Created by Hayder on 2019/6/13.
//  Copyright © 2019 Hayder. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HHDeviceTool : NSObject


/** 客户端类型 */
+ (NSString *)getClientType;

/** appstore download url */
+ (NSString *)getAppStoreUrl;

/** 设备名 */
+ (NSString *)getDeviceName;

/** 设备类型 */
+ (NSString *)getDeviceType;

/** 获取应用名 */
+ (NSString *)getAppName;

/** 获取安装的version，包含buildId */
+ (NSString *)getInstallIncludeBuildVersion;

/** 获取安装的version，不包含buildId */
+ (NSString *)getInstallVersion;

/** 设备系统类型 */
+ (NSString *)getDeviceOSType;

/** 设备系统版本号 */
+ (NSString *)getDeviceOSVersion;

/** 渠道 */
+ (NSString *)getAppSourceChannel;

/** build Identifier */
+ (NSString *)getBoundleId;
/** 手机型号*/
+ (NSString *)getCurrentDevice;
/**当前是否是竖屏模式*/
+ (BOOL)isPortrait;

+ (CGAffineTransform)getMBProgressHUDTransform;
/**当前设备是否是全面屏*/
+ (BOOL)isFullScreenIphone;
/**底部安全距离*/
+ (CGFloat)safeBottom;
/**顶部安全距离*/
+ (CGFloat)safeTop;
/**tabbarHeight*/
+ (CGFloat)tabbarHeight;
/**亮度模式*/
+ (UIUserInterfaceStyle)currentTraitCollectionStyle;

@end

