//
//  LXViewController.h
//  ChatXmppDemo
//
//  Created by 苗培根 on 2023/6/6.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LXViewController : UIViewController

@property (nonatomic, assign) BOOL prefersNavgationBarHidden;
@property (nonatomic, assign) BOOL interactivePopDisable;
@property (nonatomic, assign) BOOL stateBarHidden;

@property (nonatomic, assign, readonly) BOOL isLogin;

@end

NS_ASSUME_NONNULL_END
