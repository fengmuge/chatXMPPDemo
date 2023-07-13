//
//  UITableView+custom.h
//  ChatXmppDemo
//
//  Created by 苗培根 on 2023/6/7.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UITableView (custom)

- (void)scrollToBottom:(bool)animated;

- (void)layoutheader;

//- (void)lxRegisterClass:(Class)cellClass;
//
//- (void)lxRegisterClass:(Class)cellClass forCellReuseIdentifier:(nullable NSString *)identifier;

//- (UITableViewCell *)lxdequeueReusableCellWithClass:(Class)cellClass;
//
//- (UITableViewCell *)lxdequeueReusableCellWithClass:(Class)cellClass identifier:(nullable NSString *)identifier;
//
//- (UITableViewCell *)lxdequeueReusableCellWithClass:(Class)cellClass forIndexPath:(NSIndexPath *)indexPath;
//
//- (UITableViewCell *)lxdequeueReusableCellWithClass:(Class)cellClass identifier:(nullable NSString *)identifier forIndexPath:(NSIndexPath *)indexPath;

@end

NS_ASSUME_NONNULL_END
