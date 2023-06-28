//
//  XMPPMessage+custom.h
//  ChatXmppDemo
//
//  Created by 苗培根 on 2023/6/27.
//

#import <XMPPFramework/XMPPFramework.h>

NS_ASSUME_NONNULL_BEGIN

@interface XMPPMessage (custom)

// 是否是来自房间的邀请
- (BOOL)isRoomInvite;

@end

NS_ASSUME_NONNULL_END
