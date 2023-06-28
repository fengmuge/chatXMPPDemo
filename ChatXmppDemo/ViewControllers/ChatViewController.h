//
//  ChatViewController.h
//  ChatXmppDemo
//
//  Created by 苗培根 on 2023/6/5.
//
// 消息页面的基类
#import <UIKit/UIKit.h>

@class User;
@class Room;
NS_ASSUME_NONNULL_BEGIN

@interface ChatViewController : JSQMessagesViewController

@property (nonatomic, strong) Room *room;
@property (nonatomic, strong) User *contact;

- (void)addNotification;

@end

NS_ASSUME_NONNULL_END
