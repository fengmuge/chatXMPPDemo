//
//  LXMessage.m
//  ChatXmppDemo
//
//  Created by 苗培根 on 2023/6/16.
//

#import "LXMessage.h"
#import "User.h"

#import "XMPPMessage+custom.h"

@interface LXMessage ()

@property (nonatomic, strong) NSDate *timeDate;
@property (nonatomic, strong) NSDate *delayDate;

// 消息缓存
@property (nonatomic, strong) XMPPMessage *xmppMessage;
@property (nonatomic, strong) XMPPMessageArchiving_Message_CoreDataObject *object;

@end

@implementation LXMessage

- (instancetype)initWithMessage:(XMPPMessage *)message {
    self = [super init];
    if (self) {
        self.xmppMessage = message;
        [self sortMessage:message];
    }
    return self;
}

- (instancetype)initWithMessageCoreDataObject:(XMPPMessageArchiving_Message_CoreDataObject *)object {
    self = [super init];
    if (self) {
        self.object = object;
        [self sortCoreDataObject:object];
    }
    return self;
}

- (NSDate *)showDate {
    return self.delayDate ?: self.timeDate;
}

- (void)makeJSQMessage {
    // 测试
    if (self.fromName == nil || self.fromJid == nil) {
        NSLog(@"发送人信息为空 \n message = %@ \n or object = %@", self.xmppMessage, self.object);
        return;
    }
    switch (self.contentType) {
        case LXMessageContentText:
            self.message = [[JSQMessage alloc] initWithSenderId:self.fromName
                                              senderDisplayName:self.fromName
                                                           date:[self showDate]
                                                           text:self.body];
            break;
        case LXMessageContentAudio:
            self.message = [[JSQMessage alloc] initWithSenderId:self.fromName
                                              senderDisplayName:self.fromName
                                                           date:[self showDate]
                                                          media:[self makeAudioMedia]];
            break;
        default:
            break;
    }
}

- (JSQAudioMediaItem *)makeAudioMedia {
    UIImage *playImage = [UIImage imageNamed:@"播放"];
    UIImage *pauseImage = [UIImage imageNamed:@"暂停"];
    playImage = [playImage reSize:CGSizeMake(30, 30)];
    pauseImage = [pauseImage reSize:CGSizeMake(30, 30)];
    UIColor *backColor = self.isMySend ? [UIColor greenColor] : [UIColor blueColor];
    JSQAudioMediaViewAttributes *attributes = [[JSQAudioMediaViewAttributes alloc] initWithPlayButtonImage:playImage
                                                                                          pauseButtonImage:pauseImage
                                                                                                 labelFont:kFont_12
                                                                                     showFractionalSecodns:YES
                                                                                           backgroundColor:backColor
                                                                                                 tintColor:[UIColor blackColor]
                                                                                             controlInsets:UIEdgeInsetsMake(5, 2, 5, 2)
                                                                                            controlPadding:2
                                                                                             audioCategory:@"height"
                                                                                      audioCategoryOptions:(AVAudioSessionCategoryOptionAllowBluetooth |
                                                                                                            AVAudioSessionCategoryOptionDefaultToSpeaker |
                                                                                                            AVAudioSessionCategoryOptionAllowAirPlay)];
    
    JSQAudioMediaItem *mediaItem = [[JSQAudioMediaItem alloc] initWithData:self.audioData
                                                       audioViewAttributes:attributes];
    return mediaItem;
}

#pragma mark --coreDataObject数据处理
- (void)sortCoreDataObject:(XMPPMessageArchiving_Message_CoreDataObject *)object {
    [self sortMessage:object.message];
//    [self makeJSQMessage];
}

#pragma mark --message数据处理--
- (void)sortMessage:(XMPPMessage *)message {
    
    self.contentType = LXMessageContentText;
    
    [self makeType:message.type];
    self.fromJid = [message.from bare];
    [self makeFromNameWith:message.from];
    
    self.toJid = [message.to bare];
    self.toName = [message.to user];
    self.body = message.body;
    self.thread = message.thread;
    self.timeDate = [NSDate date];
    self.messageId = message.attributesAsDictionary[@"id"]; // 或者 [message elementID]
    
    [self makeMediaWith:message];
    
    [self makeDelayDate:message.children];
    
    [self makeJSQMessage];
}

- (void)makeType:(NSString *)messageType {
    if ([messageType isEqualToString:@"chat"]) {
        self.type = LXChatSingle;
    } else if ([messageType isEqualToString:@"groupchat"]) {
        self.type = LXChatGroup;
    } else {
        self.type = LXChatUnknow;
    }
}

- (void)makeFromNameWith:(XMPPJID *)jid {
    switch (self.type) {
        case LXChatSingle:
            self.fromName = [jid user];
            break;
        case LXChatGroup:
            self.fromName = [jid resource];
            break;
        default:
            break;
    }
    NSString *jidUser = [UserManager sharedInstance].jid.user;
    
#warning mark --测试代码(消息会出现from为空的情况)--
    if (!self.fromName) {
        self.fromName = jidUser;
        self.fromJid = [UserManager sharedInstance].jid.bare;
    }
    
    self.isMySend = [jidUser isEqualToString:self.fromName];
}

// 例子，处理多媒体线信息(通过二进制进行传递，临时使用body作为type判断，正式项目不可以这样搞)
- (void)makeMediaWith:(XMPPMessage *)message {
//    if (![self.body isEqualToString:@"voice"]) {
//        return;
//    }
//    self.contentType = LXMessageContentAudio;
//    for (NSXMLElement *element in message.children) {
//        if (![element.name isEqualToString:@"attachment"]) {
//            continue;
//        }
//        NSString *base64Str = element.stringValue;
//        NSData *data = [[NSData alloc] initWithBase64EncodedString:base64Str options:0];
//        self.audioData = data;
//        break;
//    }
    
    if (message.bodyType != LXMessageBodyAudio) {
        return;
    }
    
    NSData *data = [[NSData alloc] initWithBase64EncodedString:message.body options:0];
    self.audioData = data;
    
    NSString *duringTimeValue = message.attributesAsDictionary[@"duringTime"];
    self.audioDuringTime = [duringTimeValue doubleValue];
}

- (void)makeDelayDate:(NSArray <DDXMLNode *> *)messageChildren {
    for (NSXMLElement *item in messageChildren) {
        if (![item.name isEqualToString:@"delay"]) {
            continue;
        }
        NSString *stamp = item.attributesAsDictionary[@"stamp"];
        self.delayDate = [stamp transformToDateForXmpp];
        break;
    }
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: message=%@, messaageId=%@, toJid=%@, toName=%@, fromJid=%@, fromName=%@, showDate=%@, body=%@, audioData=%@, audioDuringTime=%f, chatType=%@, contentType=%@, thread=%@, isMySend=%@>",
            [self class], self.message, self.messageId, self.toJid, self.toName, self.fromJid, self.fromName, self.showDate, self.body, self.audioData, self.audioDuringTime, @(self.type), @(self.contentType), self.thread, @(self.isMySend)];
}

@end
