//
//  FlieManager.m
//  ChatXmppDemo
//
//  Created by 苗培根 on 2023/6/5.
//

#import "FlieManager.h"
#import "ChatManager.h"

@interface FlieManager () <
XMPPIncomingFileTransferDelegate
>

@end

@implementation FlieManager

static FlieManager *_sharedInstance;

+ (FlieManager *)sharedInstance {
    return [[self alloc] init];
}

- (instancetype)init {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [super init];
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

#pragma mark --XMPPIncomingFileTransferDelegate--
// 是否同意对方发文件给我
- (void)xmppIncomingFileTransfer:(XMPPIncomingFileTransfer *)sender didReceiveSIOffer:(XMPPIQ *)offer {
    NSLog(@"%s", __func__);
}

// 文件传输失败
- (void)xmppIncomingFileTransfer:(XMPPIncomingFileTransfer *)sender didFailWithError:(NSError *)error {
    NSLog(@"%s", __func__);
    if (!error) {
        return;
    }
//    [[NSNotificationCenter defaultCenter] postNotificationName:<#(nonnull NSNotificationName)#> object:<#(nullable id)#>];
}

// 接收文件成功
- (void)xmppIncomingFileTransfer:(XMPPIncomingFileTransfer *)sender didSucceedWithData:(NSData *)data named:(NSString *)name {
    XMPPJID *jid = [sender.senderJID copy];
    NSLog(@"%s", __func__);
    //在这个方法里面，我们通过带外来传输的文件 （带外 ？？？）
    //因此我们的消息同步器，不会帮我们自动生成Message,因此我们需要手动存储message
    //根据文件后缀名，判断文件我们是否能够处理，如果不能处理则直接显示。
    //图片 音频 （.wav,.mp3,.mp4)
    NSString *extension = [name pathExtension];
    if (![extension isEqualToString:@"wav"]) {
        return;
    }
    // 创建一个XMPPMessage对象，message必须要有from
    XMPPMessage *message = [XMPPMessage messageWithType:@"chat" to:jid];
    // 将这个文件的发送着添加到message的from
    [message addAttributeWithName:@"from" stringValue:sender.senderJID.bare];
    [message addSubject:@"audio"];
    
    NSString *path = [NSString filePathWithComponent:[XMPPStream generateUUID] extension:nil];
    [data writeToFile:path atomically:YES];
    
    [message addBody:path.lastPathComponent];
    
    [[ChatManager sharedInstance].messageCoreDataStorage archiveMessage:message
                                                               outgoing:NO
                                                             xmppStream:[ChatManager sharedInstance].stream];
}

@end
