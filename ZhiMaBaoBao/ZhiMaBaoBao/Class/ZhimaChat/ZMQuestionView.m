//
//  ZMQuestionView.m
//  ZhiMaBaoBao
//
//  Created by ios开发 on 16/11/3.
//  Copyright © 2016年 liugang. All rights reserved.
//

#import "ZMQuestionView.h"

#import "PurseLabel.h"

@interface ZMQuestionView ()

@property (nonatomic, strong) PurseLabel *passwordLabel; // 芝麻口令label

@end

@implementation ZMQuestionView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self initUI];
        
    }
    return self;
}

- (void)initUI
{
    UIView*bgView = [[UIView alloc]initWithFrame:self.bounds];
    bgView.backgroundColor = BLACKCOLOR;
    bgView.alpha = 0.7;
    [self addSubview:bgView];
    
    UIImageView*lightIV = [[UIImageView alloc]initWithFrame:self.bounds];
    lightIV.image = [UIImage imageNamed:@"whiteLight"];
    [self addSubview:lightIV];
    
    UIView*purseView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 300, 320)];
    purseView.center = bgView.center;
    [self addSubview:purseView];
    
    UIImageView*purseIV = [[UIImageView alloc]initWithFrame:CGRectMake(0, 20, 300, 237)];
    purseIV.image = [UIImage imageNamed:@"zhimatiwen"];
    [purseView addSubview:purseIV];
    
    
    self.passwordLabel = [[PurseLabel alloc]initWithFrame:CGRectMake((320-150)/2+15,120, 120, 150)];
    self.passwordLabel.font = [UIFont fontWithName:@"迷你简菱心" size:18];
    self.passwordLabel.textColor = htmlColor(@"ec3f38");
    self.passwordLabel.numberOfLines = 0;
    [purseView addSubview:self.passwordLabel];
    
    UIButton*sureBtn = [[UIButton alloc]initWithFrame:CGRectMake(DEVICEWITH-40, purseView.frameOriginY, 40, 40)];
    [sureBtn setImage:[UIImage imageNamed:@"purseClose"] forState:UIControlStateNormal];
    [sureBtn addTarget:self action:@selector(btnAction) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:sureBtn];
    
    UILabel*markLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, purseView.frameMaxY, DEVICEWITH-30, 25)];
    markLabel.font = [UIFont fontWithName:@"迷你简菱心" size:11];
    markLabel.textColor = WHITECOLOR;
    markLabel.text = @"提示：视频中有答案哦，细心的看众可以抢到芝麻哦!";
    markLabel.numberOfLines = 2;
    markLabel.textAlignment = 1;
    [self addSubview:markLabel];
}

- (void)btnAction
{
    [self.vc dismissViewControllerAnimated:YES completion:nil];
}

- (void)setQuestionStr:(NSString *)questionStr
{
    // 调整行间距
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:questionStr];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:10];
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [questionStr length])];
    self.passwordLabel.attributedText = attributedString;
    self.passwordLabel.textAlignment = 1;
}

@end
