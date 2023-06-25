//
//  UIAlertController+custom.m
//  ChatXmppDemo
//
//  Created by 苗培根 on 2023/6/13.
//

#import "UIAlertController+custom.h"

@implementation UIAlertController (custom)

#if __IPHONE_OS_VERSION_MAX_ALLOWED < 90000
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}
#else
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}
#endif

@end
