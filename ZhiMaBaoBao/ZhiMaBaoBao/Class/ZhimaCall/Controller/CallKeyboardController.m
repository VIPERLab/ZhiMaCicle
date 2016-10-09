//
//  CallKeyboardController.m
//  ZhiMaBaoBao
//
//  Created by liugang on 16/10/7.
//  Copyright © 2016年 liugang. All rights reserved.
//

#import "CallKeyboardController.h"
#import "POP.h"

@interface CallKeyboardController ()
@property (nonatomic, strong) UIView *red;
@end

@implementation CallKeyboardController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    [self addAllsubviews];
    
    UIView *red = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    red.backgroundColor = [UIColor redColor];
    [self.view addSubview:red];
    self.red = red;
    
    POPSpringAnimation *anima = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerPositionX];
    anima.fromValue = @(100);
    anima.beginTime = CACurrentMediaTime() + 1.0f;
    anima.springBounciness = 10.0f;
    //    anima.velocity = @(500000);
    [self.red pop_addAnimation:anima forKey:@"hh"];
    
    NSLog(@"%@--- red ",NSStringFromCGRect(red.frame));
    

}

- (void)addAllsubviews{
    CGFloat margin = 30; //按钮离屏幕的边距
    CGFloat paddimg = 50; //按钮之间的左右边距
    CGFloat btnS = (DEVICEWITH - 2 * (margin + paddimg))/3;  //按钮宽高
    
    //添加拨号按钮
    for (int i = 0; i < 11; i ++) {
        
        CGFloat btnY = btnS * (i/3);
        
        UIButton *btn = [[UIButton alloc] init];
        btn.tag = i+1;
        [btn setTitle:[NSString stringWithFormat:@"%d",i + 1] forState:UIControlStateNormal];
        [btn setTitleColor:WHITECOLOR forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(keyboardNumberDidClick:) forControlEvents:UIControlEventTouchUpInside];
        btn.backgroundColor = THEMECOLOR;
        btn.layer.cornerRadius = btnS/2;
        
        [self.view addSubview:btn];
        btn.size = CGSizeMake(btnS, btnS);
        btn.x = margin + (btnS + paddimg) * (i%3);
        btn.y = btnY + 300;
        
        POPSpringAnimation *anSpring = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerPositionY];
        anSpring.toValue = @(btnY);
        anSpring.beginTime = CACurrentMediaTime() + 1.0f;
        anSpring.springBounciness = 10.0f;
        [btn pop_addAnimation:anSpring forKey:@"position"];
        
        if (i == 9) {  // "0" 按键
            [btn setTitle:@"0" forState:UIControlStateNormal];
            btn.tag = 0;
            btn.x = (DEVICEWITH - btnS)/2;
            btn.y = btnS * 3 + 300;
        }
        
        if (i == 10) {
            [btn setTitle:@"拨号" forState:UIControlStateNormal];
            btn.tag = 0;
            btn.x = (DEVICEWITH - btnS)/2;
            btn.y = btnS * 4 + 10 + 300;
        }
    }
}

- (void)keyboardNumberDidClick:(UIButton *)sender{
    
}

@end
