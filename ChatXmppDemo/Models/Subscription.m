//
//  Subscription.m
//  ChatXmppDemo
//
//  Created by 苗培根 on 2023/6/13.
//

#import "Subscription.h"

@interface Subscription () {
    LXSubscriptionResult _result;
}

@end

@implementation Subscription
@synthesize result = _result;

- (instancetype)init {
    self = [super init];
    if (self) {
    }
    return self;
}

- (instancetype)initWithJid:(XMPPJID *)jid {
    self = [super init];
    if (self) {
        self.jid = jid;
        self.result = LXSubscriptionResultPending;
        self.receivedDate = [NSDate date]; // 添加收到订阅请求的时间
    }
    return self;
}

- (LXSubscriptionResult)result {
    // 如果已经过期
    if ([self isExpire]) {
        return LXSubscriptionResultExpire;
    }
    //
    if (_result) {
        return _result;
    }
    // 如果本地没有保存，那么返回待处理
    return LXSubscriptionResultPending;
}

- (void)setResult:(LXSubscriptionResult)result {
    _result = result;
}

// 判断请求是否已经过期
// 目前设置为保存3天
- (bool)isExpire{
    if (!self.receivedDate) {
        return NO;
    }
    // 还不知道这俩哪个好用
//    NSInteger receivedDay = [[NSCalendar currentCalendar] component:NSCalendarUnitDay fromDate:self.receivedDate];
//    NSInteger today = [[NSCalendar currentCalendar] component:NSCalendarUnitDay fromDate:[NSDate date]];
//    return today - receivedDay > 3;
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSCalendarUnit type = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay;
    // 利用日历比较两个时间的差
    NSDateComponents *cmps = [calendar components:type fromDate:self.receivedDate toDate:[NSDate date] options:0];
    return cmps.year > 0 || cmps.month > 0 || cmps.day > 3;
}

@end
