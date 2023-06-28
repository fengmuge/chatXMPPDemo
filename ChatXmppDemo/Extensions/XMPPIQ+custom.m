//
//  XMPPIQ+custom.m
//  ChatXmppDemo
//
//  Created by 苗培根 on 2023/6/27.
//

#import "XMPPIQ+custom.h"

@implementation XMPPIQ (custom)

// 是否是获取联系人信息的请求
- (BOOL)isFetchRoster {
    if (self.childCount>0){
        for (NSXMLElement* element in self.children) {
            if ([element.name isEqualToString:@"query"] &&
                [element.xmlns isEqualToString:@"jabber:iq:roster"])
            {
                return YES;
            }
        }
    }
    return NO;
}
// 是否是获取房间列表的请求
- (BOOL)isFetchRoomList {
    if (self.childCount>0){
        for (NSXMLElement* element in self.children) {
            if ([element.name isEqualToString:@"query"] &&
                [element.xmlns isEqualToString:@"http://jabber.org/protocol/disco#items"]){
                return YES;
            }
        }
    }
    return NO;
}
// 是否是获取房间信息
- (BOOL)isFetchRoom {
    if (self.childCount>0){
        for (NSXMLElement* element in self.children) {
            if ([element.name isEqualToString:@"query"] &&
                [element.xmlns isEqualToString:@"http://jabber.org/protocol/disco#info"]){
                BOOL has_identity=NO;
                BOOL has_feature=NO;
                for (NSXMLElement* element_item in element.children) {
                    if ([element_item.name isEqualToString:@"identity"]){
                        has_identity=YES;
                    }
                    if ([element_item.name isEqualToString:@"feature"]){
                        has_feature=YES;
                    }
                }
                return has_identity && has_feature;
            }
        }
    }
    return NO;
}

@end
