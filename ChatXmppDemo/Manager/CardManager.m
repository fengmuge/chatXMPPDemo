//
//  CardManager.m
//  ChatXmppDemo
//
//  Created by 苗培根 on 2023/6/5.
//

#import "CardManager.h"
#import "ChatManager.h"

@interface CardManager () <
XMPPvCardAvatarStorage,
XMPPvCardTempModuleDelegate,
XMPPvCardAvatarDelegate
>

@end

@implementation CardManager

static CardManager *_sharedInstance;

+ (CardManager *)sharedInstance {
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


#pragma mark --XMPPvCardTempModuleDelegate--
// 获取到一个联系人的名片信息(如果存在多个，也会多次回调)
- (void)xmppvCardTempModule:(XMPPvCardTempModule *)vCardTempModule didReceivevCardTemp:(XMPPvCardTemp *)vCardTemp forJID:(XMPPJID *)jid {
    // 打印用户信息
    XMPPvCardTemp *temp = [[ChatManager sharedInstance].cardCoreDataStorage vCardTempForJID:jid xmppStream:[ChatManager sharedInstance].stream];
    NSLog(@"xmppvCardTempModule:didReceivevCardTemp:  cardTemp: %@", temp);
    
    [[UserManager sharedInstance] didReceivevCardTemp:vCardTemp
                                               forJID:jid];
}

// 获取card信息失败
- (void)xmppvCardTempModule:(XMPPvCardTempModule *)vCardTempModule failedToFetchvCardForJID:(XMPPJID *)jid error:(DDXMLElement *)error {
    NSLog(@"%s error: %@", __func__, [error description]);
    if (!error) {
        return;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:kXMPP_VCARDTEMPMODULE_DIDRECEIVE_VCARDTEMP
                                                        object:[NSNumber numberWithBool:NO]];
}

// 名片信息更新成功
- (void)xmppvCardTempModuleDidUpdateMyvCard:(XMPPvCardTempModule *)vCardTempModule {
    NSLog(@"%s", __func__);
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kXMPP_VCARDTEMPMODULE_DIDUPDATE_MY_VCARD
                                                        object:[NSNumber numberWithBool:YES]];
}

// 更新名片信息失败
- (void)xmppvCardTempModule:(XMPPvCardTempModule *)vCardTempModule failedToUpdateMyvCard:(DDXMLElement *)error {
    NSLog(@"%s", __func__);
    if (!error) {
        return;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:kXMPP_VCARDTEMPMODULE_DIDUPDATE_MY_VCARD
                                                        object:[NSNumber numberWithBool:NO]];
}

#pragma mark --XMPPvCardAvatarDelegate--
// 收到新的头像信息
- (void)xmppvCardAvatarModule:(XMPPvCardAvatarModule *)vCardTempModule didReceivePhoto:(UIImage *)photo forJID:(XMPPJID *)jid {
    [[UserManager sharedInstance] didReceivePhoto:photo forJID:jid];
}

//- (void)archiveMessage:(XMPPMessage *)message outgoing:(BOOL)isOutgoing xmppStream:(XMPPStream *)stream {
//
//}
//
//- (BOOL)configureWithParent:(XMPPMessageArchiving *)aParent queue:(dispatch_queue_t)queue {
//
//}

#pragma mark --XMPPvCardAvatarStorage--
//- (void)clearvCardTempForJID:(nonnull XMPPJID *)jid xmppStream:(nonnull XMPPStream *)stream {
//
//}
//
//- (nullable NSData *)photoDataForJID:(nonnull XMPPJID *)jid xmppStream:(nonnull XMPPStream *)stream {
//
//}
//
//- (nullable NSString *)photoHashForJID:(nonnull XMPPJID *)jid xmppStream:(nonnull XMPPStream *)stream {
//}

@end
