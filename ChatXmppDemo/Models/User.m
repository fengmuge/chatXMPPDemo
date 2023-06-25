//
//  User.m
//  ChatXmppDemo
//
//  Created by 苗培根 on 2023/6/8.
//

#import "User.h"

@implementation User

- (NSString *)name {
    if (self.vCard.nickname) {
        return self.vCard.nickname;
    }
    return self.jid.user;
}

@end
