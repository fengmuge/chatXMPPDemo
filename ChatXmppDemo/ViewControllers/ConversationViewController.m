//
//  ConversationViewController.m
//  ChatXmppDemo
//
//  Created by 苗培根 on 2023/6/6.
//

#import "ConversationViewController.h"
#import "ConversationTableViewCell.h"
#import "Conversation.h"

@interface ConversationViewController () <
UITableViewDelegate,
UITableViewDataSource,
UIGestureRecognizerDelegate
> {
    UIView *_snapShot;
    NSIndexPath *_sourceIndexPath;
}

@property (nonatomic, strong) UITableView *conversationTableView;
@property (nonatomic, strong) NSMutableArray *conversations;
@property (nonatomic, assign) NSUInteger topConversationNum;

@end

@implementation ConversationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"会话列表";
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.topConversationNum = 0;
    
    self.conversations = [Conversation makeTestData];
    
    [self initialTableView];
    
//    [self setRightNavgationBarItemWithTarget:self selector:@selector(rightNavgationItemClicked:) title:@"编辑" titleColor:nil];
}

- (void)rightNavgationItemClicked:(id)sender {
    BOOL flag = !_conversationTableView.editing;
    [self.conversationTableView setEditing:flag animated:YES];
    
    NSString *btnTitle = flag ? @"保存" : @"编辑";
    [(UIButton *)sender setTitle:btnTitle forState:UIControlStateNormal];
    
    [self.view endEditing:YES];
}

-(void)initialTableView {
    
    self.conversationTableView = [[UITableView alloc]initWithFrame:CGRectMake(0,
                                                                     0,
                                                                     SCREEN_WIDTH,
                                                                     SCREEN_HEIGHT - TabBar_Height - NavBar_Height)
                                                    style:UITableViewStylePlain];
    self.conversationTableView.delegate = self;
    self.conversationTableView.dataSource = self;
    self.conversationTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.conversationTableView.sectionIndexBackgroundColor = [UIColor clearColor];
    if (@available(iOS 11.0, *)) {
        self.conversationTableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    [ConversationTableViewCell lxRegisterCellWith:self.conversationTableView];
    
    [self.view addSubview:self.conversationTableView];
    
    [self addGestureToTableView];
}

#pragma mark --gesture--
- (void)addGestureToTableView {
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(tableViewLongPressGesture:)];
    longPressGesture.delegate = self;
    [self.conversationTableView addGestureRecognizer:longPressGesture];
}

- (void)tableViewLongPressGesture:(UILongPressGestureRecognizer *)longPressGesture {
    UIGestureRecognizerState state = longPressGesture.state;
    CGPoint location = [longPressGesture locationInView:self.conversationTableView];
    if (location.x <= SCREEN_WIDTH - 60) {
        return;
    }
    NSIndexPath *indexPath = [self.conversationTableView indexPathForRowAtPoint:location];
    switch (state) {
        case UIGestureRecognizerStateBegan:
        {
            if (!indexPath) {
                NSLog(@"未找到目标UITableViewCell %s", __func__);
                return;
            }
            [self.view endEditing:YES];
            _sourceIndexPath = indexPath;
            UITableViewCell *cell = [self.conversationTableView cellForRowAtIndexPath:indexPath];
            _snapShot = [cell snapshotView];
            __block CGPoint center = cell.center;
            _snapShot.center = center;
            _snapShot.alpha = 0.0;
            [self.conversationTableView addSubview:_snapShot];
            __weak typeof(self) weakSelf = self;
            [UIView animateWithDuration:0.25 animations:^{
                __strong typeof(self) strongSelf = weakSelf;
                center.y = location.y;
                strongSelf->_snapShot.center = center;
                strongSelf->_snapShot.alpha = 1.0;
                cell.alpha = 0.0;
            }];
        }
            break;
        case UIGestureRecognizerStateChanged:
        {
            CGPoint center = _snapShot.center;
            center.y = location.y;
            _snapShot.center = center;
            if (indexPath && ![indexPath isEqual:_sourceIndexPath]) {
                // 改变数据源
                [self.conversations exchangeObjectAtIndex:indexPath.row withObjectAtIndex:_sourceIndexPath.row];
                // 移动cell
                [self.conversationTableView moveRowAtIndexPath:_sourceIndexPath toIndexPath:indexPath];
                _sourceIndexPath = indexPath;
                UITableViewCell *cell = [self.conversationTableView cellForRowAtIndexPath:indexPath];
                cell.alpha = 0.0;
            }
        }
            break;
        default:
        {
            UITableViewCell *cell = [self.conversationTableView cellForRowAtIndexPath:_sourceIndexPath];
            __weak typeof(self) weakSelf = self;
            [UIView animateWithDuration:0.25 animations:^{
                __strong typeof(self) strongSelf = weakSelf;
                strongSelf->_snapShot.center = cell.center;
                strongSelf->_snapShot.alpha = 0.0;
            } completion:^(BOOL finished) {
                __strong typeof(self) strongSelf = weakSelf;
                [strongSelf->_snapShot removeFromSuperview];
                strongSelf->_snapShot = nil;
                strongSelf->_sourceIndexPath = nil;
                cell.alpha = 1.0;
            }];
        }
            break;
    }
}

#pragma mark -- UIGestureRecognizerDelegate --


#pragma mark --UITableViewDelegate, UITableViewDataSource--
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.conversations.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ConversationTableViewCell *cell = [ConversationTableViewCell lxdequeueReusableCellWith:tableView
                                                                              forIndexPath:indexPath];
    [cell reload:_conversations[indexPath.row]];
    return cell;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

//左滑删除
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

//设置可编辑的样式
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewCellEditingStyleNone;
}

//设置可移动
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

//处理移动的情况
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath{
    //更新数据
    [self.conversations moveItemFrom:sourceIndexPath.row to:destinationIndexPath.row];
    //更新UI
    [tableView moveRowAtIndexPath:sourceIndexPath toIndexPath:destinationIndexPath];
}

#pragma mark - 返回按钮／处理按钮的点击事件
- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath{

    Conversation *item = _conversations[indexPath.row];
    
    NSMutableArray *actionArray = [[NSMutableArray alloc]init];
    __weak typeof(self)weakSelf = self;
    //添加一个删除按钮
    UITableViewRowAction *deleteRowAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"删除" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        NSLog(@"====%@=====",action);
        NSLog(@"点击了删除");
        //1.更新数据
        [weakSelf.conversations removeObjectAtIndex:indexPath.row];
        //2.更新UI
        [tableView reloadData];
    }];
    [deleteRowAction setBackgroundColor:[UIColor redColor]];
    [actionArray addObject:deleteRowAction];

    //添加一个置顶按钮
    UITableViewRowAction *topRowAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"置顶" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        NSLog(@"你点击了置顶按钮");
        item.isTop = YES;
        weakSelf.topConversationNum += 1;
        [weakSelf.conversations moveItemFrom:indexPath.row to:0];
        [tableView reloadData];
    }];
    [topRowAction setBackgroundColor:[UIColor yellowColor]];

    //添加一个取消置顶按钮
    UITableViewRowAction *cancelTopRowAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"取消置顶" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        NSLog(@"你点击了取消置顶按钮");
        item.isTop = NO;
        weakSelf.topConversationNum -= 1;
        [weakSelf.conversations moveItemFrom:indexPath.row to:weakSelf.topConversationNum];
        [tableView reloadData];
    }];
    [cancelTopRowAction setBackgroundColor:[UIColor purpleColor]];

    //添加一个免打扰按钮
    UITableViewRowAction *noDisturbingRowAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"免打扰" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        NSLog(@"你点击了免打扰按钮");
        item.isNoDisturbing = YES;
        [tableView reloadData];
    }];
    [noDisturbingRowAction setBackgroundColor:[UIColor greenColor]];

    //添加一个取消免打扰按钮
    UITableViewRowAction *disturbingRowAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"取消免打扰" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        NSLog(@"你点击了取消免打扰按钮");
        item.isNoDisturbing = NO;
        [tableView reloadData];
    }];
    [disturbingRowAction setBackgroundColor:[UIColor blueColor]];

    if (item.isTop) {
        [actionArray addObject:cancelTopRowAction];
    }else{
        [actionArray addObject:topRowAction];
    }

    if (item.isNoDisturbing) {
        [actionArray addObject:disturbingRowAction];
    }else{
        [actionArray addObject:noDisturbingRowAction];
    }

//    moreRowAction.backgroundEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    //将设置好的按钮存放到数组中(按钮对象在数组中的索引从0到最多,在tableViewCell中的显示则是从右到左依次排列)
    NSArray *array = [NSArray arrayWithArray:actionArray];
    return array;
}

#if TARGET_OS_IOS && __IPHONE_OS_VERSION_MAX_ALLOWED >= 110000
//兼容iOS11 防止全屏左滑删除
- (nullable UISwipeActionsConfiguration *)tableView:(UITableView *)tableView trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath API_AVAILABLE(ios(11.0)) API_UNAVAILABLE(tvos){

    Conversation *item = _conversations[indexPath.row];
    
    NSMutableArray *actionArray = [[NSMutableArray alloc]init];
    __weak typeof(self)weakSelf = self;
    //添加一个删除按钮
    UIContextualAction *deleteRowAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal title:@"删除" handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
        NSLog(@"====%@=====",action);
        NSLog(@"点击了删除");
        //1.更新数据
        [weakSelf.conversations removeObjectAtIndex:indexPath.row];
        //2.更新UI
        [tableView reloadData];
    }];
    [deleteRowAction setBackgroundColor:[UIColor redColor]];
    [actionArray addObject:deleteRowAction];

    //添加一个置顶按钮
    UIContextualAction *topRowAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal  title:@"置顶" handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
        NSLog(@"你点击了置顶按钮");
         item.isTop = !item.isTop;
         weakSelf.topConversationNum += 1;
         [weakSelf.conversations moveItemFrom:indexPath.row to:0];
         [tableView reloadData];
    }];
    [topRowAction setBackgroundColor:[UIColor cyanColor]];

    //添加一个取消置顶按钮
    UIContextualAction *cancelTopRowAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal title:@"取消置顶" handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
        NSLog(@"你点击了取消置顶按钮");
        item.isTop = !item.isTop;
        weakSelf.topConversationNum -= 1;
        [weakSelf.conversations moveItemFrom:indexPath.row to:weakSelf.topConversationNum];
        [tableView reloadData];
    }];
    [cancelTopRowAction setBackgroundColor:[UIColor purpleColor]];

    //添加一个免打扰按钮
    UIContextualAction *noDisturbingRowAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal title:@"免打扰" handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
        NSLog(@"你点击了免打扰按钮");
        item.isNoDisturbing = YES;
        [tableView reloadData];
    }];
    [noDisturbingRowAction setBackgroundColor:[UIColor greenColor]];

    //添加一个取消免打扰按钮
    UIContextualAction *disturbingRowAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal title:@"取消免打扰" handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
        NSLog(@"你点击了取消免打扰按钮");
        item.isNoDisturbing = NO;
        [tableView reloadData];
    }];
    [disturbingRowAction setBackgroundColor:[UIColor blueColor]];

    if (item.isNoDisturbing) {
        [actionArray addObject:disturbingRowAction];
    }else{
        [actionArray addObject:noDisturbingRowAction];
    }

    if (item.isTop) {
        [actionArray addObject:cancelTopRowAction];
    }else{
        [actionArray addObject:topRowAction];
    }

    //    moreRowAction.backgroundEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    //将设置好的按钮存放到数组中(按钮对象在数组中的索引从0到最多,在tableViewCell中的显示则是从右到左依次排列)
    NSArray *array = [NSArray arrayWithArray:actionArray];
   
    UISwipeActionsConfiguration *config = [UISwipeActionsConfiguration configurationWithActions:array];
    config.performsFirstActionWithFullSwipe = NO;
    return config;
}
#endif

@end
