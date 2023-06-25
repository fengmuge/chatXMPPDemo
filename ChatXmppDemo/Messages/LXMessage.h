//
//  LXMessage.h
//  ChatXmppDemo
//
//  Created by 苗培根 on 2023/6/16.
//

#import <Foundation/Foundation.h>

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
    LXMessageContentText,
    LXMessageContentAudio,
    LXMessageContentPicture,
    LXMessageContentVideo,
} LXMessageContentType;

NS_ASSUME_NONNULL_BEGIN

@interface LXMessage : NSObject

@property (nonatomic, strong) JSQMessage *message;
@property (nonatomic, strong) NSString *messageId;

@property (nonatomic, strong) NSString *toJid;
@property (nonatomic, strong) NSString *toName;

@property (nonatomic, strong) NSString *fromJid;
@property (nonatomic, strong) NSString *fromName;
 
@property (nonatomic, strong) NSDate *showDate;
@property (nonatomic, strong) NSString *body;
@property (nonatomic, strong) NSData *audioData;
@property (nonatomic, assign) NSTimeInterval audioDuringTime;
@property (nonatomic, assign) LXChatType type;
@property (nonatomic, assign) LXMessageContentType contentType;
@property (nonatomic, strong) NSString *thread;
// 是否是用户自己发送
@property (nonatomic, assign) bool isMySend;

- (instancetype)initWithMessage:(XMPPMessage *)message;

- (instancetype)initWithMessageCoreDataObject:(XMPPMessageArchiving_Message_CoreDataObject *)object;

@end

NS_ASSUME_NONNULL_END
