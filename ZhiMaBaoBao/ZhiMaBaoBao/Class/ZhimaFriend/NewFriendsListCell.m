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
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)setFriendModel:(ZhiMaFriendModel *)friendModel{
    _friendModel = friendModel;
    
    [self.avtar sd_setImageWithURL:[NSURL URLWithString:friendModel.user_Head_photo] placeholderImage:[UIImage imageNamed:@"defaultContact"]];
    self.name.text = friendModel.user_Name;
    self.subText.text = @"对方请求添加你为朋友";
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)acceptAction:(UIButton *)sender {
}
@end
