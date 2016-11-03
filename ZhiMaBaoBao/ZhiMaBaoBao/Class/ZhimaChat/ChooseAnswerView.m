//
//  ChooseAnswerView.m
//  ZhiMaBaoBao
//
//  Created by ios开发 on 16/11/3.
//  Copyright © 2016年 liugang. All rights reserved.
//

#import "ChooseAnswerView.h"
#import "ZMAnswerLabel.h"

@interface ChooseAnswerView ()

@property (nonatomic, strong) UIView*purseView;
@property (nonatomic, strong) NSMutableArray *btnsMarr; // 按钮数组
@property (nonatomic, assign) NSInteger maxNum;
@property (nonatomic, assign) NSInteger maxIndex;

@end

@implementation ChooseAnswerView

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
    self.btnsMarr = [NSMutableArray array];
    self.maxIndex = 0;
    self.maxNum = 0;
    
    UIView*bgView = [[UIView alloc]initWithFrame:self.bounds];
    bgView.backgroundColor = BLACKCOLOR;
    bgView.alpha = 0.7;
    [self addSubview:bgView];

    
    UIView*purseView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 240)];
    purseView.center = bgView.center;
    [self addSubview:purseView];
    self.purseView = purseView;
    
    UIImageView*purseIV = [[UIImageView alloc]initWithFrame:purseView.bounds];
    purseIV.image = [UIImage imageNamed:@"qingxuanzezhimadaan"];
    [purseView addSubview:purseIV];
    

    UIButton*sureBtn = [[UIButton alloc]initWithFrame:CGRectMake((320-100)/2, 240-40-24, 100, 40)];
    [sureBtn setImage:[UIImage imageNamed:@"qiangzhima"] forState:UIControlStateNormal];
    [sureBtn addTarget:self action:@selector(btnAction) forControlEvents:UIControlEventTouchUpInside];
    [purseView addSubview:sureBtn];
    

}

- (void)btnAction
{
    [self.vc dismissViewControllerAnimated:YES completion:nil];
}

- (void)setAnswerArr:(NSArray *)answerArr
{
    for (int i=0; i<answerArr.count; i++) {
        ZMAnswerLabel*label = [[ZMAnswerLabel alloc]initWithFrame:CGRectMake(30, 70+i*35, 320-30*2, 20)];
        NSString*text = answerArr[i];
        label.text = text;
        label.tag = i;
        label.userInteractionEnabled = YES;
        UITapGestureRecognizer*tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction:)];
        [label addGestureRecognizer:tap];
        
        [self.btnsMarr addObject:label];
        [self.purseView addSubview:label];
        
        NSInteger length = text.length;
        
        if (length > self.maxNum) {
            self.maxNum = length;
            self.maxIndex = i;
        }
    }
    
    ZMAnswerLabel*maxLabel = self.btnsMarr[self.maxIndex];
    maxLabel.center = CGPointMake(self.purseView.center.x-(DEVICEWITH-320)/2, 70+self.maxIndex*35+10);
    
    for (ZMAnswerLabel*label in self.btnsMarr) {
        if (![label isEqual:maxLabel]) {
            label.frameOriginX = maxLabel.frameOriginX;
        }
    }
    
}

- (void)tapAction:(UITapGestureRecognizer*)tap
{
    ZMAnswerLabel*label = (ZMAnswerLabel*)tap.view;
    if (label.isChoice) {
        return;
    }
    
    label.isChoice = YES;
    for (ZMAnswerLabel*label2 in self.btnsMarr) {
    
        if (![label2 isEqual:label]) {
            label2.isChoice = NO;
        }
    
    }
    
}

@end
