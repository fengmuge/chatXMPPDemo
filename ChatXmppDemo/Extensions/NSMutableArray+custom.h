//
//  NSMutableArray+custom.h
//  ChatXmppDemo
//
//  Created by 苗培根 on 2023/7/20.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSMutableArray (custom)

// 移除index位置的object并返回
- (id)removeItemAt:(NSUInteger)index;
//
- (id)removeLastItem;
- (id)removeFirstItem;


// 将位置from的object移动到位置to,from和to都是以0为开头的
// 且，from和to都是以数组的object未变化时候为准
- (void)moveItemFrom:(NSUInteger)from to:(NSUInteger)to;

@end

NS_ASSUME_NONNULL_END
