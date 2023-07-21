//
//  LXMessageDefine.h
//  ChatXmppDemo
//
//  Created by 苗培根 on 2023/7/19.
//

#ifndef LXMessageConfig_h
#define LXMessageConfig_h

// 消息发送状态
typedef enum : NSUInteger {
    LXMessageSendSuccess,
    LXMessageSending,
    LXMessageSendError,
} LXMessageSendStatus;

typedef enum : NSUInteger {
    LXChatSingle,
    LXChatGroup,
    LXChatUnknow,
} LXChatType;

typedef enum : NSUInteger {
    LXMessageBodyText,
    LXMessageBodyAudio,
    LXMessageBodyVideo,
    LXMessageBodyImage,
    LXMessageBodyCard,
    LXMessageBodyVideoCall,
    LXMessageBodyVoiceCell,
} LXMessageBodyType;

typedef enum : NSUInteger {
    LXCallMessageOffer,  // 通话邀请
    LXCallMessageAnswer, // 通话回复
    LXCallMessageBye,    // 挂断
    LXCallMessageCandidate, // 新的候选人/参与人 ？？？
    LXCallMessageUnknow, // 未知类型
} LXCallMessageType;

#endif /* LXMessageDefine */
