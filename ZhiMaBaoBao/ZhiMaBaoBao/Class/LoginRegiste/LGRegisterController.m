//
//  LGRegisterController.m
//  YiIM_iOS
//
//  Created by liugang on 16/8/5.
//  Copyright © 2016年 ikantech. All rights reserved.
//

#import "LGRegisterController.h"
#import "LGSetPasswordController.h"
#import "RegexKitLite.h"

//#import "KXWebViewController.h"
@interface LGRegisterController ()

@property (nonatomic, strong) UITextField *phoneField;
@property (nonatomic, strong) UITextField *VerField;
@property (nonatomic, strong) UIButton *getCodeBtn;

@property (nonatomic, copy) NSString *phoneNumber;
@property (nonatomic, copy) NSString *VerCode;

@end

@implementation LGRegisterController

- (void)viewDidLoad{
    [super viewDidLoad];
    [self setUI];
}

- (void)setUI{
    
    UILabel *prompt = [[UILabel alloc] init];
    prompt.text = @"请输入你的手机号码";
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
    verCode.text = @"验证码";
    verCode.textColor = BLACKCOLOR;
    verCode.font = MAINFONT;
    [self.view addSubview:verCode];
    [verCode mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.top.mas_equalTo(separtor1.mas_bottom).mas_offset(16);
    }];
    
    UITextField *verField = [[UITextField alloc] init];
    verField.placeholder = @"请输入验证码";
    verField.keyboardType = UIKeyboardTypePhonePad;
    verField.font = MAINFONT;
    [self.view addSubview:verField];
    self.VerField = verField;
    [verField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(verCode.mas_centerY);
        make.left.mas_equalTo(verCode.mas_right).mas_offset(37);
        make.width.mas_equalTo(150);
        make.height.mas_equalTo(40);
    }];

    UIButton *getCodeBtn = [[UIButton alloc] init];
    [getCodeBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
    [getCodeBtn setTitleColor:THEMECOLOR forState:UIControlStateNormal];
    getCodeBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [self.view addSubview:getCodeBtn];
    self.getCodeBtn = getCodeBtn;
    [getCodeBtn addTarget:self action:@selector(getVerCodeAction) forControlEvents:UIControlEventTouchUpInside];
    [getCodeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(verCode.mas_centerY);
        make.width.mas_equalTo(80);
        make.height.mas_equalTo(30);
        make.right.mas_equalTo(-15);
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
    [submitBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.right.mas_equalTo(-15);
        make.height.mas_equalTo(48);
        make.top.mas_equalTo(separtor2.mas_bottom).mas_offset(20);
    }];
    
    
    UIButton *httpButton = [[UIButton alloc] init];
    [httpButton setTitle:@"《用户注册协议》" forState:UIControlStateNormal];
    [httpButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    httpButton.titleLabel.font = [UIFont systemFontOfSize:12];
    [self.view addSubview:httpButton];
    [httpButton addTarget:self action:@selector(httpButtonDidClick) forControlEvents:UIControlEventTouchUpInside];
    [httpButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view.mas_bottom).offset(-20);
        make.right.equalTo(self.view.mas_right);
        make.left.equalTo(self.view.mas_left);
        make.height.mas_equalTo(30);
    }];
    
    UILabel *tipsLabel = [[UILabel alloc] init];
    tipsLabel.text = @"点击上面的“注册”按钮，即表示你同意";
    tipsLabel.font = [UIFont systemFontOfSize:12];
    tipsLabel.textAlignment = NSTextAlignmentCenter;
    tipsLabel.textColor = [UIColor lightGrayColor];
    [self.view addSubview:tipsLabel];
    
    [tipsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(httpButton.mas_top).offset(5);
        make.left.equalTo(self.view.mas_left);
        make.right.equalTo(self.view.mas_right);
        make.height.mas_equalTo(20);
    }];
    
    
}
/**
 *  获取验证码点击方法
 */
- (void)getVerCodeAction{
    self.getCodeBtn.enabled = NO;
    [self.view endEditing:YES];
    
    //判断手机号是否正确
    if (self.phoneField.text.length <= 0)
    {
        [LCProgressHUD showText:@"请输入手机号"];
        self.getCodeBtn.enabled = YES;
        return;
    }
    
    if (![self.phoneField.text isMatchedByRegex:@"^(13|15|17|18|14)\\d{9}$"])
    {
        [LCProgressHUD showText:@"请输入正确的手机号码"];
        self.getCodeBtn.enabled = YES;
        return;
    }
    
    
    //获取注册验证码
    [LGNetWorking getCodeWithPhone:self.phoneField.text flag:@"reg" SuccessfulBlock:^(ResponseData *obj) {
        [LCProgressHUD showText:obj.msg];
        if (obj.code == 0) {
            NSLog(@"成功获取验证码");
            
            //倒计时
            //GCD定时器不受RunLoop约束，比NSTimer更加准时
            __block int timeout=60; //倒计时时间
            dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
            dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,queue);
            dispatch_source_set_timer(timer,dispatch_walltime(NULL, 0),1.0*NSEC_PER_SEC, 0); //每秒执行
            dispatch_source_set_event_handler(timer, ^{
                if(timeout<=0){ //倒计时结束，关闭
                    dispatch_source_cancel(timer);
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        [self.getCodeBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
                        [self.getCodeBtn setTitleColor:THEMECOLOR forState:UIControlStateNormal];
                        self.getCodeBtn.userInteractionEnabled = YES;
                        self.getCodeBtn.enabled = YES;

                    });
                }else{
                    
                    int seconds = timeout;
                    NSString *strTime = [NSString stringWithFormat:@"%.2ds", seconds];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.getCodeBtn setTitle:strTime forState:UIControlStateNormal];
                        [self.getCodeBtn setTitleColor:GRAYCOLOR forState:UIControlStateNormal];
                        self.getCodeBtn.userInteractionEnabled = NO;
                        self.getCodeBtn.enabled = NO;

                    });
                    timeout--;
                }
            });
            dispatch_resume(timer);
            
            //储存验证码
            self.VerCode = [obj.data objectForKey:@"verifycode"];
        }else{
            self.getCodeBtn.enabled = NO;

        }
    }];

}
/**
 *  注册
 */
- (void)registerAction{

    [self.view endEditing:YES];
    
    if (self.phoneField.text.length <= 0)
    {
        [LCProgressHUD showText:@"请输入手机号码"];
        return;
    }
    
    if (![self.phoneField.text isMatchedByRegex:@"^(13|15|17|18|14)\\d{9}$"])
    {
        [LCProgressHUD showText:@"请输入正确的手机号码"];
        return;
    }


    if (![self.VerField hasText]) {
        [LCProgressHUD showText:@"请输入短信验证码"];
        return;
    }
    
    //对比验证码
    [LGNetWorking checkVerCode:self.phoneField.text verCode:self.VerField.text block:^(ResponseData *obj) {
        if (obj.code == 0) {
            //验证成功 - 存电话号码 - 跳转
            self.phoneNumber = self.phoneField.text;
            LGSetPasswordController *vc = [[LGSetPasswordController alloc] init];
            vc.phoneNumber = self.phoneNumber;
            vc.VerCode = self.VerCode;
            [self.navigationController pushViewController:vc animated:YES];
        }else{
            [LCProgressHUD showText:obj.msg];

        }
    }];
}


#pragma mark - 跳转用户注册协议
- (void)httpButtonDidClick {
//    KXWebViewController *webVC = [[KXWebViewController alloc] init];
//    webVC.navTitleName = @"用户注册协议";
//    webVC.htmlURL = [NSString stringWithFormat:@"%@/agreement_user.html",DFAPIURL];
//    [self.navigationController pushViewController:webVC animated:YES];
}
@end
