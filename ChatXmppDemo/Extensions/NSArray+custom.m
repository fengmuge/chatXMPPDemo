//
//  NSArray+custom.m
//  ChatXmppDemo
//
//  Created by 苗培根 on 2023/6/20.
//

#import "NSArray+custom.h"

@implementation NSArray (custom)

+ (BOOL)isEmpty:(NSArray *)array {
    return array == nil ||
           array.count == 0;
}

@end
