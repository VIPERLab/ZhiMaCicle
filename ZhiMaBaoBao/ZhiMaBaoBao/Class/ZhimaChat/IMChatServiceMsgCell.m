//
//  IMChatServiceMsgCell.m
//  ZhiMaBaoBao
//
//  Created by ios开发 on 16/11/2.
//  Copyright © 2016年 liugang. All rights reserved.
//

#import "IMChatServiceMsgCell.h"

@implementation IMChatServiceMsgCell


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
    
    [self.serviceMsgPopIV removeFromSuperview];
    [self.serviceMsgIV removeFromSuperview];
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
            [self.serviceMsgPopIV mas_makeConstraints:^(MASConstraintMaker *make){
                make.right.equalTo(self.contentView.mas_right).offset(-60);
                make.top.equalTo(self.topLabel.mas_bottom).offset(10);
                make.height.mas_equalTo(106+12);
                make.width.mas_equalTo(375-60*2);
                
            }];
        }else{
            [self.serviceMsgPopIV mas_makeConstraints:^(MASConstraintMaker *make){
                make.left.equalTo(self.contentView.mas_left).offset(60);
                make.top.equalTo(self.topLabel.mas_bottom).offset(10);
                make.height.mas_equalTo(106+12);
                make.width.mas_equalTo(375-60*2);
            }];
        }
        
    }else{
        [self.serviceMsgPopIV mas_makeConstraints:^(MASConstraintMaker *make){
            make.left.equalTo(self.contentView.mas_left).offset(60);
            make.right.equalTo(self.contentView.mas_right).offset(-60);
            make.top.equalTo(self.topLabel.mas_bottom).offset(10);
            make.height.mas_equalTo(106+12);
        }];
    }
    
    if (self.isMe) {
        self.serviceMsgPopIV.image = [UIImage imageNamed:@"serviceMsgPopRight"];
        
        [self.serviceMsgIV mas_makeConstraints:^(MASConstraintMaker *make){
            make.right.equalTo(self.serviceMsgPopIV.mas_right).offset(-18);
            make.bottom.equalTo(self.serviceMsgPopIV.mas_bottom).offset(-12);
            make.width.mas_equalTo(45);
            make.height.mas_equalTo(45);
            
        }];
        
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make){
            make.right.equalTo(self.serviceMsgPopIV.mas_right).offset(-35);
            make.left.equalTo(self.serviceMsgPopIV.mas_left).offset(10);
            make.top.equalTo(self.topLabel.mas_bottom).offset(22);
            make.height.mas_equalTo(38);
        }];
        
        [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make){
            make.right.equalTo(self.serviceMsgIV.mas_left).offset(-15);
            make.left.equalTo(self.serviceMsgPopIV.mas_left).offset(10);
            make.top.equalTo(self.titleLabel.mas_bottom).offset(9);
            make.height.mas_equalTo(32+15);
            
        }];
        
    }else{
        self.serviceMsgPopIV.image = [UIImage imageNamed:@"serviceMsgPopLeft"];
        
        [self.serviceMsgIV mas_makeConstraints:^(MASConstraintMaker *make){
            make.right.equalTo(self.serviceMsgPopIV.mas_right).offset(-12);
            make.bottom.equalTo(self.serviceMsgPopIV.mas_bottom).offset(-12);
            make.width.mas_equalTo(45);
            make.height.mas_equalTo(45);
            
        }];
        
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make){
            make.right.equalTo(self.serviceMsgPopIV.mas_right).offset(-35+6);
            make.left.equalTo(self.serviceMsgPopIV.mas_left).offset(10+6);
            make.top.equalTo(self.topLabel.mas_bottom).offset(22);
            make.height.mas_equalTo(38);
        }];
        
        [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make){
            make.right.equalTo(self.serviceMsgIV.mas_left).offset(-15);
            make.left.equalTo(self.serviceMsgPopIV.mas_left).offset(10+6);
            make.top.equalTo(self.titleLabel.mas_bottom).offset(9);
            make.height.mas_equalTo(32+15);
            
        }];
    }
    
}

- (void)createCustomViews
{
    self.serviceMsgPopIV = [[UIImageView alloc]init];
    [self.contentView addSubview:self.serviceMsgPopIV];
    
    self.serviceMsgIV = [[UIImageView alloc]init];
    self.serviceMsgIV.backgroundColor = BGCOLOR;
    [self.contentView addSubview:self.serviceMsgIV];
    
    self.titleLabel = [[UILabel alloc]init];
    self.titleLabel.numberOfLines = 2;
    self.titleLabel.text = @"这一跪，完成了三星在中国的“三连炸”";
    self.titleLabel.font = [UIFont systemFontOfSize:15];
    self.titleLabel.textColor = BLACKCOLOR;
    [self.contentView addSubview:self.titleLabel];
    
    self.contentLabel = [[UILabel alloc]init];
    self.contentLabel.numberOfLines = 3;
    self.contentLabel.text = @"初冬的北京，冻成狗。然而，那些几个月初冬的北京，冻成狗。成狗。狗。 。";
    self.contentLabel.font = [UIFont systemFontOfSize:12];
    self.contentLabel.textColor = htmlColor(@"bcbcbc");
    [self.contentView addSubview:self.contentLabel];
    
    
    //    //添加长按手势
    //    UILongPressGestureRecognizer *longGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressAction:)];
    //    [_bubble addGestureRecognizer:longGesture];
}
@end
