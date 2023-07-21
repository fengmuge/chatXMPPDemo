//
//  Conversation.m
//  ChatXmppDemo
//
//  Created by 苗培根 on 2023/7/20.
//

#import "Conversation.h"

@implementation Conversation

+ (NSMutableArray *)makeTestData {
    NSMutableArray *arrays = [[NSMutableArray alloc] init];
    for (int i = 0; i < 30; i++) {
        Conversation *item = [[Conversation alloc] init];
        item.index = i;
        item.title = @"新增板块";
        if (i < 5) {
            item.content = @"";
        } else {
            item.content = @"测试测试测试测试";
        }
        
        [arrays addObject:item];
    }
    return arrays;
}

@end
