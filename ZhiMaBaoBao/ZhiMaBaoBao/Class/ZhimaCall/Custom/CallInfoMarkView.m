//
//  CallInfoMarkView.m
//  ZhiMaBaoBao
//
//  Created by ios开发 on 16/10/13.
//  Copyright © 2016年 liugang. All rights reserved.
//

#import "CallInfoMarkView.h"

@implementation CallInfoMarkView


- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {

        [self initUI];
    }
    return self;
}

- (void)initUI
{
    self.nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, DEVICEWITH-60, 25)];
    self.nameLabel.textColor = BLACKCOLOR;
    self.nameLabel.text = @"中国移动";
    self.nameLabel.font = [UIFont systemFontOfSize:17];
    [self addSubview:self.nameLabel];
    
    self.phoneLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, 25, DEVICEWITH-60, 25)];
    self.phoneLabel.textColor = htmlColor(@"888888");
    self.phoneLabel.text = @"10086";
    self.phoneLabel.font = [UIFont systemFontOfSize:14];
    [self addSubview:self.phoneLabel];
    
    self.stateBtn = [[UIButton alloc]initWithFrame:CGRectMake(DEVICEWITH-45, 10, 30, 30)];
    [self.stateBtn setImage:[UIImage imageNamed:@"down"] forState:UIControlStateNormal];
    [self.stateBtn setImage:[UIImage imageNamed:@"up"] forState:UIControlStateSelected];
    self.stateBtn.selected = NO;
    [self.stateBtn addTarget:self action:@selector(changeBtnState) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.stateBtn];
    
    self.userInteractionEnabled = YES;
    UITapGestureRecognizer*tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(makeCall)];
    [self addGestureRecognizer:tap];
    
}

- (void)makeCall
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(call)]) {
        [self.delegate call];
    }
}

- (void)changeBtnState
{
    if (self.stateBtn.selected) {
        self.stateBtn.selected = NO;
        self.phoneLabel.hidden = NO;
        self.nameLabel.hidden = NO;
        
    }else{
        self.stateBtn.selected = YES;
        self.phoneLabel.hidden = YES;
        self.nameLabel.hidden = YES;
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(stateChange:)]) {
        [self.delegate stateChange:self.stateBtn.selected];
    }
}

- (void)changeStateWithContact:(PhoneContact*)conteact
{
    if (!conteact) {
        self.hidden = YES;
        return;
    }
    self.hidden = NO;
    self.nameLabel.text = conteact.name;
    self.phoneLabel.text = conteact.phoneNumber;
}

- (void)setColorWithString:(NSString*)string
{
    NSRange range = [self.phoneLabel.text rangeOfString:string];
    [self setTextColor:self.phoneLabel FontNumber:[UIFont systemFontOfSize:15] AndRange:range AndColor:BLACKCOLOR];
}

//设置不同字体颜色
-(void)setTextColor:(UILabel *)label FontNumber:(id)font AndRange:(NSRange)range AndColor:(UIColor *)vaColor
{
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:label.text];
    //设置字号
    [str addAttribute:NSFontAttributeName value:font range:range];
    //设置文字颜色
    [str addAttribute:NSForegroundColorAttributeName value:vaColor range:range];
    
    label.attributedText = str;
}

@end
