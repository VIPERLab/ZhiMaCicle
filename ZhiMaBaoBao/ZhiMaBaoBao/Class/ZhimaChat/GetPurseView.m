//
//  GetPurseView.m
//  ZhiMaBaoBao
//
//  Created by ios开发 on 16/11/2.
//  Copyright © 2016年 liugang. All rights reserved.
//

#import "GetPurseView.h"

@interface GetPurseView ()

@property (nonatomic, strong) UIImageView *logoIV; // logo视图
@property (nonatomic, strong) UILabel *moneyLabel; // 抢到多少钱label

@end

@implementation GetPurseView

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
    
    UIView*purseView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 310, 410)];
    purseView.center = bgView.center;
    [self addSubview:purseView];
    
    UIImageView*purseIV = [[UIImageView alloc]initWithFrame:purseView.bounds];
    purseIV.image = [UIImage imageNamed:@"qiangdaohongbao"];
    [purseView addSubview:purseIV];
    
    self.logoIV = [[UIImageView alloc]initWithFrame:CGRectMake((310-57)/2, 75, 57, 57)];
    self.logoIV.backgroundColor = WHITECOLOR;
    self.logoIV.layer.cornerRadius = 57/2;
    self.logoIV.layer.masksToBounds = YES;
    [purseView addSubview:self.logoIV];
    
    UILabel*markLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, self.logoIV.frameMaxY+20, 310, 17)];
    markLabel.font = [UIFont fontWithName:@"迷你简菱心" size:17];
    markLabel.textAlignment = 1;
    markLabel.textColor = htmlColor(@"f69c2d");
    markLabel.text = @"恭喜您!";
    [purseView addSubview:markLabel];

    self.moneyLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, markLabel.frameMaxY+18, 310, 26)];
    self.moneyLabel.font = [UIFont fontWithName:@"迷你简菱心" size:15];
    self.moneyLabel.textAlignment = 1;
    self.moneyLabel.textColor = htmlColor(@"f69c2d");
    [purseView addSubview:self.moneyLabel];
    
    UIButton*sureBtn = [[UIButton alloc]initWithFrame:CGRectMake((310-100)/2, self.moneyLabel.frameMaxY+133, 100, 40)];
    [sureBtn setImage:[UIImage imageNamed:@"quedingYellow"] forState:UIControlStateNormal];
    [sureBtn addTarget:self action:@selector(btnAction) forControlEvents:UIControlEventTouchUpInside];
    [purseView addSubview:sureBtn];
}

- (void)setMoney:(NSString *)money
{
    NSMutableAttributedString*str = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"抢到%@元",money]];
    
    NSRange range = NSMakeRange(2, money.length);
    
    [str addAttribute:NSForegroundColorAttributeName
                value:WHITECOLOR
                range:range];
    [str addAttribute:NSFontAttributeName
                value:[UIFont fontWithName:@"迷你简菱心" size:26]
                range:range];
    
    self.moneyLabel.attributedText = str;
}

- (void)btnAction
{
    [self.vc dismissViewControllerAnimated:YES completion:nil];
}

@end
