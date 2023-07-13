//
//  FlieManager.h
//  ChatXmppDemo
//
//  Created by 苗培根 on 2023/6/5.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FlieManager : NSObject

+ (FlieManager *)sharedInstance;

// 发送文件，recipient 接收人
- (void)lxSendData:(NSData *)data
             named:(NSString *)name
       toRecipient:(XMPPJID *)recipient
       description:(NSString *)description
             error:(NSError *__autoreleasing *)errPtr;

@end

NS_ASSUME_NONNULL_END
