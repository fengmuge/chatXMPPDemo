//
//  FriendMenuTableViewCell.h
//  ChatXmppDemo
//
//  Created by 苗培根 on 2023/6/13.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FriendMenuTableViewCell : UITableViewCell

- (void)reloadWithImage:(NSString *)imgname title:(NSString *)title messageCount:(NSUInteger)count;
- (void)resetMessageCount:(int)count;

@end

NS_ASSUME_NONNULL_END
