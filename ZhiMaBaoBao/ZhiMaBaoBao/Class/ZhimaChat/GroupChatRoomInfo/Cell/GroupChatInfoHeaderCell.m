//
//  GroupChatInfoHeaderCell.m
//  ZhiMaBaoBao
//
//  Created by mac on 16/10/5.
//  Copyright © 2016年 liugang. All rights reserved.
//

#import "GroupChatInfoHeaderCell.h"
#import "UIButton+WebCache.h"
#import "GroupChatModel.h"

@implementation GroupChatInfoHeaderCell {
    UIView *_bottomLineView;
    BOOL hasSubViews;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)setModelArray:(NSArray<GroupUserModel *> *)modelArray {
    _modelArray = modelArray;
    [self setupView];
}

- (void)setupView {
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if (self.subviews.count > 1) {
        return;
    }
    
    CGFloat iconW = (ScreenWidth - 20 * 5) / 4;
    CGFloat iconH = iconW;
    
    for (NSInteger index = 0; index < self.modelArray.count + 1; index++) {
        
        int line = index % 4;  // 列
        int row = (int)index / 4;   // 行
        
        UIButton *iconView = [[UIButton alloc] init];
        
        [self addSubview:iconView];
        iconView.layer.cornerRadius = 10;
        iconView.clipsToBounds = YES;
        iconView.tag = index;
        
//        CGFloat iconW = 65;
        
        CGFloat iconX = (iconW + 20) * line + 20;
        CGFloat iconY = (iconH + 45) * row + 15;
        iconView.frame = CGRectMake(iconX, iconY, iconW, iconH);
        [iconView addTarget:self action:@selector(buttonDidClick:) forControlEvents:UIControlEventTouchUpInside];
        
        UILabel *titleLabel = [UILabel new];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.font = [UIFont systemFontOfSize:13];
        titleLabel.textColor = [UIColor lightGrayColor];
        titleLabel.frame = CGRectMake(iconX, CGRectGetMaxY(iconView.frame), iconW, 30);
        [self addSubview:titleLabel];
        
        
        
        if (index == self.modelArray.count) {
            // 最后一个
            [iconView setBackgroundImage:[UIImage imageNamed:@"NewDiscover_AddPhoto"] forState:UIControlStateNormal];
            iconView.tag = 1000;
        } else {
            iconView.tag = index;
            GroupUserModel *model = self.modelArray[index];
            titleLabel.text = model.friend_nick;
            [iconView sd_setBackgroundImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",DFAPIURL,model.head_photo]] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"Image_placeHolder"]];
        }
    }
    
    _bottomLineView = [UIView new];
    _bottomLineView.backgroundColor = [UIColor colorFormHexRGB:@"dedede"];
    [self addSubview:_bottomLineView];
}

- (void)buttonDidClick:(UIButton *)sender {
    if (sender.tag == 1000) {
        // 点击了新增好友
        if ([self.delegate respondsToSelector:@selector(GroupChatInfoHeaderCellDelegateDidClickAddMember)]) {
            [self.delegate GroupChatInfoHeaderCellDelegateDidClickAddMember];
        }
        
    } else {
        GroupUserModel *model = self.modelArray[sender.tag];
        // 点击了好友头像
        if ([self.delegate respondsToSelector:@selector(GroupChatInfoHeaderCellDidClickMemberIcon:)]) {
            [self.delegate GroupChatInfoHeaderCellDidClickMemberIcon:model.userId];
        }
    }
}


- (void)layoutSubviews {
    _bottomLineView.frame = CGRectMake(10, CGRectGetMaxY(self.frame) - 0.5, CGRectGetWidth(self.frame) - 10 , 0.5);
}

@end
