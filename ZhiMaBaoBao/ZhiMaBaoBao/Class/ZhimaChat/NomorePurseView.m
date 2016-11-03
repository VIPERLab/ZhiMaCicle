//
//  NomorePurseView.m
//  ZhiMaBaoBao
//
//  Created by ios开发 on 16/11/2.
//  Copyright © 2016年 liugang. All rights reserved.
//

#import "NomorePurseView.h"

@implementation NomorePurseView

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
    
    UIView*purseView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 290, 410)];
    purseView.center = bgView.center;
    [self addSubview:purseView];
    
    UIImageView*purseIV = [[UIImageView alloc]initWithFrame:purseView.bounds];
    purseIV.image = [UIImage imageNamed:@"hongbaoqiangwanle"];
    [purseView addSubview:purseIV];
    
    UIButton*sureBtn = [[UIButton alloc]initWithFrame:CGRectMake((290-100)/2, 410-40-24, 100, 40)];
    [sureBtn setImage:[UIImage imageNamed:@"oYellow"] forState:UIControlStateNormal];
    [sureBtn addTarget:self action:@selector(btnAction) forControlEvents:UIControlEventTouchUpInside];
    [purseView addSubview:sureBtn];
}

- (void)btnAction
{
    [self.vc dismissViewControllerAnimated:YES completion:nil];
}

@end
