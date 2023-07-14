//
//  WebRTCManager.h
//  ChatXmppDemo
//
//  Created by 苗培根 on 2023/7/13.
//

#import <Foundation/Foundation.h>

@class RTCView;

typedef enum : NSUInteger {
    LXRTCEngineVideo,  // 视频通话
    LXRTCEngineAudio,  // 语音通话
} LXRTCEngineType;

typedef enum : NSUInteger {
    LXSignalingChannelClosed,
    LXSignalingChannelOpen,
    LXSignalingChannelRegistered,
    LXSignalingChannelError,
} LXSignalingChannelState;

NS_ASSUME_NONNULL_BEGIN

@interface WebRTCManager : NSObject

@property (nonatomic, strong, nullable) RTCView *rtcView;
@property (nonatomic, copy) NSString *myJid;
@property (nonatomic, copy) NSString *remoteJid;
// 房间id,用完需要清空
@property (nonatomic, copy) NSString *roomId;
// 客户端id,用完需要清空
@property (nonatomic, copy) NSString *clientId;

+ (WebRTCManager *)sharedInstance;

+ (NSString *)randomRoomId;

- (void)startEngine;

- (void)stopEngine;

// isVideo 是否是视频通话，NO的话是音频通话；
// isCallee 是否是被呼叫者
- (void)showRtcViewWith:(NSString *)remoteName isVideo:(BOOL)isVideo isCallee:(BOOL)isCallee;

- (void)resizeViews;

@end

NS_ASSUME_NONNULL_END
