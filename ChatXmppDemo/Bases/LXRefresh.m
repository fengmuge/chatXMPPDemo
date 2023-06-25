//
//  LXRefresh.m
//  ChatXmppDemo
//
//  Created by 苗培根 on 2023/6/25.
//

#import "LXRefresh.h"

@interface LXRefresh ()
// 闲置状态下的gif(拖动未达到临界点之前的)
@property (nonatomic, copy) NSArray <UIImage *> *idelImages;
// 已经达到临界点时的gif
@property (nonatomic, copy) NSArray <UIImage *> *pullingImages;
// 正在刷新时候的gif（达到临界点之后松手，进行刷新时候的）
@property (nonatomic, copy) NSArray <UIImage *> *refreshingImages;

@property (nonatomic, weak) UIScrollView *scrollView;

@end

@implementation LXRefresh

- (instancetype)init {
    if (self = [super init]) {
//        self.idelImages = @[];
//        self.pullingImages = @[];
//        self.refreshingImages = @[];
    }
    return self;
}

- (instancetype)initWith:(UIScrollView *)scrollView {
    if (self = [super init]) {
        self.scrollView = scrollView;
    }
    return self;
}

//- (void)normalModelRefresh:(UITableView *)tableView refreshType:(RefreshType)refreshType firstRefresh:(BOOL)firstRefresh timeLabHidden:(BOOL)timeLabHidden stateLabHidden:(BOOL)stateLabHidden dropDownBlock:(void(^)(void))dropDownBlock upDropBlock:(void(^)(void))upDropBlock



@end
