//
//  MessageManager.h
//  ChatXmppDemo
//
//  Created by 苗培根 on 2023/6/5.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MessageManager : NSObject

+ (MessageManager *)sharedInstance;

// 获取历史聊天记录
// toUserJid目标联系人jid,用于单聊
// toRoomJid目标聊天室jid，用于群聊
// 以上两个参数互斥，以toUserJid优先
+ (NSArray *)getHistoryMessageWith:(nullable XMPPJID *)toUserJid orRoomId:(nullable XMPPJID *)toRoomJid;

- (void)sendSignalingMessage:(NSString *)message toUser:(NSString *)userJid isVideoCall:(BOOL)isVideo;

@end

NS_ASSUME_NONNULL_END
