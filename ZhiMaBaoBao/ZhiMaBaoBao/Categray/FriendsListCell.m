//
//  FriendsListCell.m
//  ZhiMaBaoBao
//
//  Created by liugang on 16/9/28.
//  Copyright © 2016年 liugang. All rights reserved.
//

#import "FriendsListCell.h"

@implementation FriendsListCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setFriendModel:(ZhiMaFriendModel *)friendModel{
    _friendModel = friendModel;
    
    [self.avtar sd_setImageWithURL:[NSURL URLWithString:@"friendModel.user_Head_photo"] placeholderImage:[UIImage imageNamed:@"defaultContact"]];
    self.name.text = friendModel.displayName;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
