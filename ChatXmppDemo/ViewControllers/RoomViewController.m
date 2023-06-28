//
//  RoomViewController.m
//  ChatXmppDemo
//
//  Created by 苗培根 on 2023/6/6.
//

#import "RoomViewController.h"
#import "ChatViewController.h"
#import "RoomManager.h"
#import "UserManager.h"
#import "RoomConfiguration.h"
#import "Room.h"
#import "User.h"

@interface RoomViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSMutableArray <Room *> *roomDatas;
@property (nonatomic, strong) UITableView *roomList;

@property (nonatomic, strong) Room *selectedRoom;

@end

@implementation RoomViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"群组";
    [self setLeftNavgationBarItemWithTarget:self
                                   selector:@selector(refreshRoomList)
                                      title:@"刷新"
                                 titleColor:[UIColor grayColor]];
    [self setRightNavgationBarItemWithTarget:self
                                    selector:@selector(createRoom)
                                       title:@"创建群"
                                  titleColor:[UIColor grayColor]];
    
    [self makeRoomList];
    [self addNotification];
    [[RoomManager sharedInstance] fetchJoinedRoomList];
}

- (NSMutableArray *)roomDatas {
    if (!_roomDatas) {
        _roomDatas = [[NSMutableArray alloc] init];
     }
    return _roomDatas;
 }

- (void)refreshRoomList {
    [self showHud:0.25];
    [self.roomDatas removeAllObjects];
    [[RoomManager sharedInstance] fetchJoinedRoomList];
}

// 如果输入的群组id是目前已经存在的，那么会加入到群组中(细节待确认)
- (void)createRoom {
    __weak typeof(self) weakSelf = self;
    [self inputAlertWithTitle:@"创建/加入群组" textFieldHandler:^(UITextField * _Nonnull textField) {
        textField.maxTextLength = 10;
        textField.text = [NSDate transformCurrentDate];
    } actionHandler:^(bool result, UITextField * _Nullable textField) {
        if (!result) {
            return;
        }
        __strong typeof(self) strongSelf = weakSelf;
        [strongSelf createOrJoinRoom:textField];
    }];
}

- (void)createOrJoinRoom:(nullable UITextField *)tf {
    if ([NSString isNone:tf.text]) {
        NSLog(@"群组id不能为空");
        return;
    }
    // 这个地方应该添加判断，textfield是否高亮，即内容是否是合法的
    
    // roomid不允许存在空格
    NSString *roomId = [NSString stringWithFormat:@"%@@%@.%@", tf.text, kSubdomain, kDomin];
    [[ChatManager sharedInstance] makeRoom:roomId
                             usingNickname:[UserManager sharedInstance].user.name];
}

#pragma mark --notification--
- (void)addNotification {
    // 获取到群组列表
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(fetchJoinedRoomResult:)
                                                 name:kXMPP_FETCHED_GROUPS
                                               object:nil];
    // 获取到房间信息
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didFetchRoomInformation:)
                                                 name:kXMPP_FETCHED_GROUP_INFORMATION
                                               object:nil];
    // 创建房间成功
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didCreateRoom:)
                                                 name:kXMPP_ROOM_DID_CREATE
                                               object:nil];
    // 加入房间成功
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didJoinRoom:)
                                                 name:kXMPP_ROOM_DID_JOIN
                                               object:nil];
    // 离开房间成功
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didLeaveRoom:)
                                                 name:kXMPP_ROOM_DID_LEAVE
                                               object:nil];
    // 获取到房间配置
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didFetchConfigurationForm:)
                                                 name:kXMPP_ROOM_DIDFETCH_CONFIGURATIONFORM
                                               object:nil];
    // 房间销毁结果
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(roomDestory:)
                                                 name:kXMPP_ROOM_DESTROY_RESULT
                                               object:nil];
    // 收到错误信息
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didFetchPresenceError:)
                                                 name:kXMPP_PRESENCEERROR_OF_GROUP
                                               object:nil];
}

- (void)didFetchPresenceError:(NSNotification *)notification {
    [self hideHud:NO];
    NSString *from = notification.userInfo[@"roomJid"];
    NSString *message = notification.userInfo[@"message"];
    if (from != nil && ![from isEqualToString:self.selectedRoom.roomJidvalue]) {
        return;
    }
    
    [self alertAutoDisappearWithTitle:message message:nil];
}

- (void)didFetchRoomInformation:(NSNotification *)notification {
    self.roomDatas = [RoomManager sharedInstance].rooms;
    [self.roomList reloadData];
}

- (void)didFetchConfigurationForm:(NSNotification *)notification {
    XMPPRoom *room = (XMPPRoom *)notification.userInfo[@"room"];
    RoomConfiguration *config = (RoomConfiguration *)notification.userInfo[@"configuration"];
    if (!room || !config) {
        return;
    }
    // 根据配置设置UI
}

- (void)roomDestory:(NSNotification *)notification {
    
}

- (void)didLeaveRoom:(NSNotification *)notification {
    
}

// 加入房间成功
- (void)didJoinRoom:(NSNotification *)notification {
    [self hideHud:NO];
    if (!self.selectedRoom) {
        return;
    }
    XMPPRoom *room = (XMPPRoom *)[notification object];
    if (![self.selectedRoom.roomJidvalue isEqualToString:room.roomJID.bare]) {
        return;
    }
    [self.selectedRoom setRoom:room];
    [self pushToChatViewControllerWith:self.selectedRoom];
    self.selectedRoom = nil;
}

// 创建房间成功
- (void)didCreateRoom:(NSNotification *)notification {
    
}

// 获取到群组列表
- (void)fetchJoinedRoomResult:(NSNotification *)notification {
    [self hideHud:NO];
    NSArray *rooms = (NSArray *)[notification object];
    if (!rooms || rooms.count == 0) {
        return;
    }
    [self.roomDatas addObjectsFromArray:rooms];
    [self.roomList reloadData];
}

#pragma mark ---UITableView ----
//初始化好友列表
-(void)makeRoomList {
    
    self.roomList = [[UITableView alloc]initWithFrame:CGRectMake(0,
                                                                     0,
                                                                     SCREEN_WIDTH,
                                                                     SCREEN_HEIGHT)
                                                    style:UITableViewStylePlain];
    self.roomList.delegate = self;
    self.roomList.dataSource = self;
    self.roomList.separatorStyle = YES;
    self.roomList.sectionIndexBackgroundColor = [UIColor clearColor];
    if (@available(iOS 11.0, *)) {
        self.roomList.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
//        [[UITableView appearance] setEstimatedRowHeight:0];
//            [[UITableView appearance] setEstimatedSectionFooterHeight:0];
//            [[UITableView appearance] setEstimatedSectionHeaderHeight:0];
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    [self.roomList registerClass:[UITableViewCell class] forCellReuseIdentifier:@"lxRoomListTableViewCell"];
    [self.view addSubview:self.roomList];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.roomDatas.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"lxRoomListTableViewCell" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    Room *item = self.roomDatas[indexPath.row];
    cell.textLabel.text = item.name;
    cell.detailTextLabel.text = item.roomJidvalue;
    if (item.isFetchDetail) {
        cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    }
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60.0;
}

//跳转到对应的页面中去
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    Room *item = self.roomDatas[indexPath.row];
    if (item.isFetchDetail) {
        [self prepareForPushToChatViewControllerWith:item];
    } else {
        [[ChatManager sharedInstance] fetchInformationWith:item.roomJidvalue];
    }

}

- (void)prepareForPushToChatViewControllerWith:(Room *)item {
    self.selectedRoom = item;
    if (!item.configuration.isPasswordProtected) {
        [self verifyPasswordWithJid:item.roomJidvalue
                           password:nil];
        return;
    }
    __weak typeof(self) weakSelf = self;
    [self inputAlertWithTitle:@"请输入邀请码" textFieldHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"邀请码";
        textField.keyboardType = UIKeyboardTypeNumberPad;
    } actionHandler:^(bool result, UITextField * _Nullable textField) {
        __strong typeof(self) strongSelf = weakSelf;
        if (!result) {
            strongSelf.selectedRoom = nil;
            return;
        }
        [strongSelf verifyPasswordWithJid:item.roomJidvalue
                                 password:textField.text];
    }];
}

- (void)verifyPasswordWithJid:(NSString *)roomJid password:(NSString *)password {
    [self showHud:YES];
    NSString *nickName = [UserManager sharedInstance].user.name;
    [[ChatManager sharedInstance] makeRoom:roomJid
                             usingNickname:nickName
                                  password:password];
}

- (void)pushToChatViewControllerWith:(Room *)item {
    ChatViewController *chatVC = [[ChatViewController alloc] init];
    chatVC.hidesBottomBarWhenPushed = YES;
    chatVC.room = item;
    [self.navigationController pushViewController:chatVC animated:YES];
}

@end
