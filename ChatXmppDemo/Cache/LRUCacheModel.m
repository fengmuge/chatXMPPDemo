//
//  LRUCacheModel.m
//  ChatXmppDemo
//
//  Created by 苗培根 on 2023/7/5.
//

#import "LRUCacheModel.h"

@implementation LRUNode

- (instancetype)initWithKey:(NSString *)key andValue:(id)value {
    if (self = [super init]) {
        self.key = key;
        self.value = value;
    }
    return self;
}

- (instancetype)initWithKey:(NSString *)key andValue:(id)value next:(LRUNode *)next prev:(LRUNode *)prev {
    if (self = [super init]) {
        self.key = key;
        self.value = value;
        self.next = next;
        self.prev = prev;
    }
    return self;
}

//- (void)clear {
//    self.key = nil;
//    self.value = nil;
//    self.next = nil;
//    self.prev = nil;
//}

@end

@interface LRUCacheModel ()

@property (nonatomic, assign) NSInteger maxSize;
@property (nonatomic, assign, readwrite) NSInteger curSize;

@property (nonatomic, strong) LRUNode *header;
@property (nonatomic, strong) LRUNode *tail;

@property (nonatomic, strong) NSMutableDictionary <NSString *, LRUNode *> *caches;

@end

@implementation LRUCacheModel

- (instancetype)initWithMaxSize:(NSInteger)maxSize {
    if (self = [super init]) {
        self.maxSize = maxSize;
    }
    return self;
}

- (id)getValueWith:(NSString *)key {
    LRUNode *node = self.caches[key];
    if (node) {
        [self moveToHead:node];
    }
    return node.value;
}

- (void)putValue:(id)value withKey:(NSString *)key {
    LRUNode *node = self.caches[key];
    if (!node) {
        node = [[LRUNode alloc] initWithKey:key andValue:value];
        [self addNode:node];
        self.caches[key] = node;
        self.curSize += 1;
        if (self.curSize <= self.maxSize) {
            return;
        }
        [self removeTail];
        self.curSize -= 1;
    } else {
        node.value = value;
        [self moveToHead:node];
    }
}

- (void)removeValueWith:(NSString *)key {
    LRUNode *node = self.caches[key];
    if (!node) {
        return;
    }
    [self removeNode:node];
    [self.caches removeObjectForKey:key];
    self.curSize -= 1;
}

// 添加节点到头部
- (void)addNode:(LRUNode *)node {
    if (!self.header) {
        self.header = node;
        self.tail = node;
    } else {
        LRUNode *temp = self.header;
        self.header = node;
        self.header.next = temp;
        temp.prev = self.header;
    }
}

// 移动节点到头部
- (void)moveToHead:(LRUNode *)node {
    if ([node isEqual:self.header]) {
        return;
    }
    [self removeNode:node];
    
    LRUNode *temp = self.header;
    self.header = node;
    self.header.next = temp;
    temp.prev = self.header;
}

// 删除节点
- (void)removeNode:(LRUNode *)node {
    LRUNode *prev = node.prev;
    LRUNode *next = node.next;
    prev.next = next;
    if (!next) {
        self.tail = prev;
    } else {
        next.prev = prev;
    }
}

// 删除尾部
- (nullable LRUNode *)removeTail {
    if (!self.tail) {
        return nil;
    }
    [self.caches removeObjectForKey:self.tail.key];
    self.tail = self.tail.prev;
    self.tail.next = nil;
    return self.tail;
}

- (NSDictionary *)transformToDict {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    LRUNode *temp = self.header;
    while (temp) {
        dict[temp.key] = temp.value;
        temp = temp.next;
    }
    return dict;
}

- (void)transformFrom:(NSDictionary *)dict {
    NSArray <NSString *> *allKeys = dict.allKeys;
    for (NSString *key in allKeys) {
        LRUNode *temp = [[LRUNode alloc] initWithKey:key andValue:dict[key]];
        [self addNode:temp];
    }
    return;
}

// 其实我在想，需不需要将链表内的节点依次释放，毕竟，虽然ARC会将引用计数为0的对象自动释放，但是并不是立即释放。
// 如果链表内存储的节点数量太大，也是会导致部分内存浪费的
- (void)clear {
    self.maxSize = 0;
    [self.caches removeAllObjects];
    self.header = nil;
    self.tail = nil;
    self.curSize = 0;
}

@end
