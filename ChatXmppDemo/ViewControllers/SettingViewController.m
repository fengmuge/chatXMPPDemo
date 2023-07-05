//
//  SettingViewController.m
//  ChatXmppDemo
//
//  Created by 苗培根 on 2023/6/6.
//

#import "SettingViewController.h"

@interface SettingViewController ()

@property (nonatomic, strong) UIImageView *avatarImgView; // 头像，可点击
@property (nonatomic, strong) UITextField *nicknameTF;   // 姓名
@property (nonatomic, strong) UIButton *loginOutButton;  // 登出按钮

@end

@implementation SettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

@end

/**
   计划是至少: 有头像、昵称修改，状态变更和退出登录
 */
