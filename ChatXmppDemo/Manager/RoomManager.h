//
//  RoomManager.h
//  ChatXmppDemo
//
//  Created by 苗培根 on 2023/6/5.
//

#import <Foundation/Foundation.h>
@class Room;
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

@property (nonatomic, strong, readonly) NSMutableArray <Room *> *rooms;

+ (RoomManager *)sharedInstance;
// 从服务端 获取加入或者公开的群聊
- (void)fetchJoinedRoomList;
// 整理获取到的关于群的数据 如: 群列表，群详细信息
- (void)sortIqForRoom:(XMPPIQ *)iq;
// 向服务端 发送room缓存数据
- (void)configureRoom:(XMPPRoom *)room WithConfiguration:(RoomConfiguration *)configuration;

#pragma mark --本地缓存数据--
// 缓存room信息
- (Room *)getRoomWith:(NSString *)roomJid;
// 设置/替换 room信息
- (void)setRoomWith:(Room *)room;
// 删除room信息
- (void)removeRoom:(Room *)room;
// 从缓存中 获取room的配置信息
- (RoomConfiguration *)getConfigurationWith:(NSString *)roomJid;
// 向缓存中 添加room配置数据
- (void)setConfigurationCache:(RoomConfiguration *)configuration toRoom:(NSString *)roomJid;
// 删除room缓存数据
- (void)removeConfigurationFromRoom:(NSString *)roomJid;
// 根据type获取对应的缓存数据
- (NSArray <XMPPJID *> *)getRoomCacheWith:(NSString *)roomJid type:(LXRoomCachesType)type;
// 根据type设置对应的缓存数据
- (void)setRoomCachesWith:(NSString *)roomJid items:(NSArray *)items type:(LXRoomCachesType)type;
// 根据type清空对应的缓存数据
- (void)removeRoomCacheWith:(NSString *)roomJid type:(LXRoomCachesType)type;
// 根据type向对应的缓存中添加特定数据
- (void)addCacheToRoom:(NSString *)roomJid item:(XMPPJID *)item type:(LXRoomCachesType)type;
// 根据type从对应的缓存中删除特定的数据
- (void)removeCacheFromRoom:(NSString *)roomJid item:(XMPPJID *)item type:(LXRoomCachesType)type;

@end

NS_ASSUME_NONNULL_END

