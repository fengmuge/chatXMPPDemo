//
//  XMPPMessage+custom.h
//  ChatXmppDemo
//
//  Created by 苗培根 on 2023/6/27.
//

#import <XMPPFramework/XMPPFramework.h>

typedef enum : NSUInteger {
    LXMessageBodyText,
    LXMessageBodyAudio,
    LXMessageBodyVideo,
    LXMessageBodyImage,
    LXMessageBodyCard,
    LXMessageBodyVideoCall,
    LXMessageBodyVoiceCell,
} LXMessageBodyType;

NS_ASSUME_NONNULL_BEGIN

@interface XMPPMessage (custom)

@property (nonatomic, assign) LXMessageBodyType bodyType;

// 是否是来自房间的邀请
- (BOOL)isRoomInvite;

- (NSXMLElement *)request;
- (void)setRequest:(NSString *)request;

@end

NS_ASSUME_NONNULL_END
