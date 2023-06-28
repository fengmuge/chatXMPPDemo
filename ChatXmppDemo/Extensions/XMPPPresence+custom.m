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

- (BOOL)isRoomPresence {
    if (self.childCount>0){
        for (NSXMLElement* element in self.children) {
            if ([element.name isEqualToString:@"x"] &&
                [element.xmlns isEqualToString:@"http://jabber.org/protocol/muc#user"])
                return YES;
        }
    }
    return NO;
}

/**
 *  例子： 需要输入密码的加入群聊，密码输入错误
 <presence xmlns="jabber:client" to="12312@lxdev.cn/ios" from="lxchat@conference.lxdev.cn/12312" type="error">
 *         <x xmlns="http://jabber.org/protocol/muc">
 *            <password>12</password>
 *         </x>
 *         <x xmlns="vcard-temp:x:update">
 *            <photo></photo>
 *         </x>
 *         <error code="401" type="auth">
 *             <not-authorized xmlns="urn:ietf:params:xml:ns:xmpp-stanzas"></not-authorized>
 *             <text xmlns="urn:ietf:params:xml:ns:xmpp-stanzas">You're not authorized to create or join the room.</text>
 *         </error>
 </presence>
 */
- (void)sortPresenceError {
    if (![self.type isEqualToString:@"error"]) {
        return;
    }
    NSString *from = self.from.bare;
    for (NSXMLElement *item in self.children) {
        if (![item.name isEqualToString:@"error"]) {
            continue;
        }
        NSInteger code = [item.attributesAsDictionary[@"code"] integerValue];
//        NSString *errorType = item.attributesAsDictionary[@"type"];
        NSString *message = [self errorCodeMessage:(LXPresenceErrorCode)code];
        [[NSNotificationCenter defaultCenter] postNotificationName:kXMPP_PRESENCEERROR_OF_GROUP
                                                            object:nil
                                                          userInfo:@{@"roomJid": from,
                                                                     @"message": message}
        ];
        break;
    }
}

- (NSString *)errorCodeMessage:(LXPresenceErrorCode)type {
    switch (type) {
        case LXPresenceErrorPasswordWrong:
            return @"请输入正确的密码";
        case LXPresenceErrorBeingBan:
            return @"您已被禁止进入此房间";
        case LXPresenceErrorRoomAbsent:
            return @"房间不存在或已被销毁";
        case LXPresenceErrorunregistration:
            return @"禁止创建新的房间";
        case LXPresenceErrorUnallowChangeNick:
            return @"禁止修改群昵称";
        case LXPresenceErrorUnJoined:
            return @"您已被移出群";
        case LXPresenceErrorNicknameUsing:
            return @"该昵称已经被使用了";
        case LXPresenceErrorOccupantsOverflow:
            return @"该群以达到最大人数，无法加入";
        default:
            return @"未知错误";
    }
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
    } else if ([self.type isEqualToString:@"error"]) {
        return LXPresenceTypeError;
    }
    return LXPresenceTypeUnknow;
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
