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
    
    
    UIButton*visitorsBtn = [[UIButton alloc]init];
    [visitorsBtn setTitle:@"游客进入" forState:UIControlStateNormal];
    [visitorsBtn setTitleColor:GRAYCOLOR forState:UIControlStateNormal];
    visitorsBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [self.view addSubview:visitorsBtn];
    
    [visitorsBtn addTarget:self action:@selector(visitorAction) forControlEvents:UIControlEventTouchUpInside];
    
    [visitorsBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(30);
        make.width.mas_equalTo(58);
        make.bottom.mas_equalTo(-25);
        make.centerX.mas_equalTo(self.view);
    }];
    
    UIImageView*lineIV = [[UIImageView alloc]init];
    lineIV.backgroundColor = GRAYCOLOR;
    [visitorsBtn addSubview:lineIV];
    
    [lineIV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(1);
        make.bottom.mas_equalTo(-3);
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
    }];
    
    UserInfo*info = [UserInfo read];
    if (info.isVisitor) {
        UIButton*closeBtn = [[UIButton alloc]initWithFrame:CGRectMake(10, 25, 50, 50)];
        [closeBtn setImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
        [closeBtn addTarget:self action:@selector(dissBackAction) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:closeBtn];
        
        visitorsBtn.hidden = YES;
    }
}

- (void)dissBackAction
{
    [self dismissViewControllerAnimated:YES completion:nil];
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

- (void)visitorAction
{     
    UserInfo*info = [UserInfo read];
    
    if (!info) {
        info = [UserInfo shareInstance];
    }
    
    if (info.isVisitor) {
        [self dismissViewControllerAnimated:YES completion:nil];
        return;
    }
    
    info.hasLogin = YES;
    info.userID = @"0";
    info.sessionId = @"0";
    info.head_photo = @"image/user_default_head_photo.png";
    info.backgroundImg = @"image/user_default_background_image.jpg";
    info.yuan_head_photo = @"image/user_default_head_photo.png";
    info.username = @"游客";
    info.signature = @"";
    info.isVisitor = YES;
    info.unReadCount = 0;
    [info save];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:LOGIN_SUCCESS object:nil];

}

- (void)dealloc{
    
}


@end
