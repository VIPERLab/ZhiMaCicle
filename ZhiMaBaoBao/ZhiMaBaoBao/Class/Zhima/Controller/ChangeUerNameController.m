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
    [LCProgressHUD showLoadingText:@"正在修改昵称"];
    if (!self.textField.hasText) {
        [LCProgressHUD showFailureText:@"昵称不能为空"];
        return;
    }
    [LGNetWorking upLoadUserDataWithSessionID:USERINFO.sessionId andOpenFirAccount:USERINFO.userID andFunctionName:@"username" andChangeValue:self.textField.text success:^(ResponseData *responseData) {
        if (responseData.code != 0) {
            [LCProgressHUD showFailureText:@"暂不支持表情符号"];
            return ;
        }
        
        UserInfo *info = [UserInfo read];
        info.username = self.textField.text;
        [info save];
        [LCProgressHUD showSuccessText:@"修改成功"];
        
        [self.navigationController popViewControllerAnimated:YES];

    } failure:^(ErrorData *error) {
        [LCProgressHUD showFailureText:@"修改失败"];
    } ];
}

- (void)viewDidAppear:(BOOL)animated {
    [self.textField becomeFirstResponder];
}

@end
