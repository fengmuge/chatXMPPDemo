//
//  RoomManager.m
//  ChatXmppDemo
//
//  Created by 苗培根 on 2023/6/5.
//

#import "RoomManager.h"
#import "RoomConfiguration.h"
#import "Room.h"
#import "XMPPIQ+custom.h"

@interface RoomManager () <XMPPRoomDelegate, XMPPRoomStorage>
// 以下，以room.bare为key,保存不同用户的数据
@property (nonatomic, strong) NSMutableDictionary <NSString *, NSMutableArray *> *bans;
@property (nonatomic, strong) NSMutableDictionary <NSString *, NSMutableArray *> *admins;
@property (nonatomic, strong) NSMutableDictionary <NSString *, NSMutableArray *> *owners;
@property (nonatomic, strong) NSMutableDictionary <NSString *, NSMutableArray *> *members;
@property (nonatomic, strong) NSMutableDictionary <NSString *, NSMutableArray *> *Moderators;
// 其实，我想着要不要以LRU算法来管理 configuration和room。或者忽略时间的简化版LRU也不错
@property (nonatomic, strong) NSMutableDictionary <NSString *, RoomConfiguration *> *configures;
@property (nonatomic, strong, readwrite) NSMutableArray <Room *> *rooms;

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
- (Room *)getRoomWith:(NSString *)roomJid {
    for (Room *item in self.rooms) {
        if (![item.roomJidvalue isEqualToString:roomJid]) {
            continue;
        }
        return item;
    }
    return nil;
}

- (void)setRoomWith:(Room *)room {
    Room *item = [self getRoomWith:room.roomJidvalue];
    if (!item) {
        [self.rooms addObject:room];
    }
    if ([item isEqual:room]) {
        return;
    }
    NSInteger index = [self.rooms indexOfObject:item];
    [self.rooms insertObject:room atIndex:index];
    [self.rooms removeObject:item];
}

- (void)removeRoom:(Room *)room {
    Room *item = [self getRoomWith:room.roomJidvalue];
    if (!item) {
        return;
    }
    [self.rooms removeObject:item];
}

- (RoomConfiguration *)getConfigurationWith:(NSString *)roomJid {
    if (!self.configures[roomJid]) {
        return nil;
    }
    return self.configures[roomJid];
}

- (void)setConfigurationCache:(RoomConfiguration *)configuration toRoom:(NSString *)roomJid {
    self.configures[roomJid] = configuration;
}

- (void)removeConfigurationFromRoom:(NSString *)roomJid {
    if (!self.configures[roomJid]) {
        return;
    }
    [self.configures removeObjectForKey:roomJid];
}

- (NSArray <XMPPJID *> *)getRoomCacheWith:(NSString *)roomJid type:(LXRoomCachesType)type {
    NSMutableDictionary *caches = [self fliterCaches:type];
    if (!caches[roomJid]) {
        return nil;
    }
    return [caches[roomJid] copy];
}

- (void)setRoomCachesWith:(NSString *)roomJid items:(NSArray *)items type:(LXRoomCachesType)type {
    NSMutableDictionary *caches = [self fliterCaches:type];
    caches[roomJid] = [items mutableCopy];
}

- (void)removeRoomCacheWith:(NSString *)roomJid type:(LXRoomCachesType)type {
    NSMutableDictionary *caches = [self fliterCaches:type];
    [caches removeObjectForKey:roomJid];
}

// 添加，如果已经存在，那么更新
- (void)addCacheToRoom:(NSString *)roomJid item:(XMPPJID *)item type:(LXRoomCachesType)type {
    NSMutableDictionary *caches = [self fliterCaches:type];
    NSMutableArray *cacheItems = [self fliterCacheItemsForRoom:roomJid inCache:caches];
    XMPPJID *localItem = [self fliterJid:item inCaches:cacheItems];
    if (!localItem) {
        [cacheItems addObject:item];
    } else {
        NSInteger index = [cacheItems indexOfObject:localItem];
        [cacheItems insertObject:item atIndex:index];
        [cacheItems removeObject:localItem];
    }
}

- (void)removeCacheFromRoom:(NSString *)roomJid item:(XMPPJID *)item type:(LXRoomCachesType)type {
    NSMutableDictionary *caches = [self fliterCaches:type];
    if (caches[roomJid] == nil) {
        return;
    }
    NSMutableArray *cacheItems = caches[roomJid];
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

- (NSMutableArray *)fliterCacheItemsForRoom:(NSString *)roomJid inCache:(NSMutableDictionary *)caches {
    if (caches[roomJid] != nil) {
        return caches[roomJid];
    }
    NSMutableArray *cacheItems = [[NSMutableArray alloc] init];
    caches[roomJid] = cacheItems;
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
// 问题: 没有找到SDK的api
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

// 整理获取到的群组相关的信息 群列表/群详细信息
- (void)sortIqForRoom:(XMPPIQ *)iq {
    if ([iq isFetchRoomList]) {
        [self sortJoinedRoonFetchedResult:iq];
    } else if ([iq isFetchRoom]) {
        [self sortRoomInformationFetchedResult:iq];
    }
}
// 整理获取到的群组数据
- (void)sortJoinedRoonFetchedResult:(XMPPIQ *)iq {
    NSString *elementId = iq.elementID;
    if (![elementId isEqualToString:@"getJoinedRoom"]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kXMPP_FETCHED_GROUPS
                                                            object:nil];
        return;
    }
    NSArray *results = [iq elementsForXmlns:@"http://jabber.org/protocol/disco#items"];
    if (results.count < 1) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kXMPP_FETCHED_GROUPS
                                                            object:nil];
        return;
    }
    NSMutableArray *array = [NSMutableArray array]; // 群列表
    for (DDXMLElement *element in iq.children) {
        if ([element.name isEqualToString:@"query"]) {
            for (DDXMLElement *item in element.children) {
                if ([item.name isEqualToString:@"item"]) {
                    Room *room = [[Room alloc] init];
                    [room setXmlElement:item];
                    [array addObject:room];
                }
            }
        }
    }
    self.rooms = array;
    [[NSNotificationCenter defaultCenter] postNotificationName:kXMPP_FETCHED_GROUPS
                                                        object:[array copy]];
}

// 整理获取到的房间信息
- (void)sortRoomInformationFetchedResult:(XMPPIQ *)iq {
    NSString *roomJid = iq.attributesAsDictionary[@"from"];
    Room *item = [self getRoomWith:roomJid];
    if (!item) {
        item = [[Room alloc] init];
    }
    [item setIq:iq];
    [self setRoomWith:item];
    [[NSNotificationCenter defaultCenter] postNotificationName:kXMPP_FETCHED_GROUP_INFORMATION
                                                        object:item];
}

//#warning mark ---没有想好逻辑---
//- (Room *)makeRoomWith:(DDXMLElement *)item {
//    NSString *jid = [item attributeForName:@"jid"].stringValue;
//    NSString *roomSubject = [item attributeForName:@"name"].stringValue;
//
//    XMPPJID *roomJid = [XMPPJID jidWithString:jid];
//
//    XMPPRoomCoreDataStorage *roomCoreDataStorage = [XMPPRoomCoreDataStorage sharedInstance];
//    // 添加代理
//    XMPPRoom *roomItem = [[XMPPRoom alloc] initWithRoomStorage:roomCoreDataStorage
//                                                  jid:roomJid
//                                        dispatchQueue:dispatch_get_main_queue()];
//    // 激活
//    [roomItem activate:[ChatManager sharedInstance].stream];
//    [roomItem addDelegate:[RoomManager sharedInstance]
//             delegateQueue:dispatch_get_main_queue()];
//
//    Room *room = [[Room alloc] init];
////    room.name = roomSubject;
//    [room setRoom:roomItem];
//
//    return room;
//}

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
    RoomConfiguration *configuration = [[RoomConfiguration alloc] initWithXMLElement:configForm];
    // 将房间的配置信息添加到缓存
    [self setConfigurationCache:configuration
                         toRoom:sender.roomJID.bare];
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
    [self addCacheToRoom:sender.roomJID.bare
                    item:occupantJID
                    type:LXRoomCachesMember];
    // 发送消息，暂定为这样，具体业务逻辑还没想好
    [[NSNotificationCenter defaultCenter] postNotificationName:kXMPP_ROOM_OCCUPANT_DID_JOIN object:nil];
}

- (void)xmppRoom:(XMPPRoom *)sender occupantDidLeave:(XMPPJID *)occupantJID withPresence:(XMPPPresence *)presence {
    NSLog(@"%s 成员: %@离开房间成功,获取到信息: %@", __func__, occupantJID, presence);
    [self removeCacheFromRoom:sender.roomJID.bare
                         item:occupantJID
                         type:LXRoomCachesMember];
    // 发送消息，暂定为这样，具体业务逻辑还没想好
    [[NSNotificationCenter defaultCenter] postNotificationName:kXMPP_ROOM_OCCUPANT_DID_LEAVE object:nil];
}

- (void)xmppRoom:(XMPPRoom *)sender occupantDidUpdate:(XMPPJID *)occupantJID withPresence:(XMPPPresence *)presence {
    NSLog(@"%s 成员: %@信息更新, 获取到信息: %@", __func__, occupantJID, presence);
    [self addCacheToRoom:sender.roomJID.bare
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
    [self setRoomCachesWith:sender.roomJID.bare
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
    [self setRoomCachesWith:sender.roomJID.bare
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
    [self setRoomCachesWith:sender.roomJID.bare
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
    [self setRoomCachesWith:sender.roomJID.bare
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
    [self setRoomCachesWith:sender.roomJID.bare
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
