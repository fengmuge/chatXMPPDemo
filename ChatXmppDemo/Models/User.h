//
//  User.h
//  ChatXmppDemo
//
//  Created by 苗培根 on 2023/6/8.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface User : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *nickName;
@property (nonatomic, copy) NSString *password;
@property (nonatomic, strong) UIImage *avatar;

// 用户jid
@property (nonatomic, strong) XMPPJID *jid;
// 用户名片
@property (nonatomic, strong) XMPPvCardTemp *vCard;
// 是否在线
@property (nonatomic, assign) bool isAvailable;

@end

NS_ASSUME_NONNULL_END
