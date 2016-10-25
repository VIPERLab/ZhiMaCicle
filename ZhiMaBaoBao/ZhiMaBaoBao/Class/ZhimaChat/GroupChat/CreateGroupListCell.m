//
//  CreateGroupListCell.m
//  ZhiMaBaoBao
//
//  Created by liugang on 16/10/5.
//  Copyright © 2016年 liugang. All rights reserved.
//

#import "CreateGroupListCell.h"


@implementation CreateGroupListCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setFriendModel:(ZhiMaFriendModel *)friendModel{
    _friendModel = friendModel;
    
    [self.avtar sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",DFAPIURL,friendModel.user_Head_photo]] placeholderImage:[UIImage imageNamed:@"defaultContact"]];
    self.name.text = friendModel.displayName;
    self.selectFlagBtn.selected = friendModel.selectedGroup;
    self.selectFlagBtn.enabled = !friendModel.originalUser;
}


- (void)setModel:(GroupUserModel *)model{
    _model = model;
    
    [self.avtar sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",DFAPIURL,model.head_photo]] placeholderImage:[UIImage imageNamed:@"defaultContact"]];
    self.name.text = model.friend_nick;
    self.selectFlagBtn.selected = model.selectedGroup;
}

- (IBAction)flagBtnClick:(UIButton *)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(selectGroupMember:indexPath:)]) {
        [self.delegate selectGroupMember:self.tableView indexPath:self.indexPath];
    }
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}

@end
