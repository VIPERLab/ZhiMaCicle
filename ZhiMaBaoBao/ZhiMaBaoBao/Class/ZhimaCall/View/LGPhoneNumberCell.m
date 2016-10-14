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

- (void)setColorWithString:(NSString*)string
{
    NSRange range = [self.phoneNumber.text rangeOfString:string];
    [self setTextColor:self.phoneNumber FontNumber:[UIFont systemFontOfSize:15] AndRange:range AndColor:BLACKCOLOR];
}

//设置不同字体颜色
-(void)setTextColor:(UILabel *)label FontNumber:(id)font AndRange:(NSRange)range AndColor:(UIColor *)vaColor
{
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:label.text];
    //设置字号
    [str addAttribute:NSFontAttributeName value:font range:range];
    //设置文字颜色
    [str addAttribute:NSForegroundColorAttributeName value:vaColor range:range];
    
    label.attributedText = str;
}

@end
