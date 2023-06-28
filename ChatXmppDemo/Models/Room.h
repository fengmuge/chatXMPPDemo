//
//  Room.h
//  ChatXmppDemo
//
//  Created by 苗培根 on 2023/6/21.
//

#import <UIKit/UIKit.h>
@class RoomConfiguration;

typedef enum : NSUInteger {
    LXRoomInfoFieldDesc = 0,  // 房间 描述
    LXRoomInfoFieldSubject,  // 房间主题
    LXRoomInfoFieldOccupants, // 房间在线人数
    LXRoomInfoFieldCreateDate, // 房间创建时间
    LXRoomInfoFieldFormType, // 表单类型
    LXRoomInfoFieldUnknow, // 未知类型,用于容错
} LXRoomInfoFieldType;

typedef enum : NSUInteger {
    LXRoomInfoFeatureFullyAnonymous = 0, // (全匿名房间) 一个房间的房客的全JID或纯JID不能被任何人查询到, 包括房间管理员和房间所有者; 这类房间是不推荐的(NOT RECOMMENDED)或不被MUC显式支持, 但是如果一个服务提供适当的配置选项来使用这个协议，这种情况也是有可能的; 相对的则是非匿名房间和半匿名房间.
    LXRoomInfoFeatureNonAnonymous = 1, // (非匿名房间) -- 一个房客的全JID会暴露给所有其他房客的房间, 尽管房客可以选择任何期望的房间昵称; 相对的是半匿名房间和全匿名房间.
    LXRoomInfoFeatureSemiAnonymous = 2, // (半匿名房间) -- 一个房客的全JID只能被房间管理员发现的房间; 相对的是全匿名房间和非匿名房间.
    LXRoomInfoFeatureHiddenRoom = 3, // (隐藏房间) -- 一个无法被任何用户以普通方法如搜索和服务查询来发现的房间; 反义词: 公开(public)房间.
    LXRoomInfoFeaturePublicRoom = 4, // (公开房间) -- 用户可以通过普通方法如搜索和服务查询来发现的房间; 反义词: 隐藏房间.
    LXRoomInfoFeatureOpenRoom = 5, // (开放房间) -- 任何人可以加入而不需要在成员列表中的房间; 反义词: 仅限会员的房间.
    LXRoomInfoFeatureMemberOnly = 6, // (仅限会员的房间) -- 如果一个用户不在成员列表中则无法加入的一个房间; 反义词: 开放(open)房间.
    LXRoomInfoFeatureModeratedRoom = 7, // (被主持的房间) -- 只有有"发言权"的用户才可以发送消息给所有房客的房间; 反义词: 非主持的(Unmoderated)房间.
    LXRoomInfoFeatureUnmoderatedRoom = 8, // (非主持的房间) -- 任何房客都被允许发送消息给所有房客的房间; 反义词: 被主持的房间.
    LXRoomInfoFeaturePasswordProtected = 9, // (密码保护房间) -- 一个用户必须提供正确密码才能加入的房间; 反义词: 非保密房间.
    LXRoomInfoFeatureUnsecured = 10,   // (非保密房间) -- 任何人不需要提供密码就可以进入的房间; 反义词: 密码保护房间.
    LXRoomInfoFeaturePersistent = 11, // (持久房间) -- 如果最后一个房客退出也不会被销毁的房间; 反义词: 临时房间.
    LXRoomInfoFeatureTemporary = 12, // (临时房间) -- 如果最后一个房客退出就会被销毁的房间; 反义词: 持久房间.
    LXRoomInfoFeatureUnknow = 13, // 未知类型，用于容错
} LXRoomInfoFeatureType;

NS_ASSUME_NONNULL_BEGIN

//@interface RoomField : NSObject
//
//@property (nonatomic, assign, readonly) LXRoomInfoFieldType fieldType;
//@property (nonatomic, assign, readonly) NSString *infoValue;
//
//- (instancetype)initWithVar:(NSString *)var
//                       type:(NSString *)type
//                      label:(NSString *)label
//                      value:(NSString *)value;
//
//@end

@interface Room : NSObject

@property (nonatomic, strong, readonly) XMPPRoom *room;
@property (nonatomic, strong, readonly) DDXMLElement *xmlElement;
@property (nonatomic, strong, readonly) RoomConfiguration *configuration;

@property (nonatomic, strong, readonly) NSString *roomJidvalue;
@property (nonatomic, strong, readonly) XMPPJID *roomJid;

@property (nonatomic, copy, readonly) NSString *name; // 房间名称
@property (nonatomic, copy, readonly) NSString *category; // 类别
@property (nonatomic, copy, readonly) NSString *type; // 类型
@property (nonatomic, copy, readonly) NSString *subject;
@property (nonatomic, copy, readonly) NSString *createTime; //

@property (nonatomic, strong, readonly) XMPPJID *myRoomJid;
@property (nonatomic, copy, readonly) NSString *myRoomNickname;

@property (nonatomic, assign, readonly) BOOL isJoined;

@property (nonatomic, assign, readonly) int occupants; // 使用者数量

@property (nonatomic, assign, readonly) BOOL isFetchDetail;

- (void)setIq:(XMPPIQ *)iq;
- (void)setRoom:(XMPPRoom * _Nonnull)room;
- (void)removeRoom;
- (void)setXmlElement:(DDXMLElement * _Nonnull)xmlElement;
- (void)setConfiguration:(RoomConfiguration * _Nonnull)configuration;

@end

NS_ASSUME_NONNULL_END
