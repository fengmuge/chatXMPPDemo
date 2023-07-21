//
//  MessageManager.m
//  ChatXmppDemo
//
//  Created by 苗培根 on 2023/6/5.
//

#import "MessageManager.h"
#import "ChatManager.h"
#import "LXMessage.h"
#import "XMPPMessage+custom.h"

@interface MessageManager () <
XMPPMessageArchivingStorage
>

@end

@implementation MessageManager

static MessageManager *_sharedInstance;

+ (MessageManager *)sharedInstance {
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

// 获取历史记录
// toUserJid目标联系人jid,用于单聊
// toRoomJid目标聊天室jid，用于群聊
// 以上两个参数互斥，以toUserJid优先
+ (NSArray *)getHistoryMessageWith:(XMPPJID *)toUserJid orRoomId:(XMPPJID *)toRoomJid {
    XMPPMessageArchivingCoreDataStorage *storage = [ChatManager sharedInstance].messageCoreDataStorage;
    // 查询时候的上下文
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:storage.messageEntityName inManagedObjectContext:storage.mainThreadManagedObjectContext];
    [fetchRequest setEntity:entityDescription];
    // 添加过滤条件
    NSPredicate *predicate;
    if (toUserJid) {
        predicate = [NSPredicate predicateWithFormat:@"streamBareJidStr == %@ AND bareJidStr == %@", [UserManager sharedInstance].jid.bare, toUserJid.bare];
    } else {
        predicate = [NSPredicate predicateWithFormat:@"bareJidStr = %@", toRoomJid.bare];
    }
    [fetchRequest setPredicate:predicate];
    // 按照时间排序
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timestamp" ascending:YES];
    [fetchRequest setSortDescriptors:@[sortDescriptor]];
    // 请求数据
    NSError *error;
    NSArray *fetchResults = [storage.mainThreadManagedObjectContext executeFetchRequest:fetchRequest
                                                                                  error:&error];
    if (!fetchResults) {
        NSLog(@"%s with error: %@", __func__, [error localizedDescription]);
    }
    
    return [MessageManager sortHistoryMessage:fetchResults];
}

+ (NSArray *)sortHistoryMessage:(NSArray <XMPPMessageArchiving_Message_CoreDataObject *> *)messages {
    NSMutableArray *sortResultes = [[NSMutableArray alloc] init];
    for (XMPPMessageArchiving_Message_CoreDataObject *object in messages) {
        LXMessage *msg = [[LXMessage alloc] initWithMessageCoreDataObject:object];
        if (!msg.willShow) {
            continue;
        }
        [sortResultes addObject:msg];
    }
    
    return [sortResultes copy];
}

- (void)sendSignalingMessage:(NSString *)message toUser:(NSString *)userJid isVideoCall:(BOOL)isVideo {
    XMPPJID *jid = [XMPPJID lxJidWithUsername:userJid];
    
    XMPPMessage *xmppMessage = [XMPPMessage messageWithType:@"chat" to:jid];
    [xmppMessage addBody:message];
    xmppMessage.bodyType = isVideo ? LXMessageBodyVideoCall : LXMessageBodyVoiceCell;
    xmppMessage.request = kReceipts;
    
    [[ChatManager sharedInstance].stream sendElement:xmppMessage];
}

#pragma mark --XMPPMessageArchivingStorage--
- (void)archiveMessage:(XMPPMessage *)message outgoing:(BOOL)isOutgoing xmppStream:(XMPPStream *)stream {
}

- (BOOL)configureWithParent:(XMPPMessageArchiving *)aParent queue:(dispatch_queue_t)queue {
    return YES;
}


@end
