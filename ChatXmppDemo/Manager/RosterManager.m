//
//  RosterManager.m
//  ChatXmppDemo
//
//  Created by 苗培根 on 2023/6/5.
//

#import "RosterManager.h"

@interface RosterManager () <
XMPPRosterDelegate,
XMPPRosterMemoryStorageDelegate
//XMPPRosterStorage,
>

@end

@implementation RosterManager

static RosterManager *_sharedInstance;

+ (RosterManager *)sharedInstance {
    return [[self alloc] init];
}

- (instancetype)init {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [super init];
    });
    return _sharedInstance;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [super allocWithZone:zone];
    });
    return _sharedInstance;
}


- (nonnull id)copyWithZone:(nullable NSZone *)zone {
    return _sharedInstance;
}

- (nonnull id)mutableCopyWithZone:(nullable NSZone *)zone {
    return _sharedInstance;
}

#pragma mark --XMPPRosterDelegate--
// 收到订阅请求
- (void)xmppRoster:(XMPPRoster *)sender didReceivePresenceSubscriptionRequest:(XMPPPresence *)presence {
    [[UserManager sharedInstance] addSubscribesWith:presence.from];
    
//    //示例代码，接受或拒绝好友请求
//    // 添加好友一定会订阅对方，但是接受订阅不一定要添加对方为好友
//    UIViewController *currentVC = [UIViewController currentVC];
//    [currentVC alertWithTitle: [NSString stringWithFormat:@"%@申请成为你的好友", presence.from.bare]
//                      message:nil
//                actionHandler:^(bool allow) {
//        if (allow) {
//            // 接收并添加到联系人
//            [self.roster acceptPresenceSubscriptionRequestFrom:presence.from andAddToRoster:YES];
//        } else {
//            // 拒绝
//            [self.roster rejectPresenceSubscriptionRequestFrom:presence.from];
//        }
//    }];
}

//// 开始同步服务器发送过来的自己的好友列表
//- (void)xmppRosterDidBeginPopulating:(XMPPRoster *)sender withVersion:(NSString *)version {
//}

// 自己主动添加好友，被动同意添加好友或者自己被好友删除时候会收到推送
- (void)xmppRoster:(XMPPRoster *)sender didReceiveRosterPush:(XMPPIQ *)iq {
    
}

// 好友信息获取完毕
- (void)xmppRosterDidEndPopulating:(XMPPRoster *)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:kXMPP_ROSTER_DIDEND_POPULATING object:nil];
}

// 获取到一个好友节点（如果有多个好友，会多次回调）
- (void)xmppRoster:(XMPPRoster *)sender didReceiveRosterItem:(DDXMLElement *)item {
    NSLog(@"%s: %@", __func__, item);
    
    NSString *jidStr = [[item attributeForName:@"jid"] stringValue];
    XMPPJID *jid = [XMPPJID jidWithString:jidStr];
    // 好友，被订阅，订阅了对方
    if (item.subscriptionType & LXSubscriptionBoth ||
        item.subscriptionType & LXSubscriptionFrom ||
        item.subscriptionType & LXSubscriptionTo) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kXMPP_ROSTER_DIDRECEIVE_ROSTERITEM
                                                            object:nil
                                                          userInfo:@{@"isRemove": [NSNumber numberWithBool:NO],
                                                                     @"jid": jid}];
    }
    if (item.subscriptionType == LXSubscriptionRemove) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kXMPP_ROSTER_DIDRECEIVE_ROSTERITEM
                                                            object:nil
                                                          userInfo:@{@"isRemove": [NSNumber numberWithBool:YES],
                                                                     @"jid": jid}];
    }
}

// 因为使用了XMPPRosterCoreDataStorage而非XMPPRosterMemoryStorage，所以XMPPRosterMemoryStorageDelegate目前是无效的
#pragma mark --XMPPRosterMemoryStorageDelegate--
// 如果不是初试化同步来的roster，自动存入我的好友存储器
- (void)xmppRosterDidChange:(XMPPRosterMemoryStorage *)sender {
    
}

- (void)xmppRosterDidPopulate:(XMPPRosterMemoryStorage *)sender {
    
}

- (void)xmppRoster:(XMPPRosterMemoryStorage *)sender didAddUser:(XMPPUserMemoryStorageObject *)user {
    
}

- (void)xmppRoster:(XMPPRosterMemoryStorage *)sender didUpdateUser:(XMPPUserMemoryStorageObject *)user {
    
}

- (void)xmppRoster:(XMPPRosterMemoryStorage *)sender didRemoveUser:(XMPPUserMemoryStorageObject *)user {
    
}

- (void)xmppRoster:(XMPPRosterMemoryStorage *)sender didAddResource:(XMPPResourceMemoryStorageObject *)resource withUser:(XMPPUserMemoryStorageObject *)user {
    
}

- (void)xmppRoster:(XMPPRosterMemoryStorage *)sender didUpdateResource:(XMPPResourceMemoryStorageObject *)resource withUser:(XMPPUserMemoryStorageObject *)user {
    
}

- (void)xmppRoster:(XMPPRosterMemoryStorage *)sender didRemoveResource:(XMPPResourceMemoryStorageObject *)resource withUser:(XMPPUserMemoryStorageObject *)user {
    
}

@end
