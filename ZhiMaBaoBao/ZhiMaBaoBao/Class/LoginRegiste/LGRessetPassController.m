//
//  LGRessetPassController.m
//  YiIM_iOS
//
//  Created by liugang on 16/8/8.
//  Copyright © 2016年 ikantech. All rights reserved.
//

#import "LGRessetPassController.h"
#import "RegexKitLite.h"

@interface LGRessetPassController ()

@property (weak, nonatomic) IBOutlet UITextField *account;
@property (weak, nonatomic) IBOutlet UITextField *password;
@property (weak, nonatomic) IBOutlet UITextField *againPassword;


@property (weak, nonatomic) IBOutlet UITextField *verCodeField;
@property (weak, nonatomic) IBOutlet UIButton *codeBtn;

@property (nonatomic, strong) UIButton *getCodeBtn;

@property (weak, nonatomic) IBOutlet UIView *separtor;
//验证码
@property (nonatomic, copy) NSString *verCodeStr;
@end

@implementation LGRessetPassController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setNavTitle:@"重置密码"];
    [self setNavRightButton:@"确定"];
    
    [self.codeBtn removeFromSuperview];
    
    UIButton *getCodeBtn = [[UIButton alloc] init];
    [getCodeBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
    [getCodeBtn setTitleColor:THEMECOLOR forState:UIControlStateNormal];
    getCodeBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    getCodeBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [getCodeBtn setFrame:CGRectMake(DEVICEWITH - 100 - 14, 245 + 10, 100, 30)];
    [self.view addSubview:getCodeBtn];
    self.getCodeBtn = getCodeBtn;
    [getCodeBtn addTarget:self action:@selector(verCodeBtnCation:) forControlEvents:UIControlEventTouchUpInside];
    
}

- (void)navRightBtnAction{
    
    if (!self.account.hasText) {
        [LCProgressHUD showFailureText:@"请输入帐号"];
        return;
    }
    
    if (!self.password.hasText) {
        [LCProgressHUD showFailureText:@"请输入新密码"];
        return;
    }
    if (!self.againPassword.hasText) {
        [LCProgressHUD showFailureText:@"请再次输入新密码"];
        return;
    }
    
    if (![self.password.text isEqualToString:self.againPassword.text]) {
        [LCProgressHUD showFailureText:@"两次输入密码不一致"];
        return;
    }
    
    if (![self.password.text isMatchedByRegex:@"^(?![0-9]+$)(?![a-zA-Z]+$)[0-9A-Za-z]{6,18}$"]) {
        [LCProgressHUD showFailureText:@"请输入6-18位数字和字母组成的密码"];
        return;
    }
    
    if (self.password.text.length < 6 || self.password.text.length > 18) {
        [LCProgressHUD showFailureText:@"请输入6-18位数字和字母组成的密码"];
        return;
    }

    
    
    //重置密码
    [LGNetWorking forgetPassword:self.account.text verCode:self.verCodeField.text password:self.againPassword.text block:^(ResponseData *obj) {
        if (obj.code == 0) {
            //储存新密码

            [LCProgressHUD showSuccessText:@"修改成功"];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                //跳回到登录页面
                [self.navigationController popViewControllerAnimated:YES];
            });
            
        }else{
            [LCProgressHUD showFailureText:obj.msg];

        }
    }];
}
/**
 *  点击获取验证码
 *
 *  @param sender
 */
- (IBAction)verCodeBtnCation:(UIButton *)sender {
    
    [self.view endEditing:YES];
    
    //判断手机号是否正确
    if (self.account.text.length <= 0)
    {
        [LCProgressHUD showFailureText:@"请输入手机号码"];
        return;
    }
    
    if (![self.account.text isMatchedByRegex:@"^(13|15|17|18|14)\\d{9}$"])
    {
        [LCProgressHUD showFailureText:@"请输入正确的手机号码"];
        return;
    }
    
    
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
                
            });
        }else{
            
            int seconds = timeout;
            NSString *strTime = [NSString stringWithFormat:@"%.2ds", seconds];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.getCodeBtn setTitle:strTime forState:UIControlStateNormal];
                [self.getCodeBtn setTitleColor:GRAYCOLOR forState:UIControlStateNormal];
                self.getCodeBtn.userInteractionEnabled = NO;
            });
            timeout--;
        }
    });
    dispatch_resume(timer);
    
    //获取注册验证码
    [LGNetWorking getCodeWithPhone:self.account.text flag:@"forget" SuccessfulBlock:^(ResponseData *obj) {
        if (obj.code == 0) {
            [LCProgressHUD showSuccessText:obj.msg];
            NSLog(@"成功获取验证码");
            //储存验证码
            self.verCodeStr = [obj.data objectForKey:@"verifycode"];
        }else{
            [LCProgressHUD showFailureText:obj.msg];

        }
    }];

}

@end
