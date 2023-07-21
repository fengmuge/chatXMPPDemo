//
//  LoginViewController.m
//  ChatXmppDemo
//
//  Created by 苗培根 on 2023/6/14.
//

#import "LoginViewController.h"
#import "RegisterViewController.h"

#import "User.h"

@interface LoginViewController () <UITextFieldDelegate>

@property (nonatomic, strong) UITextField *userNameTF;
@property (nonatomic, strong) UITextField *passwordTF;
@property (nonatomic, strong) UIButton *loginButton;
@property (nonatomic, strong) UIButton *registerButton;

@property (nonatomic, assign) bool isPushToRegister;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"登录";
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self addNotification];
    
    [self.view addSubview:self.userNameTF];
    [self.view addSubview:self.passwordTF];
    [self.view addSubview:self.loginButton];
    [self.view addSubview:self.registerButton];
    
#warning mark --测试数据--
    self.userNameTF.text = @"12312";
    self.passwordTF.text = @"12";
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];
    self.isPushToRegister = NO;
}

- (void)actionOfLogin {
    [[ChatManager sharedInstance] loginWithJID:[XMPPJID lxJidWithUsername:self.userNameTF.text]
                                      password:self.passwordTF.text];
    [self.userNameTF resignFirstResponder];
    [self.passwordTF resignFirstResponder];
    [self showHud:0.15];
}

- (void)actionOfRegister {
    self.isPushToRegister = YES;
    RegisterViewController *registerVC = [[RegisterViewController alloc] init];
//    LXNavgationViewController *nav = [[LXNavgationViewController alloc] initWithRootViewController:registerVC];
    [self.navigationController pushViewController:registerVC animated:YES];
}

#pragma mark --Notification--
- (void)addNotification {
    // 认证成功
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didAuthenticate)
                                                 name:kXMPP_DID_AUTHENTICATE
                                               object:nil];
    // 认证失败
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didNotAuthenticate)
                                                 name:kXMPP_DIDNOT_AUTHENTICATE
                                               object:nil];
}

- (void)didAuthenticate {
    if ([ChatManager sharedInstance].connectType != LXConnectTypeLogin ||
        self.isPushToRegister) {
        return;
    }
    [self hideHud:NO];
    [[UserManager sharedInstance] configWithUsername:self.userNameTF.text
                                            password:self.passwordTF.text];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didNotAuthenticate {
    [self hideHud:NO];
    [self alertAutoDisappearWithTitle:@"登录失败" message:@"请检查账号密码"];
}

#pragma mark --UI--
- (UITextField *)userNameTF {
    if (!_userNameTF) {
        _userNameTF = [[UITextField alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2 - 150, 200, 300, 40)];
        _userNameTF.layer.cornerRadius = 5;
        _userNameTF.layer.masksToBounds = YES;
        _userNameTF.layer.borderWidth = 1;
        _userNameTF.layer.borderColor = [[UIColor blackColor] colorWithAlphaComponent:0.25].CGColor;
        UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"用户"]];
        imgView.contentMode = UIViewContentModeScaleAspectFill;
        imgView.frame = CGRectMake(0, 0, 40, 40);
        [_userNameTF setLeftView:imgView];
        [_userNameTF setLeftViewMode:UITextFieldViewModeAlways];
        _userNameTF.placeholder = @"请输入账号";
        _userNameTF.delegate = self;
    }
    return _userNameTF;
}

- (UITextField *)passwordTF {
    if (!_passwordTF) {
        _passwordTF = [[UITextField alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2 - 150, 260, 300, 40)];
        _passwordTF.layer.cornerRadius = 5;
        _passwordTF.layer.masksToBounds = YES;
        _passwordTF.layer.borderWidth = 1;
        _passwordTF.layer.borderColor = [[UIColor blackColor] colorWithAlphaComponent:0.25].CGColor;
        UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"密码"]];
        imgView.contentMode = UIViewContentModeScaleAspectFill;
        imgView.frame = CGRectMake(0, 0, 40, 40);
        [_passwordTF setLeftView:imgView];
        [_passwordTF setLeftViewMode:UITextFieldViewModeAlways];
        _passwordTF.placeholder = @"请输入密码";
        _passwordTF.delegate = self;
        
    }
    return _passwordTF;
}

- (UIButton *)loginButton {
    if (!_loginButton) {
        _loginButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_loginButton setAdjustsImageWhenHighlighted:NO];
        _loginButton.frame = CGRectMake(SCREEN_WIDTH/2 + 30, 340, 120, 40);
        [_loginButton setTitle:@"登录" forState:UIControlStateNormal];
        [_loginButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_loginButton setBackgroundColor:[UIColor redColor]];
        _loginButton.layer.cornerRadius = 5;
        _loginButton.layer.masksToBounds = YES;
        [_loginButton addTarget:self action:@selector(actionOfLogin) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return _loginButton;
}

- (UIButton *)registerButton {
    if (!_registerButton) {
        _registerButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_registerButton setAdjustsImageWhenHighlighted:NO];
        _registerButton.frame = CGRectMake(SCREEN_WIDTH/2 -150, 340, 120, 40);
        [_registerButton setTitle:@"注册" forState:UIControlStateNormal];
        [_registerButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_registerButton setBackgroundColor:[UIColor redColor]];
        _registerButton.layer.cornerRadius = 5;
        _registerButton.layer.masksToBounds = YES;
        [_registerButton addTarget:self action:@selector(actionOfRegister) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return _registerButton;
}

@end
