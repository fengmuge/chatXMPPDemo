//
//  ChatManager.h
//  ChatXmppDemo
//
//  Created by 苗培根 on 2023/6/5.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    LXConnectTypeLogin,
    LXConnectTypeRegister,
} LXConnectType;

NS_ASSUME_NONNULL_BEGIN

@interface ChatManager : NSObject

+ (ChatManager *)sharedInstance;

@property (nonatomic, strong, nullable) XMPPStream * stream;

// 辅助
@property (nonatomic, strong) XMPPAutoPing *autoPing;
// 自动链接
@property (nonatomic, strong) XMPPReconnect *reconnect;

// 联系人
@property (nonatomic, strong) XMPPRoster *roster;
@property (nonatomic, strong) XMPPRosterMemoryStorage *rosterMemoryStorage;
@property (nonatomic, strong) XMPPRosterCoreDataStorage *rosterCoreDataStorage;

// 消息
@property (nonatomic, strong) XMPPMessageArchiving *messageArchiving;
//@property (nonatomic, strong) XMPPMessageArchiveManagement *messageArchiving;
@property (nonatomic, strong) XMPPMessageArchivingCoreDataStorage *messageCoreDataStorage;
@property (nonatomic, strong) NSManagedObjectContext *messageContext;

// 群
@property (nonatomic, strong) XMPPRoom *room;
@property (nonatomic, strong) XMPPRoomMemoryStorage *roomMemoryStorage;
@property (nonatomic, strong) XMPPRoomCoreDataStorage *roomCoreDataStorage;

// 电子名片相关
@property (nonatomic, strong) XMPPvCardTempModule *cardTempModule;
@property (nonatomic, strong) XMPPvCardCoreDataStorage *cardCoreDataStorage;
@property (nonatomic, strong) XMPPvCardAvatarModule *cardAvatarModule;

// 文件接收
@property (nonatomic, strong) XMPPIncomingFileTransfer *incomingFileTransfer;


@property (nonatomic, assign) bool needRegister;
@property (nonatomic, assign, readonly) LXConnectType connectType;

// 登录
- (void)loginWithJID:(XMPPJID *)jid password:(NSString *)password;
// 注册
- (void)registerWithJID:(XMPPJID *)jid password:(NSString *)password;
// 退出
- (void)loginOut;
// 新建XMPPvCardTemp对象
- (void)setCardTempModuleWithUsername:(NSString *)username;
// 加入房间，如果房间不存在，那么创建房间  nickname 加入房间使用的昵称,默认为用户昵称
- (void)makeRoom:(NSString *)roomId usingNickname:(NSString *)nickname;

@end

NS_ASSUME_NONNULL_END
