//
//  ServiceMsgCell.m
//  ZhiMaBaoBao
//
//  Created by ios开发 on 16/11/1.
//  Copyright © 2016年 liugang. All rights reserved.
//

#import "ServiceMsgCell.h"

@implementation ServiceMsgCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        [self customInit];
        
        self.userInteractionEnabled = YES;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = WHITECOLOR;
    }
    return self;
}

- (void)customInit
{
    CGFloat width = DEVICEWITH-36;
    
    UIImageView*lineIV = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, width, 0.5)];
    lineIV.backgroundColor = htmlColor(@"d9d9d9");
    [self.contentView addSubview:lineIV];

    self.titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(12, 1, width-64, 49)];
    self.titleLabel.textColor = BLACKCOLOR;
    self.titleLabel.font = [UIFont systemFontOfSize:15];
    [self.contentView addSubview:self.titleLabel];

    self.msgIV = [[UIImageView alloc]initWithFrame:CGRectMake(width-52, 5, 40, 40)];
    self.msgIV.backgroundColor = GRAYCOLOR;
    self.msgIV.contentMode =  UIViewContentModeScaleAspectFill;
    self.msgIV.clipsToBounds  = YES;
    [self.contentView addSubview:self.msgIV];

}
#pragma mark - data

- (void)setMessage:(ZMServiceMessage *)message
{
//    [self.msgIV sd_setImageWithURL:[NSURL URLWithString:message.]];
    self.titleLabel.text = message.service.text;
}

@end
