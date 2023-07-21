//
//  ConversationTableViewCell.h
//  ChatXmppDemo
//
//  Created by 苗培根 on 2023/6/7.
//

#import <UIKit/UIKit.h>
@class Conversation;
NS_ASSUME_NONNULL_BEGIN

@interface ConversationTableViewCell : UITableViewCell

//- (void)reload:(NSString *)title content:(NSString *)content;

- (void)reload:(Conversation *)item;

@end

NS_ASSUME_NONNULL_END
