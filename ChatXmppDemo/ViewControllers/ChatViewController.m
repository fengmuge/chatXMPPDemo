//
//  ChatViewController.m
//  ChatXmppDemo
//
//  Created by 苗培根 on 2023/6/5.
//

#import "ChatViewController.h"
#import "RoomSettingViewController.h"
#import "User.h"
#import "Room.h"
#import "RoomManager.h"
#import "AudioManager.h"
#import "MessageManager.h"
#import "LXMessage.h"
#import "TranscribeVoiceView.h"
#import "XMPPMessage+custom.h"

@interface ChatViewController ()

@property (nonatomic, strong) NSMutableArray *messages;
@property (nonatomic, strong) JSQMessagesBubbleImage *myBubble;
@property (nonatomic, strong) JSQMessagesBubbleImage *otherBubble;
// 消息发送状态
@property (nonatomic, assign) LXMessageSendStatus status;

@property (nonatomic, strong) UIRefreshControl *refreshControl;

@property (nonatomic, strong, readonly) User *sender;
@property (nonatomic, strong, readonly) JSQMessagesComposerTextView *textView;

@property (nonatomic, strong) TranscribeVoiceView *voiceView;
@property (nonatomic, strong) UIButton *recordButton;

@end

@implementation ChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setNavgationControllerTitle];
    self.view.backgroundColor = [[UIColor greenColor] colorWithAlphaComponent:0.75];
    [self setLeftNavgationBarItem];
    [self setRightNavgationBar];
    [self configureInputbar];
    [self makeMessageBubble];
    [self addNotification];
    [self joinRoom];
    [self getHistoryMessage];
    [[AudioManager sharedInstance] setAudioSession];
}

- (void)dealloc {
    [self.room removeRoom];
}

- (User *)sender {
    return [UserManager sharedInstance].user;
}

- (JSQMessagesComposerTextView *)textView {
    return self.inputToolbar.contentView.textView;
}

- (void)setNavgationControllerTitle {
    if (self.room) {
        self.title = self.room.name;
        return;
    }
    if (!self.contact) {
        self.title = @"单聊";
        return;
    }
    
    if (self.contact.vCard.nickname) {
        self.title = self.contact.vCard.nickname;
    } else {
        self.title = self.contact.jid.user;
    }
}

- (void)setRightNavgationBar {
    if (!self.room) {
        return;
    }
    
    [self setRightNavgationBarItemWithTarget:self
                                    selector:@selector(rightNavgationbarClicked)
                                       title:@"群设置"
                                  titleColor:nil];
}

- (void)rightNavgationbarClicked {
    RoomSettingViewController *settingVC = [[RoomSettingViewController alloc] init];
    settingVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:settingVC animated:YES];
}

- (void)configureInputbar {
    
    [self.inputToolbar setTranslucent:YES];
    [self setInputBarLeftButton];
    [self setInputBarRightButton];
    self.inputToolbar.preferredDefaultHeight = 44 + KPhonexSafeBottomHeight;
    self.textView.placeHolder = @"请输入你想说的话~";
    self.textView.placeHolderTextColor = [[UIColor grayColor] colorWithAlphaComponent:0.75];
}

- (void)setInputBarRightButton {
    UIButton *sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [sendButton setTitle:@"发送" forState:UIControlStateNormal];
    [sendButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [sendButton setTitleColor:[[UIColor redColor] colorWithAlphaComponent:0.75] forState:UIControlStateHighlighted];
    [sendButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];

    sendButton.titleLabel.font = kFont_PFSC_semibold_17;
    sendButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    sendButton.titleLabel.minimumScaleFactor = 0.85f;
    sendButton.contentMode = UIViewContentModeCenter;
    sendButton.backgroundColor = [UIColor clearColor];
    sendButton.tintColor = [UIColor redColor];
    sendButton.frame = CGRectMake(0.0f,
                                  0.0f,
                                  45.0f,
                                  32.0f);
    self.inputToolbar.contentView.rightBarButtonItem = sendButton;
}

// 这个按钮可能是图片有问题
- (void)setInputBarLeftButton {
    UIButton *recordButton = [UIButton buttonWithType:UIButtonTypeCustom];
    recordButton.frame = CGRectMake(0.0f, 0.0f, 45.0f, 32.0f);
//    [recordButton setImage:[UIImage imageNamed:@"语音"] forState:UIControlStateNormal];
//    [recordButton setImage:[UIImage imageNamed:@"键盘"] forState:UIControlStateSelected];

    [recordButton setTitle:@"语音" forState:UIControlStateNormal];
    [recordButton setTitle:@"键盘" forState:UIControlStateSelected];
    [recordButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [recordButton setTitleColor:[UIColor grayColor] forState:UIControlStateSelected];
    [recordButton.titleLabel setFont:kFont_PFSC_semibold_17];
    
    recordButton.adjustsImageWhenHighlighted = NO;
    recordButton.contentMode = UIViewContentModeScaleAspectFill;
    recordButton.backgroundColor = [UIColor clearColor];
    recordButton.tintColor = [UIColor lightGrayColor];
    
    self.inputToolbar.contentView.leftBarButtonItem = recordButton;
}

- (TranscribeVoiceView *)voiceView {
    if (!_voiceView) {
        _voiceView = [[TranscribeVoiceView alloc] initWithFrame:CGRectMake(0, 0, 120.0f, 120.0f)];
        _voiceView.center = CGPointMake(SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2);
    }
    return _voiceView;
}

- (UIButton *)recordButton {
    if (!_recordButton) {
        _recordButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_recordButton setTitle:@"正在录音" forState:UIControlStateNormal];
        [_recordButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_recordButton.titleLabel setFont:kFont_18];

        _recordButton.adjustsImageWhenHighlighted = NO;
        _recordButton.backgroundColor = [UIColor whiteColor];
        _recordButton.layer.cornerRadius = 5;
        _recordButton.layer.masksToBounds = YES;
        _recordButton.layer.borderColor = [[UIColor grayColor] colorWithAlphaComponent:0.75].CGColor;
        _recordButton.layer.borderWidth = 1;
        [_recordButton setHidden:YES];
        [_recordButton addTarget:self action:@selector(recordButtonPress:) forControlEvents:UIControlEventTouchDown];
        [_recordButton addTarget:self action:@selector(recordButtonPressOver:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _recordButton;
}

- (void)makeMessageBubble {
    JSQMessagesBubbleImageFactory *factory = [[JSQMessagesBubbleImageFactory alloc] init];
    _myBubble = [factory outgoingMessagesBubbleImageWithColor:[UIColor greenColor]];
    _otherBubble = [factory incomingMessagesBubbleImageWithColor:[UIColor blueColor]];
}

//- (void)configureMessageCollectionView {
//    self.collectionView;
//}

// 获取历史聊天数据
- (void)getHistoryMessage {
    NSString *roomJidStr = self.room.roomJidvalue;
    XMPPJID *roomJid = [XMPPJID jidWithString:roomJidStr];
    self.messages = [[MessageManager getHistoryMessageWith:self.contact.jid
                                                  orRoomId:roomJid] mutableCopy];
    
    [self.collectionView reloadData];
    [self.collectionView scrollToBottom:NO];
}

// 加入房间
- (void)joinRoom {
    if (!self.room) {
        return;
    }
    NSString *roomJid = self.room.roomJidvalue;
    [[ChatManager sharedInstance] makeRoom:roomJid usingNickname:self.sender.name];
}

#pragma mark -- event

- (XMPPMessage *)makeBaseMessage {
    XMPPMessage *message;
    if (self.room) {
        NSString *roomJidStr = self.room.roomJidvalue;
        XMPPJID *roomJid = [XMPPJID jidWithString:roomJidStr];
        message = [XMPPMessage messageWithType:@"groupchat" to:roomJid]; // [[XMPPMessage alloc] initWithType:@"groupchat" to:self.room];
    } else {
        message = [XMPPMessage messageWithType:@"chat" to:self.contact.jid]; // [[XMPPMessage alloc] initWithType:@"chat" to:self.contact.jid];
    }
    // 添加回执，并且在didReceivedMessage回调中对回执进行组装和发送，方便我们知道消息是否发送成功
    NSXMLElement *receipt = [NSXMLElement elementWithName:@"request" xmlns:@"urn:xmpp:receipts"];
    [message addChild:receipt];
    
    return message;
}

- (void)sendMessage:(XMPPMessage *)message {
    [[ChatManager sharedInstance].stream sendElement:message];
        
    self.textView.text = @"";
    [self.textView resignFirstResponder];
    
    // 群组聊天中，自己发送的消息也会通过received收到
    // 私人聊天中则不会
    // 以现在的代码逻辑，私人的需要本地添加并更新展示，然后在根据回调调整消息状态，如发送失败等
    // 群组的则可以直接通过回调获取到消息及消息状态
    if (self.room) {
        return;
    }
    
    LXMessage *msg = [[LXMessage alloc] initWithMessage:message];
    [self.messages addObject:msg];
    [self.collectionView reloadData];
    [self.collectionView scrollToBottom:NO];
}

- (void)sendTextMessageWith:(NSString *)content {
    XMPPMessage *message = [self makeBaseMessage];
//    [message addAttributeWithName:@"bodyType" stringValue:@"text"];
    message.bodyType = LXMessageBodyText;
    [message addBody:content];
    [self sendMessage:message];
}

- (void)recordButtonPress:(UIButton *)sender {
    if (!self.voiceView.superview) {
        [self.view addSubview:self.voiceView];
    }
    [[AudioManager sharedInstance] record];
}

- (void)recordButtonPressOver:(UIButton *)sender {
    __weak typeof(self) weakSelf = self;
    [[AudioManager sharedInstance] stopAudioRecordWith:^(NSData * _Nullable audioData,
                                                         NSTimeInterval duringTime,
                                                         NSString * _Nullable error) {
        __strong typeof(self) strongSelf = weakSelf;
        if (error) {
            [strongSelf alertAutoDisappearWithTitle:error
                                            message:nil];
            return;
        }
        // 发送语音消息
        [strongSelf sendAudioMessageWith:audioData duringTime:duringTime];
    }];
    
    [self.voiceView removeFromSuperview];
}

- (void)sendAudioMessageWith:(NSData *)audioData duringTime:(NSTimeInterval)time {
    XMPPMessage *message = [self makeBaseMessage];
//    [message addBody:@"voice"];
//    [message addAttributeWithName:@"bodyType" stringValue:@"voice"];
    message.bodyType = LXMessageBodyAudio;
    NSString *timeValue = [NSString stringWithFormat:@"%f", time];
    [message addAttributeWithName:@"duringTime" stringValue:timeValue];
    NSString *audioDataValue = [audioData base64EncodedStringWithOptions:0];
//    XMPPElement *element = [XMPPElement elementWithName:@"attachment" stringValue:audioDataValue];
//    [message addChild:element];
    [message addBody:audioDataValue];
    
    [self sendMessage:message];
}

#pragma mark --notification--
- (void)addNotification {
    // 收到消息
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveMessage:)
                                                 name:kXMPP_DIDREVEICE_MESSAGE
                                               object:nil];
    // 发送消息成功
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didSendMessage:)
                                                 name:kXMPP_DIDSEND_MESSAGE
                                               object:nil];
    // 发送消息失败
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didFailToSendMessage:)
                                                 name:kXMPP_DIDFAIL_TOSEND_MESSAGE
                                               object:nil];
}
// 发送消息不需要进行处理，除非是有特殊需求，因为有消息回执的原因，发送出去的消息自己也会接收到
// 收到消息
- (void)didReceiveMessage:(NSNotification *)notification {
    XMPPMessage *message = (XMPPMessage *)[notification object];
    bool isRequest = [(NSNumber *)([notification userInfo][@"isRequest"]) boolValue];
    if (!message || !isRequest) {
        return;
    }
    // 处理消息，缓存并展示
    LXMessage *msg = [[LXMessage alloc] initWithMessage:message];
    [self.messages addObject:msg];
    [self.collectionView reloadData];
    [self.collectionView scrollToBottom:NO];
}

// 发送消息成功
- (void)didSendMessage:(NSNotification *)notification {
    XMPPMessage *message = (XMPPMessage *)[notification object];
    if (!message) {
        return;
    }
    // 处理消息，缓存并展示
}
// 发送消息失败
- (void)didFailToSendMessage:(NSNotification *)notification {
    XMPPMessage *message = (XMPPMessage *)[notification object];
    NSError *error = (NSError *)notification.userInfo[@"error"];
    if (!message) {
        return;
    }
    // 处理消息，并展示
}

#pragma mark --override--

// 点击发送按钮
- (void)didPressSendButton:(UIButton *)button withMessageText:(NSString *)text senderId:(NSString *)senderId senderDisplayName:(NSString *)senderDisplayName date:(NSDate *)date  {
    [self sendTextMessageWith:text];
}

// 点击进行录音
- (void)didPressAccessoryButton:(UIButton *)sender {
    [sender setSelected:!sender.isSelected];
    
    if (sender.isSelected) {
        [self.textView resignFirstResponder];
        if (!self.recordButton.superview) {
            self.recordButton.frame = self.textView.frame;
            [self.inputToolbar.contentView addSubview:self.recordButton];
        }
        [self.recordButton setHidden:NO];
    } else {
        [self.textView becomeFirstResponder];
        [self.recordButton setHidden:YES];
    }
}

#pragma mark --JSQMessagesCollectionViewDataSource--

// 当前用户的ID
- (NSString *)senderId {
    return self.sender.jid.user;
}
// 当前用户的用户名
- (NSString *)senderDisplayName {
    if (self.sender.vCard.nickname) {
        return self.sender.vCard.nickname;
    }
    return self.sender.jid.user;
}

// 返回每一行展示的消息
- (id<JSQMessageData>)collectionView:(JSQMessagesCollectionView *)collectionView messageDataForItemAtIndexPath:(NSIndexPath *)indexPath {
    LXMessage *msg = self.messages[indexPath.row];
    return msg.message;
}

// 执行删除操作
- (void)collectionView:(JSQMessagesCollectionView *)collectionView didDeleteMessageAtIndexPath:(NSIndexPath *)indexPath {
    
}

// 每一行的气泡信息
- (id<JSQMessageBubbleImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView messageBubbleImageDataForItemAtIndexPath:(NSIndexPath *)indexPath {
    LXMessage *msg = self.messages[indexPath.row];
    if (msg.isMySend) {
        return self.myBubble;
    }
    return self.otherBubble;
}

// 每一行的头像信息
- (id<JSQMessageAvatarImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView avatarImageDataForItemAtIndexPath:(NSIndexPath *)indexPath {
    // 测试代码
    UIImage *img = [UIImage imageNamed:@"头像"];
    
    JSQMessagesAvatarImage *avatarImage = [[JSQMessagesAvatarImage alloc] initWithAvatarImage:img
                                                                             highlightedImage:img
                                                                             placeholderImage:img];
    return avatarImage;
}
// 定义cellTopLabel的attributedString
- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath {
//    // 测试代码
//    return [[NSAttributedString alloc] initWithString:@"cellTopLabel = 顶部label内容"];
    LXMessage *msg = self.messages[indexPath.row];
    return [[NSAttributedString alloc] initWithString: [msg.showDate transformWithFormat: nil]];
}
// 定义每一行气泡的topLabel的attributedString
- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath {
    // 测试代码
//    return [[NSAttributedString alloc] initWithString:@"messageBubbleTopLabel = 气泡顶部label内容"];
    
    return nil;
}
// 定义cellBottomLabel的attributedString
- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath {
    // 测试代码
//    return [[NSAttributedString alloc] initWithString:@"cellBottomLabel = 底部label内容"];
    
    return nil;
}

#pragma mark --UICollectionViewDataSource--

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.messages.count;
}

#pragma mark --JSQMessagesCollectionViewDelegateFlowLayout--

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath {
    return 10;
}

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath {
    return 10;
}

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath {
    return 10;
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapAvatarImageView:(UIImageView *)avatarImageView atIndexPath:(NSIndexPath *)indexPath {
    [self.inputToolbar.contentView.textView resignFirstResponder];
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapMessageBubbleAtIndexPath:(NSIndexPath *)indexPath {
    [self.inputToolbar.contentView.textView resignFirstResponder];
}
// 点击cell，indexpath, location
- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapCellAtIndexPath:(NSIndexPath *)indexPath touchLocation:(CGPoint)touchLocation {
    [self.inputToolbar.contentView.textView resignFirstResponder];
}
// 点击提前加载按钮 ?? 提前加载？
- (void)collectionView:(JSQMessagesCollectionView *)collectionView
                header:(JSQMessagesLoadEarlierHeaderView *)headerView didTapLoadEarlierMessagesButton:(UIButton *)sender {
    [self.inputToolbar.contentView.textView resignFirstResponder];
}

@end
