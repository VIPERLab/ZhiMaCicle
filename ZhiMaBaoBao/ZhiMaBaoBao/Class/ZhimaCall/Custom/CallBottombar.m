//
//  CallBottombar.m
//  ZhiMaBaoBao
//
//  Created by liugang on 16/9/19.
//  Copyright © 2016年 liugang. All rights reserved.
//

#import "CallBottombar.h"

@implementation CallBottombar

+ (instancetype)shareinstance{
    static CallBottombar *callBar = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!callBar) {
            callBar = [[CallBottombar alloc] initWithFrame:CGRectMake(0, DEVICEHIGHT - 49, DEVICEWITH, 49)];
        }
    });
    return callBar;
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        UIView *bgView = [[UIView alloc] initWithFrame:self.bounds];
        bgView.backgroundColor = RGB(240, 240, 240);
        [self addSubview:bgView];
        
        UIButton *button = [[UIButton alloc] init];
        [button setFrame:CGRectMake((DEVICEWITH - 70)/2, 0, 70, 49)];
        [button setTitle:@"拨打" forState:UIControlStateNormal];
        button.backgroundColor = THEMECOLOR;
        [button addTarget:self action:@selector(callButtonClick) forControlEvents:UIControlEventTouchUpInside];
        [bgView addSubview:button];
        
        UIButton *cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(20, 4, 60, 40)];
        [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
        [cancelBtn setTitleColor:THEMECOLOR forState:UIControlStateNormal];
        cancelBtn.titleLabel.font = MAINFONT;
        [cancelBtn addTarget:self action:@selector(cancelBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [bgView addSubview:cancelBtn];
        
        self.windowLevel = UIWindowLevelStatusBar + 5;
        self.hidden = YES;
    }
    return self;
}

//拨号
- (void)callButtonClick{
    
}

//取消
- (void)cancelBtnClick{
    
}

- (void)show{
    self.hidden = NO;
    [self makeKeyAndVisible];
}

- (void)dismiss{
    self.hidden = YES;
    [self removeFromSuperview];
}


/*
+ (void)cancelBtnClick{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"cancelCall" object:nil];
}

- (instancetype)init {
    if (self = [super initWithFrame:CGRectMake(0, DEVICEHIGHT - 49, DEVICEWITH, 49)]) {
        callBar.windowLevel = UIWindowLevelStatusBar + 5;
    }
    return self;
}

+ (void)show {
    callBar.hidden = NO;
    [callBar makeKeyAndVisible];
}


+ (void)callBarClick {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"callNumber" object:nil];
}


+ (void)dismiss {
    callBar.hidden = YES;
}
 */

@end
