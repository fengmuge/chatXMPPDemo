//
//  LXCacheModel.m
//  ChatXmppDemo
//
//  Created by 苗培根 on 2023/7/5.
//
// 数据管理，目标是设置一个上限，比如10，超过10使用LRU方式进行管理，低于20则使用数组/字典的方式进行管理
// 其实可以效仿YYCache和SDCache,以缓存的数量和大小做为维度，增加一个disk缓存
#import "LXCacheModel.h"
#import "LRUCacheModel.h"

@interface LXCacheModel ()

@property (nonatomic, assign) BOOL isLRU; // 是否使用LRU算法保存数据

@property (nonatomic, strong) LRUCacheModel *lruCache; // lru model

@property (nonatomic, strong) NSMutableDictionary <NSString *, id> *caches; // 数量为达到上限时候的缓存

@end

@implementation LXCacheModel

- (NSInteger)curSize {
    if (!self.isLRU) {
        return self.caches.count;
    }
    return self.lruCache.curSize;
}

- (nullable id)getValueWith:(nonnull NSString *)key {
    if (self.isLRU) {
        return [self.lruCache getValueWith:key];
    }
    return self.caches[key];
}

- (NSArray *)getAllValue {
    if (self.isLRU) {
        return [self.lruCache getAllValue];
    }
    return [self.caches allValues];
}

- (void)putValue:(id)value withKey:(nonnull NSString *)key {
    if (self.isLRU) {
        [self.lruCache putValue:value withKey:key];
        return;
    }
    self.caches[key] = value;
    if (self.caches.count <= 10) {
        return;
    }
    [self.lruCache transformFrom:self.caches];
    [self.caches removeAllObjects];
}

- (void)removeValueWith:(NSString *)key {
    if (!self.isLRU) {
        [self.caches removeObjectForKey:key];
        return;
    }
    [self.lruCache removeValueWith:key];
    if (self.lruCache.curSize > 10) {
        return;
    }
    self.caches = [self.lruCache transformToDict].mutableCopy;
    self.lruCache = nil;
}

- (NSMutableDictionary<NSString *,id> *)caches {
    if (!_caches) {
        _caches = [[NSMutableDictionary alloc] init];
    }
    return _caches;
}

- (LRUCacheModel *)lruCache {
    if (!_lruCache) {
        _lruCache = [[LRUCacheModel alloc] initWithMaxSize:100];
    }
    return _lruCache;
}

- (void)clear {
    [self.caches removeAllObjects];
    [self.lruCache clear];
}

@end
