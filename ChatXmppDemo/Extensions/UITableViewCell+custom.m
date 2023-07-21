//
//  UITableViewCell+custom.m
//  ChatXmppDemo
//
//  Created by 苗培根 on 2023/7/12.
//

#import "UITableViewCell+custom.h"

@implementation UITableViewCell (custom)

+ (void)lxRegisterCellWith:(UITableView *)tableView {
    [[self class] lxRegisterCellWith:tableView forCellReuseIdentifier:nil];
}

+ (void)lxRegisterCellWith:(UITableView *)tableView forCellReuseIdentifier:(nullable NSString *)identifier {
    NSString *ident = ![NSString isNone:identifier] ? identifier : NSStringFromClass([self class]);
    [tableView registerClass:[self class] forCellReuseIdentifier:ident];
}

+ (instancetype)lxdequeueReusableCellWith:(UITableView *)tableView {
    return [[self class] lxdequeueReusableCellWith:tableView identifier:nil];
}

+ (instancetype)lxdequeueReusableCellWith:(UITableView *)tableView identifier:(nullable NSString *)identifier {
    return [[self class] lxdequeueReusableCellWith:tableView style:UITableViewCellStyleDefault identifier:identifier];
}

+ (instancetype)lxdequeueReusableCellWith:(UITableView *)tableView style:(UITableViewCellStyle)style identifier:(nullable NSString *)identifier {
    NSString *ident = ![NSString isNone:identifier] ? identifier : NSStringFromClass([self class]);
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ident];
    if (!cell) {
        cell = [[[self class] alloc] initWithStyle:style reuseIdentifier:ident];
    }
    return cell;
}

+ (instancetype)lxdequeueReusableCellWith:(UITableView *)tableView forIndexPath:(NSIndexPath *)indexPath {
    return [[self class] lxdequeueReusableCellWith:tableView identifier:nil forIndexPath:indexPath];
}

+ (instancetype)lxdequeueReusableCellWith:(UITableView *)tableView style:(UITableViewCellStyle)style forIndexPath:(NSIndexPath *)indexPath {
    return [[self class] lxdequeueReusableCellWith:tableView style:style identifier:nil forIndexPath:indexPath];
}

+ (instancetype)lxdequeueReusableCellWith:(UITableView *)tableView identifier:(nullable NSString *)identifier forIndexPath:(NSIndexPath *)indexPath {
    return [[self class] lxdequeueReusableCellWith:tableView style:UITableViewCellStyleDefault identifier:identifier forIndexPath:indexPath];
}

+ (instancetype)lxdequeueReusableCellWith:(UITableView *)tableView style:(UITableViewCellStyle)style identifier:(nullable NSString *)identifier forIndexPath:(NSIndexPath *)indexPath {
    NSString *ident = ![NSString isNone:identifier] ? identifier : NSStringFromClass([self class]);
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ident forIndexPath:indexPath];
    if (!cell) {
        cell = [[[self class] alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ident];
    }
    return cell;
}

@end
