//
//  RoomConfiguration.h
//  ChatXmppDemo
//
//  Created by 苗培根 on 2023/6/25.
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
    LXRoomConfigurationPM,  // 是否允许发送私有消息
    LXRoomConfigurationUnknow, // 未知类型，需要另作处理
} LXRoomConfigurationType;

typedef enum : NSUInteger {
    LXFieldNodeBoolean,   // bool
    LXFieldNodeTextSingle,  // 单选文本
    LXFieldNodeTextPrivate, // 隐私文本
    LXFieldNodeJIDMulti,   // 多选jid，实质是文本，XMPPJid.bare
    LXFieldNodeListSingle, // 单选列表，从系统提供的选项中选一个，本质是文本
    LXFieldNodeListMulti,  // 多选文本，从系统提供的选项中选多个，本质是文本
    LXFieldNodeFixed,    // 提示信息，不必进行解析
    LXFieldNodeUnknow, // 未知类型
} LXFieldNodeType;

NS_ASSUME_NONNULL_BEGIN
// 具体描述和指令key在RoomConfiguration实现文件内
@interface RoomConfiguration : NSObject

@property (nonatomic, copy) NSString *roomName; // 房间名称 类型: text-single
@property (nonatomic, copy) NSString *roomDesc; // 房间描述 类型: text-single
@property (nonatomic, copy) NSString *roomSecret; // 房间密码 类型: text-private

@property (nonatomic, strong) NSArray <NSString *> *roomadmins; // 房间管理员 类型: jid-multi 内容举例: 123@lxdev.cn,也就是jid.bare
@property (nonatomic, strong) NSArray <NSString *> *roomowners; // 房间拥有者 类型: jid-multi

@property (nonatomic, assign) BOOL isPublic; // 完全开放（在目录中列出房间，任何人都可以看到） 类型: boolean
@property (nonatomic, assign) BOOL isPersistent; // 持久性房间   类型: boolean
@property (nonatomic, assign) BOOL isModerated; // 房间是否需要审核   类型: boolean
@property (nonatomic, assign) BOOL isMembersOnly; // 仅对成员开放   类型: boolean
@property (nonatomic, assign) BOOL isAllowInvites; // 允许成员邀请其他人加入   类型: boolean, 默认情况下，只有管理员才可以在仅用于邀请的房间中发送邀请
@property (nonatomic, assign) BOOL isPasswordProtected; // 需要密码才能进入  类型: boolean, 如果需要密码才能进入房间，则必须指定密码
@property (nonatomic, assign) BOOL enableLogging; // 记录房间聊天  类型: boolean
@property (nonatomic, assign) BOOL isAllowChangeSubject; // 允许成员修改主题  类型: boolean
@property (nonatomic, assign) BOOL isReservedNick; // 仅允许注册昵称登录  类型: boolean
@property (nonatomic, assign) BOOL isAllowChangeNick; // 允许成员修改昵称  类型: boolean
@property (nonatomic, assign) BOOL isRegistration; // 允许成员注册房间  类型: boolean

@property (nonatomic, strong) NSArray <NSString *>* presencebroadcast; // 广播其存在的角色 类型: list-multi，可多选 内容： moderator、participant、visitor (是类似进入或者加入群时候的广播:"***加入了房间")

@property (nonatomic, copy) NSString *maxusers; // 房间最大人数 类型: list-single, 单选 内容: 10~50， 也可以自定义
@property (nonatomic, copy) NSString *pm; // 允许发送私有消息  list-single,单选 内容: anyone、moderators、participants、none
@property (nonatomic, copy) NSString *whois; // 谁可以查询成员信息  类型:list-single,单选 内容： moderators、anyone，默认是anyone (文档翻译为：能够发现占有者真实 JID 的角色，按照我的理解是可以查询成员的具体信息的角色)


- (NSXMLElement *)getRoomConfiguration;

- (nullable NSString *)getConfigurationValueFrom:(LXRoomConfigurationType)type;

- (instancetype)initWithXMLElement:(NSXMLElement *)element;

@end

NS_ASSUME_NONNULL_END
