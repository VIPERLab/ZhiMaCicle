//
//  LogResBaseController.m
//  ZhiMaBaoBao
//
//  Created by liugang on 16/9/19.
//  Copyright © 2016年 liugang. All rights reserved.
//  登录注册基类

#import "LogResBaseController.h"

@interface LogResBaseController (){
    UIView *navBar;     //导航栏
    UIButton *backBtn;   //返回按钮
    UIButton *rightBtn;  //导航栏右侧按钮
}

@end

@implementation LogResBaseController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    self.navigationController.navigationBarHidden = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = BGCOLOR;
    [self addSubviews];
}

//添加子试图
- (void)addSubviews{
    //自定义导航栏
    navBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, DEVICEWITH, 64)];
    navBar.backgroundColor = WHITECOLOR;
    [self.view addSubview:navBar];
    
    //返回按钮
    backBtn = [[UIButton alloc] init];
    [backBtn setTitle:@"取消" forState:UIControlStateNormal];
    [backBtn setTitleColor:THEMECOLOR forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(navBackAction) forControlEvents:UIControlEventTouchUpInside];
    backBtn.titleLabel.textAlignment = NSTextAlignmentLeft;
    backBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [navBar addSubview:backBtn];
    [backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(6);
        make.width.mas_equalTo(50);
        make.height.mas_equalTo(40);
        make.top.mas_equalTo(22);
    }];
    
}

//设置导航栏右侧按钮
- (void)setNavRightButton:(NSString *)title{
    //导航栏右侧按钮
    rightBtn = [[UIButton alloc] init];
    [rightBtn setTitle:title forState:UIControlStateNormal];
    [rightBtn setTitleColor:THEMECOLOR forState:UIControlStateNormal];
    [rightBtn addTarget:self action:@selector(navBackAction) forControlEvents:UIControlEventTouchUpInside];
    rightBtn.titleLabel.textAlignment = NSTextAlignmentRight;
    rightBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [navBar addSubview:rightBtn];
    [rightBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-6);
        make.width.mas_equalTo(100);
        make.height.mas_equalTo(40);
        make.top.mas_equalTo(22);
    }];
}

- (void)navBackAction{
    [self.navigationController popViewControllerAnimated:YES];
}


@end
