//
//  LGGuideController.m
//  YiIM_iOS
//
//  Created by liugang on 16/8/5.
//  Copyright © 2016年 ikantech. All rights reserved.
//

#import "LGGuideController.h"
#import "LGRegisterController.h"
#import "LGLoginController.h"



@implementation LGGuideController
- (void)viewDidLoad{
    [super viewDidLoad];
    
    [self hiddenBackBtn];
    [self setUI];
}
/**
 *  搭建UI
 */
- (void)setUI{
    
    UIImageView *themeImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"loginAndRes"]];
    [self.view  addSubview:themeImage];
    [themeImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(160);
        make.centerX.mas_equalTo(self.view.mas_centerX);
    }];
    
    UILabel *label = [[UILabel alloc] init];
    label.text = @"芝麻宝宝    为爱而生";
    label.textColor = THEMECOLOR;
    label.font = MAINFONT;
    [self.view addSubview:label];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(themeImage.mas_bottom).mas_offset(32);
        make.centerX.mas_equalTo(self.view.mas_centerX);
    }];
    
    
    UIButton *registerBtn = [[UIButton alloc] init];
    [registerBtn setTitle:@"注册" forState:UIControlStateNormal];
    [registerBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    registerBtn.titleLabel.font = MAINFONT;
    registerBtn.backgroundColor = THEMECOLOR;
    registerBtn.layer.cornerRadius = 5.f;
    [registerBtn addTarget:self action:@selector(registerAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:registerBtn];
    
    UIButton *loginBtn = [[UIButton alloc] init];
    [loginBtn setTitle:@"登录" forState:UIControlStateNormal];
    [loginBtn setTitleColor:THEMECOLOR forState:UIControlStateNormal];
    loginBtn.titleLabel.font = MAINFONT;
    loginBtn.layer.cornerRadius = 5.f;
    loginBtn.layer.borderWidth = 1.f;
    loginBtn.layer.borderColor = THEMECOLOR.CGColor;
    loginBtn.backgroundColor = [UIColor whiteColor];
    [loginBtn addTarget:self action:@selector(loginAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:loginBtn];
    
    [registerBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(30);
        make.height.mas_equalTo(46);
        make.bottom.mas_equalTo(-90);
        make.right.mas_equalTo(self.view.mas_centerX).mas_offset(-23);
    }];
    
    [loginBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-30);
        make.height.mas_equalTo(46);
        make.bottom.mas_equalTo(-90);
        make.left.mas_equalTo(self.view.mas_centerX).mas_offset(23);
    }];
    
    
}
//注册
- (void)registerAction{
    LGRegisterController *registerVC = [[LGRegisterController alloc] init];
    [self.navigationController pushViewController:registerVC animated:YES];
}
//登录
- (void)loginAction{
    LGLoginController *loginVC = [[LGLoginController alloc] init];
    [self.navigationController pushViewController:loginVC animated:YES];
}

- (void)dealloc{
    
}


@end
