//
//  LXCacheModel.h
//  ChatXmppDemo
//
//  Created by 苗培根 on 2023/7/5.
//
// 缓存，简单版本
// 本来想以YYCache或者SCache为目标写的，时间有限、精力有限，先这么写
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LXCacheModel : NSObject

@property (nonatomic, assign, readonly) NSInteger curSize;

- (nullable id)getValueWith:(nonnull NSString *)key;

- (NSArray *)getAllValue;

- (void)putValue:(id)value withKey:(nonnull NSString *)key;

- (void)removeValueWith:(NSString *)key;

- (void)clear;

@end

NS_ASSUME_NONNULL_END
