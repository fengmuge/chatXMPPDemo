//
//  RoomManager.h
//  ChatXmppDemo
//
//  Created by 苗培根 on 2023/6/5.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    LXRoomConfigurationName,  // 房间名称
    LXRoomConfigurationDesc,  // 房间描述
    LXRoomConfigurationSecret, // 房间密码
    LXRoomConfigurationMaxusers, // 房间最大人数
    LXRoomConfigurationAdmins, // 房间管理员 jid.bare
    LXRoomConfigurationOwners, // 房间拥有者 jie.bare
    LXRoomConfigurationPresenceBroadcast, // 房间广播类型 moderator、participant、visitor
    LXRoomConfigurationPublic,  // 房间是否公开
    LXRoomConfigurationPersistent, // 是否是持久性房间
    LXRoomConfigurationModerated, // 是否需要审核/验证
    LXRoomConfigurationMembersOnly, // 是否仅对成员开放
    LXRoomConfigurationAllowInvites, // 是否允许成员邀请其他人加入
    LXRoomConfigurationPasswordProtected, // 是否需要密码才能进入房间
    LXRoomConfigurationWhois,     // 是否可以查询成员详细信息(jid) --- 存疑，不清楚具体作用
    LXRoomConfigurationEnableLogging, // 是否记录聊天
    LXRoomConfigurationAllowChangeSubject, // 是否允许成员修改房间主题
    LXRoomConfigurationReservedNick,  // 是否仅允许注册昵称登录
    LXRoomConfigurationAllowChangeNick, // 是否允许成员修改昵称
    LXRoomConfigurationRegistration, // 是否允许成员注册房间
    LXRoomConfigurationAllowPM,  // 是否允许发送私有消息
} LXRoomConfigurationType;

typedef enum : NSUInteger {
    LXRoomCachesBan,
    LXRoomCachesAdmin,
    LXRoomCachesOwner,
    LXRoomCachesModerator,
    LXRoomCachesMember,
} LXRoomCachesType;

NS_ASSUME_NONNULL_BEGIN

// 具体描述和指令key在RoomConfiguration实现文件内
@interface RoomConfiguration : NSObject

@property (nonatomic, copy) NSString *roomName; // 房间名称 类型: text-single
@property (nonatomic, copy) NSString *roomDesc; // 房间描述 类型: text-single
@property (nonatomic, copy) NSString *roomSecret; // 房间密码 类型: text-private
@property (nonatomic, copy) NSString *maxusers; // 房间最大人数 类型: list-single
@property (nonatomic, strong) NSArray <XMPPJID *> *roomadmins; // ? 房间管理员 类型: jid-multi 内容举例: 123@lxdev.cn,也就是jid.bare
@property (nonatomic, strong) NSArray <XMPPJID *> *roomowners; // ? 房间拥有者 类型: jid-multi
@property (nonatomic, strong) NSArray <NSString *>* presencebroadcast; // 广播其存在的角色 类型: list-multi 内容： moderator、participant、visitor (不太理解这是什么意思,按照我的理解，是类似进入或者加入群时候的广播:"***加入了房间")
@property (nonatomic, assign) BOOL isPublic; // 完全开放（在目录中列出房间，任何人都可以看到） 类型: boolean
@property (nonatomic, assign) BOOL isPersistent; // 持久性房间   类型: boolean
@property (nonatomic, assign) BOOL isModerated; // 房间是否需要审核   类型: boolean
@property (nonatomic, assign) BOOL isMembersOnly; // 仅对成员开放   类型: boolean
@property (nonatomic, assign) BOOL isAllowInvites; // 允许成员邀请其他人加入   类型: boolean
@property (nonatomic, assign) BOOL isPasswordProtected; // 需要密码才能进入  类型: boolean
@property (nonatomic, assign) BOOL isAllowWhois; // ？ 可以查询成员信息  类型:list-single (文档翻译为：能够发现占有者真实 JID 的角色，按照我的理解是可以查询成员的具体信息)
@property (nonatomic, assign) BOOL enableLogging; // 记录房间聊天  类型: boolean
@property (nonatomic, assign) BOOL isAllowChangeSubject; // 允许成员修改主题  类型: boolean
@property (nonatomic, assign) BOOL isReservedNick; // 仅允许注册昵称登录  类型: boolean
@property (nonatomic, assign) BOOL isAllowChangeNick; // 允许成员修改昵称  类型: boolean
@property (nonatomic, assign) BOOL isRegistration; // 允许成员注册房间  类型: boolean
@property (nonatomic, assign) BOOL isAllowPm; // 允许发送私有消息  list-single

- (NSXMLElement *)getRoomConfiguration;

- (NSString *)getConfigurationValueFrom:(LXRoomConfigurationType)type;

@end

@interface RoomManager : NSObject

+ (RoomManager *)sharedInstance;
// 从服务端 获取加入或者公开的群聊
- (void)fetchJoinedRoomList;
// 整理获取到的群数据
- (void)sortJoinedRoonFetchedResult:(XMPPIQ *)iq;
// 向服务端 发送room缓存数据
- (void)configureRoom:(XMPPRoom *)room WithConfiguration:(RoomConfiguration *)configuration;

#pragma mark --本地缓存数据--
// 从缓存中 获取room的配置信息
- (RoomConfiguration *)getConfigurationWith:(XMPPRoom *)room;
// 向缓存中 添加room配置数据
- (void)setConfigurationCache:(RoomConfiguration *)configuration toRoom:(XMPPRoom *)room;
// 删除room缓存数据
- (void)removeConfigurationFromRoom:(XMPPRoom *)room;
// 根据type获取对应的缓存数据
- (NSArray <XMPPJID *> *)getRoomCacheWith:(XMPPRoom *)room type:(LXRoomCachesType)type;
// 根据type设置对应的缓存数据
- (void)setRoomCachesWith:(XMPPRoom *)room items:(NSArray *)items type:(LXRoomCachesType)type;
// 根据type清空对应的缓存数据
- (void)removeRoomCacheWith:(XMPPRoom *)room type:(LXRoomCachesType)type;
// 根据type向对应的缓存中添加特定数据
- (void)addCacheToRoom:(XMPPRoom *)room item:(XMPPJID *)item type:(LXRoomCachesType)type;
// 根据type从对应的缓存中删除特定的数据
- (void)removeCacheFromRoom:(XMPPRoom *)room item:(XMPPJID *)item type:(LXRoomCachesType)type;

@end

NS_ASSUME_NONNULL_END

