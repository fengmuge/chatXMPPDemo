//
//  UserManager.h
//  ChatXmppDemo
//
//  Created by 苗培根 on 2023/6/9.
//

// 用户数据管理工具

#import <UIKit/UIKit.h>

@class User;
@class Subscription;
NS_ASSUME_NONNULL_BEGIN

@interface UserManager : NSObject

// 用来管理用户信息(读写和缓存)、好友和好友请求数组
+ (UserManager *)sharedInstance;

// 用户基本信息
@property (nonatomic, strong, nullable) User *user;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, strong) XMPPJID *jid;

// 从服务器获取的所有好友数组，杂乱无章，需要排序
@property (nonatomic, strong, nullable) NSMutableArray <User *> *contacts;
// 总服务器获取的在线好友信息
@property (nonatomic, strong, nullable) NSMutableArray <XMPPJID *> *availableContacts;
// 好友请求数组，存储请求者的jid
@property (nonatomic, strong, nullable) NSMutableArray <Subscription *> *subscribes;

// 用户当前是否登录
@property (nonatomic, assign) bool isLogin;

- (void)clearAll;
// 是否是重复的好友请求
- (bool)isRepeatedSubscribeWith:(XMPPJID *)jid;
// 修改联系人available状态
- (bool)changeContactWithJID:(XMPPJID *)jid
                 isAvailable:(bool)available;
// 根据jid获取当前联系人
- (User *)getUserFromContactsWith:(XMPPJID *)jid;
// 设置jid和password
- (void)configWithUsername:(NSString *)username
                  password:(NSString *)password;

// 添加联系人
- (void)addContactWith:(XMPPJID *)jid;
// 删除联系人
- (void)removeContactWith:(XMPPJID *)jid;
// 联系人按照拼音首字母分组
- (NSDictionary *)sortContactsWithTitle;
// 更新联系人或自己的名片
- (void)didReceivevCardTemp:(XMPPvCardTemp *)vCardTemp
                     forJID:(XMPPJID *)jid;
// 更新联系人或自己的头像
- (void)didReceivePhoto:(UIImage *)photo
                 forJID:(XMPPJID *)jid;
// 添加订阅请求
- (void)addSubscribesWith:(XMPPJID *)jid;
// 删除订阅请求
- (void)removeSubscribesWith:(XMPPJID *)jid;
// 添加在线好友
- (void)addAvailableContacts:(XMPPJID *)jid;
// 移除在线好友
- (void)removeAvailableContacts:(XMPPJID *)jid;

@end

NS_ASSUME_NONNULL_END
