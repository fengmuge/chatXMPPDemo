//
//  SubscriptionTableViewCell.m
//  ChatXmppDemo
//
//  Created by 苗培根 on 2023/6/12.
//

#import "SubscriptionTableViewCell.h"
#import "Subscription.h"

@interface SubscriptionTableViewCell()

@property (nonatomic, strong) UIImageView *avatarImgView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *agreeButton;
@property (nonatomic, strong) UIButton *refuseButton;
@property (nonatomic, strong) UILabel *resultLabel; // 处理结果

@property (nonatomic, strong) Subscription *subscription;

@end

@implementation SubscriptionTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.backgroundColor = [UIColor whiteColor];
        self.contentView.backgroundColor = [UIColor whiteColor];
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [self.contentView addSubview:self.avatarImgView];
        [self.avatarImgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(15);
            make.size.mas_equalTo(CGSizeMake(40, 40));
            make.top.mas_equalTo(10);
        }];
        
        [self.contentView addSubview:self.agreeButton];
        [self.agreeButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(-15);
            make.centerY.equalTo(self.avatarImgView.mas_centerY);
            make.size.mas_equalTo(CGSizeMake(30, 20));
        }];
        
        [self.contentView addSubview:self.refuseButton];
        [self.refuseButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.agreeButton.mas_left).offset(-10);
            make.centerY.equalTo(self.avatarImgView.mas_centerY);
            make.size.mas_equalTo(CGSizeMake(30, 20));
        }];
        
        [self.contentView addSubview:self.resultLabel];
        [self.resultLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(-15).priority(MASLayoutPriorityDefaultHigh);
            make.centerY.equalTo(self.avatarImgView.mas_centerY);
            make.width.mas_equalTo(70);
        }];
        // 设置高度抗拉伸
        [self.resultLabel setContentHuggingPriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
        [self.resultLabel setContentCompressionResistancePriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
        
        [self.contentView addSubview:self.titleLabel];
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.avatarImgView.mas_right).offset(10);
            make.centerY.equalTo(self.avatarImgView.mas_centerY);
            make.right.equalTo(self.titleLabel.mas_left).offset(-10);
        }];
    }
    return self;
}

- (void)reload:(Subscription *)item {
    self.subscription = item;
    // 单纯的jid没有头像信息
//    self.avatarImgView.image = [UIImage imageWithData:item.ji]
    self.avatarImgView.image = [UIImage imageNamed:@"头像2"]; // 暂时用这个替代
    self.titleLabel.text = item.jid.user;
    
    [self setSubViewsWithSubscriptionResult:item.result];
}

- (void)setSubViewsWithSubscriptionResult:(LXSubscriptionResult)result {
    [self.agreeButton setHidden:result != LXSubscriptionResultPending];
    [self.refuseButton setHidden:result != LXSubscriptionResultPending];
    [self.resultLabel setHidden:result == LXSubscriptionResultPending];
    
    switch (result) {
        case LXSubscriptionResultPending:
            self.resultLabel.text = @"";
            break;
        case LXSubscriptionResultAgree:
            self.resultLabel.text = @"已同意";
            break;
        case LXSubscriptionResultRefuse:
            self.resultLabel.text = @"已拒绝";
            break;
        default:
            self.resultLabel.text = @"已过期";
            break;
    }
}

- (void)agree {
    if (!self.delegate || ![self.delegate respondsToSelector:@selector(subscriptioCell:agreeWith:)]) {
        NSLog(@"SubscriptionTableViewCell未发现delegate或delegate未实现subscriptioCell:agreeWith:");
        return;
    }
    [self.delegate subscriptioCell:self agreeWith:self.subscription];
}

- (void)refuse {
    if (!self.delegate || ![self.delegate respondsToSelector:@selector(subscriptioCell:refuseWith:)]) {
        NSLog(@"SubscriptionTableViewCell未发现delegate或delegate未实现subscriptioCell:refuseWith:");
        return;
    }
    [self.delegate subscriptioCell:self refuseWith:self.subscription];
}

- (UIImageView *)avatarImgView {
    if (!_avatarImgView) {
        _avatarImgView = [[UIImageView alloc] init];
        _avatarImgView.contentMode = UIViewContentModeScaleAspectFill;
        _avatarImgView.clipsToBounds = YES;
    }
    return _avatarImgView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = kFont_16;
        _titleLabel.textColor = [UIColor blackColor];
        _titleLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _titleLabel;
}

- (UILabel *)resultLabel {
    if (!_resultLabel) {
        _resultLabel = [[UILabel alloc] init];
        _resultLabel.font = kFont_16;
        _resultLabel.textColor = [[UIColor grayColor] colorWithAlphaComponent:0.8];
        _resultLabel.textAlignment = NSTextAlignmentLeft;
        [_resultLabel setHidden:YES];
    }
    return _resultLabel;
}


- (UIButton *)agreeButton {
    if (!_agreeButton) {
        _agreeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _agreeButton.adjustsImageWhenHighlighted = NO;
        [_agreeButton setTitle:@"同意" forState:UIControlStateNormal];
        [_agreeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_agreeButton addTarget:self action:@selector(agree) forControlEvents:UIControlEventTouchUpInside];
        _agreeButton.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.75];
        [_agreeButton setHidden:NO];
    }
    return _agreeButton;
}

- (UIButton *)refuseButton {
    if (!_refuseButton) {
        _refuseButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _refuseButton.adjustsImageWhenHighlighted = NO;
        [_refuseButton setTitle:@"拒绝" forState:UIControlStateNormal];
        [_refuseButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_refuseButton addTarget:self action:@selector(refuse) forControlEvents:UIControlEventTouchUpInside];
        _refuseButton.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.75];
        [_refuseButton setHidden:NO];
    }
    return _refuseButton;
}


@end
