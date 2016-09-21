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
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStylePlain target:self action:@selector(saveButtonDidClick)];
}

- (void)setupView {
    
    UITextField *textField = [[UITextField alloc] init];
    [self.view addSubview:textField];
    textField.borderStyle = UITextBorderStyleRoundedRect;
    textField.frame = CGRectMake( 10 , 64 + 20, ScreenWidth - 20, 30);
    textField.text = USERINFO.username;
    textField.placeholder = @"请输入你的昵称";
    self.textField = textField;
    
    UILabel *tipsLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(textField.frame) + 3 , ScreenWidth - 20, 30)];
    [self.view addSubview:tipsLabel];
    tipsLabel.text = @"好的名字可以让你的朋友更容易记住你";
    tipsLabel.font = [UIFont systemFontOfSize:13];
    
}

- (void)saveButtonDidClick {
    
    [LGNetWorking upLoadUserDataWithSessionID:USERINFO.sessionId andOpenFirAccount:USERINFO.openfireaccount andFunctionName:@"username" andChangeValue:self.textField.text block:^(ResponseData *responseData) {
        
        if (responseData.code != 0) {
            [LCProgressHUD showFailureText:@"请检查网络"];
            return ;
        }
        
        UserInfo *info = [UserInfo read];
        info.username = self.textField.text;
        [info save];
        [self.navigationController popViewControllerAnimated:YES];
        
    }];
}

@end
