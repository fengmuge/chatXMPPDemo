//
//  XMPPJID+custom.m
//  ChatXmppDemo
//
//  Created by 苗培根 on 2023/6/13.
//

#import "XMPPJID+custom.h"
#import "User.h"
@implementation XMPPJID (custom)

// 配置jid
+ (XMPPJID *)lxJidWithUsername:(NSString *)username {
    return [XMPPJID jidWithUser:username domain:kDomin resource:kResource];
}

- (bool)isMy {
    XMPPJID *myJid = [UserManager sharedInstance].jid;
    if (!myJid) {
        return NO;
    }
    return [self isEqualToJID:myJid];
}

@end
