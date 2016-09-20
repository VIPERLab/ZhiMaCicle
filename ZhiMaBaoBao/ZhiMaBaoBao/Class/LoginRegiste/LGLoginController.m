//
//  LGLoginController.m
//  YiIM_iOS
//
//  Created by liugang on 16/8/5.
//  Copyright © 2016年 ikantech. All rights reserved.
//

#import "LGLoginController.h"
#import "MainViewController.h"
#import "LGRessetPassController.h"

@interface LGLoginController ()
@property (nonatomic, strong) UITextField *phoneField;
@property (nonatomic, strong) UITextField *passField;
@property (nonatomic, strong) UIButton *loginBtn;

@end

@implementation LGLoginController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNavRightButton:@"忘记密码"];
    [self setUI];
}

- (void)setUI{
    
    UILabel *prompt = [[UILabel alloc] init];
    prompt.text = @"使用帐号和密码登录";
    prompt.textColor = BLACKCOLOR;
    prompt.font = [UIFont systemFontOfSize:17];
    [self.view addSubview:prompt];
    [prompt mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.view);
        make.top.mas_equalTo(100);
    }];
    
    UILabel *phone = [[UILabel alloc] init];
    phone.text = @"手机号";
    phone.textColor = BLACKCOLOR;
    phone.font = MAINFONT;
    [self.view addSubview:phone];
    [phone mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.top.mas_equalTo(prompt.mas_bottom).mas_offset(53);
    }];
    
    UITextField *phontField = [[UITextField alloc] init];
    phontField.placeholder = @"请输入手机号";
    phontField.keyboardType = UIKeyboardTypePhonePad;
    phontField.font = MAINFONT;
    [self.view addSubview:phontField];
    self.phoneField = phontField;
    [phontField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(phone.mas_centerY);
        make.left.mas_equalTo(phone.mas_right).mas_offset(37);
        make.width.mas_equalTo(150);
        make.height.mas_equalTo(40);
    }];
    
    //本地电话号码
    UserInfo *userInfo = [UserInfo read];
    NSString *phonenumber = userInfo.uphone;
    if (phonenumber.length) {
        phontField.text = phonenumber;
    }
    
    UIView *separtor1 = [[UIView alloc] init];
    separtor1.backgroundColor = SEPARTORCOLOR;
    [self.view addSubview:separtor1];
    [separtor1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(phone.mas_bottom).mas_offset(16);
        make.left.mas_equalTo(15);
        make.height.mas_equalTo(1);
        make.right.mas_equalTo(-15);
    }];
    
    UILabel *verCode = [[UILabel alloc] init];
    verCode.text = @"密码";
    verCode.textColor = BLACKCOLOR;
    verCode.font = MAINFONT;
    [self.view addSubview:verCode];
    [verCode mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.top.mas_equalTo(separtor1.mas_bottom).mas_offset(16);
    }];
    
    UITextField *verField = [[UITextField alloc] init];
    verField.placeholder = @"请输入密码";
    verField.secureTextEntry = YES;
    verField.keyboardType = UIKeyboardTypeDefault;
    verField.font = MAINFONT;
    [self.view addSubview:verField];
    self.passField = verField;
    [verField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(verCode.mas_centerY);
        make.left.mas_equalTo(self.phoneField.mas_left);
        make.width.mas_equalTo(150);
        make.height.mas_equalTo(40);
    }];
    
    UIView *separtor2 = [[UIView alloc] init];
    separtor2.backgroundColor = SEPARTORCOLOR;
    [self.view addSubview:separtor2];
    [separtor2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(verCode.mas_bottom).mas_offset(16);
        make.left.mas_equalTo(15);
        make.height.mas_equalTo(1);
        make.right.mas_equalTo(-15);
    }];
    
    UIButton *submitBtn = [[UIButton alloc] init];
    submitBtn.backgroundColor = THEMECOLOR;
    submitBtn.layer.cornerRadius = 5.f;
    [submitBtn setTitle:@"登录" forState:UIControlStateNormal];
    [submitBtn setTintColor:WHITECOLOR];
    submitBtn.titleLabel.font = MAINFONT;
    [submitBtn addTarget:self action:@selector(loginAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:submitBtn];
    [submitBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.right.mas_equalTo(-15);
        make.height.mas_equalTo(48);
        make.top.mas_equalTo(separtor2.mas_bottom).mas_offset(20);
    }];
}


//登录
- (void)loginAction{
    [self.view endEditing:YES];

    [LCProgressHUD showLoadingText:LODINGTEXT];
    [LGNetWorking loginWithPhone:self.phoneField.text password:self.passField.text success:^(ResponseData *responseData) {
        if (responseData.code == 0) {
            //登录成功
            [LCProgressHUD hide];
            UserInfo *userInfo = [UserInfo mj_objectWithKeyValues:responseData.data];
            userInfo.hasLogin = YES;
            [userInfo save];
            [[NSNotificationCenter defaultCenter] postNotificationName:LOGIN_SUCCESS object:nil];
        }else{
            [LCProgressHUD showFailureText:responseData.msg];
        }
    } failure:^(ErrorData *error) {
        [LCProgressHUD showFailureText:error.msg];
    }];
}

//忘记密码
- (void)navRightBtnAction{
    LGRessetPassController *vc = [[LGRessetPassController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
