//
//  DDXMLElement+custom.m
//  ChatXmppDemo
//
//  Created by 苗培根 on 2023/6/12.
//

#import "DDXMLElement+custom.h"

@implementation DDXMLElement (custom)

- (NSString *)subscription {
    return [[self attributeForName:@"subscription"] stringValue];
}

- (void)setSubscription:(NSString *)subscription {}

- (LXSubscriptionType)subscriptionType {
    if ([self.subscription isEqualToString:@"both"]) {
        return LXSubscriptionBoth;
    } else if ([self.subscription isEqualToString:@"from"]) {
        return LXSubscriptionFrom;
    } else if ([self.subscription isEqualToString:@"to"]) {
        return LXSubscriptionTo;
    } else if ([self.subscription isEqualToString:@"remove"]) {
        return LXSubscriptionRemove;
    }
    return LXSubscriptionNone;
}

- (void)setSubscriptionType:(LXSubscriptionType)subscriptionType {}


- (void)addChildNonNull:(nullable DDXMLNode *)child {
    if (!child) {
        return;
    }
    [self addChild:child];
}

- (void)insertChildNonNull:(nullable DDXMLNode *)child atIndex:(NSUInteger)index {
    if (!child) {
        return;
    }
    [self insertChild:child atIndex:index];
}

@end
