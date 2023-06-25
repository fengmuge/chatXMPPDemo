//
//  ContactTableViewCell.m
//  ChatXmppDemo
//
//  Created by 苗培根 on 2023/6/12.
//

#import "ContactTableViewCell.h"
#import "User.h"

@interface ContactTableViewCell()

@property (nonatomic, strong) UIImageView *avatarImgView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UIImageView *availableImgView;

@end

@implementation ContactTableViewCell

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
            make.left.equalTo(@15);
            make.top.equalTo(@10);
            make.size.mas_equalTo(CGSizeMake(40, 40));
        }];
        
        [self.contentView addSubview:self.nameLabel];
        [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.avatarImgView);
            make.left.equalTo(self.avatarImgView.mas_right).offset(10);
        }];
        
        [self.contentView addSubview:self.availableImgView];
        [self.availableImgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.avatarImgView);
            make.size.mas_equalTo(CGSizeMake(10, 10));
            make.right.equalTo(@-15).priority(MASLayoutPriorityDefaultHigh);
            make.left.equalTo(self.nameLabel.mas_right).offset(10);
        }];
    }
    return self;
}

- (void)reload:(User *)user {
    if (user.vCard.photo == nil) {
        self.avatarImgView.image = [UIImage imageNamed:@"头像"];
    } else {
        self.avatarImgView.image = [UIImage imageWithData:user.vCard.photo];
    }
    if (user.vCard.nickname) {
        self.nameLabel.text = user.vCard.nickname;
    } else {
        self.nameLabel.text = user.jid.user;
    }
    
    NSString *availableImgName = user.isAvailable ? @"在线" : @"离线";
    self.availableImgView.image = [UIImage imageNamed:availableImgName];
}

- (UIImageView *)avatarImgView {
    if (!_avatarImgView) {
        _avatarImgView = [[UIImageView alloc] init];
        _avatarImgView.contentMode = UIViewContentModeScaleAspectFill;
        _avatarImgView.clipsToBounds = YES;
    }
    return _avatarImgView;
}

- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.font = kFont_14;
        _nameLabel.textColor = [UIColor blackColor];
        _nameLabel.textAlignment = NSTextAlignmentLeft;
        _nameLabel.numberOfLines = 0;
    }
    return _nameLabel;
}

- (UIImageView *)availableImgView {
    if (!_availableImgView) {
        _availableImgView = [[UIImageView alloc] init];
        _availableImgView.contentMode = UIViewContentModeScaleAspectFill;
        _availableImgView.clipsToBounds = YES;
        _avatarImgView.layer.cornerRadius = 20;
        _avatarImgView.layer.masksToBounds = YES;
    }
    return _availableImgView;
}

@end
