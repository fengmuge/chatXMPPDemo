//
//  RTCRoom.m
//  ChatXmppDemo
//
//  Created by 苗培根 on 2023/7/17.
//

#import "RTCRoom.h"

@implementation RTCRoomParam

@end

@implementation RTCRoom

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"params": RTCRoomParam.class};
}

@end
