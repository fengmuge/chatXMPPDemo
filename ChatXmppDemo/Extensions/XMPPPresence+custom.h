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
    LXPresenceTypeUnknow,
} LXPresenceType;

//进入一个房间 遇到的错误
typedef enum : NSUInteger {
    LXPresenceErrorPasswordWrong = 401, // 需要密码，或者密码错误
    LXPresenceErrorBeingBan = 403, // 用户被房间禁止了
    LXPresenceErrorRoomAbsent = 404, // 房间不存在
    LXPresenceErrorunregistration = 405, // 限制创建房间
    LXPresenceErrorUnallowChangeNick = 406, // 必须使用保留的群昵称，即不允许修改昵称
    LXPresenceErrorUnJoined = 407, // 用户不在成员列表中
    LXPresenceErrorNicknameUsing = 409, // 群昵称已被使用
    LXPresenceErrorOccupantsOverflow = 503, // 群用户数量达到最大,无法加入
    LXPresenceErrorUnknow = 1000, // 未知错误，需要额外处理
} LXPresenceErrorCode;

NS_ASSUME_NONNULL_BEGIN

@interface XMPPPresence (custom)

@property (nonatomic, assign) LXPresenceType presenceType;

@property (nonatomic, copy) NSString *showStr;

// 是否是来自聊天室的用户状态
- (BOOL)isRoomPresence;
// 整理遇到的error数据
- (void)sortPresenceError;

+ (XMPPPresence *)lxpresenceWithType:(LXPresenceType)type;
+ (XMPPPresence *)lxPresenceWithType:(LXPresenceType)type to:(nullable XMPPJID *)to;

- (instancetype)initWithPresenceType:(LXPresenceType)type;
- (instancetype)initWithPresenceType:(LXPresenceType)type to:(nullable XMPPJID *)to;

@end

NS_ASSUME_NONNULL_END
