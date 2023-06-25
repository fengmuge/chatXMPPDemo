//
//  RoomManager.h
//  ChatXmppDemo
//
//  Created by 苗培根 on 2023/6/5.
//

#import <Foundation/Foundation.h>

@class RoomConfiguration;

typedef enum : NSUInteger {
    LXRoomCachesBan,
    LXRoomCachesAdmin,
    LXRoomCachesOwner,
    LXRoomCachesModerator,
    LXRoomCachesMember,
} LXRoomCachesType;

NS_ASSUME_NONNULL_BEGIN

@interface RoomManager : NSObject

+ (RoomManager *)sharedInstance;
// 从服务端 获取加入或者公开的群聊
- (void)fetchJoinedRoomList;
// 整理获取到的群数据
- (void)sortJoinedRoonFetchedResult:(XMPPIQ *)iq;
// 向服务端 发送room缓存数据
- (void)configureRoom:(XMPPRoom *)room WithConfiguration:(RoomConfiguration *)configuration;

#pragma mark --本地缓存数据--
// 从缓存中 获取room的配置信息
- (RoomConfiguration *)getConfigurationWith:(XMPPRoom *)room;
// 向缓存中 添加room配置数据
- (void)setConfigurationCache:(RoomConfiguration *)configuration toRoom:(XMPPRoom *)room;
// 删除room缓存数据
- (void)removeConfigurationFromRoom:(XMPPRoom *)room;
// 根据type获取对应的缓存数据
- (NSArray <XMPPJID *> *)getRoomCacheWith:(XMPPRoom *)room type:(LXRoomCachesType)type;
// 根据type设置对应的缓存数据
- (void)setRoomCachesWith:(XMPPRoom *)room items:(NSArray *)items type:(LXRoomCachesType)type;
// 根据type清空对应的缓存数据
- (void)removeRoomCacheWith:(XMPPRoom *)room type:(LXRoomCachesType)type;
// 根据type向对应的缓存中添加特定数据
- (void)addCacheToRoom:(XMPPRoom *)room item:(XMPPJID *)item type:(LXRoomCachesType)type;
// 根据type从对应的缓存中删除特定的数据
- (void)removeCacheFromRoom:(XMPPRoom *)room item:(XMPPJID *)item type:(LXRoomCachesType)type;

@end

NS_ASSUME_NONNULL_END

