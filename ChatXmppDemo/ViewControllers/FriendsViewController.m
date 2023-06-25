//
//  FriendsViewController.m
//  ChatXmppDemo
//
//  Created by 苗培根 on 2023/6/6.
//

#import "FriendsViewController.h"
#import "ChatViewController.h"
#import "SubscriptionViewController.h"
#import "ContactTableViewCell.h"
#import "FriendMenuTableViewCell.h"
#import "User.h"
#import "UITableView+custom.h"

@interface FriendsViewController () <UITableViewDelegate, UITableViewDataSource, XMPPRosterDelegate>

@property(nonatomic,strong)UITableView *contactsList;//好友列表

@property(nonatomic,strong)NSMutableDictionary *contactsPinyinDic;//联系人分级字典(用于显示的数据)

@property(nonatomic,strong)NSMutableArray *indexArray;//索引数组

@property(nonatomic,assign)BOOL isDeleteFriend;//是否是删除好友操作,设置布尔值的原因是防止服务器无故刷新数据

@property(nonatomic,strong)User *user;

@end

@implementation FriendsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"好友列表";
    self.view.backgroundColor = [UIColor whiteColor];
    self.isDeleteFriend = NO;
    
    [self addNotification];
    [self loadContactsList];
    
    //初始化好友数组
    self.indexArray = [NSMutableArray arrayWithCapacity:16];
    [self.indexArray addObject:@""];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self refetchRoster];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

// refetchRoster和sortContactsWithTitleUppercase方法我尚有疑问，
// 如果只是更新头像或者非昵称信息，为什么也需要重新获取并整理数据呢
- (void)refetchRoster {
    self.isDeleteFriend = NO;
    [[ChatManager sharedInstance].roster fetchRoster];
    [self sortContactsWithTitleUppercase];
}

// 根据联系人首字母（拼音或者英文字母）, 进行分组
- (void)sortContactsWithTitleUppercase {
    // 联系人按照首字母分组
    self.contactsPinyinDic = [[UserManager sharedInstance] sortContactsWithTitle].mutableCopy;
    // 创建索引数组
    self.indexArray = [NSMutableArray arrayWithArray:self.contactsPinyinDic.allKeys];
    
    bool isContainsJing = [self.indexArray containsObject:@"#"];
    if (isContainsJing) {
        [self.indexArray removeObject:@"#"];
    }
    for (int i = 0; i < self.indexArray.count; i++) {
        for (int j = 0; j < i; j++) {
            if (self.indexArray[j] <= self.indexArray[i]) {
                continue;
            }
            NSString *tempvalue = self.indexArray[j];
            self.indexArray[j] = self.indexArray[i];
            self.indexArray[i] = tempvalue;
        }
    }
    // 插入空字符串，对应菜单栏
    [self.indexArray insertObject:@"" atIndex:0];
    if (isContainsJing) {
        [self.indexArray addObject:@"#"];
    }
    
    [self.contactsList reloadData];
}

- (bool)isContains:(NSString *)str {
    for (NSString *item in self.indexArray) {
        if (![item isEqualToString:str]) {
            continue;
        }
        return YES;
    }
    return NO;
}

#pragma mark --notification--
- (void)addNotification {
    // 获取到好友列表
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(sortContactsWithTitleUppercase)
                                                 name:kXMPP_ROSTER_DIDEND_POPULATING
                                               object:nil];
    // 获取到好友信息
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(actionOfReceiveRosterItem:)
                                                 name:kXMPP_ROSTER_DIDRECEIVE_ROSTERITEM
                                               object:nil];
    // 收到好友请求
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedSubscription)
                                                 name:kXMPP_ADD_SUBSCRIPTION
                                               object:nil];
    // 联系人状态改变
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(rosterAvailabelStateChanged:)
                                                 name:kXMPP_CONECT_AVAILABLE_CHANGE
                                               object:nil];
    // 更新联系人或自己的名片
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceivevCardTemp:)
                                                 name:kXMPP_VCARDTEMPMODULE_DIDRECEIVE_VCARDTEMP
                                               object:nil];
    // 更新联系人或自己的头像
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveAvatarModulePhoto:)
                                                 name:kXMPP_AVATAR_DIDRECEIVE_PHOTO
                                               object:nil];
}

// 更新联系人或者自己的头像信息
- (void)didReceiveAvatarModulePhoto:(NSNotification *)notification {
    XMPPJID *jid = (XMPPJID *)[notification object];
    if (!jid) {
        return;
    }
    if ([jid isMy]) {
        // 更新个人头像信息
    } else {
        // 更新他人信息
        [self refetchRoster];
    }
}

// 更新联系人或自己的名片
- (void)didReceivevCardTemp:(NSNotification *)notification {
    bool isSuccess = [(NSNumber *)[notification object] boolValue];
    if (!isSuccess) {
        return;
    }
    NSDictionary *userInfo = [notification userInfo];
    XMPPJID *jid = (XMPPJID *)[userInfo valueForKey:@"jid"];
    // 传jid本意是万一页面能用到，现在看来有点鸡肋
    if ([jid isMy]) {
        // 更新自己的信息
    } else {
        // 更新联系人信息
        [self sortContactsWithTitleUppercase];
    }
}

// 好友状态改变
- (void)rosterAvailabelStateChanged:(NSNotification *)notification {
//    User *item = (User *)[notification object];
    [self refetchRoster];
}

// 收到添加好友请求的时候
- (void)receivedSubscription {
    NSIndexPath *indexpath = [NSIndexPath indexPathForRow:0 inSection:0];
    for (NSIndexPath *visibleIndexPath in self.contactsList.indexPathsForVisibleRows) {
        if (visibleIndexPath.section != indexpath.section ||
            visibleIndexPath.row != indexpath.row)
        {
            continue;
        }
        [self.contactsList reloadRowsAtIndexPaths:@[indexpath]
                                 withRowAnimation:UITableViewRowAnimationNone];
    }
}

// 收到好朋友信息
- (void)actionOfReceiveRosterItem:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    if (!userInfo) {
        return;
    }
    bool isRemove = [(NSNumber *)[userInfo valueForKey:@"isRemove"] boolValue];
    XMPPJID *jid = (XMPPJID *)[userInfo valueForKey:@"jid"];
    
    if (isRemove) {
        // 将联系人从在线联系人列表中删除
        [[UserManager sharedInstance] removeAvailableContacts:jid];
        // 将联系人从所有联系人列表中删除
        [[UserManager sharedInstance] removeContactWith:jid];
        // 整理数据，并从新reload tableview
        [self sortContactsWithTitleUppercase];
        return;
    }
    
    if (self.isDeleteFriend) {
        return;
    }
    [[UserManager sharedInstance] addContactWith:jid];
    
}

#pragma mark ---UITableView ----
//初始化好友列表
-(void)loadContactsList{
    
    self.contactsList = [[UITableView alloc]initWithFrame:CGRectMake(0,
                                                                     0,
                                                                     SCREEN_WIDTH,
                                                                     SCREEN_HEIGHT)
                                                    style:UITableViewStyleGrouped];
    self.contactsList.delegate = self;
    self.contactsList.dataSource = self;
    self.contactsList.separatorStyle = NO;
    self.contactsList.sectionIndexBackgroundColor = [UIColor clearColor];
    if (@available(iOS 11.0, *)) {
        self.contactsList.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
//        [[UITableView appearance] setEstimatedRowHeight:0];
//            [[UITableView appearance] setEstimatedSectionFooterHeight:0];
//            [[UITableView appearance] setEstimatedSectionHeaderHeight:0];
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    [self.contactsList lxRegisterClass:[FriendMenuTableViewCell class]];
    [self.contactsList lxRegisterClass:[ContactTableViewCell class]];
    [self.view addSubview:self.contactsList];
}


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.indexArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if (section == 0) {
        return 1;
    }else{
        NSMutableArray *sectionArray = self.contactsPinyinDic[self.indexArray[section]];
        return sectionArray.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        FriendMenuTableViewCell *cell = (FriendMenuTableViewCell *)[tableView lxdequeueReusableCellWithClass:[FriendMenuTableViewCell class]
                                                                                                    forIndexPath:indexPath];
        [cell reloadWithImage:@"新的朋友"
                        title:@"新的朋友"
                 messageCount:[UserManager sharedInstance].subscribes.count];
         return cell;
    }else{
        ContactTableViewCell *cell = (ContactTableViewCell *)[tableView lxdequeueReusableCellWithClass:[ContactTableViewCell class]
                                                                                          forIndexPath:indexPath];
        NSArray *contactSource = self.contactsPinyinDic[self.indexArray[indexPath.section]];
        User *item = contactSource[indexPath.row];
        [cell reload:item];
        return cell;
    }
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60.0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section== 0) {
        return 5.0f;
    }else{
        return 20.0;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 1.0;
}

//跳转到对应的页面中去
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
        if (indexPath.section == 0) {
        SubscriptionViewController *subscriptionVC = [[SubscriptionViewController alloc]init];
        subscriptionVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:subscriptionVC animated:YES];
    }
    else{
        ChatViewController *chatVC = [[ChatViewController alloc] init];
        chatVC.hidesBottomBarWhenPushed = YES;
        NSMutableArray *sectionArray =self.contactsPinyinDic[self.indexArray[indexPath.section]];
        User *contact = sectionArray[indexPath.row];
        chatVC.contact = contact;
        [self.navigationController pushViewController:chatVC animated:YES];
    }
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UILabel *titleLable = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 20)];
    titleLable.text = [NSString stringWithFormat:@"  %@",self.indexArray[section]];
    titleLable.font = [UIFont systemFontOfSize:15];
    titleLable.tintColor = [UIColor lightGrayColor];
    return titleLable;
}


//左滑删除
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section>0) {
        return YES;
    } else {
        return NO;
    }
}
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"删除";
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    // 从数据源中删除
    NSMutableArray *sectionArray =self.contactsPinyinDic[self.indexArray[indexPath.section]];
    User *item = sectionArray[indexPath.row];

    UIAlertController *alertView =[UIAlertController alertControllerWithTitle:@"确认删除" message:[NSString stringWithFormat:@"确认要删除好友 %@ ?",item.vCard.nickname] preferredStyle:UIAlertControllerStyleAlert];
    __weak typeof(self)temp = self;
    UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:@"确认删除" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [[UserManager sharedInstance].contacts removeObject:sectionArray[indexPath.row]];
        XMPPJID *jid = item.jid;
        [sectionArray removeObjectAtIndex:indexPath.row];
        if (sectionArray.count == 0) {
            [temp.contactsPinyinDic removeObjectForKey:temp.indexArray[indexPath.section]];
            [temp.indexArray removeObjectAtIndex:indexPath.section];
            [tableView reloadData];
        }else{
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
        temp.isDeleteFriend = YES;
        [[ChatManager sharedInstance].roster removeUser:jid];
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    
    [alertView addAction:deleteAction];
    [alertView addAction:cancelAction];
    
    [self presentViewController:alertView animated:YES completion:nil];
    
}


//快速索引
-(NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView{
    return self.indexArray;
}

-(NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index{
    return index;
}

@end
