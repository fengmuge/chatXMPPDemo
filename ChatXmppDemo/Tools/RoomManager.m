//
//  RoomManager.m
//  ChatXmppDemo
//
//  Created by 苗培根 on 2023/6/5.
//

#import "RoomManager.h"
#import "Room.h"

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
//        self.isAllowWhois = YES; // 这个应该是错误的，因为whois是list-single类型的
        self.enableLogging = YES;
        self.isAllowChangeSubject = YES;
        self.isReservedNick = NO;
        self.isAllowChangeNick = YES;
        self.isRegistration = NO;
        self.isAllowPm = YES;
    }
    return self;
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
//    // 是否可以查询具体成员信息  --- whois类型是list-single，应该不是bool，目前还不明白具体用法
//    NSXMLElement *whoisField = [self setBooleanConfigureWith:LXRoomConfigurationWhois value:self.isAllowWhois];
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
    // 允许发送私有信息
    NSXMLElement *pmField = [self setBooleanConfigureWith:LXRoomConfigurationAllowPM value:self.isAllowPm];
    [options addChildNonNull:pmField];
    
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
        default:
            return @"muc#roomconfig_allowpm";
    }
}

@end

@interface RoomManager () <XMPPRoomDelegate, XMPPRoomStorage>
// 以下，以room.bare为key,保存不同用户的数据
@property (nonatomic, strong) NSMutableDictionary <NSString *, NSMutableArray *> *bans;
@property (nonatomic, strong) NSMutableDictionary <NSString *, NSMutableArray *> *admins;
@property (nonatomic, strong) NSMutableDictionary <NSString *, NSMutableArray *> *owners;
@property (nonatomic, strong) NSMutableDictionary <NSString *, NSMutableArray *> *members;
@property (nonatomic, strong) NSMutableDictionary <NSString *, NSMutableArray *> *Moderators;
@property (nonatomic, strong) NSMutableDictionary <NSString *, RoomConfiguration *> *configures;
@property (nonatomic, strong) NSMutableArray <Room *> *rooms;

@end

@implementation RoomManager
static RoomManager *_sharedInstance;

+ (RoomManager *)sharedInstance {
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

#pragma mark --本地数据--
- (RoomConfiguration *)getConfigurationWith:(XMPPRoom *)room {
    if (!self.configures[room.roomJID.bare]) {
        return nil;
    }
    return self.configures[room.roomJID.bare];
}

- (void)setConfigurationCache:(RoomConfiguration *)configuration toRoom:(XMPPRoom *)room {
    self.configures[room.roomJID.bare] = configuration;
}

- (void)removeConfigurationFromRoom:(XMPPRoom *)room {
    NSString *bare = room.roomJID.bare;
    if (!self.configures[bare]) {
        return;
    }
    [self.configures removeObjectForKey:bare];
}

- (NSArray <XMPPJID *> *)getRoomCacheWith:(XMPPRoom *)room type:(LXRoomCachesType)type {
    NSMutableDictionary *caches = [self fliterCaches:type];
    if (!caches[room.roomJID.bare]) {
        return nil;
    }
    return [caches[room.roomJID.bare] copy];
}

- (void)setRoomCachesWith:(XMPPRoom *)room items:(NSArray *)items type:(LXRoomCachesType)type {
    NSMutableDictionary *caches = [self fliterCaches:type];
    caches[room.roomJID.bare] = [items mutableCopy];
}

- (void)removeRoomCacheWith:(XMPPRoom *)room type:(LXRoomCachesType)type {
    NSMutableDictionary *caches = [self fliterCaches:type];
    [caches removeObjectForKey:room.roomJID.bare];
}

// 添加，如果已经存在，那么更新
- (void)addCacheToRoom:(XMPPRoom *)room item:(XMPPJID *)item type:(LXRoomCachesType)type {
    NSMutableDictionary *caches = [self fliterCaches:type];
    NSMutableArray *cacheItems = [self fliterCacheItemsForRoom:room inCache:caches];
    XMPPJID *localItem = [self fliterJid:item inCaches:cacheItems];
    if (!localItem) {
        [cacheItems addObject:item];
    } else {
        NSInteger index = [cacheItems indexOfObject:localItem];
        [cacheItems insertObject:item atIndex:index];
        [cacheItems removeObject:localItem];
    }
}

- (void)removeCacheFromRoom:(XMPPRoom *)room item:(XMPPJID *)item type:(LXRoomCachesType)type {
    NSMutableDictionary *caches = [self fliterCaches:type];
    NSString *bare = room.roomJID.bare;
    if (caches[bare] == nil) {
        return;
    }
    NSMutableArray *cacheItems = caches[bare];
    XMPPJID *localItem = [self fliterJid:item inCaches:cacheItems];
    if (!localItem) {
        return;
    }
    [cacheItems removeObject:localItem];
}

- (NSMutableDictionary *)fliterCaches:(LXRoomCachesType)type {
    switch (type) {
        case LXRoomCachesBan:
            return self.bans;
        case LXRoomCachesAdmin:
            return self.admins;
        case LXRoomCachesOwner:
            return self.owners;
        case LXRoomCachesMember:
            return self.members;
        default:
            return self.Moderators;
    }
}

- (NSMutableArray *)fliterCacheItemsForRoom:(XMPPRoom *)room inCache:(NSMutableDictionary *)caches {
    NSString *bare = room.roomJID.bare;
    if (caches[bare] != nil) {
        return caches[bare];
    }
    NSMutableArray *cacheItems = [[NSMutableArray alloc] init];
    caches[bare] = cacheItems;
    return cacheItems;
}

// 从缓存的数据中找到目标用户
- (XMPPJID *)fliterJid:(XMPPJID *)jid inCaches:(NSMutableArray *)cacheItems {
    for (XMPPJID *item in cacheItems) {
        if (![jid.user isEqualToString:item.user] ||
            ![jid.domain isEqualToString:item.domain]) {
            continue;
        }
        return item;
    }
    return nil;
}

// 获取加入过的群组和公开的群组
- (void)fetchJoinedRoomList {
    NSXMLElement *queryElement = [NSXMLElement elementWithName:@"query" xmlns:@"http://jabber.org/protocol/disco#items"];
    NSXMLElement *iqElement = [NSXMLElement elementWithName:@"iq"];
    [iqElement addAttributeWithName:@"type" stringValue:@"get"];
    [iqElement addAttributeWithName:@"from" stringValue:[UserManager sharedInstance].jid.bare];
    
    NSString *service = [NSString stringWithFormat:@"%@.%@", kSubdomain, kDomin];
    [iqElement addAttributeWithName:@"to" stringValue:service];
    [iqElement addAttributeWithName:@"id" stringValue:@"getJoinedRoom"];
    [iqElement addChild:queryElement];
    
    [[ChatManager sharedInstance].stream sendElement:iqElement];
}

// 整理获取到的群组数据
- (void)sortJoinedRoonFetchedResult:(XMPPIQ *)iq {
    NSString *elementId = iq.elementID;
    if (![elementId isEqualToString:@"getJoinedRoom"]) {
        return;
    }
    NSArray *results = [iq elementsForXmlns:@"http://jabber.org/protocol/disco#items"];
    if (results.count < 1) {
        return;
    }
    NSMutableArray *array = [NSMutableArray array]; // 群列表
    for (DDXMLElement *element in iq.children) {
        if ([element.name isEqualToString:@"query"]) {
            for (DDXMLElement *item in element.children) {
                if ([item.name isEqualToString:@"item"]) {
//                    Room *room = [self makeRoomWith:item];
                    [array addObject:item];
                }
            }
        }
    }
    self.rooms = array;
    [[NSNotificationCenter defaultCenter] postNotificationName:kXMPP_FETCHED_GROUPS
                                                        object:[array copy]];
}

- (Room *)makeRoomWith:(DDXMLElement *)item {
    NSString *jid = [item attributeForName:@"jid"].stringValue;
    NSString *roomSubject = [item attributeForName:@"name"].stringValue;

    XMPPJID *roomJid = [XMPPJID jidWithString:jid];

    XMPPRoomCoreDataStorage *roomCoreDataStorage = [XMPPRoomCoreDataStorage sharedInstance];
    // 添加代理
    XMPPRoom *roomItem = [[XMPPRoom alloc] initWithRoomStorage:roomCoreDataStorage
                                                  jid:roomJid
                                        dispatchQueue:dispatch_get_main_queue()];
    // 激活
    [roomItem activate:[ChatManager sharedInstance].stream];
    [roomItem addDelegate:[RoomManager sharedInstance]
             delegateQueue:dispatch_get_main_queue()];

    Room *room = [[Room alloc] init];
    room.roomName = roomSubject;
    [room setRoom:roomItem];

    return room;
}

- (void)configureRoom:(XMPPRoom *)room WithConfiguration:(RoomConfiguration *)configuration {
    NSXMLElement *options = [configuration getRoomConfiguration];
    [room configureRoomUsingOptions:options];
}

#pragma mark --XMPPRoomDelegate--
- (void)xmppRoomDidCreate:(XMPPRoom *)sender {
    NSLog(@"%s 房间创建成功", __func__);
    // 对房间进行初始化配置
    RoomConfiguration *configuration = [[RoomConfiguration alloc] init];
    [self configureRoom:sender WithConfiguration:configuration];
    [[NSNotificationCenter defaultCenter] postNotificationName:kXMPP_ROOM_DID_CREATE
                                                        object:sender];
}

/**
 * Invoked with the results of a request to fetch the configuration form.
 * The given config form will look something like:
 *
 * <x xmlns='jabber:x:data' type='form'>
 *   <title>Configuration for MUC Room</title>
 *   <field type='hidden'
 *           var='FORM_TYPE'>
 *     <value>http://jabber.org/protocol/muc#roomconfig</value>
 *   </field>
 *   <field label='Natural-Language Room Name'
 *           type='text-single'
 *            var='muc#roomconfig_roomname'/>
 *   <field label='Enable Public Logging?'
 *           type='boolean'
 *            var='muc#roomconfig_enablelogging'>
 *     <value>0</value>
 *   </field>
 *   ...
 * </x>
 *
 * The form is to be filled out and then submitted via the configureRoomUsingOptions: method.
 *
 * @see fetchConfigurationForm:
 * @see configureRoomUsingOptions:
**/
- (void)xmppRoom:(XMPPRoom *)sender didFetchConfigurationForm:(NSXMLElement *)configForm {
    NSLog(@"%s 房间配置获取成功", __func__);
    // 直接用RoomConfiguration对象进行解析，并发送到房间聊天页面缓存，和进行相关UI配置
    RoomConfiguration *configuration; // =
    // 将房间的配置信息添加到缓存
    [self setConfigurationCache:configuration
                         toRoom:sender];
    // 将配置信息发送到聊天页面
    [[NSNotificationCenter defaultCenter] postNotificationName:kXMPP_ROOM_DIDFETCH_CONFIGURATIONFORM
                                                        object:nil
                                                      userInfo:@{@"room": sender,
                                                                 @"configuration": configuration
                                                               }
    ];
}
// 房间配置这仨回调目前不需要处理
- (void)xmppRoom:(XMPPRoom *)sender willSendConfiguration:(XMPPIQ *)roomConfigForm {
    NSLog(@"%s 即将发送配置", __func__);
}

- (void)xmppRoom:(XMPPRoom *)sender didConfigure:(XMPPIQ *)iqResult {
    NSLog(@"%s 房间配置成功", __func__);
}

- (void)xmppRoom:(XMPPRoom *)sender didNotConfigure:(XMPPIQ *)iqResult {
    NSLog(@"%s 房间配置失败", __func__);
}

- (void)xmppRoomDidJoin:(XMPPRoom *)sender {
    NSLog(@"%s 加入房间成功", __func__);
    // 获取被禁成员列表
    [sender fetchBanList];
    // 获取管理员列表
    [sender fetchAdminsList];
    // 获取群拥有者列表
    [sender fetchOwnersList];
    // 获取群成员列表
    [sender fetchMembersList];
    // 获取审核员列表
    [sender fetchModeratorsList];
    // 获取群配置信息
    [sender fetchConfigurationForm];
    // 发送通知
    [[NSNotificationCenter defaultCenter] postNotificationName:kXMPP_ROOM_DID_JOIN
                                                        object:sender];
    
}

- (void)xmppRoomDidLeave:(XMPPRoom *)sender {
    NSLog(@"%s 离开房间成功", __func__);
    [[NSNotificationCenter defaultCenter] postNotificationName:kXMPP_ROOM_DID_LEAVE
                                                        object:sender];
}

- (void)xmppRoomDidDestroy:(XMPPRoom *)sender {
    NSLog(@"%s 房间销毁成功", __func__);
    [[NSNotificationCenter defaultCenter] postNotificationName:kXMPP_ROOM_DESTROY_RESULT
                                                        object:sender
                                                      userInfo:@{@"result": [NSNumber numberWithBool:YES]}];
}

- (void)xmppRoom:(XMPPRoom *)sender didFailToDestroy:(XMPPIQ *)iqError {
    NSLog(@"%s 房间销毁失败", __func__);
    [[NSNotificationCenter defaultCenter] postNotificationName:kXMPP_ROOM_DESTROY_RESULT
                                                        object:sender
                                                      userInfo:@{@"result": [NSNumber numberWithBool:NO]}];
}

- (void)xmppRoom:(XMPPRoom *)sender occupantDidJoin:(XMPPJID *)occupantJID withPresence:(XMPPPresence *)presence {
    NSLog(@"%s 成员: %@加入房间成功,获取到信息: %@", __func__, occupantJID, presence);
    [self addCacheToRoom:sender
                    item:occupantJID
                    type:LXRoomCachesMember];
    // 发送消息，暂定为这样，具体业务逻辑还没想好
    [[NSNotificationCenter defaultCenter] postNotificationName:kXMPP_ROOM_OCCUPANT_DID_JOIN object:nil];
}

- (void)xmppRoom:(XMPPRoom *)sender occupantDidLeave:(XMPPJID *)occupantJID withPresence:(XMPPPresence *)presence {
    NSLog(@"%s 成员: %@离开房间成功,获取到信息: %@", __func__, occupantJID, presence);
    [self removeCacheFromRoom:sender
                         item:occupantJID
                         type:LXRoomCachesMember];
    // 发送消息，暂定为这样，具体业务逻辑还没想好
    [[NSNotificationCenter defaultCenter] postNotificationName:kXMPP_ROOM_OCCUPANT_DID_LEAVE object:nil];
}

- (void)xmppRoom:(XMPPRoom *)sender occupantDidUpdate:(XMPPJID *)occupantJID withPresence:(XMPPPresence *)presence {
    NSLog(@"%s 成员: %@信息更新, 获取到信息: %@", __func__, occupantJID, presence);
    [self addCacheToRoom:sender
                    item:occupantJID
                    type:LXRoomCachesMember];
    // 发送消息，暂定为这样，具体业务逻辑还没想好
    [[NSNotificationCenter defaultCenter] postNotificationName:kXMPP_ROOM_OCCUPANT_DID_UPDATE object:nil];
}

/**
 * Invoked when a message is received.
 * The occupant parameter may be nil if the message came directly from the room, or from a non-occupant.
**/
// 我还没想好这个怎么处理，并且，这个回调是否和didReceivedMessage: 回调冲突或者同时回调 ??
- (void)xmppRoom:(XMPPRoom *)sender didReceiveMessage:(XMPPMessage *)message fromOccupant:(XMPPJID *)occupantJID {
    NSLog(@"%s 收到成员: %@的消息: %@", __func__, occupantJID, message);
}

- (void)xmppRoom:(XMPPRoom *)sender didFetchBanList:(NSArray *)items {
    NSLog(@"%s 获取到被禁群成员列表: %@", __func__, items);
    [self setRoomCachesWith:sender
                      items:items
                       type:LXRoomCachesBan];
    [[NSNotificationCenter defaultCenter] postNotificationName:kXMPP_ROOM_FETCHBANLIST_RESULT
                                                        object:[NSNumber numberWithBool:YES]];
}
- (void)xmppRoom:(XMPPRoom *)sender didNotFetchBanList:(XMPPIQ *)iqError {
    NSLog(@"%s 获取被禁群成员列表失败: %@", __func__, iqError);
    [[NSNotificationCenter defaultCenter] postNotificationName:kXMPP_ROOM_FETCHBANLIST_RESULT
                                                        object:[NSNumber numberWithBool:NO]];
}

- (void)xmppRoom:(XMPPRoom *)sender didFetchMembersList:(NSArray *)items {
    NSLog(@"%s 获取到群成员列表: %@", __func__, items);
    [self setRoomCachesWith:sender
                      items:items
                       type:LXRoomCachesMember];
    [[NSNotificationCenter defaultCenter] postNotificationName:kXMPP_ROOM_FETCHMEMBERSLIST_RESULT
                                                        object:[NSNumber numberWithBool:YES]];
    
}
- (void)xmppRoom:(XMPPRoom *)sender didNotFetchMembersList:(XMPPIQ *)iqError {
    NSLog(@"%s 获取群成员列表失败: %@", __func__, iqError);
    [[NSNotificationCenter defaultCenter] postNotificationName:kXMPP_ROOM_FETCHMEMBERSLIST_RESULT
                                                        object:[NSNumber numberWithBool:NO]];
}

- (void)xmppRoom:(XMPPRoom *)sender didFetchAdminsList:(NSArray *)items {
    NSLog(@"%s 获取到管理员列表: %@", __func__, items);
    [self setRoomCachesWith:sender
                      items:items
                       type:LXRoomCachesAdmin];
    [[NSNotificationCenter defaultCenter] postNotificationName:kXMPP_ROOM_FETCHADMINSLIST_RESULT
                                                        object:[NSNumber numberWithBool:YES]];
}
- (void)xmppRoom:(XMPPRoom *)sender didNotFetchAdminsList:(XMPPIQ *)iqError {
    NSLog(@"%s 获取管理员列表失败: %@", __func__, iqError);
    [[NSNotificationCenter defaultCenter] postNotificationName:kXMPP_ROOM_FETCHADMINSLIST_RESULT
                                                        object:[NSNumber numberWithBool:NO]];
}

- (void)xmppRoom:(XMPPRoom *)sender didFetchOwnersList:(NSArray *)items {
    NSLog(@"%s 获取到群拥有者列表: %@", __func__, items);
    [self setRoomCachesWith:sender
                      items:items
                       type:LXRoomCachesOwner];
    [[NSNotificationCenter defaultCenter] postNotificationName:kXMPP_ROOM_FETCHOWNERSLIST_RESULT
                                                        object:[NSNumber numberWithBool:YES]];
}
- (void)xmppRoom:(XMPPRoom *)sender didNotFetchOwnersList:(XMPPIQ *)iqError {
    NSLog(@"%s 获取拥有者列表失败: %@", __func__, iqError);
    [[NSNotificationCenter defaultCenter] postNotificationName:kXMPP_ROOM_FETCHOWNERSLIST_RESULT
                                                        object:[NSNumber numberWithBool:NO]];
}

// 房间可以设置为需要审核才能加入
- (void)xmppRoom:(XMPPRoom *)sender didFetchModeratorsList:(NSArray *)items {
    NSLog(@"%s 获取到审核员列表: %@", __func__, items);
    [self setRoomCachesWith:sender
                      items:items
                       type:LXRoomCachesModerator];
    [[NSNotificationCenter defaultCenter] postNotificationName:kXMPP_ROOM_FETCHMODERATORSLIST_RESULT
                                                        object:[NSNumber numberWithBool:YES]];
}

- (void)xmppRoom:(XMPPRoom *)sender didNotFetchModeratorsList:(XMPPIQ *)iqError {
    NSLog(@"%s 获取审核员列表失败: %@", __func__, iqError);
    [[NSNotificationCenter defaultCenter] postNotificationName:kXMPP_ROOM_FETCHMODERATORSLIST_RESULT
                                                        object:[NSNumber numberWithBool:NO]];
}

// 暂时还不知道 iqResult格式
- (void)xmppRoom:(XMPPRoom *)sender didEditPrivileges:(XMPPIQ *)iqResult {
    NSLog(@"%s 编辑群权限完成 %@", __func__, iqResult);
    [[NSNotificationCenter defaultCenter] postNotificationName:kXMPP_ROOM_EDITPRIVILEGES_RESULT
                                                        object:[NSNumber numberWithBool:YES]];
}

- (void)xmppRoom:(XMPPRoom *)sender didNotEditPrivileges:(XMPPIQ *)iqError {
    NSLog(@"%s 编辑群权限失败 %@", __func__, iqError);
    [[NSNotificationCenter defaultCenter] postNotificationName:kXMPP_ROOM_EDITPRIVILEGES_RESULT
                                                        object:[NSNumber numberWithBool:NO]];
}

//
- (void)xmppRoomDidChangeSubject:(XMPPRoom *)sender {
    NSLog(@"%s 房间主题已经改变", __func__);
    [[NSNotificationCenter defaultCenter] postNotificationName:kXMPP_ROOM_DIDCHANGE_SUBJIEC
                                                        object:sender];
}

#pragma mark --XMPPRoomStorage--
//
- (BOOL)configureWithParent:(XMPPRoom *)aParent queue:(dispatch_queue_t)queue {
    return YES;
}

/**
 * Updates and returns the occupant for the given presence element.
 * If the presence type is "available", and the occupant doesn't already exist, then one should be created.
**/
- (void)handlePresence:(XMPPPresence *)presence room:(XMPPRoom *)room {

}

/**
 * Stores or otherwise handles the given message element.
**/
- (void)handleIncomingMessage:(XMPPMessage *)message room:(XMPPRoom *)room {

}

- (void)handleOutgoingMessage:(XMPPMessage *)message room:(XMPPRoom *)room {

}

/**
 * Handles leaving the room, which generally means clearing the list of occupants.
**/
- (void)handleDidLeaveRoom:(XMPPRoom *)room {

}

/**
 * May be used if there's anything special to do when joining a room.
**/
- (void)handleDidJoinRoom:(XMPPRoom *)room withNickname:(NSString *)nickname {

}


@end
