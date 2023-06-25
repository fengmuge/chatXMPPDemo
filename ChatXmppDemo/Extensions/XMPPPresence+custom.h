//
//  XMPPPresence+custom.h
//  ChatXmppDemo
//
//  Created by 苗培根 on 2023/6/9.
//

#import <XMPPFramework/XMPPFramework.h>

typedef enum : NSUInteger {
    LXPresenceTypeAvailabel, // 默认，用户空闲状态
    LXPresenceTypeUnavailable, // 用户忙碌中
    LXPresenceTypeSubscribe, // 请求添加别人为好友
    LXPresenceTypeSubscribed, // 同意别人对自己的好友请求
    LXPresenceTypeUnsubscribe, // 请求删除好友
    LXPresenceTypeUnsubscribed, // 拒绝对方的好友请求
    LXPresenceTypeError,  // 当前状态packet有错误
} LXPresenceType;


NS_ASSUME_NONNULL_BEGIN

@interface XMPPPresence (custom)

@property (nonatomic, assign) LXPresenceType presenceType;

@property (nonatomic, copy) NSString *showStr;

+ (XMPPPresence *)lxpresenceWithType:(LXPresenceType)type;
+ (XMPPPresence *)lxPresenceWithType:(LXPresenceType)type to:(nullable XMPPJID *)to;

- (instancetype)initWithPresenceType:(LXPresenceType)type;
- (instancetype)initWithPresenceType:(LXPresenceType)type to:(nullable XMPPJID *)to;

@end

NS_ASSUME_NONNULL_END
