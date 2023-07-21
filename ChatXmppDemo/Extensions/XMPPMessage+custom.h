//
//  XMPPMessage+custom.h
//  ChatXmppDemo
//
//  Created by 苗培根 on 2023/6/27.
//

#define kReceipts @"urn:xmpp:receipts"

#import <XMPPFramework/XMPPFramework.h>
#import "LXMessageDefine.h"

NS_ASSUME_NONNULL_BEGIN

@interface XMPPMessage (custom)

@property (nonatomic, assign) LXMessageBodyType bodyType;

// 是否是来自房间的邀请
- (BOOL)isRoomInvite;
// 是否是音视频通话相关的信息
- (BOOL)isCallAbout;

- (BOOL)isRequest;
- (NSXMLElement *)request;
- (void)setRequest:(NSString *)request;

- (BOOL)isReceived;
- (NSXMLElement *)received;
- (void)setReceived:(NSString *)received;

- (LXCallMessageType)callMessageType;

- (NSDictionary *)transformBodyToDict;

@end

NS_ASSUME_NONNULL_END
