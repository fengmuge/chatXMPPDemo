//
//  XMPPJID+custom.h
//  ChatXmppDemo
//
//  Created by 苗培根 on 2023/6/13.
//

#import <XMPPFramework/XMPPFramework.h>

NS_ASSUME_NONNULL_BEGIN

@interface XMPPJID (custom)

// 配置jid
+ (XMPPJID *)lxJidWithUsername:(NSString *)username;

// 是否是用户自己
- (bool)isMy;

@end

NS_ASSUME_NONNULL_END
