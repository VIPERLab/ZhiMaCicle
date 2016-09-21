//
//  ModifySignController.m
//  ZhiMaBaoBao
//
//  Created by mac on 16/9/21.
//  Copyright © 2016年 liugang. All rights reserved.
//

#import "ModifySignController.h"

@interface ModifySignController ()
@property (nonatomic, weak) UITextView *textView;
@end

@implementation ModifySignController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setCustomTitle:@"修改个性签名"];
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
    
    UITextView *textView = [[UITextView alloc] init];
    [self.view addSubview:textView];
    textView.frame = CGRectMake( 10 , 64 + 20, ScreenWidth - 20, 70);
    textView.text = USERINFO.signature;
    textView.layer.borderColor = [UIColor colorFormHexRGB:@"dedede"].CGColor;
    textView.layer.borderWidth = 0.5;
    textView.layer.cornerRadius = 5;
    textView.font = [UIFont systemFontOfSize:15];
    self.textView = textView;
    
    UILabel *tipsLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(textView.frame) + 3 , ScreenWidth - 20, 30)];
    [self.view addSubview:tipsLabel];
    tipsLabel.text = @"独享的自我个性";
    tipsLabel.font = [UIFont systemFontOfSize:13];
    
}


- (void)saveButtonDidClick {
    
    [LGNetWorking upLoadUserDataWithSessionID:USERINFO.sessionId andOpenFirAccount:USERINFO.openfireaccount andFunctionName:@"signature" andChangeValue:self.textView.text block:^(ResponseData *responseData) {
        if (responseData.code != 0) {
            [LCProgressHUD showFailureText:@"请检查网络"];
            return ;
        }
//        USERINFO.signature = self.textField.text;
        [LCProgressHUD showInfoText:@"修改成功"];
        [self.navigationController popViewControllerAnimated:YES];
    }];
}

@end
