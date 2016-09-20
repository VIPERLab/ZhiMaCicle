//
//  ChangeMoenySubController.m
//  YiIM_iOS
//
//  Created by mac on 16/8/27.
//  Copyright © 2016年 ikantech. All rights reserved.
//

#import "ChangeMoenySubController.h"
#import "ChangeMoneyCell.h"
#import "NSString+MD5.h"

#import "LCProgressHUD.h"
#import "MyAccountViewController.h"

#define changeMoenyCellReuserID @"changeMoenyCellReuserID"

@interface ChangeMoenySubController ()

@property (nonatomic, weak) UITextField *textField;
@property (nonatomic, weak) UILabel *subTileLabel;
@property (nonatomic, assign) BOOL isWeCheat;

@end

@implementation ChangeMoenySubController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setCustomTitle:@"提现"];
    [self setupView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self request];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupView {
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    UIView *view1 = [[UIView alloc] initWithFrame:CGRectMake(0, 30 + 64, [UIScreen mainScreen].bounds.size.width, 70)];
    view1.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:view1];
    
    CGFloat titleX = 10;
    CGFloat titleH = 30;
    CGFloat titleW = 60;
    CGFloat titleY =( CGRectGetHeight(view1.frame) - titleH )* 0.5;
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(titleX, titleY, titleW, titleH)];
    titleLabel.text = @"提现微信";
    titleLabel.font = [UIFont systemFontOfSize:15];
    [view1 addSubview:titleLabel];
    
    
    CGFloat subLabelX = CGRectGetMaxX(titleLabel.frame) + 20;
    CGFloat subLabelW = 200;
    CGFloat subLabelH = 40;
    CGFloat subLabelY = (CGRectGetHeight(view1.frame) - subLabelH )* 0.5 ;
    UILabel *subLabel = [[UILabel alloc] initWithFrame:CGRectMake(subLabelX, subLabelY, subLabelW, subLabelH)];
    subLabel.numberOfLines = 2;
    self.subTileLabel = subLabel;
    subLabel.textColor = [UIColor blueColor];
    subLabel.font = [UIFont systemFontOfSize:14];
    subLabel.text = @"请绑定微信公众号:";
    [view1 addSubview:subLabel];
    
    
    UIView *view2 = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(view1.frame), [UIScreen mainScreen].bounds.size.width, 50)];
    view2.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:view2];
    
    subLabelY = (CGRectGetHeight(view2.frame) - subLabelH) * 0.5;
    UILabel *titleLabel2 = [[UILabel alloc] initWithFrame:CGRectMake(titleX, subLabelY, titleW, subLabelH)];
    [view2 addSubview:titleLabel2];
    titleLabel2.text = @"金额(元)";
    titleLabel2.font = [UIFont systemFontOfSize:15];
    
    subLabelX = CGRectGetMaxX(titleLabel2.frame) + 20;
    subLabelY = (CGRectGetHeight(view2.frame) - subLabelH )* 0.5 ;
    UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(subLabelX, subLabelY, subLabelW, subLabelH)];
    self.textField = textField;
    [view2 addSubview:textField];
    textField.placeholder = @"请输入提现金额";
    textField.keyboardType = UIKeyboardTypeNumberPad;
    
    
    
    UIView *fooerView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(view2.frame), [UIScreen mainScreen].bounds.size.width, 100)];
    [self.view addSubview:fooerView];
    UIButton *nextButton = [[UIButton alloc] initWithFrame:CGRectMake(20, 50, [UIScreen mainScreen].bounds.size.width - 40, 40)];
    [nextButton setTitle:@"下一步" forState:UIControlStateNormal];
    [nextButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    nextButton.backgroundColor = THEMECOLOR;
    nextButton.layer.cornerRadius = 5;
    [nextButton addTarget:self action:@selector(nextButtonDidClick) forControlEvents:UIControlEventTouchUpInside];
    [fooerView addSubview:nextButton];
    
}

- (void)request {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer.timeoutInterval = 30.f;
    manager.securityPolicy = [AFSecurityPolicy defaultPolicy];
    manager.responseSerializer.acceptableContentTypes = nil;
    manager.securityPolicy.allowInvalidCertificates = YES;//忽略https证书
    manager.securityPolicy.validatesDomainName = NO;//是否验证域名
    //[NSSet setWithObjects:@"text/html",@"application/json",nil];
    NSString *sign = [NSString stringWithFormat:@"openfireaccount=%@&apikey=%@",USERINFO.openfireaccount,RECHAPPKEY];
    NSString *md5Sign = [NSString md5:sign];
    
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    param[@"openfireaccount"] = USERINFO.openfireaccount;
    param[@"sign"] = [md5Sign uppercaseString];
    
    [manager POST:@"http://120.76.239.173/Api/Index/chkwx" parameters:param progress:0 success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        if ([responseObject[@"code"] intValue] != 8888) {
//            [self showHint:responseObject[@"msg"]];
            [LCProgressHUD showFailureText:responseObject[@"msg"]];
            return ;
        }
        
        NSLog(@"%@",responseObject);
        
        int status = [responseObject[@"data"][@"status"] intValue];
        if (status == 0) {
            self.subTileLabel.text = [NSString stringWithFormat:@"请绑定微信公众号:%@",responseObject[@"data"][@"wx"]];
            self.isWeCheat = NO;
        } else if (status == 1) {
            self.subTileLabel.text = @"您已绑定公众号";
            self.isWeCheat = YES;
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
    
}




- (void)nextButtonDidClick {
    [self.textField resignFirstResponder];
    
    if (!self.isWeCheat) {
        [LCProgressHUD showFailureText:@"请先关注微信公众号并绑定芝麻号"];
        return;
    }
    
    if ([self.textField.text isEqualToString:@""]) {
        [LCProgressHUD showFailureText:@"请输入金额"];
        return;
    }
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer.timeoutInterval = 30.f;
    manager.responseSerializer.acceptableContentTypes = nil;//[NSSet setWithObject:@"text/plain"];
    manager.securityPolicy = [AFSecurityPolicy defaultPolicy];
    manager.securityPolicy.allowInvalidCertificates = YES;//忽略https证书
    manager.securityPolicy.validatesDomainName = NO;//是否验证域名
    
    NSString *sign = [NSString stringWithFormat:@"money=%@&openfireaccount=%@&apikey=%@",self.textField.text,USERINFO.openfireaccount,RECHAPPKEY];
    NSString *md5Sign = [NSString md5:sign];
    md5Sign = [md5Sign uppercaseString];
    
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    param[@"openfireaccount"] = USERINFO.openfireaccount;
    param[@"money"] = self.textField.text;
    param[@"sign"] = md5Sign;
    
    [manager POST:@"http://120.76.239.173/Api/Index/sendredbag" parameters:@"http://120.76.239.173/Api/Index/sendredbag" progress:0 success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        if ([responseObject[@"code"] intValue]!= 8888) {
            [LCProgressHUD showFailureText:responseObject[@"msg"]];
            return ;
        }
        
        [LCProgressHUD showSuccessText:responseObject[@"msg"]];
        
        for (UIViewController *controller in self.navigationController.viewControllers) {
            if ([controller isKindOfClass:[MyAccountViewController class]]) {
                [self.navigationController popToViewController:controller animated:YES];
                return;
            }
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        
        [LCProgressHUD showFailureText:@"提现失败"];

    }];
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.textField resignFirstResponder];
}


@end
