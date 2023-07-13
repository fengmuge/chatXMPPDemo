//
//  ConversationViewController.m
//  ChatXmppDemo
//
//  Created by 苗培根 on 2023/6/6.
//

#import "ConversationViewController.h"

@interface ConversationViewController ()

@end

@implementation ConversationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSArray *imgNames = @[@"关闭", @"键盘", @"离开", @"头像", @"在线", @"昵称"];
    NSMutableArray *images = [[NSMutableArray alloc] init];
    for (NSString *imgName in imgNames) {
        UIImage *image = [UIImage imageNamed:imgName];
        [images addObject:image];
    }
    UIImage *result = [UIImage addImages:images withSize:100];
    
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(30, 100, 100, 100)];
    imgView.contentMode = UIViewContentModeScaleAspectFill;
    imgView.image = result;
    imgView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:imgView];
}

@end
