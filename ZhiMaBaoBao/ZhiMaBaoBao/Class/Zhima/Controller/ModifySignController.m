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
    [self setCustomTitle:@"个性签名"];
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self setupNav];
    [self setupView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    self.automaticallyAdjustsScrollViewInsets = YES;
}

- (void)setupNav {
    self.view.backgroundColor = [UIColor colorFormHexRGB:@"efeff4"];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStylePlain target:self action:@selector(saveButtonDidClick)];
}


- (void)setupView {
    
    UITextView *textView = [[UITextView alloc] init];
    textView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:textView];
    textView.frame = CGRectMake( 0 , 64 + 20, ScreenWidth, 70);
    textView.text = USERINFO.signature;
    textView.layer.borderColor = [UIColor colorFormHexRGB:@"dedede"].CGColor;
    textView.layer.borderWidth = 0.5;
    textView.font = [UIFont systemFontOfSize:15];
    self.textView = textView;
    
}


- (void)saveButtonDidClick {
    
    [LGNetWorking upLoadUserDataWithSessionID:USERINFO.sessionId andOpenFirAccount:USERINFO.userID andFunctionName:@"signature" andChangeValue:self.textView.text block:^(ResponseData *responseData) {
        if (responseData.code != 0) {
            [LCProgressHUD showFailureText:@"请检查网络"];
            return ;
        }
        UserInfo *info = [UserInfo read];
        
        info.signature = self.textView.text;
        [info save];
        [LCProgressHUD showInfoText:@"修改成功"];
        [self.navigationController popViewControllerAnimated:YES];
    }];
}

@end
