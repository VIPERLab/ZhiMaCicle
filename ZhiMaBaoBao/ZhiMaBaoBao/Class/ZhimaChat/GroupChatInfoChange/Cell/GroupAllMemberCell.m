//
//  GroupAllMemberCell.m
//  ZhiMaBaoBao
//
//  Created by mac on 16/10/10.
//  Copyright © 2016年 liugang. All rights reserved.
//

#import "GroupAllMemberCell.h"
#import "UIImageView+WebCache.h"

@implementation GroupAllMemberCell {
    UIImageView *_iconView;
    UILabel *_nameLabel;
    UIView *_bottomLineView;
    UIButton *_deletedButton;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setupView];
    }
    return self;
}

- (void)setupView {
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    _iconView = [UIImageView new];
    [self addSubview:_iconView];
    
    _nameLabel = [UILabel new];
    [self addSubview:_nameLabel];
    
    _bottomLineView = [UIView new];
    _bottomLineView.backgroundColor = [UIColor colorFormHexRGB:@"dedede"];
    [self addSubview:_bottomLineView];
    
    _deletedButton = [UIButton new];
    [_deletedButton addTarget:self action:@selector(deletedButtonDidClick) forControlEvents:UIControlEventTouchUpInside];
    [_deletedButton setImage:[UIImage imageNamed:@"DelGroupMember_button"] forState:UIControlStateNormal];
    [self addSubview:_deletedButton];
}

- (void)setIsDeletedMembers:(BOOL)isDeletedMembers {
    _isDeletedMembers = isDeletedMembers;
    _deletedButton.hidden = !isDeletedMembers;
}


- (void)setModel:(GroupUserModel *)model {
    _model = model;
    
    [_iconView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",DFAPIURL,model.head_photo]] placeholderImage:[UIImage imageNamed:@"Image_placeHolder"]];
    
    _nameLabel.text = model.friend_nick;
    
}


- (void)deletedButtonDidClick {
    if ([self.delegate respondsToSelector:@selector(GroupAllMemberCellDelegateDeletedButtonDidClick:andCell:)]) {
        [self.delegate GroupAllMemberCellDelegateDeletedButtonDidClick:self.model andCell:self];
    }
}

- (void)layoutSubviews {
    
    CGFloat iconX = 20;
    CGFloat iconW = 40;
    CGFloat iconH = iconW;
    CGFloat iconY = (CGRectGetHeight(self.frame) - iconH) * 0.5;
    _iconView.frame = CGRectMake(iconX, iconY, iconW, iconH);
    
    CGFloat nameX = CGRectGetMaxX(_iconView.frame) + 10;
    CGFloat nameY = 0;
    CGFloat nameW = CGRectGetWidth(self.frame) - nameX;
    CGFloat nameH = CGRectGetHeight(self.frame);
    _nameLabel.frame = CGRectMake(nameX, nameY, nameW, nameH);
    
    CGFloat deletedW = 25;
    CGFloat deletedH = deletedW;
    CGFloat deletedX = ScreenWidth - deletedW - 30;
    CGFloat deletedY = (CGRectGetHeight(self.frame) - deletedH) * 0.5;
    _deletedButton.frame = CGRectMake(deletedX, deletedY, deletedW, deletedH);
    
    _bottomLineView.frame = CGRectMake(10, CGRectGetHeight(self.frame) - 0.5, ScreenWidth - 10, 0.5);
    
}


@end
