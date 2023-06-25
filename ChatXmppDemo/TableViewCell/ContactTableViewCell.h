//
//  ContactTableViewCell.h
//  ChatXmppDemo
//
//  Created by 苗培根 on 2023/6/12.
//

#import <UIKit/UIKit.h>
@class User;

NS_ASSUME_NONNULL_BEGIN

@interface ContactTableViewCell : UITableViewCell

- (void)reload:(User *)user;

@end

NS_ASSUME_NONNULL_END
