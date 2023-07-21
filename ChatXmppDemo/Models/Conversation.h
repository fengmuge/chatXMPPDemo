//
//  Conversation.h
//  ChatXmppDemo
//
//  Created by 苗培根 on 2023/7/20.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Conversation : NSObject

@property (nonatomic, assign) int index;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *content;

@property (nonatomic, assign) BOOL isTop;
@property (nonatomic, assign) BOOL isNoDisturbing;


// 测试数据
+ (NSMutableArray *)makeTestData;

@end

NS_ASSUME_NONNULL_END
