//
//  NSMutableArray+custom.m
//  ChatXmppDemo
//
//  Created by 苗培根 on 2023/7/20.
//

#import "NSMutableArray+custom.h"

@implementation NSMutableArray (custom)

- (id)removeItemAt:(NSUInteger)index {
    if (index >= self.count) {
        return nil;
    }
    id object = [self objectAtIndex:index];
    [self removeObjectAtIndex:index];
    return object;
}

- (id)removeLastItem {
    if (self.count == 0) {
        return nil;
    }
    id object = self.lastObject;
    [self removeLastObject];
    return object;
}

- (id)removeFirstItem {
    if (self.count == 0) {
        return nil;
    }
    id object = self.firstObject;
    [self removeObjectAtIndex:0];
    return object;
}

- (void)moveItemFrom:(NSUInteger)from to:(NSUInteger)to {
    NSUInteger count = self.count;
    if (from >= count || from == to) {
        return;
    }
    id object = [self removeItemAt:from];
    if (to >= count) {
        [self addObject:object];
    } else {
        [self insertObject:object atIndex:to];
    }
}


@end
