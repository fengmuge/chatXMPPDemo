//
//  RTCRoom.h
//  ChatXmppDemo
//
//  Created by 苗培根 on 2023/7/17.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RTCRoomParam : NSObject
 
@property (nonatomic, assign) BOOL is_initiator;
@property (nonatomic, copy) NSString *room_id;
@property (nonatomic, copy) NSString *client_id;
@property (nonatomic, strong) NSArray *messages;
@property (nonatomic, copy) NSString *wss_url;
@property (nonatomic, copy) NSString *wss_post_url;

@end

@interface RTCRoom : NSObject

@property (nonatomic, copy) NSString *result;
@property (nonatomic, strong) RTCRoomParam *params;

@end

NS_ASSUME_NONNULL_END

