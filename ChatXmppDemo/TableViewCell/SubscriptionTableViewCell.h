//
//  SubscriptionTableViewCell.h
//  ChatXmppDemo
//
//  Created by 苗培根 on 2023/6/12.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class Subscription;
@class SubscriptionTableViewCell;
@protocol SubscriptionTableViewCellDelegate <NSObject>

// 同意订阅请求
- (void)subscriptioCell:(SubscriptionTableViewCell *)cell agreeWith:(Subscription *)subscription;
// 拒绝订阅请求
- (void)subscriptioCell:(SubscriptionTableViewCell *)cell refuseWith:(Subscription *)subscription;

@end

@interface SubscriptionTableViewCell : UITableViewCell

@property (nonatomic, assign) id<SubscriptionTableViewCellDelegate> delegate;

- (void)reload:(Subscription *)item;

@end

NS_ASSUME_NONNULL_END
