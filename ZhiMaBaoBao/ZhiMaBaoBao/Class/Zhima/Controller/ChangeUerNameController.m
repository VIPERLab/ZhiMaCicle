//
//  ChangeUerNameController.m
//  ZhiMaBaoBao
//
//  Created by mac on 16/9/21.
//  Copyright © 2016年 liugang. All rights reserved.
//

#import "ChangeUerNameController.h"

@interface ChangeUerNameController () <UITextFieldDelegate>
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

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    //判断加上输入的字符，是否超过界限
    NSString *textStr = textField.text;
    NSString *copyStr = [textField.text substringWithRange:range];
    if ([copyStr isEqualToString:@""]) {
        copyStr = [textStr stringByAppendingString:string];
    } else {
        copyStr = [textStr substringWithRange:NSMakeRange(0, range.location)];
    }
    
    
    if (copyStr.length > 20) {
        return NO;
    }
    return YES;
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
    textField.delegate = self;
    [view addSubview:textField];
    self.textField = textField;
    
}

- (void)saveButtonDidClick {
    [self.textField resignFirstResponder];
    [LCProgressHUD showLoadingText:@"正在修改昵称"];
    
    NSString *tempString = self.textField.text;
    if ([tempString isBlankString]) {
        [LCProgressHUD showFailureText:@"昵称不能为空"];
        return;
    }
    NSCharacterSet *doNotWant = [NSCharacterSet characterSetWithCharactersInString:@"[]{}（#%-*+=_）\\|~(＜＞$%^&*)_+ "];
    tempString = [[tempString componentsSeparatedByCharactersInSet:doNotWant] componentsJoinedByString: @""];
    if (!tempString.length) {
        [LCProgressHUD showFailureText:@"昵称不能为空"];
        return;
    }
    
    [LGNetWorking upLoadUserDataWithSessionID:USERINFO.sessionId andOpenFirAccount:USERINFO.userID andFunctionName:@"username" andChangeValue:tempString success:^(ResponseData *responseData) {
        if (responseData.code != 0) {
            [LCProgressHUD showFailureText:responseData.msg];
            return ;
        }
        
        UserInfo *info = [UserInfo read];
        info.username = tempString;
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
