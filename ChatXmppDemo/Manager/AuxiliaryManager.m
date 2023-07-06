//
//  AuxiliaryManager.m
//  ChatXmppDemo
//
//  Created by 苗培根 on 2023/6/5.
//

#import "AuxiliaryManager.h"
#import "ChatManager.h"

@interface AuxiliaryManager () <
XMPPReconnectDelegate,
XMPPAutoPingDelegate
>

@end

@implementation AuxiliaryManager

static AuxiliaryManager *_sharedInstance;

+ (AuxiliaryManager *)sharedInstance {
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

#pragma mark --XMPPReconnectDelegate--

// xmpp意外断开连接
- (void)xmppReconnect:(XMPPReconnect *)sender didDetectAccidentalDisconnect:(SCNetworkConnectionFlags)connectionFlags {
    if (connectionFlags == kSCNetworkFlagsConnectionRequired) {
        NSLog(@"xmpp意外断开连接");
    }
    XMPPJID *myJid = [[UserManager sharedInstance].jid copy];
    // 清空本地用户数据
    [[UserManager sharedInstance] clearAll];
    
//    [[ChatManager sharedInstance] connectToServerWithJID:myJid pasword:self.password type:LXConnectTypeLogin];
    // 重新进行认证
    NSError *error;
    [[ChatManager sharedInstance].stream authenticateWithPassword:[UserManager sharedInstance].password error:&error];
    if (error) {
        NSLog(@"%s \n authenticateWithPassword:error: %@", __func__, [error localizedDescription]);
    }
}

- (BOOL)xmppReconnect:(XMPPReconnect *)sender shouldAttemptAutoReconnect:(SCNetworkConnectionFlags)connectionFlags {
    return YES;
}

#pragma mark -- XMPPAutoPingDelegate--
- (void)xmppAutoPingDidSendPing:(XMPPAutoPing *)sender {
    NSLog(@"%s", __func__);
}

- (void)xmppAutoPingDidReceivePong:(XMPPAutoPing *)sender {
    NSLog(@"%s", __func__);
}

- (void)xmppAutoPingDidTimeout:(XMPPAutoPing *)sender {
    NSLog(@"%s", __func__);
}


@end
