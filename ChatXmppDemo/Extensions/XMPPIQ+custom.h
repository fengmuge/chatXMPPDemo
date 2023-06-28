//
//  XMPPIQ+custom.h
//  ChatXmppDemo
//
//  Created by 苗培根 on 2023/6/27.
//

#import <XMPPFramework/XMPPFramework.h>

NS_ASSUME_NONNULL_BEGIN

@interface XMPPIQ (custom)

// 是否是获取联系人信息的请求
- (BOOL)isFetchRoster;
// 是否是获取房间列表的请求
- (BOOL)isFetchRoomList;
// 是否是获取房间信息
- (BOOL)isFetchRoom;

@end

NS_ASSUME_NONNULL_END
