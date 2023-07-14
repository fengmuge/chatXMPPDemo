//
//  WebRTCManager.m
//  ChatXmppDemo
//
//  Created by 苗培根 on 2023/7/13.
//

#import "WebRTCManager.h"

#import "RTCHeader.h"
#import "RTCView.h"

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
        // 注册房间，并加入
//        [self req];
    } else {
        
    }
}

// 关于RTC配置
- (void)initRTCConfiguration {
    self.peerConnection = [self.peerConnectionFactory peerConnectionWithICEServers:_ICEServers constraints:self.pcConstraints delegate:self];
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
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedSignalingMessage)
                                                 name:kReceivedSignalingMessageNotification
                                               object:nil];
}

// 挂断
- (void)hangUp {
    
}

// 同意对方的语音或视频通话请求
- (void)accept {
    
}

// 收到视频/语音 通话消息
- (void)receivedSignalingMessage {
    if (@available(iOS 10.0, *)) {
        
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


#pragma mark --getter/setter--
- (NSMutableArray *)ICEServers {
    if (!_ICEServers) {
        _ICEServers = [NSMutableArray arrayWithObject:[self defaultSTUNServer]];
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
// Triggered when the SignalingState changed.
- (void)peerConnection:(RTCPeerConnection *)peerConnection
 signalingStateChanged:(RTCSignalingState)stateChanged {
    
}

// Triggered when media is received on a new stream from remote peer.
- (void)peerConnection:(RTCPeerConnection *)peerConnection
           addedStream:(RTCMediaStream *)stream {
    
}

// Triggered when a remote peer close a stream.
- (void)peerConnection:(RTCPeerConnection *)peerConnection
         removedStream:(RTCMediaStream *)stream {
    
}

// Triggered when renegotiation is needed, for example the ICE has restarted.
- (void)peerConnectionOnRenegotiationNeeded:(RTCPeerConnection *)peerConnection {
    
}

// Called any time the ICEConnectionState changes.
- (void)peerConnection:(RTCPeerConnection *)peerConnection
  iceConnectionChanged:(RTCICEConnectionState)newState {
    
}

// Called any time the ICEGatheringState changes.
- (void)peerConnection:(RTCPeerConnection *)peerConnection
   iceGatheringChanged:(RTCICEGatheringState)newState {
    
}

// New Ice candidate have been found.
- (void)peerConnection:(RTCPeerConnection *)peerConnection
       gotICECandidate:(RTCICECandidate *)candidate {
    
}

// New data channel has been opened.
- (void)peerConnection:(RTCPeerConnection*)peerConnection
    didOpenDataChannel:(RTCDataChannel*)dataChannel {
    
}

#pragma mark --RTCSessionDescriptionDelegate--
// Called when creating a session.
- (void)peerConnection:(RTCPeerConnection *)peerConnection
    didCreateSessionDescription:(RTCSessionDescription *)sdp
                 error:(NSError *)error {
    
}

// Called when setting a local or remote description.
- (void)peerConnection:(RTCPeerConnection *)peerConnection
didSetSessionDescriptionWithError:(NSError *)error {
    
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
