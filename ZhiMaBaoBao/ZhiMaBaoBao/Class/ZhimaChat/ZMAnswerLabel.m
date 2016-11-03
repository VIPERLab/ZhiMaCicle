//
//  ZMAnswerLabel.m
//  ZhiMaBaoBao
//
//  Created by ios开发 on 16/11/3.
//  Copyright © 2016年 liugang. All rights reserved.
//

#import "ZMAnswerLabel.h"

@interface ZMAnswerLabel ()

@property (nonatomic, strong) UIButton *btn; // 选择按钮
@property (nonatomic, strong) UILabel *label; // 答案label

@end

@implementation ZMAnswerLabel

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
    self.btn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 20, 20)];
    [self.btn setImage:[UIImage imageNamed:@"nomalState"] forState:UIControlStateNormal];
    [self.btn setImage:[UIImage imageNamed:@"choiceState"] forState:UIControlStateSelected];
    self.btn.userInteractionEnabled = NO;
    [self addSubview:self.btn];
    
    self.label = [[UILabel alloc]initWithFrame:CGRectMake(35, 0, 100, 20)];
    self.label.textColor = htmlColor(@"888888");
    self.label.font = [UIFont fontWithName:@"迷你简菱心" size:17];
    [self addSubview:self.label];
    
}

- (void)setText:(NSString *)text
{
    self.label.text = text;
    [self.label sizeToFit];//320-30*2
    
    self.label.frameSizeWidth = self.label.width > 320-30*2-35 ? 320-30*2-35 : self.label.width;
    self.frameSizeWidth = self.label.width + 35;
    
    
}

- (void)setIsChoice:(BOOL)isChoice
{
    if (isChoice) {
        self.btn.selected = YES;
        self.label.textColor = htmlColor(@"ec3f38");
    }else{
        self.btn.selected = NO;
        self.label.textColor = htmlColor(@"888888");
    }
}

@end
