//
//  DDXMLElement+custom.h
//  ChatXmppDemo
//
//  Created by 苗培根 on 2023/6/12.
//

#import <KissXML/KissXML.h>

//typedef enum {
//    LXSubscriptionBoth = 1<<0,
//    LXSubscriptionFrom = 1<<1,
//    LXSubscriptionTo = 1<<2,
//    LXSubscriptionRemove = 1<<3,
//    LXSubscriptionNone = 1<<4,
//} LXSubscriptionType;

typedef NS_OPTIONS(NSUInteger, LXSubscriptionType) {
    LXSubscriptionBoth = 1<<0,
    LXSubscriptionFrom = 1<<1,
    LXSubscriptionTo = 1<<2,
    LXSubscriptionRemove = 1<<3,
    LXSubscriptionNone = 1<<4,
};

NS_ASSUME_NONNULL_BEGIN

@interface DDXMLElement (custom)

@property (nonatomic, strong) NSString *subscription;

@property (nonatomic, assign) LXSubscriptionType subscriptionType;

- (void)addChildNonNull:(nullable DDXMLNode *)child;

- (void)insertChildNonNull:(nullable DDXMLNode *)child atIndex:(NSUInteger)index;

@end

NS_ASSUME_NONNULL_END
