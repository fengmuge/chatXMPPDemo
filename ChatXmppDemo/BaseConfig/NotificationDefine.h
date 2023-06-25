//
//  NotificationDefine.h
//  ChatXmppDemo
//
//  Created by 苗培根 on 2023/6/12.
//

#ifndef NotificationDefine_h
#define NotificationDefine_h

// 联系人同步完成
#define kXMPP_ROSTER_DIDEND_POPULATING @"kXMPP_ROSTER_DIDEND_POPULATING"
// 获取好友信息
#define kXMPP_ROSTER_DIDRECEIVE_ROSTERITEM @"kXMPP_ROSTER_DIDRECEIVE_ROSTERITEM"
// 将订阅请求添加到缓存
#define kXMPP_ADD_SUBSCRIPTION @"kXMPP_ADD_SUBSCRIPTION"
// 订阅他人的请求结果
#define kXMPP_SUBSCRIPTION_OTHER_RESULT @"kXMPP_SUBSCRIPTION_OTHER_RESULT"
// 获取到群数据
#define kXMPP_FETCHED_GROUPS @"kXMPP_FETCHED_GROUPS"
// xmpp登录成功
#define kXMPP_LOGIN_SUCCESS @"kXMPP_LOGIN_SUCCESS"
// xmpp认证失败
#define kXMPP_DIDNOT_AUTHENTICATE @"kXMPP_DIDNOT_AUTHENTICATE"
// xmpp认证成功
#define kXMPP_DID_AUTHENTICATE @"kXMPP_DID_AUTHENTICATE"
// xmpp注册结果
#define kXMPP_REGIST_RESULT @"kXMPP_REGIST_RESULT"
// 联系人available状态改变
#define kXMPP_CONECT_AVAILABLE_CHANGE @"kXMPP_CONECT_AVAILABLE_CHANGE"
// 获取名片信息 object 为bool 获取成功 YES
#define kXMPP_VCARDTEMPMODULE_DIDRECEIVE_VCARDTEMP @"kXMPP_VCARDTEMPMODULE_DIDRECEIVE_VCARDTEMP"
// 更新我的名片 object 为bool 获取成功 YES
#define kXMPP_VCARDTEMPMODULE_DIDUPDATE_MY_VCARD @"kXMPP_VCARDTEMPMODULE_DIDUPDATE_MY_VCARD"
// 更新头像信息
#define kXMPP_AVATAR_DIDRECEIVE_PHOTO @"kXMPP_AVATAR_DIDRECEIVE_PHOTO"
// 收到消息
#define kXMPP_DIDREVEICE_MESSAGE @"kXMPP_DIDREVEICE_MESSAGE"
// 发送消息
#define kXMPP_DIDSEND_MESSAGE @"kXMPP_DIDSEND_MESSAGE"
// 发送消息失败
#define kXMPP_DIDFAIL_TOSEND_MESSAGE @"kXMPP_DIDFAIL_TOSEND_MESSAGE"
// 房间创建成功
#define kXMPP_ROOM_DID_CREATE @"kXMPP_ROOM_DID_CREATE"
// 房间配置获取成功
#define kXMPP_ROOM_DIDFETCH_CONFIGURATIONFORM @"kXMPP_ROOM_DIDFETCH_CONFIGURATIONFORM"
// 即将发送配置
#define kXMPP_ROOM_WILLSEND_CONFIGURATION @"kXMPP_ROOM_WILLSEND_CONFIGURATION"
// 房间配置结果
#define kXMPP_ROOM_CONFIGURE_RESULT @"kXMPP_ROOM_CONFIGURE_RESULT"
// 加入房间成功
#define kXMPP_ROOM_DID_JOIN @"kXMPP_ROOM_DID_JOIN"
// 离开房间
#define kXMPP_ROOM_DID_LEAVE @"kXMPP_ROOM_DID_LEAVE"
// 房间销毁结果
#define kXMPP_ROOM_DESTROY_RESULT @"kXMPP_ROOM_DESTROY_RESULT"
// 成员加入房间
#define kXMPP_ROOM_OCCUPANT_DID_JOIN @"kXMPP_ROOM_OCCUPANT_DID_JOIN"
// 成员离开房间
#define kXMPP_ROOM_OCCUPANT_DID_LEAVE @"kXMPP_ROOM_OCCUPANT_DID_LEAVE"
// 成员信息更新
#define kXMPP_ROOM_OCCUPANT_DID_UPDATE @"kXMPP_ROOM_OCCUPANT_DID_UPDATE"
// 收到成员发来的消息
#define kXMPP_ROOM_DIDRECEIVE_MESSAGE_FROM_OCCUPANT @"kXMPP_ROOM_DIDRECEIVE_MESSAGE_FROM_OCCUPANT"
// 获取被禁成员列表结果
#define kXMPP_ROOM_FETCHBANLIST_RESULT @"kXMPP_ROOM_FETCHBANLIST_RESULT"
// 获取群成员列表结果
#define kXMPP_ROOM_FETCHMEMBERSLIST_RESULT @"kXMPP_ROOM_FETCHMEMBERSLIST_RESULT"
// 获取管理员列表结果
#define kXMPP_ROOM_FETCHADMINSLIST_RESULT @"kXMPP_ROOM_FETCHADMINSLIST_RESULT"
// 获取群拥有者列表结果
#define kXMPP_ROOM_FETCHOWNERSLIST_RESULT @"kXMPP_ROOM_FETCHOWNERSLIST_RESULT"
// 获取审核员列表结果
#define kXMPP_ROOM_FETCHMODERATORSLIST_RESULT @"kXMPP_ROOM_FETCHMODERATORSLIST_RESULT"
// 编辑群权限结果
#define kXMPP_ROOM_EDITPRIVILEGES_RESULT @"kXMPP_ROOM_EDITPRIVILEGES_RESULT"
// 房间主题变更
#define kXMPP_ROOM_DIDCHANGE_SUBJIEC @"kXMPP_ROOM_DIDCHANGE_SUBJIEC"

#endif /* NotificationDefine_h */