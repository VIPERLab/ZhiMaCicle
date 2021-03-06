//
//  LGSetPasswordController.m
//  YiIM_iOS
//
//  Created by liugang on 16/8/5.
//  Copyright © 2016年 ikantech. All rights reserved.
//

#import "LGSetPasswordController.h"
#import "LGSetNickNameController.h"
#import "RegexKitLite.h"
#import "JPUSHService.h"
@interface LGSetPasswordController ()

@property (nonatomic, strong) UITextField *passField;
@property (nonatomic, strong) UITextField *confirmPassField;
@property (nonatomic, strong) UIButton *registerBtn;

@end

@implementation LGSetPasswordController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setUI];
}

- (void)setUI{
    self.view.backgroundColor = WHITECOLOR;
    
    UILabel *prompt = [[UILabel alloc] init];
    prompt.text = @"请设置你的帐号密码";
    prompt.textColor = BLACKCOLOR;
    prompt.font = [UIFont systemFontOfSize:17];
    [self.view addSubview:prompt];
    [prompt mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.view);
        make.top.mas_equalTo(100);
    }];
    
    UILabel *phone = [[UILabel alloc] init];
    phone.text = @"密码";
    phone.textColor = BLACKCOLOR;
    phone.font = MAINFONT;
    [self.view addSubview:phone];
    [phone mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.top.mas_equalTo(prompt.mas_bottom).mas_offset(53);
    }];
    
    UITextField *phontField = [[UITextField alloc] init];
    phontField.placeholder = @"请输入密码";
    phontField.keyboardType = UIKeyboardTypeDefault;
    phontField.font = MAINFONT;
    phontField.secureTextEntry = YES;
    [self.view addSubview:phontField];
    self.passField = phontField;
    [phontField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(phone.mas_centerY);
        make.left.mas_equalTo(phone.mas_right).mas_offset(53);
        make.width.mas_equalTo(150);
        make.height.mas_equalTo(40);
    }];
    
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
    verCode.text = @"确认密码";
    verCode.textColor = BLACKCOLOR;
    verCode.font = MAINFONT;
    [self.view addSubview:verCode];
    [verCode mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.top.mas_equalTo(separtor1.mas_bottom).mas_offset(16);
    }];
    
    UITextField *verField = [[UITextField alloc] init];
    verField.placeholder = @"请再次输入密码";
    verField.font = MAINFONT;
    verField.secureTextEntry = YES;
    [self.view addSubview:verField];
    self.confirmPassField = verField;
    [verField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(verCode.mas_centerY);
        make.left.mas_equalTo(self.passField.mas_left);
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
    [submitBtn setTitle:@"注册" forState:UIControlStateNormal];
    [submitBtn setTintColor:WHITECOLOR];
    submitBtn.titleLabel.font = MAINFONT;
    [submitBtn addTarget:self action:@selector(registerAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:submitBtn];
    self.registerBtn = submitBtn;
    [submitBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.right.mas_equalTo(-15);
        make.height.mas_equalTo(48);
        make.top.mas_equalTo(separtor2.mas_bottom).mas_offset(20);
    }];
    
}
/**
 *  注册
 */
- (void)registerAction{
    [self.view endEditing:YES];
    
    if (![self.passField.text isMatchedByRegex:@"^(?![0-9]+$)(?![a-zA-Z]+$)[0-9A-Za-z]{6,18}$"]) {
        [LCProgressHUD showFailureText:@"请输入数字和字母组成的密码"];
        return;
    }
    
    if (self.passField.text.length < 6 || self.passField.text.length > 18) {
        [LCProgressHUD showFailureText:@"请输入6-18位密码"];
        return;
    }
    
    if (!self.passField.hasText) {
        [LCProgressHUD showFailureText:@"请输入密码"];
        return;
    }
    if (!self.confirmPassField.hasText) {
        [LCProgressHUD showFailureText:@"请再次输入密码"];

        return;
    }
    if (![self.passField.text isEqualToString:self.confirmPassField.text]) {
        [LCProgressHUD showFailureText:@"密码输入不一致"];
        return;
    }
    
    //注册
    [LGNetWorking registerWithPhone:self.phoneNumber verCode:self.VerCode passWord:self.passField.text SuccessfulBlock:^(ResponseData *obj) {
        if (obj.code == 0) {
            //存储用户资料
            
            UserInfo *userInfo = [UserInfo mj_objectWithKeyValues:obj.data];
            
            if ([userInfo.area isEqualToString:@""] || userInfo.area == nil) {
                userInfo.area = @"";
            }
            
            
            // 旧的数据
            UserInfo *oldInfo = [UserInfo read];
            userInfo.isVisitor = oldInfo.isVisitor;
            
            if ([userInfo.userID isEqualToString:oldInfo.userID]) {
                // 有旧数据
                userInfo.newMessageVoiceNotify = oldInfo.newMessageVoiceNotify;
                userInfo.newMessageShakeNotify = oldInfo.newMessageShakeNotify;
                userInfo.newMessageNotify = oldInfo.newMessageNotify;
            } else {
                // 无旧数据 -  默认打开
                userInfo.newMessageNotify = YES;
                userInfo.newMessageShakeNotify = YES;
                userInfo.newMessageVoiceNotify = YES;
            }
            
            [JPUSHService setTags:[NSSet setWithObject:userInfo.userID] alias:userInfo.userID callbackSelector:nil object:nil];
            [userInfo save];

            
            LGSetNickNameController *vc = [[LGSetNickNameController alloc] init];
            vc.phoneNumber = self.phoneNumber;
            vc.password    = self.passField.text;
            [self.navigationController pushViewController:vc animated:YES];
        }else{
            [LCProgressHUD showFailureText:obj.msg];
        }
    }];
    
}



@end
