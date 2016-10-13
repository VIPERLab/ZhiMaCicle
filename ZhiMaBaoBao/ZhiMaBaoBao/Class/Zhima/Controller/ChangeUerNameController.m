//
//  ChangeUerNameController.m
//  ZhiMaBaoBao
//
//  Created by mac on 16/9/21.
//  Copyright © 2016年 liugang. All rights reserved.
//

#import "ChangeUerNameController.h"

@interface ChangeUerNameController ()
@property (nonatomic, weak) UITextField *textField;
@end

@implementation ChangeUerNameController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setCustomTitle:@"修改昵称"];
    [self setupNav];
    [self setupView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupNav {
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStylePlain target:self action:@selector(saveButtonDidClick)];
}

- (void)setupView {
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake( 0 , 64 + 20, ScreenWidth, 40)];
    view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:view];
    
    
    UITextField *textField = [[UITextField alloc] init];
    textField.frame = CGRectMake( 10 , 0, ScreenWidth - 20 , 40);
    textField.text = USERINFO.username;
    textField.placeholder = @"请输入你的昵称";
    textField.backgroundColor = [UIColor whiteColor];
    textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    [view addSubview:textField];
    self.textField = textField;
    
}

- (void)saveButtonDidClick {
    [self.textField resignFirstResponder];
    [LCProgressHUD showText:@"正在修改昵称"];
    [LGNetWorking upLoadUserDataWithSessionID:USERINFO.sessionId andOpenFirAccount:USERINFO.userID andFunctionName:@"username" andChangeValue:self.textField.text block:^(ResponseData *responseData) {
        [LCProgressHUD hide];
        if (responseData.code != 0) {
            [LCProgressHUD showFailureText:@"请检查网络"];
            return ;
        }
        
        UserInfo *info = [UserInfo read];
        info.username = self.textField.text;
        [info save];
        [LCProgressHUD showSuccessText:@"修改成功"];
//        [[SocketManager shareInstance] updateProfile];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [LCProgressHUD hide];
            [self.navigationController popViewControllerAnimated:YES];
        });
        
        
    }];
}

- (void)viewDidAppear:(BOOL)animated {
    [self.textField becomeFirstResponder];
}

@end
