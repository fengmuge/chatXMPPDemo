//
//  SubscriptionViewController.m
//  ChatXmppDemo
//
//  Created by 苗培根 on 2023/6/13.
//

#import "SubscriptionViewController.h"

#import "User.h"
#import "Subscription.h"

#import "SubscriptionTableViewCell.h"


@interface SubscriptionViewController () <UITableViewDelegate, UITableViewDataSource, SubscriptionTableViewCellDelegate> {
    
}

@property (nonatomic, strong) UITableView *subscriptionList;
@property (nonatomic, strong) NSMutableArray *subscribes; // 订阅
@property (nonatomic, assign) NSUInteger count; // 订阅的数量

@end

@implementation SubscriptionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"新的朋友";
    [self setLeftNavgationBarItem];
    [self setRightNavgationBarItemWithTarget:self
                                    selector:@selector(actionOfSubscribesOther)
                                       title:@"添加好友"
                                  titleColor:[UIColor blackColor]
                                 normalImage:nil
                               selectedImage:nil];
    [self.view setBackgroundColor:[UIColor colorWithPatternImage: [[UIImage imageNamed:@"没有好友请求"] reSize: CGSizeMake(SCREEN_WIDTH, SCREEN_HEIGHT)]]];
    
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (NSMutableArray *)subscribes {
    return [UserManager sharedInstance].subscribes;
}

- (NSUInteger)count {
    return self.subscribes.count;
}

// 订阅操作
- (void)actionOfSubscribesOther {
    __weak typeof(self) weakSelf = self;
    [self inputAlertWithTitle:@"添加好友" textFieldHandler:^(UITextField * _Nonnull textField) {
        textField.maxTextLength = 10;
    } actionHandler:^(bool result, UITextField * _Nullable textField) {
        if (!result) {
            return;
        }
        __strong typeof(self) strongSelf = weakSelf;
        [strongSelf subscriptionToOther:textField];
    }];
}

- (void)subscriptionToOther:(nullable UITextField *)tf {
    if ([NSString isNone:tf.text]) {
        NSLog(@"添加好友失败，输入不能为空");
        return;
    }
    // 这个地方应该添加判断，textfield是否高亮，即内容是否是合法的
    
    // 进行判断
    XMPPJID *jid = [XMPPJID lxJidWithUsername:tf.text];
    if ([[UserManager sharedInstance] isRepeatedSubscribeWith:jid]) {
        NSLog(@"添加好友失败，目标已经在订阅请求列表中");
        return;
    }
    if ([[UserManager sharedInstance] getUserFromContactsWith:jid] != nil) {
        NSLog(@"添加好友失败，目标已经在联系人列表中");
        return;
    }
    if ([jid isMy]) {
        NSLog(@"添加好友失败，不能添加自己为好友");
        return;
    }
    // 发送订阅请求
    [[ChatManager sharedInstance].roster subscribePresenceToUser:jid];
}

#pragma mark ----请求消息列表----
//初始化
-(void)loadAddFirendList{
    self.subscriptionList = [[UITableView alloc]initWithFrame:CGRectMake(0,
                                                                         0,
                                                                         SCREEN_WIDTH,
                                                                         SCREEN_HEIGHT)
                                                        style:UITableViewStylePlain];
    self.subscriptionList.backgroundColor = [UIColor whiteColor];
    self.subscriptionList.delegate = self;
    self.subscriptionList.dataSource = self;
    self.subscriptionList.separatorStyle = NO;
    if (@available(iOS 11.0, *)) {
        self.subscriptionList.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
//        [[UITableView appearance] setEstimatedRowHeight:0];
//            [[UITableView appearance] setEstimatedSectionFooterHeight:0];
//            [[UITableView appearance] setEstimatedSectionHeaderHeight:0];
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    [self.subscriptionList lxRegisterClass:[SubscriptionTableViewCell class]];
    
    [self.view addSubview:self.subscriptionList];
    
    [self setSubscriptionListHidden];
}

- (void)setSubscriptionListHidden {
    [self.subscriptionList setHidden:self.count == 0];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    SubscriptionTableViewCell *cell = (SubscriptionTableViewCell *)[tableView lxdequeueReusableCellWithClass:[SubscriptionTableViewCell class]
                                                                                                forIndexPath:indexPath];
    cell.delegate = self;
    [cell reload:self.subscribes[indexPath.row]];
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}

#pragma mark --notification--
- (void)addNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedNewSubscription)
                                                 name:kXMPP_ADD_SUBSCRIPTION
                                               object:nil];
}

- (void)receivedNewSubscription {
    [self.subscriptionList reloadData];
    [self setSubscriptionListHidden];
}

#pragma mark --SubscriptionTableViewCellDelegate--
// 同意订阅请求
// 同意之后是否需要通知好友列表 ??
- (void)subscriptioCell:(SubscriptionTableViewCell *)cell agreeWith:(Subscription *)subscription {
    // 同意，并添加到联系人
    [[ChatManager sharedInstance].roster acceptPresenceSubscriptionRequestFrom:subscription.jid
                                                                andAddToRoster:YES];
    subscription.result = LXSubscriptionResultAgree;
    [cell reload:subscription];
    [self setSubscriptionListHidden];
}
// 拒绝订阅请求
- (void)subscriptioCell:(SubscriptionTableViewCell *)cell refuseWith:(Subscription *)subscription {
    // 拒绝，并从联系人里移除
    [[ChatManager sharedInstance].roster rejectPresenceSubscriptionRequestFrom:subscription.jid];
    [[ChatManager sharedInstance].roster removeUser:subscription.jid];
    
    subscription.result = LXSubscriptionResultRefuse;
    [cell reload:subscription];
    [self setSubscriptionListHidden];
}

@end
