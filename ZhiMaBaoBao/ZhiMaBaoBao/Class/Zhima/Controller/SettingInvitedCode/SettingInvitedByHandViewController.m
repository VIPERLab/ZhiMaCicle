//
//  SettingInvitedByHandViewController.m
//  YiIM_iOS
//
//  Created by mac on 16/9/19.
//  Copyright © 2016年 ikantech. All rights reserved.
//

#import "SettingInvitedByHandViewController.h"
#import "LCProgressHUD.h"
#import "KXPersonalMessageSettingController.h"

@interface SettingInvitedByHandViewController ()

@property (nonatomic, weak) UITextField *textField;

@end

@implementation SettingInvitedByHandViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setCustomTitle:@"绑定"];
    [self setView];
}

- (void)setView {
    self.view.backgroundColor = [UIColor colorFormHexRGB:@"efeff4"];
    
    if ([self.invitedCode isEqualToString:@""]) {
        
    }
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(30, 64 + 20, ScreenWidth - 60, 30)];
    label.textAlignment = NSTextAlignmentLeft;
    label.font = [UIFont systemFontOfSize:16];
    label.textColor = [UIColor lightGrayColor];
    [self.view addSubview:label];
    
    UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(30, CGRectGetMaxY(label.frame) + 10, [UIScreen mainScreen].bounds.size.width - 60, 50)];
    self.textField = textField;
    [self.view addSubview:textField];
    textField.borderStyle = UITextBorderStyleRoundedRect;
    textField.textAlignment = NSTextAlignmentCenter;
    textField.font = [UIFont boldSystemFontOfSize:25];
    textField.textColor = [UIColor blackColor];
    textField.text = self.invitedCode;
    textField.keyboardType = UIKeyboardTypeNumberPad;
    
    if ([self.invitedCode isEqualToString:@""]) {
        label.text = @"请输入邀请码";
        textField.userInteractionEnabled = YES;
    }
    
    UIButton *commitButton = [[UIButton alloc] initWithFrame:CGRectMake(30, CGRectGetMaxY(textField.frame) + 20, [UIScreen mainScreen].bounds.size.width - 60, 45)];
    [commitButton setTitle:@"去绑定" forState:UIControlStateNormal];
    [commitButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [commitButton setBackgroundColor:THEMECOLOR];
    commitButton.layer.cornerRadius = 5;
    
    [commitButton addTarget:self action:@selector(commitButtonDidClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:commitButton];
    
    
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}


- (void)commitButtonDidClick {
    [self.textField resignFirstResponder];
    if ([self.textField.text isEqualToString:@""]) {
        [LCProgressHUD showFailureText:@"请输入邀请码"];
        return;
    }
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer.timeoutInterval = 15.f;
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html",@"application/json",nil];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"sessionId"] = USERINFO.sessionId;
    params[@"invite_code"] = self.textField.text;
    
    [manager POST:[NSString stringWithFormat:@"%@/moblie/setInviter.do",DFAPIURL] parameters:params progress:0 success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        ResponseData *data = [ResponseData mj_objectWithKeyValues:responseObject];
        if (data.code != 0) {
            [LCProgressHUD showFailureText:data.msg];
            return ;
        }
        
        [LCProgressHUD showSuccessText:@"设置成功"];
        USERINFO.is_self_reg = 0;
        
        for (UIViewController *vc in self.navigationController.viewControllers) {
            if ([vc isKindOfClass:[KXPersonalMessageSettingController class]]) {
                [self.navigationController popToViewController:vc animated:YES];
            }
        }
        
        
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
