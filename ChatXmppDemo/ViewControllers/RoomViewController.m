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
#import "Room.h"
#import "User.h"

@interface RoomViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSMutableArray *roomDatas;
@property(nonatomic,strong) UITableView *roomList;//好友列表


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
    //
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
    DDXMLElement *item = self.roomDatas[indexPath.row];
    NSString *roomName = [NSString stringWithFormat:@"%@", [item attributeForName:@"name"].stringValue];
    cell.textLabel.text = roomName;
    cell.detailTextLabel.text = [item attributeForName:@"jid"].stringValue;
//    Room *item = self.roomDatas[indexPath.row];
//    cell.textLabel.text = item.subject ?: item.roomName;
//    cell.detailTextLabel.text = item.roomJid.bare;
    return cell;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60.0;
}

//跳转到对应的页面中去
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    ChatViewController *chatVC = [[ChatViewController alloc] init];
    chatVC.hidesBottomBarWhenPushed = YES;
    DDXMLElement *item = self.roomDatas[indexPath.row];
    chatVC.room = item;
    [self.navigationController pushViewController:chatVC animated:YES];
}

@end
