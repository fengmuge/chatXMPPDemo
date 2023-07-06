//
//  RoomCacheModel.h
//  ChatXmppDemo
//
//  Created by 苗培根 on 2023/7/6.
//
// room 数据管理工具
#import <Foundation/Foundation.h>
@class Room;
@class RoomConfiguration;

typedef enum : NSUInteger {
    LXRoomCachesBan,
    LXRoomCachesAdmin,
    LXRoomCachesOwner,
    LXRoomCachesModerator,
    LXRoomCachesMember,
    LXRoomCachesConfigure,
    LXRoomCachesRoom,
} LXRoomCachesType;

NS_ASSUME_NONNULL_BEGIN

@interface RoomCacheModel : NSObject

@property (nonatomic, strong, readonly) NSMutableArray <Room *> *rooms;

#pragma mark --本地缓存数据--
// 缓存room信息
- (Room *)getRoomWith:(NSString *)roomJid;
// 设置/替换 room信息
- (void)setRoomWith:(Room *)room;
// 批量设置room信息
- (void)setRoomsWith:(NSArray <Room *> *)rooms;
// 删除room信息
- (void)removeRoom:(Room *)room;

// 从缓存中 获取room的配置信息
- (RoomConfiguration *)getConfigurationWith:(NSString *)roomJid;
// 向缓存中 添加room配置数据
- (void)setConfigurationCache:(RoomConfiguration *)configuration toRoom:(NSString *)roomJid;
// 删除room缓存数据
- (void)removeConfigurationFromRoom:(NSString *)roomJid;

#pragma mark --除配置和room之外的数据的操作--
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
