//
//  LGPhoneNumberCell.m
//  YiIM_iOS
//
//  Created by liugang on 16/9/7.
//  Copyright © 2016年 ikantech. All rights reserved.
//

#import "LGPhoneNumberCell.h"

@implementation LGPhoneNumberCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (IBAction)callBtnAction:(id)sender {
    if ([self.delegate respondsToSelector:@selector(makeCall:)]) {
        [self.delegate makeCall:_row];
    }
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
