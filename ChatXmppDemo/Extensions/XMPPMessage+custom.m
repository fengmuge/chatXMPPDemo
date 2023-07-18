//
//  XMPPMessage+custom.m
//  ChatXmppDemo
//
//  Created by 苗培根 on 2023/6/27.
//

#import "XMPPMessage+custom.h"

@implementation XMPPMessage (custom)

// 是否是来自房间的邀请
- (BOOL)isRoomInvite {
    if (self.childCount > 0){
        for (NSXMLElement* element in self.children) {
            if (![element.name isEqualToString:@"x"] ||
                ![element.xmlns isEqualToString:@"http://jabber.org/protocol/muc#user"])
            {
                continue;
            }
            for (NSXMLElement *element_a in element.children) {
                if ([element_a.name isEqualToString:@"invite"]){
                    return YES;
                }
            }
        }
    }
    return NO;
}

- (NSXMLElement *)request {
    return [self elementForName:@"request"];
}

- (void)setRequest:(NSString *)request {
    NSXMLElement *receipt = [NSXMLElement elementWithName:@"request" xmlns:request];
    [self addChild:receipt];
}

- (LXMessageBodyType)bodyType {
    NSString *bodyTypeValue = self.attributesAsDictionary[@"bodyType"];
    if ([bodyTypeValue isEqualToString:@"text"]) {
        return LXMessageBodyText;
    } else if ([bodyTypeValue isEqualToString:@"audio"]) {
        return LXMessageBodyAudio;
    } else if ([bodyTypeValue isEqualToString:@"video"]) {
        return LXMessageBodyVideo;
    } else if ([bodyTypeValue isEqualToString:@"image"]) {
        return LXMessageBodyImage;
    } else if ([bodyTypeValue isEqualToString:@"videoCall"]) {
        return LXMessageBodyVideoCall;
    } else if ([bodyTypeValue isEqualToString:@"voiceCall"]) {
        return LXMessageBodyVoiceCell;
    }
    return LXMessageBodyCard;
}

- (void)setBodyType:(LXMessageBodyType)bodyType {
    NSString *bodyTypeValue = [self bodyTypeValueWith:bodyType];
    [self addAttributeWithName:@"bodyType" stringValue:bodyTypeValue];
}

- (NSString *)bodyTypeValueWith:(LXMessageBodyType)bodyType {
    switch (bodyType) {
        case LXMessageBodyText:
            return @"text";
        case LXMessageBodyAudio:
            return @"audio";
        case LXMessageBodyVideo:
            return @"video";
        case LXMessageBodyImage:
            return @"image";
        case LXMessageBodyVideoCall:
            return @"videoCall";
        case LXMessageBodyVoiceCell:
            return @"voiceCall";
        default:
            return @"card";
    }
}

@end
