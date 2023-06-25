//
//  XMPPPresence+custom.m
//  ChatXmppDemo
//
//  Created by 苗培根 on 2023/6/9.
//

#import "XMPPPresence+custom.h"

@implementation XMPPPresence (custom)

+ (XMPPPresence *)lxpresenceWithType:(LXPresenceType)type {
    NSString *typeValue = [XMPPPresence presenceTypeValue:type];
    return [XMPPPresence presenceWithType:typeValue];
}
+ (XMPPPresence *)lxPresenceWithType:(LXPresenceType)type to:(nullable XMPPJID *)to {
    NSString *typeValue = [XMPPPresence presenceTypeValue:type];
    return [XMPPPresence presenceWithType:typeValue to:to];
}

- (instancetype)initWithPresenceType:(LXPresenceType)type {
    NSString *typeValue = [XMPPPresence presenceTypeValue:type];
    return [self initWithType:typeValue];
}
- (instancetype)initWithPresenceType:(LXPresenceType)type to:(nullable XMPPJID *)to {
    NSString *typeValue = [XMPPPresence presenceTypeValue:type];
    return [self initWithType:typeValue to:to];
}

- (LXPresenceType)presenceType {
    if ([self.type isEqualToString:@"available"]) {
        return LXPresenceTypeAvailabel;
    } else if ([self.type isEqualToString:@"unavailable"]) {
        return LXPresenceTypeUnavailable;
    } else if ([self.type isEqualToString:@"subscribe"]) {
        return LXPresenceTypeSubscribe;
    } else if ([self.type isEqualToString:@"subscribed"]) {
        return LXPresenceTypeSubscribed;
    } else if ([self.type isEqualToString:@"unsubscribe"]) {
        return LXPresenceTypeUnsubscribe;
    } else if ([self.type isEqualToString:@"unsubscribed"]) {
        return LXPresenceTypeUnsubscribed;
    }
    return LXPresenceTypeError;
}

- (void)setPresenceType:(LXPresenceType)presenceType {}

- (NSString *)showStr {
    switch (self.showValue) {
        case XMPPPresenceShowDND:
            return @"免打扰";
        case XMPPPresenceShowXA:
            return @"离开";
        case XMPPPresenceShowAway:
            return @"隐身";
        case XMPPPresenceShowChat:
            return @"在线";
        default:
            return @"其他状态";
    }
}

- (void)setShowStr:(NSString *)showStr {}

+ (NSString *)presenceTypeValue:(LXPresenceType)type {
    switch (type) {
        case LXPresenceTypeAvailabel:
            return @"available";
        case LXPresenceTypeUnavailable:
            return @"unavailable";
        case LXPresenceTypeSubscribe:
            return @"subscribe";
        case LXPresenceTypeSubscribed:
            return @"subscribed";
        case LXPresenceTypeUnsubscribe:
            return @"unsubscribe";
        case LXPresenceTypeUnsubscribed:
            return @"unsubscribed";
        default:
            return @"error";
    }
}

@end
