//
//  ModifySignController.m
//  ZhiMaBaoBao
//
//  Created by mac on 16/9/21.
//  Copyright © 2016年 liugang. All rights reserved.
//

#import "ModifySignController.h"

#define MaxCount 30

@interface ModifySignController () <UITextViewDelegate>
@property (nonatomic, weak) UITextView *textView;
@property (nonatomic, weak) UILabel *countLabel;
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
    self.textView.delegate = self;
    
    
    UILabel *countLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(textView.frame) - 50, CGRectGetHeight(textView.frame) - 30, 50, 30)];
    self.countLabel = countLabel;
    countLabel.text = [NSString stringWithFormat:@"%zd",MaxCount - textView.text.length];
    countLabel.textColor = [UIColor lightGrayColor];
    countLabel.font = [UIFont systemFontOfSize:16];
    [textView addSubview:countLabel];
}


- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    //判断加上输入的字符，是否超过界限
    NSString *str = [NSString stringWithFormat:@"%@%@", textView.text, text];
    if (str.length > MaxCount) {
        textView.text = [str substringToIndex:MaxCount];
        return NO;
    }
    _countLabel.text = [NSString stringWithFormat:@"%zd",MaxCount - str.length];
    return YES;
}


- (void)saveButtonDidClick {
    [LCProgressHUD showText:@"正在更改个性签名"];
    [LGNetWorking upLoadUserDataWithSessionID:USERINFO.sessionId andOpenFirAccount:USERINFO.userID andFunctionName:@"signature" andChangeValue:self.textView.text block:^(ResponseData *responseData) {
        [LCProgressHUD hide];
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
