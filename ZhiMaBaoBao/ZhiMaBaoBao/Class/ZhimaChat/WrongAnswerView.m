//
//  WrongAnswerView.m
//  ZhiMaBaoBao
//
//  Created by ios开发 on 16/11/3.
//  Copyright © 2016年 liugang. All rights reserved.
//

#import "WrongAnswerView.h"

@implementation WrongAnswerView


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

    UIView*purseView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 280, 200)];
    purseView.center = bgView.center;
    purseView.layer.cornerRadius = 15;
    purseView.backgroundColor = WHITECOLOR;
    [self addSubview:purseView];

    UIButton*sureBtn = [[UIButton alloc]initWithFrame:CGRectMake((280-100)/2, 200-40-24, 100, 40)];
    [sureBtn setImage:[UIImage imageNamed:@"haobaRed"] forState:UIControlStateNormal];
    [sureBtn addTarget:self action:@selector(btnAction) forControlEvents:UIControlEventTouchUpInside];
    [purseView addSubview:sureBtn];
    
    UILabel*markLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, 45, 280-30, 50)];
    markLabel.font = [UIFont fontWithName:@"迷你简菱心" size:20];
    markLabel.textColor = htmlColor(@"ec3f38");
    markLabel.numberOfLines = 0;
    [purseView addSubview:markLabel];
    
    NSString* str  = @"好可惜，答案不正确，再试一次吧";
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:str];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:10];
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [str length])];
    markLabel.attributedText = attributedString;
    markLabel.textAlignment = 1;

}

- (void)btnAction
{
    [self.vc dismissViewControllerAnimated:YES completion:nil];
}

@end
