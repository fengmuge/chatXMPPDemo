//
//  RoomConfiguration.m
//  ChatXmppDemo
//
//  Created by 苗培根 on 2023/6/25.
//

#import "RoomConfiguration.h"

@interface RoomConfiguration ()

@end

@implementation RoomConfiguration

- (instancetype)init {
    if (self = [super init]) {
        self.maxusers = @"10000";
        self.isPublic = YES;
        self.isPersistent = YES;
        self.isModerated = NO;
        self.isMembersOnly = YES;
        self.isAllowInvites = YES;
        self.isPasswordProtected = NO;
//        self.whois = @"";
        self.enableLogging = YES;
        self.isAllowChangeSubject = YES;
        self.isReservedNick = NO;
        self.isAllowChangeNick = YES;
        self.isRegistration = NO;
//        self.pm = @"";
    }
    return self;
}

- (instancetype)initWithXMLElement:(DDXMLElement *)element {
    if (self = [super init]) {
        [self sortXMLElement:element];
    }
    return self;
}

- (void)sortXMLElement:(NSXMLElement *)element {
    for (NSXMLElement *item in element.children) {
        if ([item.name isEqualToString:@"title"]) {
            // 表单标题
//            = item.stringValue;
        } else if ([item.name isEqualToString:@"instructions"]) {
            // 表单描述
//            = item.stringValue;
        } else if ([item.name isEqualToString:@"field"]) {
            [self sortFieldNode:item];
        }
    }
}

- (void)sortFieldNode:(NSXMLElement *)item {
    NSString *var = item.attributesAsDictionary[@"var"];
    NSString *type = item.attributesAsDictionary[@"type"];
    
    // 数据格式:
    //    <field var="FORM_TYPE" type="hidden"><value>http://jabber.org/protocol/muc#roomconfig</value></field>,
    if ([var isEqualToString:@"FORM_TYPE"]) {
        return;;
    }
    if (!var && [type isEqualToString:@"fixed"]) {
        NSLog(@"配置提示，fixed： %@", item.stringValue);
        return;
    }
    
    LXRoomConfigurationType configType = [self getConfigurationTypeFrom:var];
    if ([type isEqualToString:@"boolean"]) {
        [self sortBooleanTypeFieldNode:configType value:item.stringValue];
    } else if ([type isEqualToString:@"text-single"] || [type isEqualToString:@"text-private"]) {
        [self sortTextTypeFieldNode:configType value:item.stringValue];
    } else if ([type isEqualToString:@"jid-multi"]) {
        [self sortJidMultiTypeFieldNode:configType children:item.children];
    } else if ([type isEqualToString:@"list-multi"]) {
        [self sortListMultiTypeFieldNode:configType children:item.children];
    } else if ([type isEqualToString:@"list-single"]) {
        [self sortListSingleTypeFieldNode:configType children:item.children];
    }
}

// 目前仅有 最大人数、pm和whois三个值符合类型
// 数据格式:
// <field var="muc#roomconfig_maxusers" type="list-single" label="最大房间成员人数">
//        <option label="10"><value>10</value></option>
//        <option label="20"><value>20</value></option>
//        <option label="30"><value>30</value></option>
//        <option label="40"><value>40</value></option>
//        <option label="50"><value>50</value></option>
//        <option label="无"><value>0</value></option>
//        <value>10000</value>
// </field>
// children中仅有一个value值，如无需展示所有选项，找到children中item.name == @"value"的item，并且获取他的值就可以了
- (void)sortListSingleTypeFieldNode:(LXRoomConfigurationType)type children:(NSArray <DDXMLNode *> *)children {
    if (type != LXRoomConfigurationMaxusers &&
        type != LXRoomConfigurationPM &&
        type != LXRoomConfigurationWhois)
    {
        return;
    }
    
    NSString *value;
    for (DDXMLNode *item in children) {
        if (![item.name isEqualToString:@"value"]) {
            continue;
        }
        value = item.stringValue;
        break;
    }
    switch (type) {
        case LXRoomConfigurationMaxusers:
            self.maxusers = value;
            break;
        case LXRoomConfigurationWhois:
            self.whois = value;
            break;
        default:
            self.pm = value;
            break;
    }
}

// 目前仅仅有presencebroadcast
// 数据格式:
// <field var="muc#roomconfig_presencebroadcast" type="list-multi" label="广播其存在的角色">
//        <option label="审核者"><value>moderator</value></option>
//        <option label="参与者"><value>participant</value></option>
//        <option label="访客"><value>visitor</value></option>
//        <value>moderator</value>
//        <value>participant</value>
//        <value>visitor</value>
// </field>
// children中有多个value值，如无需展示所有选项，找到children中item.name == @"value"的item，并且获取他的值就可以了
- (void)sortListMultiTypeFieldNode:(LXRoomConfigurationType)type children:(NSArray <DDXMLNode *> *)children {
    if (type != LXRoomConfigurationPresenceBroadcast) {
        return;
    }
    NSMutableArray *result = [[NSMutableArray alloc] init];
    for (DDXMLNode *item in children) {
        if (![item.name isEqualToString:@"value"]) {
            continue;
        }
        [result addObject:item.stringValue];
    }
    self.presencebroadcast = [result copy];
}

// 目前仅房间管理员和房间拥有者
// 数据格式:
//    <field var="muc#roomconfig_roomadmins" type="jid-multi" label="房间管理员">
//           <value>123123@lxdev.cn</value>
//           <value>12310@lxdev.cn</value>
//    </field>,
- (void)sortJidMultiTypeFieldNode:(LXRoomConfigurationType)type children:(NSArray <DDXMLNode *> *)children {
    if (type != LXRoomConfigurationAdmins &&
        type != LXRoomConfigurationOwners)
    {
        return;
    }
    
    NSMutableArray *result = [[NSMutableArray alloc] init];
    for (DDXMLNode *item in children) {
        [result addObject:item.stringValue];
    }
    switch (type) {
        case LXRoomConfigurationAdmins:
            self.roomadmins = [result copy];
            break;
        default:
            self.roomowners = [result copy];
            break;
    }
}

// 除自定义外，基本只有 房间名称、描述和密码
// 数据格式：
//    <field var="muc#roomconfig_roomname" type="text-single" label="房间名称">
//           <value>灵犀3群</value>
//    </field>
- (void)sortTextTypeFieldNode:(LXRoomConfigurationType)type value:(NSString *)value {
    switch (type) {
        case LXRoomConfigurationName:
            self.roomName = value;
            break;
        case LXRoomConfigurationDesc:
            self.roomDesc = value;
            break;
        case LXRoomConfigurationSecret:
            self.roomSecret = value;
            break;
        default:
            break;
    }
}

// bool 类型数据
// 数据格式:
// <field var="muc#roomconfig_changesubject" type="boolean" label="允许成员更改主题">
//        <value>1</value>
// </field>
- (void)sortBooleanTypeFieldNode:(LXRoomConfigurationType)type value:(NSString *)value {
    bool isAllow = [value isEqualToString:@"1"];
    switch (type) {
        case LXRoomConfigurationPublic:
            self.isPublic = isAllow;
            break;
        case LXRoomConfigurationPersistent:
            self.isPersistent = isAllow;
            break;
        case LXRoomConfigurationModerated:
            self.isModerated = isAllow;
            break;
        case LXRoomConfigurationMembersOnly:
            self.isMembersOnly = isAllow;
            break;
        case LXRoomConfigurationAllowInvites:
            self.isAllowInvites = isAllow;
            break;
        case LXRoomConfigurationPasswordProtected:
            self.isPasswordProtected = isAllow;
            break;
        case LXRoomConfigurationEnableLogging:
            self.enableLogging = isAllow;
            break;
        case LXRoomConfigurationAllowChangeSubject:
            self.isAllowChangeSubject = isAllow;
            break;
        case LXRoomConfigurationReservedNick:
            self.isReservedNick = isAllow;
            break;
        case LXRoomConfigurationAllowChangeNick:
            self.isAllowChangeNick = isAllow;
            break;
        case LXRoomConfigurationRegistration:
            self.isRegistration = isAllow;
            break;
        default:
            break;
    }
}



/**
 房间名称| muc#roomconfig_roomname
 描述| muc#roomconfig_roomdesc
 允许占有者更改主题| muc#roomconfig_changesubject
 最大房间占有者人数| muc#roomconfig_maxusers
 其 Presence 是 Broadcast 的角色| muc#roomconfig_presencebroadcast
 列出目录中的房间| muc#roomconfig_publicroom
 房间是持久的| muc#roomconfig_persistentroom
 房间是适度的| muc#roomconfig_moderatedroom
 房间仅对成员开放| muc#roomconfig_membersonly
 允许占有者邀请其他人| muc#roomconfig_allowinvites
 需要密码才能进入房间| muc#roomconfig_passwordprotectedroom
 密码| muc#roomconfig_roomsecret
 能够发现占有者真实 JID 的角色| muc#roomconfig_whois
 登录房间对话| muc#roomconfig_enablelogging
 仅允许注册的昵称登录| x-muc#roomconfig_reservednick
 允许使用者修改昵称| x-muc#roomconfig_canchangenick
 允许用户注册房间| x-muc#roomconfig_registration
 房间管理员| muc#roomconfig_roomadmins
 房间拥有者| muc#roomconfig_roomowners
 允许发送私聊  muc#roomconfig_allowpm
 */

#warning mark --测试代码,具体业务中应该是可以单独设置任意一项的--
- (DDXMLElement *)getRoomConfiguration {
    NSXMLElement *options = [NSXMLElement elementWithName:@"x" xmlns:@"jabber:x:data"];
    // 房间名称
    NSXMLElement *nameField = [self setTextConfigureWith:LXRoomConfigurationName value:self.roomName];
    [options addChildNonNull:nameField];
    // 房间描述
    NSXMLElement *descField = [self setTextConfigureWith:LXRoomConfigurationDesc value:self.roomDesc];
    [options addChildNonNull:descField];
    // 房间密码
    NSXMLElement *secretField = [self setTextConfigureWith:LXRoomConfigurationSecret value:self.roomSecret];
    [options addChildNonNull:secretField];
    // 是否需要密码
    NSXMLElement *isPasseordProtectedField = [self setBooleanConfigureWith:LXRoomConfigurationPasswordProtected value:self.isPasswordProtected];
    [options addChildNonNull:isPasseordProtectedField];
    // 房间最大人数
    NSXMLElement *maxusersField = [self setTextConfigureWith:LXRoomConfigurationMaxusers value:self.maxusers];
    [options addChildNonNull:maxusersField];
    // 房间管理员
    NSXMLElement *adminsField = [self setJidMultiConfigureWith:LXRoomConfigurationAdmins multiData:self.roomadmins];
    [options addChildNonNull:adminsField];
    // 房间拥有者
    NSXMLElement *ownersField = [self setJidMultiConfigureWith:LXRoomConfigurationOwners multiData:self.roomowners];
    [options addChildNonNull:ownersField];
    // 广播其存在的角色 不知道是否正确
    NSXMLElement *broadcastField = [self setListMultiConfigureWith:LXRoomConfigurationPresenceBroadcast multiData:self.presencebroadcast];
    [options addChildNonNull:broadcastField];
    // 是否是开放的房间
    NSXMLElement *publicField = [self setBooleanConfigureWith:LXRoomConfigurationPublic value:self.isPublic];
    [options addChildNonNull:publicField];
    // 是否是持久性房间
    NSXMLElement *persistentField = [self setBooleanConfigureWith:LXRoomConfigurationPersistent value:self.isPersistent];
    [options addChildNonNull:persistentField];
    // 进入房间是否需要审核
    NSXMLElement *moderatedField = [self setBooleanConfigureWith:LXRoomConfigurationModerated value:self.isModerated];
    [options addChildNonNull:moderatedField];
    // 是否仅对成员开放
    NSXMLElement *membersOnlyField = [self setBooleanConfigureWith:LXRoomConfigurationMembersOnly value:self.isMembersOnly];
    [options addChildNonNull:membersOnlyField];
    // 是否允许成员邀请其他人加入
    NSXMLElement *allowInvitesField = [self setBooleanConfigureWith:LXRoomConfigurationAllowInvites value:self.isAllowInvites];
    [options addChildNonNull:allowInvitesField];
//    // 谁（成员角色）可以查询具体成员信息  --- whois类型是list-single
//    NSXMLElement *whoisField = [self setBooleanConfigureWith:LXRoomConfigurationWhois value:self.whois];
//    [options addChildNonNull:whoisField];
    // 是否记录聊天信息
    NSXMLElement *enableLoggingField = [self setBooleanConfigureWith:LXRoomConfigurationEnableLogging value:self.enableLogging];
    [options addChildNonNull:enableLoggingField];
    // 是否允许成员修改主题
    NSXMLElement *changeSubjectField = [self setBooleanConfigureWith:LXRoomConfigurationAllowChangeSubject value:self.isAllowChangeSubject];
    [options addChildNonNull:changeSubjectField];
    // 仅允许注册昵称登录
    NSXMLElement *reservedNickField = [self setBooleanConfigureWith:LXRoomConfigurationReservedNick value:self.isReservedNick];
    [options addChildNonNull:reservedNickField];
    // 允许成员修改昵称
    NSXMLElement *changeNickField = [self setBooleanConfigureWith:LXRoomConfigurationAllowChangeNick value:self.isAllowChangeNick];
    [options addChildNonNull:changeNickField];
    // 允许成员注册房间
    NSXMLElement *registrationField = [self setBooleanConfigureWith:LXRoomConfigurationRegistration value:self.isRegistration];
    [options addChildNonNull:registrationField];
//    // 允许发送私有信息
//    NSXMLElement *pmField = [self setBooleanConfigureWith:LXRoomConfigurationPM value:self.isAllowPm];
//    [options addChildNonNull:pmField];
    
    return options;
}


// 设置text-single类型数据，不知道text-private类型数据是否需要添加其他参数
- (NSXMLElement *)setTextConfigureWith:(LXRoomConfigurationType)type value:(NSString *)value {
    if ([NSString isNone:value]) {
        return nil;
    }
    NSString *typeValue = [self getConfigurationValueFrom:type];
    NSXMLElement *p = [NSXMLElement elementWithName:@"field" ];
    [p addAttributeWithName:@"var"stringValue:typeValue];
    [p addChild:[NSXMLElement elementWithName:@"value"stringValue:value]];
    return p;
}

// 设置boolean类型配置数据
- (NSXMLElement *)setBooleanConfigureWith:(LXRoomConfigurationType)type value:(BOOL)value {
    NSString *valueStr = value ? @"1" : @"0";
    return [self setTextConfigureWith:type value:valueStr];
}

// 设置jid多选配置数据
- (NSXMLElement *)setJidMultiConfigureWith:(LXRoomConfigurationType)type multiData:(NSArray <XMPPJID *> *)datas {
    if ([NSArray isEmpty:datas]) {
        return nil;
    }
    NSString *typeValue = [self getConfigurationValueFrom:type];
    NSXMLElement *p = [NSXMLElement elementWithName:@"field" ];
    [p addAttributeWithName:@"var"stringValue:typeValue];
    for (XMPPJID *jid in datas) {
        [p addChild:[NSXMLElement elementWithName:@"value" stringValue:jid.bare]];
    }
    
    return p;
}

// 设置list-multi类型数据配置 (说实话，我不明白这怎么配置，数组元素数据类型是什么)
- (NSXMLElement *)setListMultiConfigureWith:(LXRoomConfigurationType)type multiData:(NSArray <NSString *> *)datas {
    if ([NSArray isEmpty:datas]) {
        return nil;
    }
    NSString *typeValue = [self getConfigurationValueFrom:type];
    NSXMLElement *p = [NSXMLElement elementWithName:@"field" ];
    [p addAttributeWithName:@"var"stringValue:typeValue];
    for (NSString *val in datas) {
        [p addChild:[NSXMLElement elementWithName:@"value" stringValue:val]];
    }
    
    return p;
}

- (NSString *)getConfigurationValueFrom:(LXRoomConfigurationType)type {
    switch (type) {
        case LXRoomConfigurationName:
            return @"muc#roomconfig_roomname";
        case LXRoomConfigurationDesc:
            return @"muc#roomconfig_roomdesc";
        case LXRoomConfigurationSecret:
            return @"muc#roomconfig_roomsecret";
        case LXRoomConfigurationMaxusers:
            return @"muc#roomconfig_maxusers";
        case LXRoomConfigurationAdmins:
            return @"muc#roomconfig_roomadmins";
        case LXRoomConfigurationOwners:
            return @"muc#roomconfig_roomowners";
        case LXRoomConfigurationPresenceBroadcast:
            return @"muc#roomconfig_presencebroadcast";
        case LXRoomConfigurationPublic:
            return @"muc#roomconfig_publicroom";
        case LXRoomConfigurationPersistent:
            return @"muc#roomconfig_persistentroom";
        case LXRoomConfigurationModerated:
            return @"muc#roomconfig_moderatedroom";
        case LXRoomConfigurationMembersOnly:
            return @"muc#roomconfig_membersonly";
        case LXRoomConfigurationAllowInvites:
            return @"muc#roomconfig_allowinvites";
        case LXRoomConfigurationPasswordProtected:
            return @"muc#roomconfig_passwordprotectedroom";
        case LXRoomConfigurationWhois:
            return @"muc#roomconfig_whois";
        case LXRoomConfigurationEnableLogging:
            return @"muc#roomconfig_enablelogging";
        case LXRoomConfigurationAllowChangeSubject:
            return @"muc#roomconfig_changesubject";
        case LXRoomConfigurationReservedNick:
            return @"x-muc#roomconfig_reservednick";
        case LXRoomConfigurationAllowChangeNick:
            return @"x-muc#roomconfig_canchangenick";
        case LXRoomConfigurationRegistration:
            return @"x-muc#roomconfig_registration";
        case LXRoomConfigurationPM:
            return @"muc#roomconfig_allowpm";
        default:
            return nil;
    }
}

- (LXRoomConfigurationType)getConfigurationTypeFrom:(NSString *)value {
    if ([value isEqualToString:@"muc#roomconfig_roomname"]) {
        return LXRoomConfigurationName;
    } else if ([value isEqualToString:@"muc#roomconfig_roomdesc"]) {
        return LXRoomConfigurationDesc;
    } else if ([value isEqualToString:@"muc#roomconfig_roomsecret"]) {
        return LXRoomConfigurationSecret;
    } else if ([value isEqualToString:@"muc#roomconfig_maxusers"]) {
        return LXRoomConfigurationMaxusers;
    } else if ([value isEqualToString:@"muc#roomconfig_roomadmins"]) {
        return LXRoomConfigurationAdmins;
    } else if ([value isEqualToString:@"muc#roomconfig_roomowners"]) {
        return LXRoomConfigurationOwners;
    } else if ([value isEqualToString:@"muc#roomconfig_presencebroadcast"]) {
        return LXRoomConfigurationPresenceBroadcast;
    } else if ([value isEqualToString:@"muc#roomconfig_publicroom"]) {
        return LXRoomConfigurationPublic;
    } else if ([value isEqualToString:@"muc#roomconfig_persistentroom"]) {
        return LXRoomConfigurationPersistent;
    } else if ([value isEqualToString:@"muc#roomconfig_moderatedroom"]) {
        return LXRoomConfigurationModerated;
    } else if ([value isEqualToString:@"muc#roomconfig_membersonly"]) {
        return LXRoomConfigurationMembersOnly;
    } else if ([value isEqualToString:@"muc#roomconfig_allowinvites"]) {
        return LXRoomConfigurationAllowInvites;
    } else if ([value isEqualToString:@"muc#roomconfig_passwordprotectedroom"]) {
        return LXRoomConfigurationPasswordProtected;
    } else if ([value isEqualToString:@"muc#roomconfig_whois"]) {
        return LXRoomConfigurationWhois;
    } else if ([value isEqualToString:@"muc#roomconfig_enablelogging"]) {
        return LXRoomConfigurationEnableLogging;
    } else if ([value isEqualToString:@"muc#roomconfig_changesubject"]) {
        return LXRoomConfigurationAllowChangeSubject;
    } else if ([value isEqualToString:@"x-muc#roomconfig_reservednick"]) {
        return LXRoomConfigurationReservedNick;
    } else if ([value isEqualToString:@"x-muc#roomconfig_canchangenick"]) {
        return LXRoomConfigurationAllowChangeNick;
    } else if ([value isEqualToString:@"x-muc#roomconfig_registration"]) {
        return LXRoomConfigurationRegistration;
    } else if ([value isEqualToString:@"muc#roomconfig_allowpm"]) {
        return LXRoomConfigurationPM;
    }
    return LXRoomConfigurationUnknow;
}

@end
