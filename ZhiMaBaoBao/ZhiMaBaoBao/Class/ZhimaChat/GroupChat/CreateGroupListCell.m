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

//- (void)setSelectedMembers:(NSArray *)selectedMembers{
//    _selectedMembers = selectedMembers;
//    
//    //如果是已选成员 ， flagBtn  默认显示灰色勾选
//    for (NSString *userId in selectedMembers) {
//        if ([_friendModel.user_Id isEqualToString:userId]) {
//            self.selectFlagBtn.enabled = NO;
//        }
//    }
//}

- (IBAction)flagBtnClick:(UIButton *)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(selectGroupMember:indexPath:)]) {
        [self.delegate selectGroupMember:self.tableView indexPath:self.indexPath];
    }
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}

@end
