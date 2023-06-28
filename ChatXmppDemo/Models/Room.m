//
//  Room.m
//  ChatXmppDemo
//
//  Created by 苗培根 on 2023/6/21.
//

#import "Room.h"
#import "RoomManager.h"
#import "RoomConfiguration.h"

//@interface RoomField ()
//
//@property (nonatomic, copy) NSString *var;
//@property (nonatomic, copy) NSString *type;
//@property (nonatomic, copy) NSString *label;
//@property (nonatomic, copy) NSString *value;
//
//@end
//
//@implementation RoomField
//
//- (nonnull instancetype)initWithVar:(nonnull NSString *)var type:(nonnull NSString *)type label:(nonnull NSString *)label value:(nonnull NSString *)value {
//    if (self = [super init]) {
//        self.var = var;
//        self.type = type;
//        self.label = label;
//        self.value = value;
//    }
//    return self;
//}
//
//- (LXRoomInfoFieldType)fieldType {
//    if ([self.var isEqualToString:@"muc#roominfo_description"]) {
//        return LXRoomInfoFieldDesc;
//    } else if ([self.var isEqualToString:@"muc#roominfo_subject"]) {
//        return LXRoomInfoFieldSubject;
//    } else if ([self.var isEqualToString:@"muc#roominfo_occupants"]) {
//        return LXRoomInfoFieldOccupants;
//    } else if ([self.var isEqualToString:@"x-muc#roominfo_creationdate"]) {
//        return LXRoomInfoFieldCreateDate;
//    } else if ([self.var isEqualToString:@"FORM_TYPE"]) {
//        return LXRoomInfoFieldFormType;
//    }
//    return LXRoomInfoFieldUnknow;
//}
//
//- (NSString *)infoValue {
//    return self.value;
//}
//
//@end

@interface Room () {
    XMPPRoom *_room;
    DDXMLElement *_xmlElement;
    RoomConfiguration *_configuration;
}

@property (nonatomic, strong, readwrite) XMPPRoom *room;
@property (nonatomic, strong, readwrite) DDXMLElement *xmlElement;
@property (nonatomic, strong, readwrite) RoomConfiguration *configuration;

@property (nonatomic, copy, readwrite) NSString *category; // 类别
@property (nonatomic, copy, readwrite) NSString *type; // 类型
@property (nonatomic, copy, readwrite) NSString *subject;
@property (nonatomic, copy, readwrite) NSString *createTime; //

@property (nonatomic, assign, readwrite) int occupants; // 使用者数量

@property (nonatomic, assign, readwrite) BOOL isFetchDetail;

@end

@implementation Room
@synthesize room = _room;
@synthesize xmlElement = _xmlElement;
@synthesize configuration = _configuration;

- (void)setRoom:(XMPPRoom *)room {
    _room = room;
}

- (void)removeRoom {
    [_room deactivate];
    [_room removeDelegate:[RoomManager sharedInstance]];
    _room = nil;
}

- (void)setXmlElement:(DDXMLElement *)xmlElement {
    _xmlElement = xmlElement;
}

- (void)setConfiguration:(RoomConfiguration *)configuration {
    _configuration = configuration;
}

- (RoomConfiguration *)configuration {
    if (_configuration) {
        return _configuration;
    }
    RoomConfiguration *config = [[RoomManager sharedInstance] getConfigurationWith:self.roomJidvalue];
    if (!config) {
        config = [[RoomConfiguration alloc] init];
        [[RoomManager sharedInstance] setConfigurationCache:config
                                                     toRoom:self.roomJidvalue];
    }
    _configuration = config;
    return _configuration;
}

// --- iq 数据样例 ---
/**
 <iq xmlns="jabber:client" type="result" id="disco-1" from="lx@conference.lxdev.cn" to="12312@lxdev.cn/ios">
     <query xmlns="http://jabber.org/protocol/disco#info">
            <identity category="conference" name="lx" type="text"></identity>
            <feature var="http://jabber.org/protocol/muc"></feature>
            <feature var="muc_public"></feature>
            <feature var="muc_membersonly"></feature>
            <feature var="muc_unmoderated"></feature>
            <feature var="muc_nonanonymous"></feature>
            <feature var="muc_unsecured"></feature>
            <feature var="muc_persistent"></feature>
            <feature var="http://jabber.org/protocol/muc#self-ping-optimization"></feature>
            <feature var="vcard-temp"></feature>
            <feature var="urn:xmpp:sid:0"></feature>
            <feature var="http://jabber.org/protocol/disco#info"></feature>
            <feature var="urn:xmpp:bookmarks-conversion:0"></feature>
            <x xmlns="jabber:x:data" type="result">
               <field var="FORM_TYPE" type="hidden"><value>http://jabber.org/protocol/muc#roominfo</value></field>
               <field var="muc#roominfo_description" type="text-single" label="描述"><value>lx</value></field>
               <field var="muc#roominfo_subject" type="text-single" label="主题"><value></value></field>
               <field var="muc#roominfo_occupants" type="text-single" label="成员人数"><value>1</value></field>
               <field var="x-muc#roominfo_creationdate" type="text-single" label="创建日期"><value>2023-06-27T06:54:43.211Z</value></field>
            </x>
     </query>
 </iq>
 */


- (void)setIq:(XMPPIQ *)iq {
    NSXMLElement *iqChild = iq.childElement;
    if (![iqChild.xmlns isEqualToString:@"http://jabber.org/protocol/disco#info"]) {
        return;
    }
    for (NSXMLElement *item in iqChild.children) {
        if ([item.name isEqualToString:@"identity"]) {
            self.category = item.attributesAsDictionary[@"category"];
//            self.name = item.attributesAsDictionary[@"name"];
            self.type = item.attributesAsDictionary[@"type"];
            self.configuration.roomName = item.attributesAsDictionary[@"name"];
        } else if ([item.name isEqualToString:@"feature"]) {
//            [tempFeatures addObject:item.attributesAsDictionary[@"var"]];
            [self sortRoomInfoFeatureWith: item.attributesAsDictionary[@"var"]];  // 根据var对应的value,设置configuration
        } else if ([item.name isEqualToString:@"x"]) {
            for (NSXMLElement *xItem in item.children) {
                NSString *var = xItem.attributesAsDictionary[@"var"];
//                NSString *type = xItem.attributesAsDictionary[@"type"];
//                NSString *label = xItem.attributesAsDictionary[@"label"];
                NSString *value = [xItem.children firstObject].stringValue;
                
//                RoomField *field = [[RoomField alloc] initWithVar:var
//                                                             type:type
//                                                            label:label
//                                                            value:value];
                
                [self sortRoomInfoFieldWith:var value:value];
            }
        }
    }
    
    self.isFetchDetail = YES;
}

- (void)sortRoomInfoFeatureWith:(NSString *)feature {
    LXRoomInfoFeatureType type = [self featureTypeWith:feature];
    switch (type) {
        case LXRoomInfoFeatureTemporary:
        case LXRoomInfoFeaturePersistent:
            self.configuration.isPersistent = (type == LXRoomInfoFeaturePersistent);
            break;
        case LXRoomInfoFeatureHiddenRoom:
        case LXRoomInfoFeaturePublicRoom:
            self.configuration.isPublic = (type == LXRoomInfoFeaturePublicRoom);
            break;
        case LXRoomInfoFeatureMemberOnly:
        case LXRoomInfoFeatureOpenRoom:
            self.configuration.isMembersOnly = (type == LXRoomInfoFeatureMemberOnly);
            break;
        case LXRoomInfoFeatureModeratedRoom:
        case LXRoomInfoFeatureUnmoderatedRoom:
            self.configuration.isModerated = (type == LXRoomInfoFeatureModeratedRoom);
            break;
        case LXRoomInfoFeaturePasswordProtected:
        case LXRoomInfoFeatureUnsecured:
            self.configuration.isPasswordProtected = (type == LXRoomInfoFeaturePasswordProtected);
            break;
        case LXRoomInfoFeatureNonAnonymous:
            self.configuration.whois = @"anyone";
            break;
        case LXRoomInfoFeatureSemiAnonymous:
            self.configuration.whois = @"moderators";
            break;
        case LXRoomInfoFeatureFullyAnonymous:
            // 这类房间是不推荐的(NOT RECOMMENDED)或不被MUC显式支持, 但是如果一个服务提供适当的配置选项来使用这个协议，这种情况也是有可能的
            // 目前服务器不支持
            break;
        default:
            NSLog(@"发现未知类型的/无需处理的 feature: %@", feature);
            break;
    }
}

- (void)sortRoomInfoFieldWith:(NSString *)var value:(NSString *)value {
    switch ([self fieldTypeWith:var]) {
        case LXRoomInfoFieldDesc:
            self.configuration.roomDesc = value;
            break;
        case LXRoomInfoFieldSubject:
            self.subject = value;
            break;
        case LXRoomInfoFieldOccupants:
            self.occupants = [value intValue];
            break;
        case LXRoomInfoFieldCreateDate:
            self.createTime = [[value transformToDateForXmpp] transformWithFormat: nil];
            break;
        default:
            break;
    }
}

- (NSString *)name {
    if (![NSString isNone:self.configuration.roomName]) {
        return self.configuration.roomName;
    }
    return [self.xmlElement attributeForName:@"name"].stringValue;
}

- (NSString *)roomJidvalue {
    if (self.room.roomJID) {
        return self.room.roomJID.bare;
    }
    return [self.xmlElement attributeForName:@"jid"].stringValue;
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

- (LXRoomInfoFieldType)fieldTypeWith:(NSString *)var {
    if ([var isEqualToString:@"muc#roominfo_description"]) {
        return LXRoomInfoFieldDesc;
    } else if ([var isEqualToString:@"muc#roominfo_subject"]) {
        return LXRoomInfoFieldSubject;
    } else if ([var isEqualToString:@"muc#roominfo_occupants"]) {
        return LXRoomInfoFieldOccupants;
    } else if ([var isEqualToString:@"x-muc#roominfo_creationdate"]) {
        return LXRoomInfoFieldCreateDate;
    } else if ([var isEqualToString:@"FORM_TYPE"]) {
        return LXRoomInfoFieldFormType;
    }
    return LXRoomInfoFieldUnknow;
}

// 部分value是根据真实数据猜测的，可能不准确
- (LXRoomInfoFeatureType)featureTypeWith:(NSString *)value {
    if ([value isEqualToString:@"muc_nonanonymous"]) {
        return LXRoomInfoFeatureNonAnonymous;
    } else if ([value isEqualToString:@"muc_fullyanonymous"]) {
        return LXRoomInfoFeatureFullyAnonymous;
    } else if ([value isEqualToString:@"muc_semianonymous"]) {
        return LXRoomInfoFeatureSemiAnonymous;
    } else if ([value isEqualToString:@"muc_hidden"]) {
        return LXRoomInfoFeatureHiddenRoom;
    } else if ([value isEqualToString:@"muc_public"]) {
        return LXRoomInfoFeaturePublicRoom;
    } else if ([value isEqualToString:@"muc_open"]) {
        return LXRoomInfoFeatureOpenRoom;
    } else if ([value isEqualToString:@"muc_memberonly"]) {
        return LXRoomInfoFeatureMemberOnly;
    } else if ([value isEqualToString:@"muc_unmoderated"]) {
        return LXRoomInfoFeatureUnmoderatedRoom;
    } else if ([value isEqualToString:@"muc_moderated"]) {
        return LXRoomInfoFeatureModeratedRoom;
    } else if ([value isEqualToString:@"muc_passwordprotected"]) {
        return LXRoomInfoFeaturePasswordProtected;
    } else if ([value isEqualToString:@"muc_unsecured"]) {
        return LXRoomInfoFeatureUnsecured;
    } else if ([value isEqualToString:@"muc_persistent"]) {
        return LXRoomInfoFeaturePersistent;
    } else if ([value isEqualToString:@"muc_temporary"]) {
        return LXRoomInfoFeatureTemporary;
    }
    return LXRoomInfoFeatureUnknow;
}

@end
