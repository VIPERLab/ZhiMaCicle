//
//  IMChatActivityPurseCell.m
//  ZhiMaBaoBao
//
//  Created by ios开发 on 16/10/29.
//  Copyright © 2016年 liugang. All rights reserved.
//

#import "IMChatActivityPurseCell.h"

@implementation IMChatActivityPurseCell


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.bubble.hidden = YES;
        
        [self createCustomViews];        
    }
    return self;
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    [self.activityPursePopIV removeFromSuperview];
    [self.activtityPurseIV removeFromSuperview];
    [self.titleLabel removeFromSuperview];
    [self.contentLabel removeFromSuperview];

    [self createCustomViews];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
//    [self.activityPursePopIV setFrameOriginXRightOfView:self.userIcon offset:5];
    [self.activityPursePopIV setFrameOriginYBelowView:self.topLabel offset:10];
    [self.activtityPurseIV setFrameOriginYBelowView:self.topLabel offset:22];
    [self.titleLabel setFrameOriginYBelowView:self.topLabel offset:32];
    [self.contentLabel setFrameOriginYBelowView:self.titleLabel offset:6];


}

- (void)createCustomViews
{

    CGFloat originX = self.userIcon.frameMaxX + 15;
    CGFloat originY = self.userIcon.frameOriginY;
    
    self.activityPursePopIV = [[UIImageView alloc]initWithFrame:CGRectMake(originX, originY, DEVICEWITH-originX*2, 115)];
    self.activityPursePopIV.image = [UIImage imageNamed:@"activityPursePop"];
    [self.contentView addSubview:self.activityPursePopIV];
    
    self.activtityPurseIV = [[UIImageView alloc]initWithFrame:CGRectMake(originX+12-5, originY+12, 73, 89)];
    self.activtityPurseIV.image = [UIImage imageNamed:@"activityChatPurse"];
    [self.contentView addSubview:self.activtityPurseIV];
    
    self.titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.activtityPurseIV.frameMaxX+5, originY+22, DEVICEWITH-originX-self.activtityPurseIV.frameMaxX-10, 38)];
    self.titleLabel.numberOfLines = 2;
    self.titleLabel.text = @"麦当劳邀您抢双十一红包雨";
    self.titleLabel.font = [UIFont systemFontOfSize:15];
    self.titleLabel.textColor = BLACKCOLOR;
    [self.contentView addSubview:self.titleLabel];
    
    self.contentLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.activtityPurseIV.frameMaxX+5, self.titleLabel.frameMaxY+12, DEVICEWITH-originX-self.activtityPurseIV.frameMaxX-10, 32)];
    self.contentLabel.numberOfLines = 2;
    self.contentLabel.text = @"爱的哈咖啡的建安是的发送到发送到发法国恢复供货法国恢复送到大东方";
    self.contentLabel.font = [UIFont systemFontOfSize:12];
    self.contentLabel.textColor = htmlColor(@"bcbcbc");
    [self.contentView addSubview:self.contentLabel];
    
    
//    //添加长按手势
//    UILongPressGestureRecognizer *longGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressAction:)];
//    [_bubble addGestureRecognizer:longGesture];
}

@end
