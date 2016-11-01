//
//  ServiceSingleMsgCell.m
//  ZhiMaBaoBao
//
//  Created by ios开发 on 16/10/31.
//  Copyright © 2016年 liugang. All rights reserved.
//

#import "ServiceSingleMsgCell.h"

@implementation ServiceSingleMsgCell


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
    CGFloat scale = 1;//width/(375 - 36);
    
    self.timeLabel = [[UILabel alloc]initWithFrame:CGRectMake(18, 15, width, 20)];
    self.timeLabel.textColor = [UIColor whiteColor];
    self.timeLabel.font = SUBFONT;
    self.timeLabel.backgroundColor= RGB(206, 206, 206);
    self.timeLabel.textAlignment = 1;
    self.timeLabel.layer.cornerRadius = 3;
    self.timeLabel.layer.masksToBounds = YES;
    self.timeLabel.lineBreakMode = NSLineBreakByCharWrapping;
    [self.contentView addSubview:self.timeLabel];
    
    UIImageView*bgIV = [[UIImageView alloc]initWithFrame:CGRectMake(18, self.timeLabel.frameMaxY+15, width, width*700/676)];
    bgIV.backgroundColor = WHITECOLOR;
    bgIV.layer.cornerRadius = 5;
    bgIV.layer.borderColor = htmlColor(@"d9d9d9").CGColor;
    bgIV.layer.borderWidth = 1;
    [self.contentView addSubview:bgIV];
    
    
    self.titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(18+12, bgIV.frameOriginY+13*scale, width-24, 19)];
    self.titleLabel.textColor = BLACKCOLOR;
    self.titleLabel.font = [UIFont systemFontOfSize:17];
    [self.contentView addSubview:self.titleLabel];
    
    self.msgTimeLabel = [[UILabel alloc]initWithFrame:CGRectMake(18+12, self.titleLabel.frameMaxY+14*scale, width-24, 14)];
    self.msgTimeLabel.textColor = GRAYCOLOR;
    self.msgTimeLabel.font = SUBFONT;
    [self.contentView addSubview:self.msgTimeLabel];
    
    self.msgIV = [[UIImageView alloc]initWithFrame:CGRectMake(18+12, self.msgTimeLabel.frameMaxY+15*scale, width-24, 178*scale)];
    self.msgIV.backgroundColor = GRAYCOLOR;
    
    [self.contentView addSubview:self.msgIV];
    
    self.contentLabel = [[UILabel alloc]initWithFrame:CGRectMake(18+12, self.msgIV.frameMaxY+15*scale, width-24, 15)];
    self.contentLabel.textColor = GRAYCOLOR;
    self.contentLabel.font = [UIFont systemFontOfSize:15];
    [self.contentView addSubview:self.contentLabel];
    
    UIImageView*lineIV = [[UIImageView alloc]initWithFrame:CGRectMake(18+12, self.contentLabel.frameMaxY+15*scale, width-12, 0.5)];
    lineIV.backgroundColor = htmlColor(@"d9d9d9");
    [self.contentView addSubview:lineIV];
    
    UILabel*markLabel = [[UILabel alloc]initWithFrame:CGRectMake(18+12, lineIV.frameMaxY+1, width-24, bgIV.frameMaxY-lineIV.frameMaxY-2)];
    markLabel.textColor = BLACKCOLOR;
    markLabel.font = [UIFont systemFontOfSize:17];
    markLabel.text = @"阅读全文";
    [self.contentView addSubview:markLabel];
    
    self.timeLabel.text = @"昨天 13:30";
    [self.timeLabel sizeToFit];
    self.timeLabel.width += 10;
    self.timeLabel.center = CGPointMake(DEVICEWITH/2, 15+10);
    
    self.titleLabel.text = @"怎么样才能不迟到？";
    self.contentLabel.text = @"陪你一起领红包，1亿红包...";
    self.msgTimeLabel.text = @"2016-09-09 16:30";
}

@end
