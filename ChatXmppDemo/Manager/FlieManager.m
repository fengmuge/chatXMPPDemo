//
//  FlieManager.m
//  ChatXmppDemo
//
//  Created by 苗培根 on 2023/6/5.
//

#import "FlieManager.h"
#import "ChatManager.h"
<<<<<<< HEAD
#import "XMPPMessage+custom.h"

@interface FlieManager () <
XMPPIncomingFileTransferDelegate,
XMPPOutgoingFileTransferDelegate
=======

@interface FlieManager () <
XMPPIncomingFileTransferDelegate
>>>>>>> 854b75d26cabd7d317d2b4ed108afde93654cb47
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

<<<<<<< HEAD
- (void)lxSendData:(NSData *)data
             named:(NSString *)name
       toRecipient:(XMPPJID *)recipient
       description:(NSString *)description
             error:(NSError *__autoreleasing  _Nullable *)errPtr {
    NSError *error;
    BOOL isFinish = [[ChatManager sharedInstance].outgoingFileTransfer sendData:data
                                                                          named:name
                                                                    toRecipient:recipient
                                                                    description:description
                                                                          error:&error];
    if (!error && isFinish) {
        return;
    }
    NSLog(@"发送文件失败 error = %@", [error localizedDescription]);
}

=======
>>>>>>> 854b75d26cabd7d317d2b4ed108afde93654cb47
#pragma mark --XMPPIncomingFileTransferDelegate--
// 是否同意对方发文件给我
- (void)xmppIncomingFileTransfer:(XMPPIncomingFileTransfer *)sender didReceiveSIOffer:(XMPPIQ *)offer {
    NSLog(@"%s", __func__);
<<<<<<< HEAD
    // 可以设置弹窗给用户，选择是否接收文件
    
    // 这里直接接收
    [[ChatManager sharedInstance].incomingFileTransfer acceptSIOffer:offer];
=======
>>>>>>> 854b75d26cabd7d317d2b4ed108afde93654cb47
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
<<<<<<< HEAD
    // 将这个文件的发送者添加到message的from
    [message addAttributeWithName:@"from" stringValue:sender.senderJID.bare];
    // 这个感觉可以写入attribute，使用我们对xmppMessage的扩展 例如 message.bodyType = LXMessageBodyAudio;
    [message addSubject:@"audio"];
    // 文件写入本地
=======
    // 将这个文件的发送着添加到message的from
    [message addAttributeWithName:@"from" stringValue:sender.senderJID.bare];
    [message addSubject:@"audio"];
    
>>>>>>> 854b75d26cabd7d317d2b4ed108afde93654cb47
    NSString *path = [NSString filePathWithComponent:[XMPPStream generateUUID] extension:nil];
    [data writeToFile:path atomically:YES];
    
    [message addBody:path.lastPathComponent];
<<<<<<< HEAD
    // 将消息保存到本地
    //archiveMessage:outgoing:xmppStream: 执行完毕会发送通知，然后更新相应的历史消息
    [[ChatManager sharedInstance].messageCoreDataStorage archiveMessage:message
                                                               outgoing:NO
                                                             xmppStream:[ChatManager sharedInstance].stream];
}

/**
 XMPP发送文件的功能依赖于对方客户端，在XMPPStream建立连接之后会询问对方客户端的特性，然后根据返回的特性，判断对方是否能够接收某一种类型的文件。

 而XMPP支持的特性有：

  <query xmlns="http://jabber.org/protocol/disco#info">
 *     <identity category="client" type="phone"/>
 *       <feature var="http://jabber.org/protocol/si"/>
 *       <feature var="http://jabber.org/protocol/si/profile/file-transfer"/>
 *       <feature var="http://jabber.org/protocol/bytestreams"/>
 *       <feature var="http://jabber.org/protocol/ibb"/>
 *   </query>
 */
#pragma mark --XMPPOutgoingFileTransferDelegate--

- (void)xmppOutgoingFileTransfer:(XMPPOutgoingFileTransfer *)sender
                didFailWithError:(NSError *)error {
    NSLog(@"文件发送失败 %s, 失败原因 %@", __func__, [error localizedDescription]);
}


- (void)xmppOutgoingFileTransferDidSucceed:(XMPPOutgoingFileTransfer *)sender {
    NSLog(@"文件发送成功 %s", __func__);
    
    XMPPMessage *message = [XMPPMessage messageWithType:@"caht"
                                                     to:[sender.recipientJID copy]];
    // 将文件的发送者添加到message from
    [message addAttributeWithName:@"from"
                      stringValue:[UserManager sharedInstance].jid.bare];
    // 这一步可以写入attribute，使用我们对xmppMessage的扩展 例如 message.bodyType = LXMessageBodyAudio;
    [message addSubject:@"audio"];
    // 文件写入
    NSString *path = [NSString filePathWithComponent:sender.outgoingFileName
                                           extension:nil];
    
    [message addBody:path.lastPathComponent];
=======
>>>>>>> 854b75d26cabd7d317d2b4ed108afde93654cb47
    
    [[ChatManager sharedInstance].messageCoreDataStorage archiveMessage:message
                                                               outgoing:NO
                                                             xmppStream:[ChatManager sharedInstance].stream];
}

<<<<<<< HEAD

- (void)xmppOutgoingFileTransferIBBClosed:(XMPPOutgoingFileTransfer *)sender {
    
}

=======
>>>>>>> 854b75d26cabd7d317d2b4ed108afde93654cb47
@end
