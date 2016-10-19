//
//  LGFeedBackViewController.m
//  YiIM_iOS
//
//  Created by liugang on 16/8/20.
//  Copyright © 2016年 ikantech. All rights reserved.
//

#import "LGFeedBackViewController.h"

@interface LGFeedBackViewController ()<UITextViewDelegate>

@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, strong) UILabel *pLabel;
//@property (nonatomic, copy) NSString *examineText;

@end

@implementation LGFeedBackViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setCustomTitle:@"意见反馈"];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = BGCOLOR;
    [self addAllViews];
    
    // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated {
    [self.textView becomeFirstResponder];
}

- (void)addAllViews
{
    UITextView *textView = [[UITextView alloc]initWithFrame:CGRectMake(7, 74, DEVICEWITH - 14, 200)];
    textView.delegate = self;
    textView.backgroundColor = [UIColor whiteColor];
    
    textView.layer.borderWidth = 1;
    textView.layer.borderColor = [UIColor colorFormHexRGB:@"e1e1e1"].CGColor;
    [textView.layer setMasksToBounds:YES];
    textView.font = MAINFONT;
    
    [self.view addSubview:textView];
    self.textView = textView;
    
    UIButton *subBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    subBtn.frame = CGRectMake(CGRectGetMinX(textView.frame), CGRectGetMaxY(textView.frame) + 18, CGRectGetWidth(textView.frame), 50);
    [subBtn setTitle:@"提交" forState:UIControlStateNormal];
    [subBtn setBackgroundColor:THEMECOLOR];
    subBtn.layer.masksToBounds = YES;
    subBtn.layer.cornerRadius = 5.0;
    [subBtn addTarget:self action:@selector(didClickedSubmit:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:subBtn];
    
    UILabel *uilabel = [[UILabel alloc]init];
    uilabel.frame =CGRectMake(8, 3, CGRectGetWidth(textView.frame), 25);
    uilabel.text = @"您的意见对我们是非常宝贵的....";
    uilabel.font = [UIFont systemFontOfSize:15];
    uilabel.textColor = [UIColor lightGrayColor];
    [self.textView addSubview:uilabel];
    self.pLabel = uilabel;
}

- (void)didClickedSubmit:(UIButton *)sender
{
    [self.textView resignFirstResponder];
    if (!self.textView.text.length) {
        [LCProgressHUD showFailureText:@"建议不能为空"];
        return;
    }
    [LCProgressHUD showLoadingText:@"正在提交"];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer.timeoutInterval = 30.0f;
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html",@"application/json",nil];
    
    NSString *url = [NSString stringWithFormat:@"%@/moblie/addsuggestion.do",DFAPIURL];
    
    NSMutableDictionary *parms = [NSMutableDictionary dictionary];
    parms[@"sessionId"] = USERINFO.sessionId;
    parms[@"content"] = self.textView.text;
    
    [manager POST:url parameters:parms progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        ResponseData *data = [ResponseData mj_objectWithKeyValues:responseObject];
        if (![data.msg containsString:@"成功"]) {
            [LCProgressHUD showFailureText:data.msg];
            return ;
        }
        
        [LCProgressHUD showSuccessText:data.msg];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [LCProgressHUD hide];
            [self.navigationController popViewControllerAnimated:YES];
        });
        
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
    
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    self.pLabel.hidden = YES;
}


- (void)textViewDidEndEditing:(UITextView *)textView {
    if ([textView.text isEqualToString:@""]) {
        self.pLabel.hidden = NO;
    } else {
        self.pLabel.hidden = YES;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)dealloc {
    self.automaticallyAdjustsScrollViewInsets = YES;
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
