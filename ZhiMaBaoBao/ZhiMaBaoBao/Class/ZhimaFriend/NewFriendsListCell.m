//
//  NewFriendsListCell.m
//  ZhiMaBaoBao
//
//  Created by liugang on 16/9/28.
//  Copyright © 2016年 liugang. All rights reserved.
//

#import "NewFriendsListCell.h"

@implementation NewFriendsListCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.acceptBtn.layer.cornerRadius = 5.0f;
//    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)setFriendModel:(ZhiMaFriendModel *)friendModel{
    _friendModel = friendModel;
    
    [self.avtar sd_setImageWithURL:[NSURL URLWithString:friendModel.user_Head_photo] placeholderImage:[UIImage imageNamed:@"defaultContact"]];
    self.name.text = friendModel.user_Name;
    self.subText.text = @"对方请求添加你为朋友";
    
    if (friendModel.status) {   //已添加好友
        [self.acceptBtn setTitle:@"已添加" forState:UIControlStateNormal];
        [self.acceptBtn setTitleColor:GRAYCOLOR forState:UIControlStateNormal];
        self.acceptBtn.backgroundColor = [UIColor clearColor];
        self.acceptBtn.enabled = NO;
    }
    else{
        [self.acceptBtn setTitle:@"接受" forState:UIControlStateNormal];
        [self.acceptBtn setTitleColor:WHITECOLOR forState:UIControlStateNormal];
        self.acceptBtn.backgroundColor = THEMECOLOR;
        self.acceptBtn.enabled = YES;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)acceptAction:(UIButton *)sender {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(acceptNewFriendRequest:)]) {
        [self.delegate acceptNewFriendRequest:self.indexPath];
    }
}
@end
