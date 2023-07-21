//
//  ConversationTableViewCell.m
//  ChatXmppDemo
//
//  Created by 苗培根 on 2023/6/7.
//

#import "ConversationTableViewCell.h"
#import "Conversation.h"

@interface ConversationTableViewCell () <UITextFieldDelegate>

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UITextField *inputTF;
@property (nonatomic, strong) UIButton *moveButton;

@property (nonatomic, strong) UILabel *topLabel;
@property (nonatomic, strong) UILabel *disLabel;

@end

@implementation ConversationTableViewCell

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
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [self.contentView addSubview:self.titleLabel];
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(10);
            make.centerY.equalTo(self.contentView.mas_centerY);
        }];
        [self.titleLabel setContentHuggingPriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
        [self.titleLabel setContentCompressionResistancePriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
        
        [self.contentView addSubview:self.inputTF];
        [self.inputTF mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(-60);
            make.centerY.equalTo(self.titleLabel);
            make.left.equalTo(self.titleLabel.mas_right).offset(10);
            make.top.mas_equalTo(10);
            make.bottom.mas_equalTo(-10);
        }];
        
        [self.contentView addSubview:self.moveButton];
        [self.moveButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.titleLabel);
            make.size.mas_equalTo(CGSizeMake(40, 20));
            make.right.mas_equalTo(-10);
        }];
        
        [self.contentView addSubview:self.disLabel];
        [self.disLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(18, 18));
            make.centerY.equalTo(self.titleLabel);
            make.right.mas_equalTo(-60);
        }];
        
        [self.contentView addSubview:self.topLabel];
        [self.topLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(18, 18));
            make.centerY.equalTo(self.titleLabel);
            make.right.mas_equalTo(-60);
        }];
    }
    return self;
}

- (void)reload:(Conversation *)item {
    self.titleLabel.text = [NSString stringWithFormat:@"%@ %@ : ",[NSString stringWithFormat:@"%d", item.index], item.title];
    self.inputTF.text = item.content;
    
    CGFloat rightSpace = 60;
    
    [self setDisLabelHidden:!item.isNoDisturbing space:&rightSpace];
    [self setTopLabelHidden:!item.isTop space:&rightSpace];
    [self relayoutInputTF:rightSpace];
    
    [self.contentView setNeedsLayout];
    [self.contentView layoutIfNeeded];
}

- (void)setDisLabelHidden:(BOOL)isHidden space:(CGFloat *)space {
    [self.disLabel setHidden:isHidden];
    *space += isHidden ? 0 : 28;
}

- (void)setTopLabelHidden:(BOOL)isHidden space:(CGFloat *)space {
    [self.topLabel setHidden:isHidden];
    [self.topLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-*space);
    }];
    *space += isHidden ? 0 : 28;
}

- (void)relayoutInputTF:(CGFloat)space {
    [self.inputTF mas_updateConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-space);
    }];
}

- (UILabel *)topLabel {
    if (!_topLabel) {
        _topLabel = [[UILabel alloc] init];
        _topLabel.textAlignment = NSTextAlignmentCenter;
        _topLabel.font = kFont_15;
        _topLabel.textColor = [UIColor whiteColor];
        _topLabel.backgroundColor = [UIColor redColor];
        _topLabel.layer.cornerRadius = 9;
        _topLabel.layer.masksToBounds = YES;
        _topLabel.text = @"顶";
        [_topLabel setHidden:YES];
    }
    return _topLabel;
}

- (UILabel *)disLabel {
    if (!_disLabel) {
        _disLabel = [[UILabel alloc] init];
        _disLabel.textAlignment = NSTextAlignmentCenter;
        _disLabel.font = kFont_15;
        _disLabel.textColor = [UIColor whiteColor];
        _disLabel.backgroundColor = [UIColor blueColor];
        _disLabel.layer.cornerRadius = 9;
        _disLabel.layer.masksToBounds = YES;
        _disLabel.text = @"免";
        [_disLabel setHidden:YES];
    }
    return _disLabel;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        _titleLabel.font = kFont_15;
        _titleLabel.numberOfLines = 0;
        _titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    }
    return _titleLabel;
}

- (UITextField *)inputTF {
    if (!_inputTF) {
        _inputTF = [[UITextField alloc] init];
        _inputTF.textAlignment = NSTextAlignmentLeft;
        _inputTF.placeholder = @"请输入新增内容~";
        _inputTF.font = kFont_15;
        _inputTF.delegate = self;
        _inputTF.returnKeyType = UIReturnKeyDone;
        _inputTF.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.25];
        _inputTF.layer.cornerRadius = 5;
        _inputTF.layer.masksToBounds = YES;
    }
    return _inputTF;
}

- (UIButton *)moveButton {
    if (!_moveButton) {
        _moveButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_moveButton setTitle:@"移动" forState:UIControlStateNormal];
        [_moveButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [_moveButton.titleLabel setFont:kFont_15];
        [_moveButton setUserInteractionEnabled:NO];
        _moveButton.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.25];
        _moveButton.layer.cornerRadius = 4;
        _moveButton.layer.masksToBounds = YES;
    }
    return _moveButton;
}

@end
