//
//  FriendMenuTableViewCell.m
//  ChatXmppDemo
//
//  Created by 苗培根 on 2023/6/13.
//

#import "FriendMenuTableViewCell.h"

@interface FriendMenuTableViewCell ()

@property (nonatomic, strong) UIImageView *iconImgView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *messageCountLabel;

@end

@implementation FriendMenuTableViewCell

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
        
        [self.contentView addSubview:self.iconImgView];
        [self.iconImgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(40, 40));
            make.left.equalTo(@15);
            make.top.equalTo(@10);
        }];
        
        [self.contentView addSubview:self.titleLabel];
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.iconImgView.mas_right).offset(10);
            make.centerY.equalTo(self.iconImgView.mas_centerY);
        }];
        
        [self.contentView addSubview:self.messageCountLabel];
        [self.messageCountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(@-15).priority(MASLayoutPriorityDefaultHigh);
            make.left.equalTo(self.titleLabel.mas_right).offset(15);
            make.centerY.equalTo(self.iconImgView.mas_centerY);
            make.width.greaterThanOrEqualTo(@20);
        }];
        
        [self.messageCountLabel setContentHuggingPriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
        [self.messageCountLabel setContentCompressionResistancePriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
    }
    return self;
}

- (void)resetMessageCount:(int)count {
    [self.messageCountLabel setHidden:count == 0];
    self.messageCountLabel.text = [NSString stringWithFormat:@"%d", count];
}

- (void)reloadWithImage:(NSString *)imgname title:(NSString *)title messageCount:(NSUInteger)count {
    self.iconImgView.image = [UIImage imageNamed:imgname];
    self.titleLabel.text = title;
    self.messageCountLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)count];
}

- (UIImageView *)iconImgView {
    if (!_iconImgView) {
        _iconImgView = [[UIImageView alloc] init];
        _iconImgView.contentMode = UIViewContentModeScaleAspectFill;
        _iconImgView.clipsToBounds = YES;
    }
    return _iconImgView;
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

- (UILabel *)messageCountLabel {
    if (!_messageCountLabel) {
        _messageCountLabel = [[UILabel alloc] init];
        _messageCountLabel.font = kFont_10;
        _messageCountLabel.textColor = [UIColor whiteColor];
        _messageCountLabel.textAlignment = NSTextAlignmentLeft;
        _messageCountLabel.backgroundColor = [UIColor redColor];
        _messageCountLabel.layer.masksToBounds = YES;
        _messageCountLabel.layer.cornerRadius = 10;
        [_messageCountLabel setHidden:YES];
    }
    return _messageCountLabel;
}


@end
