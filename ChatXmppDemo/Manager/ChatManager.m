//
//  ChatManager.m
//  ChatXmppDemo
//
//  Created by 苗培根 on 2023/6/5.
//

#import "ChatManager.h"
#import "RoomManager.h"
#import "UIViewController+custom.h"

@interface ChatManager() <NSCopying,
NSMutableCopying,
XMPPStreamDelegate,
XMPPMessageArchivingStorage,
XMPPRosterDelegate,
XMPPRosterMemoryStorageDelegate,
//XMPPRosterStorage,
XMPPvCardAvatarStorage,
XMPPvCardTempModuleDelegate,
XMPPIncomingFileTransferDelegate,
XMPPReconnectDelegate,
XMPPvCardAvatarDelegate
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
    [self.roster addDelegate:self delegateQueue:dispatch_get_main_queue()];
    // 手动禁用自动获取名单
    self.roster.autoFetchRoster = NO;    
}

- (void)makeReconnect {
    self.reconnect = [[XMPPReconnect alloc] init];
    // 激活reconnect
    [self.reconnect activate:self.stream];
    [self.reconnect setAutoReconnect:YES];
    [self.reconnect addDelegate:self delegateQueue:dispatch_get_main_queue()];
}

- (void)makePing {
    self.autoPing = [[XMPPAutoPing alloc] init];
    // 激活autoPing
    [self.autoPing activate:self.stream];
    //autoping由于会定时发送ping，对方如果想表达自己是活跃的，应该返回一个ping
    // 有默认 分别60s和10s
//    [self.autoPing setPingInterval:1000];
//    [self.autoPing setPingTimeout:6000];
    
    // 不仅仅是服务器来的响应，如果是普通用户，也会响应
    [self.autoPing setRespondsToQueries:YES];
}

- (void)makevCard {
    self.cardCoreDataStorage = [XMPPvCardCoreDataStorage sharedInstance];
    
    self.cardTempModule = [[XMPPvCardTempModule alloc] initWithvCardStorage:self.cardCoreDataStorage];
    // 激活card
    [self.cardTempModule activate:self.stream];
    [self.cardTempModule addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    self.cardAvatarModule = [[XMPPvCardAvatarModule alloc] initWithvCardTempModule:self.cardTempModule];
    // 激活avatarmodule
    [self.cardAvatarModule activate:self.stream];
    [self.cardAvatarModule addDelegate:self delegateQueue:dispatch_get_main_queue()];
}

- (void)makeMessage {
    // 初试化聊天记录管理对象
    self.messageCoreDataStorage = [XMPPMessageArchivingCoreDataStorage sharedInstance];
    
    self.messageArchiving = [[XMPPMessageArchiving alloc] initWithMessageArchivingStorage:self.messageCoreDataStorage dispatchQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 9)];
    // 激活管理对象
    [self.messageArchiving activate:self.stream];
    // 设置代理
    [self.messageArchiving addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    self.messageContext = self.messageCoreDataStorage.mainThreadManagedObjectContext;
//    // 允许后台socket运行
//    self.stream.enableBackgroundingOnSocket = YES;
}

- (void)makeFileTransfer {
    self.incomingFileTransfer = [[XMPPIncomingFileTransfer alloc] initWithDispatchQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)];
    [self.incomingFileTransfer activate:self.stream];
    [self.incomingFileTransfer addDelegate:self delegateQueue: dispatch_get_main_queue()];
    [self.incomingFileTransfer setAutoAcceptFileTransfers:YES];
}

// 加入房间，如果房间不存在，那么新建房间
- (void)makeRoom:(NSString *)roomId usingNickname:(NSString *)nickname {
    
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
                            password:nil];
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

- (BOOL)xmppStream:(XMPPStream *)sender didReceiveIQ:(XMPPIQ *)iq {
    NSLog(@"%s  iq: %@",__func__, iq);
    // 处理获取到的消息
    [[RoomManager sharedInstance] sortJoinedRoonFetchedResult:iq];
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

#pragma mark --XMPPReconnectDelegate--

// xmpp意外断开连接
- (void)xmppReconnect:(XMPPReconnect *)sender didDetectAccidentalDisconnect:(SCNetworkConnectionFlags)connectionFlags {
    if (connectionFlags == kSCNetworkFlagsConnectionRequired) {
        NSLog(@"xmpp意外断开连接");
    }
    XMPPJID *myJid = [[UserManager sharedInstance].jid copy];
    // 清空本地用户数据
    [[UserManager sharedInstance] clearAll];
    
    [self connectToServerWithJID:myJid pasword:self.password type:LXConnectTypeLogin];
//    // 重新进行认证
//    NSError *error;
//    [[ChatManager sharedInstance].stream authenticateWithPassword:[UserManager sharedInstance].password error:&error];
//    if (error) {
//        NSLog(@"%s \n authenticateWithPassword:error: %@", __func__, [error localizedDescription]);
//    }
}

#pragma mark --XMPPRosterDelegate--
// 收到订阅请求
- (void)xmppRoster:(XMPPRoster *)sender didReceivePresenceSubscriptionRequest:(XMPPPresence *)presence {
    [[UserManager sharedInstance] addSubscribesWith:presence.from];
    
//    //示例代码，接受或拒绝好友请求
//    // 添加好友一定会订阅对方，但是接受订阅不一定要添加对方为好友
//    UIViewController *currentVC = [UIViewController currentVC];
//    [currentVC alertWithTitle: [NSString stringWithFormat:@"%@申请成为你的好友", presence.from.bare]
//                      message:nil
//                actionHandler:^(bool allow) {
//        if (allow) {
//            // 接收并添加到联系人
//            [self.roster acceptPresenceSubscriptionRequestFrom:presence.from andAddToRoster:YES];
//        } else {
//            // 拒绝
//            [self.roster rejectPresenceSubscriptionRequestFrom:presence.from];
//        }
//    }];
}

//// 开始同步服务器发送过来的自己的好友列表
//- (void)xmppRosterDidBeginPopulating:(XMPPRoster *)sender withVersion:(NSString *)version {
//}

// 获取好友列表
- (void)xmppRosterDidEndPopulating:(XMPPRoster *)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:kXMPP_ROSTER_DIDEND_POPULATING object:nil];
}

// 获取到一个好友节点（如果有多个好友，会多次回调）
- (void)xmppRoster:(XMPPRoster *)sender didReceiveRosterItem:(DDXMLElement *)item {
    NSLog(@"%s: %@", __func__, item);
    
    NSString *jidStr = [[item attributeForName:@"jid"] stringValue];
    XMPPJID *jid = [XMPPJID jidWithString:jidStr];
    // 好友，被订阅，订阅了对方
    if (item.subscriptionType & LXSubscriptionBoth ||
        item.subscriptionType & LXSubscriptionFrom ||
        item.subscriptionType & LXSubscriptionTo) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kXMPP_ROSTER_DIDRECEIVE_ROSTERITEM
                                                            object:nil
                                                          userInfo:@{@"isRemove": [NSNumber numberWithBool:NO],
                                                                     @"jid": jid}];
    }
    if (item.subscriptionType == LXSubscriptionRemove) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kXMPP_ROSTER_DIDRECEIVE_ROSTERITEM
                                                            object:nil
                                                          userInfo:@{@"isRemove": [NSNumber numberWithBool:YES],
                                                                     @"jid": jid}];
    } 
}

// 因为使用了XMPPRosterCoreDataStorage而非XMPPRosterMemoryStorage，所以XMPPRosterMemoryStorageDelegate目前是无效的
#pragma mark --XMPPRosterMemoryStorageDelegate--
// 如果不是初试化同步来的roster，自动存入我的好友存储器
- (void)xmppRosterDidChange:(XMPPRosterMemoryStorage *)sender {
    
}

- (void)xmppRosterDidPopulate:(XMPPRosterMemoryStorage *)sender {
    
}

- (void)xmppRoster:(XMPPRosterMemoryStorage *)sender didAddUser:(XMPPUserMemoryStorageObject *)user {
    
}

- (void)xmppRoster:(XMPPRosterMemoryStorage *)sender didUpdateUser:(XMPPUserMemoryStorageObject *)user {
    
}

- (void)xmppRoster:(XMPPRosterMemoryStorage *)sender didRemoveUser:(XMPPUserMemoryStorageObject *)user {
    
}

- (void)xmppRoster:(XMPPRosterMemoryStorage *)sender didAddResource:(XMPPResourceMemoryStorageObject *)resource withUser:(XMPPUserMemoryStorageObject *)user {
    
}

- (void)xmppRoster:(XMPPRosterMemoryStorage *)sender didUpdateResource:(XMPPResourceMemoryStorageObject *)resource withUser:(XMPPUserMemoryStorageObject *)user {
    
}

- (void)xmppRoster:(XMPPRosterMemoryStorage *)sender didRemoveResource:(XMPPResourceMemoryStorageObject *)resource withUser:(XMPPUserMemoryStorageObject *)user {
    
}

#pragma mark --XMPPIncomingFileTransferDelegate--
// 是否同意对方发文件给我
- (void)xmppIncomingFileTransfer:(XMPPIncomingFileTransfer *)sender didReceiveSIOffer:(XMPPIQ *)offer {
    NSLog(@"%s", __func__);
}

// 文件传输失败
- (void)xmppIncomingFileTransfer:(XMPPIncomingFileTransfer *)sender didFailWithError:(NSError *)error {
    NSLog(@"%s", __func__);
    if (!error) {
        return;
    }
//    [[NSNotificationCenter defaultCenter] postNotificationName:<#(nonnull NSNotificationName)#> object:<#(nullable id)#>];
}

// 接收文件成功
- (void)xmppIncomingFileTransfer:(XMPPIncomingFileTransfer *)sender didSucceedWithData:(NSData *)data named:(NSString *)name {
    XMPPJID *jid = [sender.senderJID copy];
    NSLog(@"%s", __func__);
    //在这个方法里面，我们通过带外来传输的文件 （带外 ？？？）
    //因此我们的消息同步器，不会帮我们自动生成Message,因此我们需要手动存储message
    //根据文件后缀名，判断文件我们是否能够处理，如果不能处理则直接显示。
    //图片 音频 （.wav,.mp3,.mp4)
    NSString *extension = [name pathExtension];
    if (![extension isEqualToString:@"wav"]) {
        return;
    }
    // 创建一个XMPPMessage对象，message必须要有from
    XMPPMessage *message = [XMPPMessage messageWithType:@"chat" to:jid];
    // 将这个文件的发送着添加到message的from
    [message addAttributeWithName:@"from" stringValue:sender.senderJID.bare];
    [message addSubject:@"audio"];
    
    NSString *path = [NSString filePathWithComponent:[XMPPStream generateUUID] extension:nil];
    [data writeToFile:path atomically:YES];
    
    [message addBody:path.lastPathComponent];
    
    [self.messageCoreDataStorage archiveMessage:message outgoing:NO xmppStream:self.stream];
}

#pragma mark --XMPPvCardTempModuleDelegate--
// 获取到一个联系人的名片信息(如果存在多个，也会多次回调)
- (void)xmppvCardTempModule:(XMPPvCardTempModule *)vCardTempModule didReceivevCardTemp:(XMPPvCardTemp *)vCardTemp forJID:(XMPPJID *)jid {
    // 打印用户信息
    XMPPvCardTemp *temp = [self.cardCoreDataStorage vCardTempForJID:jid xmppStream:self.stream];
    NSLog(@"xmppvCardTempModule:didReceivevCardTemp:  cardTemp: %@", temp);
    
    [[UserManager sharedInstance] didReceivevCardTemp:vCardTemp
                                               forJID:jid];
}

// 获取card信息失败
- (void)xmppvCardTempModule:(XMPPvCardTempModule *)vCardTempModule failedToFetchvCardForJID:(XMPPJID *)jid error:(DDXMLElement *)error {
    NSLog(@"%s error: %@", __func__, [error description]);
    if (!error) {
        return;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:kXMPP_VCARDTEMPMODULE_DIDRECEIVE_VCARDTEMP
                                                        object:[NSNumber numberWithBool:NO]];
}

// 名片信息更新成功
- (void)xmppvCardTempModuleDidUpdateMyvCard:(XMPPvCardTempModule *)vCardTempModule {
    NSLog(@"%s", __func__);
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kXMPP_VCARDTEMPMODULE_DIDUPDATE_MY_VCARD
                                                        object:[NSNumber numberWithBool:YES]];
}

// 更新名片信息失败
- (void)xmppvCardTempModule:(XMPPvCardTempModule *)vCardTempModule failedToUpdateMyvCard:(DDXMLElement *)error {
    NSLog(@"%s", __func__);
    if (!error) {
        return;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:kXMPP_VCARDTEMPMODULE_DIDUPDATE_MY_VCARD
                                                        object:[NSNumber numberWithBool:NO]];
}

#pragma mark --XMPPvCardAvatarDelegate--
// 收到新的头像信息
- (void)xmppvCardAvatarModule:(XMPPvCardAvatarModule *)vCardTempModule didReceivePhoto:(UIImage *)photo forJID:(XMPPJID *)jid {
    [[UserManager sharedInstance] didReceivePhoto:photo forJID:jid];
}

//- (void)archiveMessage:(XMPPMessage *)message outgoing:(BOOL)isOutgoing xmppStream:(XMPPStream *)stream {
//
//}
//
//- (BOOL)configureWithParent:(XMPPMessageArchiving *)aParent queue:(dispatch_queue_t)queue {
//
//}
//
//- (void)clearvCardTempForJID:(nonnull XMPPJID *)jid xmppStream:(nonnull XMPPStream *)stream {
//
//}
//
//- (nullable NSData *)photoDataForJID:(nonnull XMPPJID *)jid xmppStream:(nonnull XMPPStream *)stream {
//
//}
//
//- (nullable NSString *)photoHashForJID:(nonnull XMPPJID *)jid xmppStream:(nonnull XMPPStream *)stream {
//}


@end
