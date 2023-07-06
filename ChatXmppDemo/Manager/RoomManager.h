//
//  RoomManager.h
//  ChatXmppDemo
//
//  Created by 苗培根 on 2023/6/5.
//

#import <Foundation/Foundation.h>
@class Room;
@class RoomCacheModel;
@class RoomConfiguration;

NS_ASSUME_NONNULL_BEGIN

@interface RoomManager : NSObject

@property (nonatomic, strong, readonly) NSMutableArray <Room *> *rooms;
@property (nonatomic, strong, readonly) RoomCacheModel *cacheMode;

+ (RoomManager *)sharedInstance;
// 从服务端 获取加入或者公开的群聊
- (void)fetchJoinedRoomList;
// 整理获取到的关于群的数据 如: 群列表，群详细信息
- (void)sortIqForRoom:(XMPPIQ *)iq;
// 向服务端 发送room缓存数据
- (void)configureRoom:(XMPPRoom *)room WithConfiguration:(RoomConfiguration *)configuration;

@end

NS_ASSUME_NONNULL_END

