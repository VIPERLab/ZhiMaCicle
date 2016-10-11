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

- (void)setIsGroupCreater:(BOOL)isGroupCreater {
    _isGroupCreater = isGroupCreater;
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
    
    NSInteger maxCount;
    if (self.isGroupCreater) {
        maxCount = self.modelArray.count + 2;
    } else {
        maxCount = self.modelArray.count + 1;
    }
    for (NSInteger index = 0; index < maxCount; index++) {
        
        int line = index % 4;  // 列
        int row = (int)index / 4;   // 行
        
        UIButton *iconView = [[UIButton alloc] init];
        
        [self addSubview:iconView];
        iconView.tag = index;
        
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
        
        if (!self.isGroupCreater) {
            if (index == self.modelArray.count) {
                // 最后一个
                [iconView setBackgroundImage:[UIImage imageNamed:@"ChatAddMember"] forState:UIControlStateNormal];
                iconView.tag = 999;
            } else {
                iconView.tag = index;
                GroupUserModel *model = self.modelArray[index];
                titleLabel.text = model.friend_nick;
                [iconView sd_setBackgroundImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",DFAPIURL,model.head_photo]] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"Image_placeHolder"]];
            }
            continue;
        }
        
        if (index == maxCount - 2) {
            // 倒数第二个
            [iconView setBackgroundImage:[UIImage imageNamed:@"ChatAddMember"] forState:UIControlStateNormal];
            iconView.tag = 999;
        } else if (index == maxCount - 1) {
            // 倒数第一个
            [iconView setBackgroundImage:[UIImage imageNamed:@"GroupDelMember"] forState:UIControlStateNormal];
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
    if (sender.tag == 999) {
        // 点击了新增好友
        if ([self.delegate respondsToSelector:@selector(GroupChatInfoHeaderCellDelegateDidClickAddMember)]) {
            [self.delegate GroupChatInfoHeaderCellDelegateDidClickAddMember];
        }
        
    } else if (sender.tag == 1000) {
        // 点击了删除好友
        if ([self.delegate respondsToSelector:@selector(GroupChatInfoHeaderCellDelegateDidClickDeletedMembers)]) {
            [self.delegate GroupChatInfoHeaderCellDelegateDidClickDeletedMembers];
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
