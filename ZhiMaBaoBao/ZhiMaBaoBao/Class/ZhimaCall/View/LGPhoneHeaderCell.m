//
//  LGPhoneHeaderCell.m
//  YiIM_iOS
//
//  Created by liugang on 16/9/7.
//  Copyright © 2016年 ikantech. All rights reserved.
//

#import "LGPhoneHeaderCell.h"

@implementation LGPhoneHeaderCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.avtar.layer.cornerRadius = 40;
    self.avtar.clipsToBounds = YES;
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
}

@end
