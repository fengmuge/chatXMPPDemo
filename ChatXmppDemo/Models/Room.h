//
//  Room.h
//  ChatXmppDemo
//
//  Created by 苗培根 on 2023/6/21.
//

#import <Foundation/Foundation.h>
@class RoomConfiguration;
NS_ASSUME_NONNULL_BEGIN

@interface Room : NSObject

@property (nonatomic, strong, readonly) XMPPRoom *room;
@property (nonatomic, strong, readonly) RoomConfiguration *configuration;
@property (nonatomic, strong, readonly) XMPPJID *roomJid;
@property (nonatomic, strong, readonly) XMPPJID *myRoomJid;
@property (nonatomic, copy, readonly) NSString *myRoomNickname;
@property (nonatomic, copy, readonly) NSString *subject;
@property (nonatomic, assign, readonly) BOOL isJoined;

// 测试数据,我还不知道subject是如何拿到的
@property (nonatomic, strong) NSString *roomName;

- (void)setRoom:(XMPPRoom *)room;
- (void)setConfiguration:(RoomConfiguration *)configuration;

@end

NS_ASSUME_NONNULL_END
