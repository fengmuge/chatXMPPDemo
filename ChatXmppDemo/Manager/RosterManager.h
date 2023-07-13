//
//  RosterManager.h
//  ChatXmppDemo
//
//  Created by 苗培根 on 2023/6/5.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RosterManager : NSObject

+ (RosterManager *)sharedInstance;

- (NSArray *)fetchUsers;

- (void)addUser:(NSString *)username reason:(NSString *)reason;
// 接受对方的好友请求， flag 同意对方请求的同时，是否请求添加对方为好友
- (void)acceptAddRequestFrom:(NSString *)username addAddRoster:(BOOL)flag;
// 拒绝对方的好友请求
- (void)rejectAddRequestFrom:(NSString *)username;
// 删除某个好友
- (void)removeUser:(NSString *)username;
// 为好友添加备注
- (void)setNickname:(NSString *)nickname forUser:(NSString *)username;


@end

NS_ASSUME_NONNULL_END
