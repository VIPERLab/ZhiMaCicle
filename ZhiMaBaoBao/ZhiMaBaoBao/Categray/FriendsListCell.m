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
    
    self.unreadLabel.backgroundColor = THEMECOLOR;
    self.unreadLabel.textColor = WHITECOLOR;
    self.unreadLabel.layer.cornerRadius = 8.f;
    self.unreadLabel.clipsToBounds = YES;
}

- (void)setFriendModel:(ZhiMaFriendModel *)friendModel{
    _friendModel = friendModel;
    
    [self.avtar sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",DFAPIURL,friendModel.user_Head_photo]] placeholderImage:[UIImage imageNamed:@"defaultContact"]];
    self.name.text = friendModel.displayName;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
