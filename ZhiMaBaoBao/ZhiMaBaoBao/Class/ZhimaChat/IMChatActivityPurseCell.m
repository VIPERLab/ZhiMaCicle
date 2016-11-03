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
        self.sending.hidden = YES;
        self.sendAgain.hidden = YES;
        
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
    //如果屏幕宽度>6的宽度 则显示固定大小的尺寸 否则跟随屏幕宽度变化
    if (DEVICEWITH > 375) {
        if (self.isMe) {
            [self.activityPursePopIV mas_makeConstraints:^(MASConstraintMaker *make){
                make.right.equalTo(self.contentView.mas_right).offset(-60);
                make.top.equalTo(self.topLabel.mas_bottom).offset(10);
                make.height.mas_equalTo(106);
                make.width.mas_equalTo(375-60*2);

            }];
        }else{
            [self.activityPursePopIV mas_makeConstraints:^(MASConstraintMaker *make){
                make.left.equalTo(self.contentView.mas_left).offset(60);
                make.top.equalTo(self.topLabel.mas_bottom).offset(10);
                make.height.mas_equalTo(106);
                make.width.mas_equalTo(375-60*2);
            }];
        }

    }else{
        [self.activityPursePopIV mas_makeConstraints:^(MASConstraintMaker *make){
            make.left.equalTo(self.contentView.mas_left).offset(60);
            make.right.equalTo(self.contentView.mas_right).offset(-60);
            make.top.equalTo(self.topLabel.mas_bottom).offset(10);
            make.height.mas_equalTo(106);
        }];
    }
    
    if (self.isMe) {
        self.activityPursePopIV.image = [UIImage imageNamed:@"activityPursePopRight"];
        
        [self.activtityPurseIV mas_makeConstraints:^(MASConstraintMaker *make){
            make.left.equalTo(self.activityPursePopIV.mas_left).offset(5);
            make.top.equalTo(self.topLabel.mas_bottom).offset(22);
            make.width.mas_equalTo(66);
            make.height.mas_equalTo(80);

        }];
        
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make){
            make.right.equalTo(self.activityPursePopIV.mas_right).offset(-11);
            make.left.equalTo(self.activtityPurseIV.mas_right).offset(4);
            make.top.equalTo(self.topLabel.mas_bottom).offset(22);
            make.height.mas_equalTo(38);
        }];
        
        [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make){
            make.right.equalTo(self.activityPursePopIV.mas_right).offset(-11);
            make.left.equalTo(self.activtityPurseIV.mas_right).offset(4);
            make.top.equalTo(self.titleLabel.mas_bottom).offset(10);
            make.height.mas_equalTo(32);

        }];
        
    }else{
        self.activityPursePopIV.image = [UIImage imageNamed:@"activityPursePopLeft"];
        
        [self.activtityPurseIV mas_makeConstraints:^(MASConstraintMaker *make){
            make.left.equalTo(self.activityPursePopIV.mas_left).offset(11);
            make.top.equalTo(self.topLabel.mas_bottom).offset(22);
            make.width.mas_equalTo(66);
            make.height.mas_equalTo(80);

        }];
        
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make){
            make.right.equalTo(self.activityPursePopIV.mas_right).offset(-5);
            make.left.equalTo(self.activtityPurseIV.mas_right).offset(4);
            make.top.equalTo(self.topLabel.mas_bottom).offset(22);
            make.height.mas_equalTo(38);
        }];
        
        [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make){
            make.right.equalTo(self.activityPursePopIV.mas_right).offset(-5);
            make.left.equalTo(self.activtityPurseIV.mas_right).offset(4);
            make.top.equalTo(self.titleLabel.mas_bottom).offset(10);
            make.height.mas_equalTo(32);

        }];
    }

}

- (void)createCustomViews
{
    self.activityPursePopIV = [[UIImageView alloc]init];
    [self.contentView addSubview:self.activityPursePopIV];
    
    self.activtityPurseIV = [[UIImageView alloc]init];
    self.activtityPurseIV.image = [UIImage imageNamed:@"activityChatPurse"];
    [self.contentView addSubview:self.activtityPurseIV];
    
    self.titleLabel = [[UILabel alloc]init];
    self.titleLabel.numberOfLines = 2;
    self.titleLabel.text = @"麦当劳邀您抢双十一红包雨";
    self.titleLabel.font = [UIFont systemFontOfSize:15];
    self.titleLabel.textColor = BLACKCOLOR;
    [self.contentView addSubview:self.titleLabel];
    
    self.contentLabel = [[UILabel alloc]init];
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
