//
//  globalDefine.h
//  iOSDevelopSDK
//
//  Created by Hayder on 2019/6/13.
//  Copyright © 2019 Hayder. All rights reserved.
//

#ifndef globalDefine_h
#define globalDefine_h

//#import "HHCategoryHeader.h"
//#import "HHNetworkAPI.h"
#import "HHDeviceTool.h"
//#import "RequestURLHeader.h"
//#import "BaseHeader.h"
//#import "DJ_UserInfoManager.h"
//#import "DJ_UMManager.h"
//#import "FMDBManager.h"


// openfire服务器IP地址
#define  kHostName      @"10.32.177.200"

//#define  kHostName      @"192.168.0.100"

// openfire服务器端口 默认5222
#define  kHostPort      5222
// openfire服务器名称
#define kDomin @"lxdev.cn"
// resource(资源)
#define kResource @"ios"
//
#define kSubdomain @"conference"
// rct room server url
#define kRTCRoomServer @""
// stun 服务器url
#define kRTCSTUNServer @""
// turn 服务器url
#define kRTCTURNServer @""

#pragma mark ---------------------打印----------------------------
#ifdef DEBUG // 调试状态, 打开LOG功能
#define NSLog(...) NSLog(__VA_ARGS__)
#else // 发布状态, 关闭LOG功能
#define NSLog(...)
#endif

#pragma mark ---------------------常规定义----------------------------

#define WS(weakSelf)  __weak __typeof(&*self)weakSelf = self;
//屏幕宽高
#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)
#define SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)
#define FlexW(width) (width)/375.0 * SCREEN_WIDTH
#define FlexH(height) (height)/667.0 * SCREEN_HEIGHT
//判断是否是ipad
#define kIsPad ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
#define IS_IPHONE_X ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125, 2436), [[UIScreen mainScreen] currentMode].size) && !kIsPad : NO)
//判断iPHoneXr
#define IS_IPHONE_Xr ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(828, 1792), [[UIScreen mainScreen] currentMode].size) && !kIsPad : NO)
//判断iPhoneXs
#define IS_IPHONE_Xs ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125, 2436), [[UIScreen mainScreen] currentMode].size) && !kIsPad : NO)
//判断iPhoneXs Max
#define IS_IPHONE_Xs_Max ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1242, 2688), [[UIScreen mainScreen] currentMode].size) && !kIsPad : NO)


//是否是全面屏
//#define KIsFullPhone ((IS_IPHONE_X==YES || IS_IPHONE_Xr ==YES || IS_IPHONE_Xs== YES || IS_IPHONE_Xs_Max== YES)?YES:NO)
#define KIsFullPhone [HHDeviceTool isFullScreenIphone]

//iPhoneX系列
#define StatusBar_Height [HHDeviceTool safeTop]
#define NavBar_Height 44 + StatusBar_Height
#define TabBar_Height [HHDeviceTool tabbarHeight]
#define KPhonexSafeBottomHeight [HHDeviceTool safeBottom]

#define Font(size) [UIFont systemFontOfSize:size]
#define BoldFont(size) [UIFont boldSystemFontOfSize:size]
#define SemiBoldFont(size) [UIFont systemFontOfSize:size weight:UIFontWeightSemibold]
#define RegularFont(size) [UIFont systemFontOfSize:size weight:UIFontWeightRegular]
#pragma mark ---------------------颜色----------------------------

#define kThemeColor ColorHexString(@"#051224")
#define kBlackColor ColorHexString(@"141414")
#define kBlueColor ColorHexString(@"00A7E4")
#define kLightGrayColor ColorHexString(@"F2F2F2")
#define kTextGrayColor ColorHexString(@"8f8f8f")
#define kWhiteColor ColorHexString(@"ffffff")
#define kLineColor ColorHexString(@"EFEFEF")
#define kYellowColor ColorHexString(@"#E4F53B")

#define RGBA(r,g,b,a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]

#define RGB(r,g,b) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1]

#define ColorHexString(colorString) [UIColor darkColorWithHexString:colorString]

// 51灰
#define kGray_51 [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0]
// 68灰
#define kGray_68 [UIColor colorWithRed:68.0/255.0 green:68.0/255.0 blue:68.0/255.0 alpha:1.0]
// 85灰
#define kGray_85 [UIColor colorWithRed:85.0/255.0 green:85.0/255.0 blue:85.0/255.0 alpha:1.0]
// 105灰
#define kGray_105 [UIColor colorWithRed:105.0/255.0 green:105.0/255.0 blue:105.0/255.0 alpha:1.0]
// 150灰
#define kGray_150 [UIColor colorWithRed:150.0/255.0 green:150.0/255.0 blue:150.0/255.0 alpha:1.0]
// 182灰
#define kGray_182 [UIColor colorWithRed:182.0/255.0 green:182.0/255.0 blue:182.0/255.0 alpha:1.0]
// 230灰
#define kGray_230 [UIColor colorWithRed:230.0/255.0 green:230.0/255.0 blue:230.0/255.0 alpha:1.0]


#pragma mark ---------------------系统信息----------------------------

#define iOSVersion  [[UIDevice currentDevice].systemVersion doubleValue]

// 是否为iOS9
#define kisiOS9 (iOSVersion >= 9.0)

// 是否为iOS10
#define kisiOS10 (iOSVersion >= 10.0)
// 是否为iOS11
#define kisiOS11 (iOSVersion >= 11.0)

#define SYSTME_VERSION_NEED_UPDATE @"目前仅支持iOS13.0以上系统使用苹果登录，请您先升级系统或更换其他方式登录"
#define isShowLoginKey @"showLogin"

#endif
