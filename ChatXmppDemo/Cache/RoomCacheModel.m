//
//  RoomCacheModel.m
//  ChatXmppDemo
//
//  Created by 苗培根 on 2023/7/6.
//

#import "Room.h"
#import "LXCacheModel.h"
#import "RoomCacheModel.h"
#import "RoomConfiguration.h"

@interface RoomCacheModel ()

@property (nonatomic, strong) LXCacheModel *banCache;
@property (nonatomic, strong) LXCacheModel *adminCache;
@property (nonatomic, strong) LXCacheModel *ownerCache;
@property (nonatomic, strong) LXCacheModel *memberCache;
@property (nonatomic, strong) LXCacheModel *moderatorCache;
@property (nonatomic, strong) LXCacheModel *configureCache;
@property (nonatomic, strong) LXCacheModel *roomCache;

@end

@implementation RoomCacheModel

- (NSMutableArray<Room *> *)rooms {
    if (self.roomCache.curSize == 0) {
        return nil;
    }
    return [self.roomCache getAllValue].mutableCopy;
}

#pragma mark --本地数据--
- (Room *)getRoomWith:(NSString *)roomJid {
    return (Room *)[self.roomCache getValueWith:roomJid];
}

- (void)setRoomWith:(Room *)room {
    [self.roomCache putValue:room withKey:room.roomJidvalue];
}

- (void)setRoomsWith:(NSArray<Room *> *)rooms {
    [self.roomCache clear];
    for (Room *item in rooms) {
        [self.roomCache putValue:item withKey:item.roomJidvalue];
    }
}

- (void)removeRoom:(Room *)room {
    [self.roomCache removeValueWith:room.roomJidvalue];
}

- (RoomConfiguration *)getConfigurationWith:(NSString *)roomJid {
    return (RoomConfiguration *)[self.configureCache getValueWith:roomJid];
}

- (void)setConfigurationCache:(RoomConfiguration *)configuration toRoom:(NSString *)roomJid {
    [self.configureCache putValue:configuration withKey:roomJid];
}

- (void)removeConfigurationFromRoom:(NSString *)roomJid {
    [self.configureCache removeValueWith:roomJid];
}

- (NSArray <XMPPJID *> *)getRoomCacheWith:(NSString *)roomJid type:(LXRoomCachesType)type {
    LXCacheModel *cacheModel = [self fliterCaches:type];
    return [(NSMutableArray *)[cacheModel getValueWith:roomJid] copy];
}

- (void)setRoomCachesWith:(NSString *)roomJid items:(NSArray *)items type:(LXRoomCachesType)type {
    LXCacheModel *cacheModel = [self fliterCaches:type];
    [cacheModel putValue:[items mutableCopy] withKey:roomJid];
}

- (void)removeRoomCacheWith:(NSString *)roomJid type:(LXRoomCachesType)type {
    LXCacheModel *cacheModel = [self fliterCaches:type];
    [cacheModel removeValueWith:roomJid];
}

// 添加，如果已经存在，那么更新
- (void)addCacheToRoom:(NSString *)roomJid item:(XMPPJID *)item type:(LXRoomCachesType)type {
    LXCacheModel *cacheModel = [self fliterCaches:type];
    NSMutableArray *cacheItems = (NSMutableArray *)[cacheModel getValueWith:roomJid]; // [self fliterCacheItemsForRoom:roomJid inCache:caches];
    XMPPJID *localItem = [self fliterJid:item inCaches:cacheItems];
    if (!localItem) {
        [cacheItems addObject:item];
    } else {
        NSInteger index = [cacheItems indexOfObject:localItem];
        [cacheItems insertObject:item atIndex:index];
        [cacheItems removeObject:localItem];
    }
}

- (void)removeCacheFromRoom:(NSString *)roomJid item:(XMPPJID *)item type:(LXRoomCachesType)type {
    LXCacheModel *cacheModel = [self fliterCaches:type];
    NSMutableArray *caches = (NSMutableArray *)[cacheModel getValueWith:roomJid];
    XMPPJID *localItem = [self fliterJid:item inCaches:caches];
    if (!localItem) {
        return;
    }
    [caches removeObject:localItem];
    
    if (![NSArray isEmpty:caches]) {
        return;
    }
    [cacheModel removeValueWith:roomJid];
}

- (LXCacheModel *)fliterCaches:(LXRoomCachesType)type {
    switch (type) {
        case LXRoomCachesBan:
            return self.banCache;
        case LXRoomCachesAdmin:
            return self.adminCache;
        case LXRoomCachesOwner:
            return self.ownerCache;
        case LXRoomCachesMember:
            return self.memberCache;
        case LXRoomCachesModerator:
            return self.moderatorCache;
        case LXRoomCachesConfigure:
            return self.configureCache;
        default:
            return self.roomCache;
    }
}

- (NSMutableArray *)fliterCacheItemsForRoom:(NSString *)roomJid inCache:(NSMutableDictionary *)caches {
    if (caches[roomJid] != nil) {
        return caches[roomJid];
    }
    NSMutableArray *cacheItems = [[NSMutableArray alloc] init];
    caches[roomJid] = cacheItems;
    return cacheItems;
}

// 从缓存的数据中找到目标用户
- (XMPPJID *)fliterJid:(XMPPJID *)jid inCaches:(NSMutableArray *)cacheItems {
    for (XMPPJID *item in cacheItems) {
        if (![jid.user isEqualToString:item.user] ||
            ![jid.domain isEqualToString:item.domain]) {
            continue;
        }
        return item;
    }
    return nil;
}

#pragma mark --setter/getter--

- (LXCacheModel *)banCache {
    if (!_banCache) {
        _banCache = [[LXCacheModel alloc] init];
    }
    return _banCache;
}

- (LXCacheModel *)adminCache {
    if (!_adminCache) {
        _adminCache = [[LXCacheModel alloc] init];
    }
    return _adminCache;
}

- (LXCacheModel *)ownerCache {
    if (!_ownerCache) {
        _ownerCache = [[LXCacheModel alloc] init];
    }
    return _ownerCache;
}

- (LXCacheModel *)memberCache {
    if (!_memberCache) {
        _memberCache = [[LXCacheModel alloc] init];
    }
    return _memberCache;
}

- (LXCacheModel *)moderatorCache {
    if (!_moderatorCache) {
        _moderatorCache = [[LXCacheModel alloc] init];
    }
    return _moderatorCache;
}

- (LXCacheModel *)configureCache {
    if (!_configureCache) {
        _configureCache = [[LXCacheModel alloc] init];
    }
    return _configureCache;
}

- (LXCacheModel *)roomCache {
    if (!_roomCache) {
        _roomCache = [[LXCacheModel alloc] init];
    }
    return _roomCache;
}

@end
