//
//  Room.m
//  ChatXmppDemo
//
//  Created by 苗培根 on 2023/6/21.
//

#import "Room.h"
//#import "R"
@interface Room ()

@property (nonatomic, strong, readwrite) XMPPRoom *room;
@property (nonatomic, strong, readwrite) RoomConfiguration *configuration;

@end

@implementation Room

- (void)setRoom:(XMPPRoom *)room {
    self.room = room;
}

- (void)setConfiguration:(RoomConfiguration *)configuration {
    self.configuration = configuration;
}

- (XMPPJID *)roomJid {
    return self.room.roomJID;
}

- (XMPPJID *)myRoomJid {
    return self.room.myRoomJID;
}

- (NSString *)myRoomNickname {
    return self.room.myNickname;
}

- (NSString *)subject {
    return self.room.roomSubject;
}

- (BOOL)isJoined {
    return self.room.isJoined;
}

@end
