//
//  ChatManager.m
//  ChatXmppDemo
//
//  Created by 苗培根 on 2023/6/5.
//

#import "ChatManager.h"
#import "RoomManager.h"
#import "CardManager.h"
#import "FlieManager.h"
#import "RosterManager.h"
#import "MessageManager.h"
#import "AuxiliaryManager.h"
#import "UIViewController+custom.h"

@interface ChatManager() <NSCopying,
NSMutableCopying,
XMPPStreamDelegate
> {
    
}

@property (nonatomic, copy) NSString *password;
//@property (nonatomic, copy) NSString *registerPassword;
@property (nonatomic, assign, readwrite) LXConnectType connectType;

@end

@implementation ChatManager
static ChatManager *_sharedInstance;

+ (ChatManager *)sharedInstance {
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

- (XMPPStream *)stream {
    if (!_stream) {
        [self makeStream];
        [self makeRoster];
        [self makeReconnect];
        [self makePing];
        [self makevCard];
        [self makeMessage];
        [self makeFileTransfer];
    }
    return _stream;
}

- (void)makeStream {
    self.stream = [[XMPPStream alloc] init];
    self.stream.hostName = kHostName;
    self.stream.hostPort = kHostPort;
    // 设置stream的代理
    [self.stream addDelegate:self delegateQueue:dispatch_get_main_queue()];
}

- (void)makeRoster {
    self.rosterCoreDataStorage = [XMPPRosterCoreDataStorage sharedInstance];
    
    self.roster = [[XMPPRoster alloc] initWithRosterStorage:self.rosterCoreDataStorage dispatchQueue:dispatch_get_global_queue(0, 0)];
    //激活roster
    [self.roster activate:self.stream];
    // 设置roster代理
    [self.roster addDelegate:[RosterManager sharedInstance] delegateQueue:dispatch_get_main_queue()];
    // 手动禁用自动获取名单
    self.roster.autoFetchRoster = NO;    
}

- (void)makeReconnect {
    self.reconnect = [[XMPPReconnect alloc] init];
    // 激活reconnect
    [self.reconnect activate:self.stream];
    [self.reconnect setAutoReconnect:YES];
    [self.reconnect addDelegate:[AuxiliaryManager sharedInstance] delegateQueue:dispatch_get_main_queue()];
}

- (void)makePing {
    self.autoPing = [[XMPPAutoPing alloc] init];
    // 激活autoPing
    [self.autoPing activate:self.stream];
    //autoping由于会定时发送ping，对方如果想表达自己是活跃的，应该返回一个ping
    // 有默认 分别60s和10s
//    [self.autoPing setPingInterval:1000];
//    [self.autoPing setPingTimeout:6000];
    
    [self.autoPing addDelegate:[AuxiliaryManager sharedInstance] delegateQueue:dispatch_get_main_queue()];
    // 不仅仅是服务器来的响应，如果是普通用户，也会响应
    [self.autoPing setRespondsToQueries:YES];
}

- (void)makevCard {
    self.cardCoreDataStorage = [XMPPvCardCoreDataStorage sharedInstance];
    
    self.cardTempModule = [[XMPPvCardTempModule alloc] initWithvCardStorage:self.cardCoreDataStorage];
    // 激活card
    [self.cardTempModule activate:self.stream];
    [self.cardTempModule addDelegate:[CardManager sharedInstance] delegateQueue:dispatch_get_main_queue()];
    
    self.cardAvatarModule = [[XMPPvCardAvatarModule alloc] initWithvCardTempModule:self.cardTempModule];
    // 激活avatarmodule
    [self.cardAvatarModule activate:self.stream];
    [self.cardAvatarModule addDelegate:[CardManager sharedInstance] delegateQueue:dispatch_get_main_queue()];
}

- (void)makeMessage {
    // 初试化聊天记录管理对象
    self.messageCoreDataStorage = [XMPPMessageArchivingCoreDataStorage sharedInstance];
    
    self.messageArchiving = [[XMPPMessageArchiving alloc] initWithMessageArchivingStorage:self.messageCoreDataStorage dispatchQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 9)];
    // 激活管理对象
    [self.messageArchiving activate:self.stream];
    // 设置代理
    [self.messageArchiving addDelegate:[MessageManager sharedInstance] delegateQueue:dispatch_get_main_queue()];
    
    self.messageContext = self.messageCoreDataStorage.mainThreadManagedObjectContext;
//    // 允许后台socket运行
//    self.stream.enableBackgroundingOnSocket = YES;
}

- (void)makeFileTransfer {
    self.incomingFileTransfer = [[XMPPIncomingFileTransfer alloc] initWithDispatchQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)];
    [self.incomingFileTransfer activate:self.stream];
    [self.incomingFileTransfer addDelegate:[FlieManager sharedInstance] delegateQueue: dispatch_get_main_queue()];
    [self.incomingFileTransfer setAutoAcceptFileTransfers:YES];
}

// 加入房间，如果房间不存在，那么新建房间
- (void)makeRoom:(NSString *)roomId usingNickname:(NSString *)nickname {
    [self makeRoom:roomId
     usingNickname:nickname
          password:nil];
}

- (void)makeRoom:(NSString *)roomId
   usingNickname:(NSString *)nickname
        password:(NSString *)password
{
    XMPPJID *roomJid = [XMPPJID jidWithString:roomId];
    
    self.roomCoreDataStorage = [XMPPRoomCoreDataStorage sharedInstance];
    // 添加代理
    self.room = [[XMPPRoom alloc] initWithRoomStorage:self.roomCoreDataStorage
                                                  jid:roomJid
                                        dispatchQueue:dispatch_get_main_queue()];
    // 激活
    [self.room activate:self.stream];
    [self.room addDelegate:[RoomManager sharedInstance]
             delegateQueue:dispatch_get_main_queue()];
    // 加入房间
    [self.room joinRoomUsingNickname:nickname
                             history: nil
                            password:password];
}

#pragma mark -- selector
// 登录
// 例如： [[ChatManager sharedInstance] loginWithJID:[XMPPJID jidWithUser:username domain:kXMPP_DOMAIN resource:kXMPP_RESOURCE] password:password];
- (void)loginWithJID:(XMPPJID *)jid password:(NSString *)password {
    [self connectToServerWithJID:jid pasword:password type:LXConnectTypeLogin];
}

// 注册
// 例如： [[ChatManager sharedInstance] registerWithJID:[XMPPJID jidWithUser:username domain:kXMPP_DOMAIN resource:kXMPP_RESOURCE] password:password];
- (void)registerWithJID:(XMPPJID *)jid password:(NSString *)password {
    [self connectToServerWithJID:jid pasword:password type:LXConnectTypeRegister];
}

// 退出
- (void)loginOut {
    // 清空本地用户数据
    [[UserManager sharedInstance] clearAll];
    [self.stream disconnect];
    [self.stream removeDelegate:self];
    self.reconnect.autoReconnect = NO;
    [self.reconnect deactivate];
    [self.autoPing deactivate];
    [self.roster deactivate];
    [self.messageArchiving deactivate];
    [self.incomingFileTransfer deactivate];
    [self.cardAvatarModule deactivate];
    [self.cardTempModule deactivate];
    [self.room deactivate];
    self.stream = nil;
}

// 新建名片，根据username
- (void)setCardTempModuleWithUsername:(NSString *)username {
    XMPPvCardTemp *temp = [XMPPvCardTemp vCardTemp];
    temp.nickname = username;
    // 更新自己的名片信息
    [self.cardTempModule updateMyvCardTemp:temp];
}

// 建立链接
- (void)connectToServerWithJID:(XMPPJID *)jid pasword:(NSString *)password type:(LXConnectType)type {
    if ([self.stream isConnected]) {
        [self.stream disconnect];
    }
    [self.stream setMyJID:jid];
    self.password = password;
    self.connectType = type;
    NSError *error;
    [self.stream connectWithTimeout:30.0f error:&error];
    if (error) {
        NSLog(@"%@", [NSString stringWithFormat:@"connectToServer error %@", [error localizedDescription]]);
    }
}

// 根据jid获取群、联系人信息
- (void)fetchInformationWith:(NSString *)jid {
    NSString *myJid = [UserManager sharedInstance].jid.bare;
    XMPPIQ *iq = [XMPPIQ iqWithType:@"get"];
    [iq addAttributeWithName:@"from" stringValue: myJid];
    [iq addAttributeWithName:@"id" stringValue:@"disco-1"];
    [iq addAttributeWithName:@"to" stringValue:jid];
    
    NSXMLElement* element = [NSXMLElement elementWithName:@"query" xmlns:@"http://jabber.org/protocol/disco#info"];
    [iq addChild:element];
    
    [self.stream sendElement:iq];
}

#pragma mark -- XMPPStreamDelegate --
- (void)xmppStream:(XMPPStream *)sender socketDidConnect:(GCDAsyncSocket *)socket {
    NSLog(@"%s socket 建立连接成功", __func__);
}

// xml初试化成功
- (void)xmppStreamDidConnect:(XMPPStream *)sender {
    NSError *error;
    if (self.connectType == LXConnectTypeRegister) {
        bool result = [self.stream registerWithPassword:self.password error:&error];
        if (!result || error != nil) {
            NSLog(@"%s 注册失败 error: %@", __func__, [error localizedDescription]);
//            return;
        }
//        NSNumber *resultNumber = [NSNumber numberWithBool:result];
//        [[NSNotificationCenter defaultCenter] postNotificationName:kXMPP_REGIST_RESULT object:resultNumber];
    } else {
        [self.stream authenticateWithPassword:self.password error:&error];
        if (error) {
            NSLog(@"%s 认证失败 error %@", __func__, [error localizedDescription]);
        }
    }
}

- (void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error {
    NSLog(@"%s 断开连接 error: %@", __func__, [error localizedDescription]);
}

#warning mark --注册结果走xmppStreamDidRegister还是xmppStreamDidConnect的判断结果都可以, 但是xmppStreamDidConnect里面的判断结果会导致 [stream isConnected]判断错误, xmppStreamDidRegister等回调里面[stream isConnected]才是正确的
// 注册失败
- (void)xmppStream:(XMPPStream *)sender didNotRegister:(DDXMLElement *)error {
    NSLog(@"%s 注册连接 error: %@", __func__, [error description]);
    if (!error) {
        return;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:kXMPP_REGIST_RESULT object:[NSNumber numberWithBool:NO]];
}
//
// 注册成功
- (void)xmppStreamDidRegister:(XMPPStream *)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:kXMPP_REGIST_RESULT object:[NSNumber numberWithBool:YES]];
}

// 认证失败
- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(DDXMLElement *)error {
    NSLog(@"%s 认证失败 error: %@", __func__, [error description]);
    if (!error) {
        return;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:kXMPP_DIDNOT_AUTHENTICATE object:nil];
}

// 认证成功
- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender {
    XMPPPresence *presence = [XMPPPresence presenceWithType:@"available"];
    [self.stream sendElement:presence];
//    [self.roster fetchRoster];
    [[NSNotificationCenter defaultCenter] postNotificationName:kXMPP_LOGIN_SUCCESS object:nil];
    // 认证成功 ---- 与登录成功仅需一个
    [[NSNotificationCenter defaultCenter] postNotificationName:kXMPP_DID_AUTHENTICATE object:nil];
    
}

#warning mark --有多个状态数据未进行处理
// 收到presence(联系人状态等信息)
// 这个方法不能用来获取好友列表，只能获取到线上好友信息，如果好友没上线，这个方法就无法获取这个好友的信息，
- (void)xmppStream:(XMPPStream *)sender didReceivePresence:(XMPPPresence *)presence {
    
    NSLog(@"%s 获取到在线联系人信息 ID: %@, 状态: %@ 全部状态",__func__, presence.from, presence.type);
    
    switch (presence.presenceType) {
        case LXPresenceTypeAvailabel:
            [[UserManager sharedInstance] changeContactWithJID:presence.from isAvailable:YES];
            break;
        case LXPresenceTypeUnavailable:
            [[UserManager sharedInstance] changeContactWithJID:presence.from isAvailable:NO];
            break;
        case LXPresenceTypeUnsubscribe:
            // 从我本地通讯录中将它删除
            [self.roster removeUser:presence.from];
            break;
        case LXPresenceTypeError:
            [presence sortPresenceError];
            break;
        default:
            break;
    }
}

- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message {
    NSLog(@"%s", __func__);
    
    bool isRequest = YES;
    // XEP--0136 已经用coreData实现了数据的接受和保存
    NSXMLElement *request = [message elementForName:@"request"];
    if (request) {
        if (![request.xmlns isEqualToString:@"urn:xmpp:receipts"]) { // 如果不是消息回执
            return;
        }
        // 组装消息回执
        NSXMLElement *recieved = [NSXMLElement elementWithName:@"received" xmlns:@"urn:xmpp:receipts"];
        XMPPMessage *msg = [XMPPMessage messageWithType:[message attributeStringValueForName:@"type"] to:message.from elementID:[message attributeStringValueForName:@"id"] child:recieved];
        // 发送回执
        [[ChatManager sharedInstance].stream sendElement:msg];
    } else {
        NSXMLElement *received = [message elementForName:@"received"];
        if (!received || ![received.xmlns isEqualToString:@"urn:xmpp:receipts"]) { // 判断是否是消息回执
            return;
        }
        isRequest = NO;
        NSLog(@"消息回执发送成功");
    }
    // 通知，收到消息
    [[NSNotificationCenter defaultCenter] postNotificationName:kXMPP_DIDREVEICE_MESSAGE
                                                        object:message
                                                      userInfo:@{@"isRequest": [NSNumber numberWithBool:isRequest]}
    ];
}

// 会收到各种信息，包括房间列表、房间信息、用户信息等等
- (BOOL)xmppStream:(XMPPStream *)sender didReceiveIQ:(XMPPIQ *)iq {
    NSLog(@"%s  iq: %@",__func__, iq);
    // 处理获取到的消息
    [[RoomManager sharedInstance] sortIqForRoom:iq];
    return YES;
}

// 自己发送的消息
- (void)xmppStream:(XMPPStream *)sender didSendMessage:(XMPPMessage *)message {
    [[NSNotificationCenter defaultCenter] postNotificationName:kXMPP_DIDSEND_MESSAGE
                                                        object:message];
}

// 发送消息失败
- (void)xmppStream:(XMPPStream *)sender didFailToSendMessage:(XMPPMessage *)message error:(NSError *)error {
    if (!error) {
        return;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:kXMPP_DIDFAIL_TOSEND_MESSAGE
                                                        object:message
                                                      userInfo:@{@"error": error}];
}

@end
