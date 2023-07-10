//
//  SettingViewController.m
//  ChatXmppDemo
//
//  Created by 苗培根 on 2023/6/6.
//

#import "SettingViewController.h"
#import "ImagePickerManager.h"
#import "PermissionsManager.h"
#import "UIImage+custom.h"
#import "User.h"

@interface SettingViewController ()

@property (nonatomic, strong) UIImageView *avatarImgView; // 头像，可点击
//@property (nonatomic, strong) UITextField *nicknameTF;   // 姓名
@property (nonatomic, strong) UIButton *changNicknameButton; // 修改昵称按钮
@property (nonatomic, strong) UIButton *loginOutButton;  // 登出按钮

@end

@implementation SettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initialUI];
}

- (void)initialUI {
    XMPPvCardTemp *myCard = [ChatManager sharedInstance].cardTempModule.myvCardTemp;
    
    if (myCard.photo) {
        UIImage *avatarImg = [UIImage imageWithData:myCard.photo];
        self.avatarImgView.image = avatarImg;
    }
    self.avatarImgView.frame = CGRectMake((SCREEN_WIDTH - 60) / 2, 100, 60, 60);
    [self.avatarImgView setUserInteractionEnabled:YES];
    [self.view addSubview:self.avatarImgView];
    
    UITapGestureRecognizer *avatarTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(fetchPhotoPermission)];
    [self.avatarImgView addGestureRecognizer:avatarTap];
    
    if (![NSString isNone:myCard.nickname]) {
        [self.changNicknameButton setTitle:myCard.nickname forState:UIControlStateNormal];
    } else {
        [self.changNicknameButton setTitle:[UserManager sharedInstance].user.name forState:UIControlStateNormal];
    }
    
    self.changNicknameButton.frame = CGRectMake((SCREEN_WIDTH - 100) / 2, CGRectGetMaxY(self.avatarImgView.frame) + 20, 100, 40);
    [self.view addSubview:self.changNicknameButton];
    
    self.loginOutButton.frame = CGRectMake((SCREEN_WIDTH - 100) / 2, CGRectGetMaxY(self.changNicknameButton.frame) + 20, 100, 40);
    [self.view addSubview:self.loginOutButton];
}

- (void)clear {
    self.avatarImgView.image = [UIImage imageNamed:@"头像"];
    [self.changNicknameButton setTitle:@"请输入昵称" forState:UIControlStateNormal];
}

- (void)fetchPhotoPermission {
    [[PermissionsManager sharedInstance] fetchStatusFor:PermissionPhotos withComplete:^(PermissionStatus status) {
        switch (status) {
            case PermissionNotDetermined:
                [self requestPhotoPermission];
                break;
            case PermissionNotAvailable:
                [self alertAutoDisappearWithTitle:@"未授权访问相册"
                                          message:nil];
                break;
            case PermissionDenied:
                [self alertWithTitle:@"请授权访问相册" message:nil actionHandler:^(bool result) {
                    if (!result) {
                        return;
                    }
                    NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                    if ([[UIApplication sharedApplication] canOpenURL:url]) {
                        [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:^(BOOL success) {
                            NSLog(@"UIApplication open %@ result %@", url, [NSNumber numberWithBool:success]);
                        }];
                    }
                }];
                break;
            default:
                [self fetchPhoto];
                break;
        }
    }];
}

- (void)requestPhotoPermission {
    [[PermissionsManager sharedInstance] requestFor:PermissionPhotos withComplete:^(PermissionStatus status) {
        if (status != PermissionAuthorized) {
            return;
        }
        [self fetchPhoto];
    }];
}

- (void)fetchPhoto {
    __weak typeof(self) weakSelf = self;
    [[ImagePickerManager sharedInstance] getPhotoFrom:self withComplete:^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto, NSArray<NSDictionary *> *infos) {
        __strong typeof(self) strongSelf = weakSelf;
        NSLog(@"%s", __func__);
        
        self.avatarImgView.image = photos[0];
        XMPPvCardTemp *myCard = [ChatManager sharedInstance].cardTempModule.myvCardTemp;
        UIImage *avatarImg = [photos[0] reSize:CGSizeMake(100, 100)];
        myCard.photo = [avatarImg toData];
        [[ChatManager sharedInstance].cardTempModule updateMyvCardTemp:myCard];
    }];
}

- (void)changNicknameButtonClicked:(UIButton *)sender {
    __weak typeof(self) weakSelf = self;
    [self inputAlertWithTitle:@"修改昵称" textFieldHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"输入昵称";
        textField.maxTextLength = 10; // 昵称最多十个字
    } actionHandler:^(bool result, UITextField * _Nullable textField) {
        __strong typeof(self) strongSelf = weakSelf;
        [strongSelf changeNickname:textField.text];
    }];
}

- (void)changeNickname:(NSString *)nickname {
    if ([NSString isNone:nickname]) {
        [self alertAutoDisappearWithTitle:@"昵称不能为空" message:nil];
        return;
    }
    [self.changNicknameButton setTitle:nickname forState:UIControlStateNormal];
    XMPPvCardTemp *myCard = [ChatManager sharedInstance].cardTempModule.myvCardTemp;
    myCard.nickname = nickname;
    [[ChatManager sharedInstance].cardTempModule updateMyvCardTemp:myCard];
}

- (void)loginOutButtonClicked:(UIButton *)sender {
    [self clear];
    [[ChatManager sharedInstance] loginOut];
    [[NSNotificationCenter defaultCenter] postNotificationName:kAPP_LOGIN_OUT
                                                        object:nil];
}

- (UIImageView *)avatarImgView {
    if (!_avatarImgView) {
        _avatarImgView = [[UIImageView alloc] init];
        _avatarImgView.image = [UIImage imageNamed:@"头像"];
        _avatarImgView.contentMode = UIViewContentModeScaleAspectFill;
//        _avatarImgView.clipsToBounds = YES;
        _avatarImgView.layer.cornerRadius = 30;
        _avatarImgView.layer.masksToBounds = YES;
    }
    return _avatarImgView;
}

- (UIButton *)changNicknameButton {
    if (!_changNicknameButton) {
        _changNicknameButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _changNicknameButton.layer.cornerRadius = 4;
        _changNicknameButton.layer.masksToBounds = YES;
        _changNicknameButton.layer.borderColor = [UIColor blueColor].CGColor;
        _changNicknameButton.layer.borderWidth = 1;
        [_changNicknameButton setTitle:@"输入昵称" forState:UIControlStateNormal];
        [_changNicknameButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [_changNicknameButton addTarget:self action:@selector(changNicknameButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _changNicknameButton;
}

- (UIButton *)loginOutButton {
    if (!_loginOutButton) {
        _loginOutButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _loginOutButton.layer.cornerRadius = 4;
        _loginOutButton.layer.masksToBounds = YES;
        _loginOutButton.layer.borderColor = [UIColor blueColor].CGColor;
        _loginOutButton.layer.borderWidth = 1;
        [_loginOutButton setTitle:@"退出登录" forState:UIControlStateNormal];
        [_loginOutButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [_loginOutButton addTarget:self action:@selector(loginOutButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _loginOutButton;
}

@end

/**
   计划是至少: 有头像、昵称修改，状态变更和退出登录
 */
