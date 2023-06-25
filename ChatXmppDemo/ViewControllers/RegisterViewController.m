//
//  RegisterViewController.m
//  ChatXmppDemo
//
//  Created by 苗培根 on 2023/6/14.
//

#import "RegisterViewController.h"

@interface RegisterViewController () <UITextFieldDelegate>

@property (nonatomic, strong) UITextField *userNameTF;
@property (nonatomic, strong) UITextField *loginNameTF;
@property (nonatomic, strong) UITextField *passwordTF;
@property (nonatomic, strong) UITextField *verifyPasswordTF;
@property (nonatomic, strong) UIButton *registerButton;

@end

@implementation RegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"注册";
    self.view.backgroundColor = [UIColor whiteColor];
    [self setLeftNavgationBarItem];
    [self addNotification];
    
    [self.view addSubview:self.userNameTF]; // 账号
    [self.view addSubview:self.loginNameTF]; // 昵称
    [self.view addSubview:self.passwordTF]; // 密码
    [self.view addSubview:self.verifyPasswordTF]; // 确认密码
    [self.view addSubview:self.registerButton];
}

- (void)actionOfRegister {
    if ([NSString isNone:self.userNameTF.text] ||
        [NSString isNone:self.loginNameTF.text] ||
        [NSString isNone:self.passwordTF.text] ||
        [NSString isNone:self.verifyPasswordTF.text]) {
        [self alertAutoDisappearWithTitle:@"用户信息填写不完整" message:nil];
        return;
    }
    if (![self.passwordTF.text isEqualToString:self.verifyPasswordTF.text]) {
        [self alertAutoDisappearWithTitle:@"两次输入密码不一致" message:nil];
        return;
    }
    [self showHud:0.15];
    // 进行注册
    [[ChatManager sharedInstance] registerWithJID:[XMPPJID lxJidWithUsername:self.userNameTF.text]
                                         password:self.passwordTF.text];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.userNameTF resignFirstResponder];
    [self.loginNameTF resignFirstResponder];
    [self.passwordTF resignFirstResponder];
    [self.passwordTF resignFirstResponder];
}

#pragma mark --Notification--
- (void)addNotification {
    // 获取注册结果
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedRegisterResult:)
                                                 name:kXMPP_REGIST_RESULT
                                               object:nil];
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

- (void)receivedRegisterResult:(NSNotification *)notification {
    bool result = [(NSNumber *)[notification object] boolValue];
    if (result) {
        [[ChatManager sharedInstance] loginWithJID:[XMPPJID lxJidWithUsername:self.userNameTF.text]
                                          password:self.passwordTF.text];
    } else {
        [self hideHud:NO];
        [self alertAutoDisappearWithTitle:@"注册失败" message:nil];
    }
}

- (void)didAuthenticate {
    [self hideHud:NO];
    [[UserManager sharedInstance] configWithUsername:self.userNameTF.text
                                            password:self.passwordTF.text];
    [[ChatManager sharedInstance] setCardTempModuleWithUsername:self.loginNameTF.text];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didNotAuthenticate {
    [self hideHud:NO];
    __weak typeof(self) weakSelf = self;
    [self alertWithTitle:@"登录失败" message:@"轻跳转登录页面重试" actionHandler:^(bool result) {
        __strong typeof(self) strongSelf = weakSelf;
        [strongSelf.navigationController popViewControllerAnimated:YES];
    }];
}

#pragma mark --UI--
- (UITextField *)userNameTF {
    if (!_userNameTF) {
        _userNameTF = [[UITextField alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2 - 150, 100, 300, 40)];
        _userNameTF.layer.cornerRadius = 5;
        _userNameTF.layer.masksToBounds = YES;
        _userNameTF.layer.borderWidth = 1;
        _userNameTF.layer.borderColor = [[UIColor blackColor] colorWithAlphaComponent:0.25].CGColor;
        UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"用户"]];
        imgView.contentMode = UIViewContentModeScaleAspectFill;
        imgView.clipsToBounds = YES;
        imgView.frame = CGRectMake(0, 0, 30, 30);
        [_userNameTF setLeftView:imgView];
        [_userNameTF setLeftViewMode:UITextFieldViewModeAlways];
        _userNameTF.placeholder = @"请输入账号";
        _userNameTF.delegate = self;
        _userNameTF.returnKeyType = UIReturnKeyDone;
    }
    return _userNameTF;
}

- (UITextField *)loginNameTF {
    if (!_loginNameTF) {
        _loginNameTF = [[UITextField alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2 - 150, 150, 300, 40)];
        _loginNameTF.layer.cornerRadius = 5;
        _loginNameTF.layer.masksToBounds = YES;
        _loginNameTF.layer.borderWidth = 1;
        _loginNameTF.layer.borderColor = [[UIColor blackColor] colorWithAlphaComponent:0.25].CGColor;
        UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"名片"]];
        imgView.contentMode = UIViewContentModeScaleAspectFill;
        imgView.clipsToBounds = YES;
        imgView.frame = CGRectMake(0, 0, 30, 30);
        [_loginNameTF setLeftView:imgView];
        [_loginNameTF setLeftViewMode:UITextFieldViewModeAlways];
        _loginNameTF.placeholder = @"请输入用户名";
        _loginNameTF.delegate = self;
        _loginNameTF.returnKeyType = UIReturnKeyDone;
    }
    return _loginNameTF;
}


- (UITextField *)passwordTF {
    if (!_passwordTF) {
        _passwordTF = [[UITextField alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2 - 150, 200, 300, 40)];
        _passwordTF.layer.cornerRadius = 5;
        _passwordTF.layer.masksToBounds = YES;
        _passwordTF.layer.borderWidth = 1;
        _passwordTF.layer.borderColor = [[UIColor blackColor] colorWithAlphaComponent:0.25].CGColor;
        UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"注册密码"]];
        imgView.contentMode = UIViewContentModeScaleAspectFill;
        imgView.clipsToBounds = YES;
        imgView.frame = CGRectMake(0, 0, 30, 30);
        [_passwordTF setLeftView:imgView];
        [_passwordTF setLeftViewMode:UITextFieldViewModeAlways];
        _passwordTF.placeholder = @"请输入密码";
        _passwordTF.delegate = self;
        _passwordTF.returnKeyType = UIReturnKeyDone;
    }
    return _passwordTF;
}

- (UITextField *)verifyPasswordTF {
    if (!_verifyPasswordTF) {
        _verifyPasswordTF = [[UITextField alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2 - 150, 250, 300, 40)];
        _verifyPasswordTF.layer.cornerRadius = 5;
        _verifyPasswordTF.layer.masksToBounds = YES;
        _verifyPasswordTF.layer.borderWidth = 1;
        _verifyPasswordTF.layer.borderColor = [[UIColor blackColor] colorWithAlphaComponent:0.25].CGColor;
        UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"确认密码"]];
        imgView.contentMode = UIViewContentModeScaleAspectFill;
        imgView.clipsToBounds = YES;
        imgView.frame = CGRectMake(0, 0, 30, 30);
        [_verifyPasswordTF setLeftView:imgView];
        [_verifyPasswordTF setLeftViewMode:UITextFieldViewModeAlways];
        _verifyPasswordTF.placeholder = @"请确认密码";
        _verifyPasswordTF.delegate = self;
        _verifyPasswordTF.returnKeyType = UIReturnKeyDone;
    }
    return _verifyPasswordTF;
}

- (UIButton *)registerButton {
    if (!_registerButton) {
        _registerButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_registerButton setAdjustsImageWhenHighlighted:NO];
        _registerButton.frame = CGRectMake(SCREEN_WIDTH/2 - 100, SCREEN_HEIGHT - 240, 200, 40);
        [_registerButton setTitle:@"注册" forState:UIControlStateNormal];
        [_registerButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_registerButton setBackgroundColor:[UIColor redColor]];
        _registerButton.layer.cornerRadius = 5;
        _registerButton.layer.masksToBounds = YES;
        [_registerButton addTarget:self action:@selector(actionOfRegister) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return _registerButton;
}

#pragma mark --UITextFieldDelegate--
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ([textField isEqual:self.userNameTF]) {
        [self.loginNameTF becomeFirstResponder];
    } else if ([textField isEqual:self.loginNameTF]) {
        [self.passwordTF becomeFirstResponder];
    } else if ([textField isEqual:self.passwordTF]) {
        [self.verifyPasswordTF becomeFirstResponder];
    } else {
        [self.verifyPasswordTF resignFirstResponder];
    }
    return YES;
}

@end
