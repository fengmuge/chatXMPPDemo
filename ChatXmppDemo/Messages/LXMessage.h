//
//  LXMessage.h
//  ChatXmppDemo
//
//  Created by 苗培根 on 2023/6/16.
//

#import <Foundation/Foundation.h>
#import "LXMessageDefine.h"
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
@property (nonatomic, strong) NSString *noti; // 通知，显示在气泡顶部或者cell顶部
@property (nonatomic, strong) NSData *audioData;
@property (nonatomic, assign) NSTimeInterval audioDuringTime;
@property (nonatomic, assign) LXChatType type;
@property (nonatomic, assign) LXMessageBodyType contentType;
@property (nonatomic, assign) LXCallMessageType callMessageType;
@property (nonatomic, strong) NSString *thread;
// 是否是用户自己发送
@property (nonatomic, assign) BOOL isMySend;
// 是否是通知信息，比如谁打视频过来了，视频结束了，谁加入群聊了之类的
@property (nonatomic, assign) BOOL isNotification;
// 消息是否展示
@property (nonatomic, assign) BOOL willShow;

- (instancetype)initWithMessage:(XMPPMessage *)message;

- (instancetype)initWithMessageCoreDataObject:(XMPPMessageArchiving_Message_CoreDataObject *)object;

@end

NS_ASSUME_NONNULL_END
