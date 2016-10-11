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
    
    [self setView];
}

- (void)setView {
    self.view.backgroundColor = [UIColor colorFormHexRGB:@"efeff4"];
    
    if ([self.invitedCode isEqualToString:@""]) {
        [self setCustomTitle:@"绑定"];
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
        
    } else {
        [self setCustomTitle:@"确认"];
        CGFloat tickWidth = 100;
        UIImageView *tickIcon = [[UIImageView alloc] initWithFrame:CGRectMake((ScreenWidth - tickWidth) * 0.5, 64 + 100, tickWidth, tickWidth)];
        tickIcon.image = [UIImage imageNamed:@"comfirTick"];
        [self.view addSubview:tickIcon];
        
        UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(30, CGRectGetMaxY(tickIcon.frame) + 25, [UIScreen mainScreen].bounds.size.width - 60, 50)];
        self.textField = textField;
        [self.view addSubview:textField];
        textField.textAlignment = NSTextAlignmentCenter;
        textField.font = [UIFont boldSystemFontOfSize:17];
        textField.textColor = [UIColor blackColor];
        textField.text = [NSString stringWithFormat:@"是否确认绑定邀请码：%@",self.invitedCode];
        textField.userInteractionEnabled = NO;
        textField.backgroundColor = [UIColor clearColor];
        
        
        UIButton *commitButton = [[UIButton alloc] initWithFrame:CGRectMake(30, CGRectGetMaxY(textField.frame) + 20, [UIScreen mainScreen].bounds.size.width - 60, 45)];
        [commitButton setTitle:@"确认绑定" forState:UIControlStateNormal];
        [commitButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [commitButton setBackgroundColor:THEMECOLOR];
        commitButton.layer.cornerRadius = 5;
        
        [commitButton addTarget:self action:@selector(commitButtonDidClick) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:commitButton];
        
        
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [self.textField becomeFirstResponder];
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
    [LCProgressHUD showText:@"正在设置正在设置邀请码"];
    [manager POST:[NSString stringWithFormat:@"%@/moblie/setInviter.do",DFAPIURL] parameters:params progress:0 success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [LCProgressHUD hide];
        ResponseData *data = [ResponseData mj_objectWithKeyValues:responseObject];
        if (data.code != 0) {
            [LCProgressHUD showFailureText:data.msg];
            return ;
        }
        
        [LCProgressHUD showSuccessText:@"设置成功"];
        UserInfo *info = [UserInfo read];
        info.is_self_reg = 0;
        info.invite_code = self.textField.text;
        [info save];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            for (UIViewController *vc in self.navigationController.viewControllers) {
                if ([vc isKindOfClass:[KXPersonalMessageSettingController class]]) {
                    [self.navigationController popToViewController:vc animated:YES];
                }
            }
        });
        
        
        
        
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
