//
//  Subscription.h
//  ChatXmppDemo
//
//  Created by 苗培根 on 2023/6/13.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    LXSubscriptionResultPending, // 待处理
    LXSubscriptionResultAgree, // 同意
    LXSubscriptionResultRefuse, // 拒绝
    LXSubscriptionResultExpire, // 过期
} LXSubscriptionResult;

NS_ASSUME_NONNULL_BEGIN

@interface Subscription : NSObject

@property (nonatomic, strong) XMPPJID *jid;

@property (nonatomic, strong) NSDate *receivedDate; // 收到订阅请求的日期

@property (nonatomic, assign) LXSubscriptionResult result;

- (instancetype)initWithJid:(XMPPJID *)jid;

@end

NS_ASSUME_NONNULL_END
