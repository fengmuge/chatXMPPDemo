//
//  WebRTCManager.m
//  ChatXmppDemo
//
//  Created by 苗培根 on 2023/7/13.
//

#import "WebRTCManager.h"

#import "RTCHeader.h"
#import "RTCView.h"

#import "RTCRoom.h"

#import "MessageManager.h"
#import "XMPPMessage+custom.h"

@interface WebRTCManager () <
RTCPeerConnectionDelegate,
RTCSessionDescriptionDelegate,
RTCEAGLVideoViewDelegate,
CXCallObserverDelegate
>

@property (nonatomic, strong)   RTCPeerConnectionFactory *peerConnectionFactory;
@property (nonatomic, strong)   RTCMediaConstraints *pcConstraints;
@property (nonatomic, strong)   RTCMediaConstraints *sdpConstraints;
@property (nonatomic, strong)   RTCMediaConstraints *videoConstraints;
@property (nonatomic, strong)   RTCPeerConnection *peerConnection;

@property (nonatomic, strong)   RTCEAGLVideoView *localVideoView;
@property (nonatomic, strong)   RTCEAGLVideoView *remoteVideoView;
@property (nonatomic, strong)   RTCVideoTrack *localVideoTrack;
@property (nonatomic, strong)   RTCVideoTrack *remoteVideoTrack;
// 音频播放器
@property (nonatomic, strong)   AVAudioPlayer *audioPlayer;
//#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_10_0
@property (nonatomic, strong)   CXCallObserver *callObserver;
//#endif

//#if __IPHONE_OS_VERSION_MAX_ALLOWED < __IPHONE_10_0
//@property (nonatomic, strong)   CTCallCenter *callCenter;
//#endif
@property (strong, nonatomic)   NSMutableArray *ICEServers;
// 传令消息队列
@property (strong, nonatomic)   NSMutableArray *messages;
//// 已经发送的候选请求
//@property (assign, nonatomic)   BOOL HaveSentCandidate;
// 是否是发起方
@property (nonatomic, assign)   BOOL initiator;
// 是否收到SDP信息
@property (nonatomic, assign)   BOOL hasReceivedSdp;
// 已经发送候选
@property (nonatomic, assign)   BOOL HaveSentCandidate;

@property (nonatomic, assign)   BOOL isVideoCall;

@end

@implementation WebRTCManager
static WebRTCManager *_sharedInstance;

+ (WebRTCManager *)sharedInstance {
    return [[self alloc] init];
}

- (instancetype)init {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [super init];
        [_sharedInstance addNotification];
        [_sharedInstance callHandler];
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

+ (NSString *)randomRoomId {
    return [NSString random];
}

- (RTCICEServer *)defaultSTUNServer {
    NSURL *defaultSTUNServerUrl = [NSURL URLWithString:kRTCSTUNServer];
    return [[RTCICEServer alloc] initWithURI:defaultSTUNServerUrl
                                    username:nil
                                    password:nil];
    
}

- (void)startEngine {
    [RTCPeerConnectionFactory initializeSSL];
    self.peerConnectionFactory = [[RTCPeerConnectionFactory alloc] init];
    NSArray *mandatoryConstraints = @[[[RTCPair alloc] initWithKey:@"OfferToReceiveAudio" value:@"true"],
                                      [[RTCPair alloc] initWithKey:@"OfferToReceiveVideo" value:@"true"]
    ];
    NSArray *optionalConstraints = @[[[RTCPair alloc] initWithKey:@"DtlsSrtpKeyAgreement" value:@"false"]];

    self.pcConstraints = [[RTCMediaConstraints alloc] initWithMandatoryConstraints:mandatoryConstraints
                                                               optionalConstraints:optionalConstraints];
    
    NSArray *sdpMandatoryConstraints = @[[[RTCPair alloc] initWithKey:@"OfferToReceiveAudio" value:@"true"],
                                         [[RTCPair alloc] initWithKey:@"OfferToReceiveVideo" value:@"true"]
    ];
    self.sdpConstraints = [[RTCMediaConstraints alloc] initWithMandatoryConstraints:sdpMandatoryConstraints optionalConstraints:nil];
    
    self.videoConstraints = [[RTCMediaConstraints alloc] initWithMandatoryConstraints:nil optionalConstraints:nil];
}

- (void)stopEngine {
    [RTCPeerConnectionFactory deinitializeSSL];
    
    _peerConnectionFactory = nil;
}

- (void)showRtcViewWith:(NSString *)remoteName isVideo:(BOOL)isVideo isCallee:(BOOL)isCallee {
    // 显示视图
    self.rtcView = [[RTCView alloc] initWithIsVideo:isVideo isCallee:isCallee];
    self.rtcView.nickName = remoteName;
    self.rtcView.connectText = @"等待对方接听";
    self.rtcView.netTipText = @"网络状况良好";
    [self.rtcView show];
    
    // 播放声音
    NSURL *audioURL;
    if (isCallee) {
        audioURL = [[NSBundle mainBundle] URLForResource:@"AVChat_incoming.mp3" withExtension:nil];
    } else {
        audioURL = [[NSBundle mainBundle] URLForResource:@"AVChat_waitingForAnswer.mp3" withExtension:nil];
    }
    NSError *error;
    _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:audioURL error:&error];
    _audioPlayer.numberOfLoops = -1;
    [_audioPlayer prepareToPlay];
    [_audioPlayer play];
    
    // 通话时候，禁止黑屏
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    
    // 监听系统电话 --- 已经在单例初始化时候声明
//    [self callHandler];
    
    // 做RTC必要设置
    if (isCallee) { // 如果是被呼叫者
        self.initiator = NO;
        // 如果是被呼叫者,需要处理信号信息,创建一个answer
        NSLog(@"如果是接收者，就要处理信号信息");
        self.rtcView.connectText = isVideo ? @"视频通话" : @"语音通话";
//        // 注册房间，并加入
//        [self requestRoomServerWithURL:kRTCRoomServer roomId:self.roomId completionHandler:^(RTCRoom *info, BOOL success) {
//            if (!success) {
//                NSLog(@"加入房间失败");
//                return;
//            }
//            NSLog(@"加入房间成功 %@", info);
//            self.roomId = info.params.room_id;
//            self.clientId = info.params.client_id;
//
//            for (NSString *messageStr in info.params.messages) {
//                NSData *data = [messageStr dataUsingEncoding:NSUTF8StringEncoding];
//                NSDictionary *messageDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
//                [self handleSignalingMessage:messageDict];
//            }
//        }];
    } else { // 如果是呼叫者
        self.initiator = YES;
//        NSString *roomId = [NSString random];
//
//        [self requestRoomServerWithURL:kRTCRoomServer roomId:roomId completionHandler:^(RTCRoom *info, BOOL success) {
//            if (!success) {
//                NSLog(@"加入房间失败");
//                return;
//            }
//            self.roomId = info.params.room_id;
//            self.clientId = info.params.client_id;
//            self.initiator = info.params.is_initiator;
            
            [self initRTCConfiguration];
            // 创建一个offer信号
            [self.peerConnection createOfferWithDelegate:self constraints:self.sdpConstraints];
//        }];
    }
}

// 关于RTC配置
- (void)initRTCConfiguration {
    self.peerConnection = [self.peerConnectionFactory peerConnectionWithICEServers:self.ICEServers constraints:self.pcConstraints delegate:self];
    // 设置local media stream
    RTCMediaStream *mediaStream = [self.peerConnectionFactory mediaStreamWithLabel:@"ARDAMS"];
    // 添加 local video track
    RTCAVFoundationVideoSource *source = [[RTCAVFoundationVideoSource alloc] initWithFactory:self.peerConnectionFactory constraints:self.videoConstraints];
    RTCVideoTrack *localVideoTrack = [[RTCVideoTrack alloc] initWithFactory:self.peerConnectionFactory source:source trackId:@"AVAMSv0"];
    [mediaStream addVideoTrack:localVideoTrack];
    self.localVideoTrack = localVideoTrack;
    
    // 添加 local audio track
    RTCAudioTrack *localAudioTrack = [self.peerConnectionFactory audioTrackWithID:@"ARDAMSa0"];
    [mediaStream addAudioTrack:localAudioTrack];
    // 添加mediaStream
    [self.peerConnection addStream:mediaStream];
    
    RTCEAGLVideoView *localVideoView = [[RTCEAGLVideoView alloc] initWithFrame:self.rtcView.ownImageView.bounds];
    localVideoView.transform = CGAffineTransformMakeScale(-1, 1);
    localVideoView.delegate = self;
    [self.rtcView.ownImageView addSubview:localVideoView];
    self.localVideoView = localVideoView;
    
    [self.localVideoTrack addRenderer:self.localVideoView];
    
    RTCEAGLVideoView *remoteVideoView = [[RTCEAGLVideoView alloc] initWithFrame:self.rtcView.adverseImageView.bounds];
    remoteVideoView.transform = CGAffineTransformMakeScale(-1, 1);
    remoteVideoView.delegate = self;
    [self.rtcView.adverseImageView addSubview:remoteVideoView];
    self.remoteVideoView = remoteVideoView;
}

- (void)resizeViews {
    [self videoView:self.localVideoView didChangeVideoSize:self.rtcView.ownImageView.bounds.size];
    [self videoView:self.remoteVideoView didChangeVideoSize:self.rtcView.adverseImageView.bounds.size];
}

- (void)cleanCache {
    self.rtcView = nil;
    
    if ([_audioPlayer isPlaying]) {
        [_audioPlayer stop];
    }
    _audioPlayer = nil;
    
    // 取消手机常亮
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    
    // 取消系统电话监听
    // ??? 怎么样才能根据系统版本声明，为什么第三方库可以
    self.callObserver = nil;
//    self.callCenter = nil;
    
    _peerConnection = nil;
    _localVideoTrack = nil;
    _remoteVideoTrack = nil;
    _localVideoView = nil;
    _remoteVideoView = nil;
    _hasReceivedSdp = NO;
}

#pragma mark --notification--
- (void)addNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(hangUp)
                                                 name:kHangUpNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(accept)
                                                 name:kAcceptNotification
                                               object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(receivedSignalingMessage:)
//                                                 name:kReceivedSignalingMessageNotification
//                                               object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(receivedOfferMessage:)
//                                                 name:kReceivedOfferSignalingMessageNotification
//                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedCallAboutMessage:)
                                                 name:kRTC_DIDREVEICE_CALLMESSAGE
                                               object:nil];
}

// 收到通讯相关消息
- (void)receivedCallAboutMessage:(NSNotification *)notification {
    XMPPMessage *message = (XMPPMessage *)[notification object];
    
    NSData *data = [message.body dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data
                                                         options:NSJSONReadingAllowFragments
                                                           error:&error];
    if (error) {
        NSLog(@"视频/语音通话数据解析失败!");
        return;
    }
    
    BOOL isVideoCall = message.bodyType == LXMessageBodyVideoCall;
    NSString *myJid = [UserManager sharedInstance].jid.user;
    
    NSMutableDictionary *mutableDict = [dict mutableCopy];
    mutableDict[@"myJid"] = myJid;
    mutableDict[@"isVideo"] = [NSNumber numberWithBool:isVideoCall];
    
    if ([dict objectForKey:@"roomId"]) {
        [self receivedOfferMessage:mutableDict];
    } else {
        mutableDict[@"remoteJid"] = message.from.user;
        [self receivedSignalingMessage: mutableDict];
    }
}

// 收到通话邀请
- (void)receivedOfferMessage:(NSDictionary *)dict {
    NSString *jid = dict[@"myJid"];
    BOOL isVideo = [(NSNumber *)dict[@"isVideo"] boolValue];
    [self showRtcViewWith:jid isVideo:isVideo isCallee:YES];
}

// 挂断
- (void)hangUp {
    [self processMessageDict:@{@"type": @"bye"}];
}

// 同意对方的语音或视频通话请求
- (void)accept {
    [self.audioPlayer stop];
    [self initRTCConfiguration];
    
//    [self drainMessage];
    
    NSLog(@"%@", self.remoteVideoView);

    for (NSDictionary *dict in self.messages) {
        [self processMessageDict:dict];
    }
    [self.messages removeAllObjects];
}

- (void)drainMessage {
    if (!_peerConnection || !_hasReceivedSdp) {
        return;
    }
    for (NSDictionary *dict in self.messages) {
        [self processMessageDict:dict];
    }
    [self.messages removeAllObjects];
}

// 收到视频/语音 通话消息
- (void)receivedSignalingMessage:(NSDictionary *)dict {
    self.myJid = dict[@"myJid"];
    self.remoteJid = dict[@"remoteJid"];
    
    [self handleSignalingMessage:dict];
    
//    [self drainMessage];
}

- (void)handleSignalingMessage:(NSDictionary *)dict {
    NSString *type = dict[@"type"];
    if ([type isEqualToString:@"offer"]) {
        [self showRtcViewWith:self.remoteJid isVideo:YES isCallee:YES];
        [self.messages insertObject:dict atIndex:0];
        _hasReceivedSdp = YES;
    } else if ([type isEqualToString:@"answer"]) {
        RTCSessionDescription *sdp = [[RTCSessionDescription alloc] initWithType:type sdp:dict[@"sdp"]];
        [self.peerConnection setRemoteDescriptionWithDelegate:self sessionDescription:sdp];
    } else if ([type isEqualToString:@"candidate"]) {
        [self.messages addObject:dict];
    } else if ([type isEqualToString:@"bye"]) {
        [self processMessageDict:dict];
    }
}

- (void)processMessageDict:(NSDictionary *)dict {
    NSString *type = dict[@"type"];
    if ([type isEqualToString:@"offer"]) {
        RTCSessionDescription *remoteSdp = [[RTCSessionDescription alloc] initWithType:type sdp:dict[@"sdp"]];
        
        [self.peerConnection setRemoteDescriptionWithDelegate:self sessionDescription:remoteSdp];
        
        [self.peerConnection createAnswerWithDelegate:self constraints:self.sdpConstraints];
    } else if ([type isEqualToString:@"answer"]) {
        RTCSessionDescription *remoteSdp = [[RTCSessionDescription alloc] initWithType:type sdp:dict[@"sdp"]];
        
        [self.peerConnection setRemoteDescriptionWithDelegate:self sessionDescription:remoteSdp];
        
    } else if ([type isEqualToString:@"candidate"]) {
        NSString *mid = [dict objectForKey:@"id"];
        NSNumber *sdpLineIndex = [dict objectForKey:@"label"];
        NSString *sdp = [dict objectForKey:@"sdp"];
        RTCICECandidate *candidate = [[RTCICECandidate alloc] initWithMid:mid index:sdpLineIndex.intValue sdp:sdp];

        [self.peerConnection addICECandidate:candidate];
    } else if ([type isEqualToString:@"bye"]) {

        if (self.rtcView) {
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:nil];
            NSString *jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            if (jsonStr.length > 0) {
                [[MessageManager sharedInstance] sendSignalingMessage:jsonStr toUser:self.remoteJid isVideoCall:self.isVideoCall];
            }
            
            [self.rtcView dismiss];
            
            [self cleanCache];
        }
    }
}

#pragma mark --电话监听--

- (void)callHandler {
//#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_10_0
    self.callObserver = [[CXCallObserver alloc] init];
    [self.callObserver setDelegate:self queue:dispatch_get_main_queue()];
//#else
//    self.callCenter = [[CTCallCenter alloc] init];
//#endif
}

- (void)listenSystemCall {
//#if __IPHONE_OS_VERSION_MAX_ALLOWED < __IPHONE_10_0
//#endif
//    __weak typeof(self) weakSelf = self;
//    self.callCenter.callEventHandler = ^(CTCall *call) {
//        __strong typeof(self) strongSelf = weakSelf;
//        dispatch_async(dispatch_get_main_queue(), ^{
//            switch (call.callState) {
//                case CTCallStateDialing:
//                    NSLog(@"拨打");
//                    break;
//                case CTCallStateIncoming:
//                    NSLog(@"来电");
//                    break;
//                case CTCallStateConnected:
//                    NSLog(@"接通");
//                    break;
//                case CTCallStateDisconnected:
//                    NSLog(@"挂断");
//                    break;
//                default:
//                    NSLog(@"其他");
//                    break;
//            }
//        });
//    };
}

- (void)callObserver:(CXCallObserver *)callObserver callChanged:(CXCall *)call {
    if (!call.outgoing && !call.onHold && !call.hasConnected && !call.hasEnded) {
        NSLog(@"来电");
    } else if (!call.outgoing && !call.onHold && !call.hasConnected && call.hasEnded) {
        NSLog(@"来电-挂掉(未接通)");
    } else if (!call.outgoing && !call.onHold && call.hasConnected && !call.hasEnded) {
        NSLog(@"来电-接通");
    } else if (!call.outgoing && !call.onHold && call.hasConnected && call.hasEnded) {
        NSLog(@"来电-接通-挂掉");
    } else if (call.outgoing && !call.onHold && !call.hasConnected && !call.hasEnded) {
        NSLog(@"拨打");
    } else if (call.outgoing && !call.onHold && !call.hasConnected && call.hasEnded) {
        NSLog(@"拨打-挂掉(未接通)");
    } else if (call.outgoing && !call.onHold && call.hasConnected && !call.hasEnded) {
        NSLog(@"拨打-接通");
    } else if (call.outgoing && !call.onHold && call.hasConnected && call.hasEnded) {
        NSLog(@"拨打-接通-挂掉");
    }
    NSLog(@"outgoing(拨打):%d  onHold(待接通):%d   hasConnected(接通):%d   hasEnded(挂断):%d",call.outgoing,call.onHold,call.hasConnected,call.hasEnded);
}

/**
 *  在服务器端创建房间
 *
 *  @param URL               房间服务器地址
 *  @param roomId            房间号
 *  @param completionHandler 完成后回调
 */
- (void)requestRoomServerWithURL:(NSString *)URL roomId:(NSString *)roomId completionHandler:(void (^)(RTCRoom *info, BOOL success))completionHandler
{
    [SJNetworkConfig sharedConfig].baseUrl = kRTCRoomServer;
    [[SJNetworkManager sharedManager] sendPostRequest:[NSString stringWithFormat:@"/join/%@", roomId] parameters:nil success:^(id responseObject) {
        RTCRoom *item = [RTCRoom yy_modelWithJSON:responseObject];
        if (completionHandler) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completionHandler(item, item != nil);
            });
        }
    } failure:^(NSURLSessionTask *task, NSError *error, NSInteger statusCode) {
        NSLog(@"在服务器上创建房间失败");
        if (completionHandler) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completionHandler(nil, NO);
            });
        }
    }];
}

- (void)registWithRoomId:(NSString *)roomId clientId:(NSString *)clientId completionHandle:(void (^)(NSDictionary *dict))completionHandler
{
    [SJNetworkConfig sharedConfig].baseUrl = kRTCRoomServer;
    [[SJNetworkManager sharedManager] sendPostRequest:[NSString stringWithFormat:@"/%@/%@", roomId, clientId] parameters:nil success:^(id responseObject) {
        NSLog(@"%s result: %@", __func__, responseObject);
        
    } failure:^(NSURLSessionTask *task, NSError *error, NSInteger statusCode) {
        if (completionHandler) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completionHandler(nil);
            });
        }
    }];
}

- (RTCSessionDescription *)descriptionWithDescription:(RTCSessionDescription *)description videoFormat:(NSString *)videoFormat
{
    NSString *sdpString = description.description;
    NSString *lineChar = @"\n";
    NSMutableArray *lines = [NSMutableArray arrayWithArray:[sdpString componentsSeparatedByString:lineChar]];
    NSInteger mLineIndex = -1;
    NSString *videoFormatRtpMap = nil;
    NSString *pattern = [NSString stringWithFormat:@"^a=rtpmap:(\\d+) %@(/\\d+)+[\r]?$", videoFormat];
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:nil];
    for (int i = 0; (i < lines.count) && (mLineIndex == -1 || !videoFormatRtpMap); ++i) {
        // mLineIndex 和 videoFromatRtpMap 都更新了之后跳出循环
        NSString *line = lines[i];
        if ([line hasPrefix:@"m=video"]) {
            mLineIndex = i;
            continue;
        }
        
        NSTextCheckingResult *result = [regex firstMatchInString:line options:0 range:NSMakeRange(0, line.length)];
        if (result) {
            videoFormatRtpMap = [line substringWithRange:[result rangeAtIndex:1]];
            continue;
        }
    }
    
    if (mLineIndex == -1) {
        // 没有m = video line, 所以不能转格式,所以返回原来的description
        return description;
    }
    
    if (!videoFormatRtpMap) {
        // 没有videoFormat 类型的rtpmap。
        return description;
    }
    
    NSString *spaceChar = @" ";
    NSArray *origSpaceLineParts = [lines[mLineIndex] componentsSeparatedByString:spaceChar];
    if (origSpaceLineParts.count > 3) {
        NSMutableArray *newMLineParts = [NSMutableArray arrayWithCapacity:origSpaceLineParts.count];
        NSInteger origPartIndex = 0;
        
        [newMLineParts addObject:origSpaceLineParts[origPartIndex++]];
        [newMLineParts addObject:origSpaceLineParts[origPartIndex++]];
        [newMLineParts addObject:origSpaceLineParts[origPartIndex++]];
        [newMLineParts addObject:videoFormatRtpMap];
        for (; origPartIndex < origSpaceLineParts.count; ++origPartIndex) {
            if (![videoFormatRtpMap isEqualToString:origSpaceLineParts[origPartIndex]]) {
                [newMLineParts addObject:origSpaceLineParts[origPartIndex]];
            }
        }
        
        NSString *newMLine = [newMLineParts componentsJoinedByString:spaceChar];
        [lines replaceObjectAtIndex:mLineIndex withObject:newMLine];
    } else {
        NSLog(@"SDP Media description 格式 错误");
    }
    NSString *mangledSDPString = [lines componentsJoinedByString:lineChar];
    
    return [[RTCSessionDescription alloc] initWithType:description.type sdp:mangledSDPString];
}

#pragma mark --getter/setter--
- (BOOL)isVideoCall {
    return self.rtcView.isVideo;
}

- (NSMutableArray *)ICEServers {
    if (!_ICEServers) {
        _ICEServers = [[NSMutableArray alloc] init]; // [NSMutableArray arrayWithObject:[self defaultSTUNServer]];
    }
    return _ICEServers;
}

- (NSMutableArray *)messages {
    if (!_messages) {
        _messages = [[NSMutableArray alloc] init];
    }
    return _messages;
}

#pragma mark --RTCPeerConnectionDelegate--
// 信号状态改变
- (void)peerConnection:(RTCPeerConnection *)peerConnection
 signalingStateChanged:(RTCSignalingState)stateChanged {
    NSLog(@"信号状态改变 %s", __func__);
    
    switch (stateChanged) {
        case RTCSignalingStable:
            break;
        case RTCSignalingClosed:
            break;
        case RTCSignalingHaveLocalOffer:
            break;
        case RTCSignalingHaveRemoteOffer:
            break;
        case RTCSignalingHaveLocalPrAnswer:
            break;
        case RTCSignalingHaveRemotePrAnswer:
            break;
        default:
            break;
    }
}

// 已添加多媒体流
- (void)peerConnection:(RTCPeerConnection *)peerConnection
           addedStream:(RTCMediaStream *)stream {
    NSLog(@"received %lu video tracks and %lu audio tracks", stream.videoTracks.count, stream.audioTracks.count);
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong typeof(self) strongSelf = weakSelf;
        if (stream.videoTracks.count) {
            strongSelf.remoteVideoTrack = nil;
            [strongSelf.remoteVideoView renderFrame:nil];
            
            strongSelf.remoteVideoTrack = stream.videoTracks[0];
            [strongSelf.remoteVideoTrack addRenderer:strongSelf.remoteVideoView];
        }
        
        [strongSelf videoView:strongSelf.remoteVideoView
           didChangeVideoSize:strongSelf.rtcView.adverseImageView.bounds.size];
        
        [strongSelf videoView:strongSelf.localVideoView
           didChangeVideoSize:strongSelf.rtcView.ownImageView.bounds.size];
    });
}

// 已移除多媒体流
- (void)peerConnection:(RTCPeerConnection *)peerConnection
         removedStream:(RTCMediaStream *)stream {
    NSLog(@"%s", __func__);
}

// 重新协商时候触发, 例如ICE重新启动
- (void)peerConnectionOnRenegotiationNeeded:(RTCPeerConnection *)peerConnection {
    NSLog(@"%s", __func__);
}

// ICE 连接状态改变时候触发
- (void)peerConnection:(RTCPeerConnection *)peerConnection
  iceConnectionChanged:(RTCICEConnectionState)newState {
    switch (newState) {
        case RTCICEConnectionNew:
            break;
        case RTCICEConnectionMax:
            break;
        case RTCICEConnectionClosed:
            break;
        case RTCICEConnectionFailed:
            break;
        case RTCICEConnectionChecking:
            break;
        case RTCICEConnectionCompleted:
            break;
        case RTCICEConnectionConnected:
            break;
        case RTCICEConnectionDisconnected:
        {
            __weak typeof(self) weakSelf = self;
            dispatch_async(dispatch_get_main_queue(), ^{
                __strong typeof(self) strongSelf = weakSelf;
                [strongSelf.rtcView dismiss];
                [strongSelf cleanCache];
            });
        }
            break;
        default:
            break;
    }
}

// ICEGatheringState 收集状态改变时候触发
- (void)peerConnection:(RTCPeerConnection *)peerConnection
   iceGatheringChanged:(RTCICEGatheringState)newState {
    switch (newState) {
        case RTCICEGatheringNew:
            break;
        case RTCICEGatheringComplete:
            break;
        case RTCICEGatheringGathering:
            break;
        default:
            break;
    }
}

// 新的ICE candidate候选人被发现时候触发
- (void)peerConnection:(RTCPeerConnection *)peerConnection
       gotICECandidate:(RTCICECandidate *)candidate {
    if (self.HaveSentCandidate) {
        return;
    }
    NSDictionary *jsonDict = @{@"type": @"candidate",
                               @"label": [NSNumber numberWithInteger:candidate.sdpMLineIndex],
                               @"id": candidate.sdpMid,
                               @"sdp": candidate.sdp
    };
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDict options:0 error:&error];
    if (error || jsonData.length <= 0) {
        NSLog(@"候选人信息处理失败 error: %@", [error localizedDescription]);
        return;
    }
    NSString *jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    [[MessageManager sharedInstance] sendSignalingMessage:jsonStr toUser:self.remoteJid isVideoCall:self.isVideoCall];
    self.HaveSentCandidate = YES;
}

// 新的数据通道被打开
- (void)peerConnection:(RTCPeerConnection*)peerConnection
    didOpenDataChannel:(RTCDataChannel*)dataChannel {
    NSLog(@"%s", __func__);
}

#pragma mark --RTCSessionDescriptionDelegate--
// Called when creating a session.
- (void)peerConnection:(RTCPeerConnection *)peerConnection
    didCreateSessionDescription:(RTCSessionDescription *)sdp
                 error:(NSError *)error {
    if (error) {
        NSLog(@"创建SessionDescription失败 error: %@", [error localizedDescription]);
    } else {
        NSLog(@"创建SessionDescription成功");
        RTCSessionDescription *sdpH264 = [self descriptionWithDescription:sdp videoFormat:@"h264"];
        [self.peerConnection setLocalDescriptionWithDelegate:self sessionDescription:sdpH264];
        
//        if ([sdp.type isEqualToString:@"offer"]) {
//            NSDictionary *dict = @{@"roomId": self.roomId};
//            NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:0 error:nil];
//            NSString *message = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//
//            [[MessageManager sharedInstance] sendSignalingMessage:message toUser:self.remoteJid isVideoCall:self.isVideoCall];
//        }
        
        NSDictionary *jsonDict = @{@"type": sdp.type, @"sdp": sdp.description};
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDict options:0 error:nil];
        NSString *jsonMessage = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        [[MessageManager sharedInstance] sendSignalingMessage:jsonMessage toUser:self.remoteJid isVideoCall:self.isVideoCall];
    }
}

// Called when setting a local or remote description.
- (void)peerConnection:(RTCPeerConnection *)peerConnection
didSetSessionDescriptionWithError:(NSError *)error {
    NSLog(@"%s", __func__);
    if (error) {
        NSLog(@"设置SessionDescription失败 error: %@", [error localizedDescription]);
    }
}

#pragma mark --RTCEAGLVideoViewDelegate--
- (void)videoView:(RTCEAGLVideoView*)videoView didChangeVideoSize:(CGSize)size {
    if (videoView == self.localVideoView) {
        NSLog(@"local %s %@", __func__, NSStringFromCGSize(size));
    } else {
        NSLog(@"remote %s %@", __func__, NSStringFromCGSize(size));
    }
}

@end
