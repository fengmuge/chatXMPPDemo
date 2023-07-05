//
//  LRUCacheModel.h
//  ChatXmppDemo
//
//  Created by 苗培根 on 2023/7/5.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

// 限于OC的原因，使用NSObject；如果是swift或者go，可以使用结构体或者自定义类
@interface LRUNode : NSObject

@property (nonatomic, copy) NSString *key;
// 用来保存的是对象或者数组、字典，并非协议委托对象，所以使用strong修饰
@property (nonatomic, strong) id value;

@property (nonatomic, strong, nullable) LRUNode *next;
@property (nonatomic, strong, nullable) LRUNode *prev;

- (instancetype)initWithKey:(NSString *)key andValue:(id)value;
- (instancetype)initWithKey:(NSString *)key andValue:(id)value next:(LRUNode *)next prev:(LRUNode *)prev;

- (void)clear;

@end

@interface LRUCacheModel : NSObject

@property (nonatomic, assign, readonly) NSInteger curSize;

- (instancetype)initWithMaxSize:(NSInteger)maxSize;

- (nullable id)getValueWith:(nonnull NSString *)key;

- (void)putValue:(id)value withKey:(nonnull NSString *)key;

- (void)removeValueWith:(NSString *)key;
// 将存储的内容转换成字典
- (NSDictionary *)transformToDict;
// 将字典转换成链表
- (void)transformFrom:(NSDictionary *)dict;
// 清理
- (void)clear;

@end

NS_ASSUME_NONNULL_END
