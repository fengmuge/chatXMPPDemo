//
//  UITableView+custom.m
//  ChatXmppDemo
//
//  Created by 苗培根 on 2023/6/7.
//

#import "UITableView+custom.h"

@implementation UITableView (custom)

- (void)lxRegisterClass:(Class)cellClass {
    if (![cellClass isSubclassOfClass:[UITableViewCell class]]) {
        NSLog(@"lxRegisterClass with class type error");
        return;
    }
    [self lxRegisterClass:cellClass forCellReuseIdentifier:nil];
}

- (void)lxRegisterClass:(Class)cellClass forCellReuseIdentifier:(NSString *)identifier {
    if (![cellClass isSubclassOfClass:[UITableViewCell class]]) {
        NSLog(@"lxRegisterClass:forCellReuseIdentifier: with class type error");
        return;
    }
    NSString *ident = !identifier ? NSStringFromClass(cellClass) : identifier;
    [self registerClass:cellClass forCellReuseIdentifier:ident];
}

- (UITableViewCell *)lxdequeueReusableCellWithClass:(Class)cellClass {
    return [self lxdequeueReusableCellWithClass:cellClass identifier:nil];
}

- (UITableViewCell *)lxdequeueReusableCellWithClass:(Class)cellClass identifier:(NSString *)identifier {
    if (![cellClass isSubclassOfClass:[UITableViewCell class]]) {
        NSLog(@"lxdequeueReusableCellWithClass:identifier: with class type error");
        return nil;
    }
    NSString *ident = !identifier ? NSStringFromClass(cellClass) : identifier;
    UITableViewCell *cell = [self dequeueReusableCellWithIdentifier:ident];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ident];
    }
    return cell;
}

- (UITableViewCell *)lxdequeueReusableCellWithClass:(Class)cellClass forIndexPath:(NSIndexPath *)indexPath {
    return [self lxdequeueReusableCellWithClass:cellClass identifier:nil forIndexPath:indexPath];
}

- (UITableViewCell *)lxdequeueReusableCellWithClass:(Class)cellClass identifier:(NSString *)identifier forIndexPath:(NSIndexPath *)indexPath {
    if (![cellClass isSubclassOfClass:[UITableViewCell class]]) {
        NSLog(@"lxdequeueReusableCellWithClass:identifier:forIndexPath: with class type error");
        return nil;
    }
    NSString *ident = !identifier ? NSStringFromClass(cellClass) : identifier;
    UITableViewCell *cell = [self dequeueReusableCellWithIdentifier:ident forIndexPath:indexPath];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ident];
    }
    return cell;
}

- (void)scrollToBottom:(bool)animated {
    NSInteger sections = [self numberOfSections];
    NSInteger rows = [self numberOfRowsInSection:sections - 1];
    if (rows <= 0) {
        return;
    }
    [self scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:rows - 1
                                                    inSection:sections - 1]
                atScrollPosition:UITableViewScrollPositionBottom
                        animated:animated];
}

- (void)layoutheader {
    if (!self.tableHeaderView) {
        return;
    }
    UIView *tbHeaderView = self.tableHeaderView;
    [tbHeaderView setNeedsLayout];
    [tbHeaderView layoutIfNeeded];
    CGFloat headerHeight = [tbHeaderView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
    CGRect tbHeaderframe = tbHeaderView.frame;
    tbHeaderView.frame = CGRectMake(tbHeaderframe.origin.x,
                                    tbHeaderframe.origin.y,
                                    tbHeaderframe.size.width,
                                    headerHeight);
    self.tableHeaderView = tbHeaderView;
}

@end
