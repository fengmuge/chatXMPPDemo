//
//  UITableViewCell+custom.h
//  ChatXmppDemo
//
//  Created by 苗培根 on 2023/7/12.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UITableViewCell (custom)

+ (void)lxRegisterCellWith:(UITableView *)tableView;

+ (void)lxRegisterCellWith:(UITableView *)tableView forCellReuseIdentifier:(nullable NSString *)identifier;

+ (instancetype)lxdequeueReusableCellWith:(UITableView *)tableView;

+ (instancetype)lxdequeueReusableCellWith:(UITableView *)tableView identifier:(nullable NSString *)identifier;

+ (instancetype)lxdequeueReusableCellWith:(UITableView *)tableView forIndexPath:(NSIndexPath *)indexPath;

+ (instancetype)lxdequeueReusableCellWith:(UITableView *)tableView identifier:(nullable NSString *)identifier forIndexPath:(NSIndexPath *)indexPath;

@end

NS_ASSUME_NONNULL_END
