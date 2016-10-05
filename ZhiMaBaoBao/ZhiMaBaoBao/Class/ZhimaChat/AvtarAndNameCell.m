//
//  AvtarAndNameCell.m
//  ZhiMaBaoBao
//
//  Created by liugang on 16/10/5.
//  Copyright © 2016年 liugang. All rights reserved.
//

#import "AvtarAndNameCell.h"

@implementation AvtarAndNameCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setConversion:(ConverseModel *)conversion{
    _conversion = conversion;
    
    [self.avtar sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",DFAPIURL,conversion.converseHead_photo]] placeholderImage:[UIImage imageNamed:@"defaultContact"]];
    self.name.text = conversion.converseName;
}

- (void)setFriendModel:(ZhiMaFriendModel *)friendModel{
    _friendModel = friendModel;
    [self.avtar sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",DFAPIURL,friendModel.head_photo]] placeholderImage:[UIImage imageNamed:@"defaultContact"]];
    self.name.text = friendModel.displayName;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
