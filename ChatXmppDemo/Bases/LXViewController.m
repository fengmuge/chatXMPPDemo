//
//  LXViewController.m
//  ChatXmppDemo
//
//  Created by 苗培根 on 2023/6/6.
//

#import "LXViewController.h"
#import <FDFullscreenPopGesture/UINavigationController+FDFullscreenPopGesture.h>
#import <MBProgressHUD/MBProgressHUD.h>

@interface LXViewController () {
}

//@property (nonatomic, assign, readwrite) BOOL isCurrentVC;

@end

@implementation LXViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
//    self.isCurrentVC = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
//    self.isCurrentVC = NO;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

#pragma mark -- setter/getter
//- (BOOL)isCurrentVC {
//
//}

#pragma mark -- 方向和状态栏
- (BOOL)prefersNavgationBarHidden {
    return self.fd_prefersNavigationBarHidden;
}

- (void)setPrefersNavgationBarHidden:(BOOL)prefersNavgationBarHidden {
    self.fd_prefersNavigationBarHidden = prefersNavgationBarHidden;
}

- (BOOL)interactivePopDisable {
    return self.fd_interactivePopDisabled;
}

- (void)setInteractivePopDisable:(BOOL)interactivePopDisable {
    self.fd_interactivePopDisabled = interactivePopDisable;
}
 
- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (BOOL)prefersStatusBarHidden {
    return _stateBarHidden;
}


@end
