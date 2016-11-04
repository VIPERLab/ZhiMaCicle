//
//  ServicePurseCell.m
//  ZhiMaBaoBao
//
//  Created by ios开发 on 16/10/31.
//  Copyright © 2016年 liugang. All rights reserved.
//

#import "ServicePurseCell.h"

@implementation ServicePurseCell

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
    CGFloat scale = width/(375 - 36);
    
    self.timeLabel = [[UILabel alloc]initWithFrame:CGRectMake(18, 15, width, 20)];
    self.timeLabel.textColor = [UIColor whiteColor];
    self.timeLabel.font = SUBFONT;
    self.timeLabel.backgroundColor= RGB(206, 206, 206);
    self.timeLabel.textAlignment = 1;
    self.timeLabel.layer.cornerRadius = 3;
    self.timeLabel.layer.masksToBounds = YES;
    self.timeLabel.lineBreakMode = NSLineBreakByCharWrapping;
    [self.contentView addSubview:self.timeLabel];
    
    UIImageView*bgIV = [[UIImageView alloc]initWithFrame:CGRectMake(18, self.timeLabel.frameMaxY+15, width, width*690/682)];
    bgIV.image = [UIImage imageNamed:@"ServicePurseBG"];
    [self.contentView addSubview:bgIV];
    
    self.titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(18+12, bgIV.frameOriginY+15*scale, width-24, 19)];
    self.titleLabel.textColor = [UIColor redColor];
    self.titleLabel.font = [UIFont fontWithName:@"迷你简菱心" size:17];
    [self.contentView addSubview:self.titleLabel];
    
    self.purseIV = [[UIImageView alloc]initWithFrame:CGRectMake(18+12, self.titleLabel.frameMaxY+27*scale, width-24, 180*scale)];
    self.purseIV.backgroundColor = RGB(235, 63, 78);
    self.purseIV.layer.borderWidth = 5;
    self.purseIV.layer.borderColor = WHITECOLOR.CGColor;
    self.purseIV.contentMode =  UIViewContentModeScaleAspectFill;
    self.purseIV.clipsToBounds  = YES;
    [self.contentView addSubview:self.purseIV];
    
    self.contentLabel = [[UILabel alloc]initWithFrame:CGRectMake(18+12, self.purseIV.frameMaxY+16*scale, width-24, 15)];
    self.contentLabel.textColor = WHITECOLOR;
    self.contentLabel.font = [UIFont systemFontOfSize:15];
    [self.contentView addSubview:self.contentLabel];

}

#pragma mark - data

- (void)setMessage:(ZMServiceMessage *)message
{
    LGServiceList*listModel;

    if (message.list.count) {
         listModel = message.list[0];
    }
    
    [self.purseIV sd_setImageWithURL:[NSURL URLWithString:listModel.picurl]];
    self.titleLabel.text = listModel.subject;
    self.contentLabel.text = listModel.subsubject;
    
    NSString*timeStr = [NSDate dateStrFromCstampTime:message.timeStamp withDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    self.timeLabel.text = [NSString timeStringChangeToZMTimeString:timeStr];
    [self.timeLabel sizeToFit];
    self.timeLabel.width += 10;
    self.timeLabel.center = CGPointMake(DEVICEWITH/2, 15+10);
}


@end
