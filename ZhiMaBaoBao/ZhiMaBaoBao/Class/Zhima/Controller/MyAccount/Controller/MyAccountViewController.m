//
//  MyAccountViewController.m
//  YiIM_iOS
//
//  Created by mac on 16/8/25.
//  Copyright © 2016年 ikantech. All rights reserved.
//

#import "MyAccountViewController.h"
#import "MyAccountHeaderView.h"
#import "NSString+MD5.h"
#import "AFNetworking.h"

#import "MyAccountModel.h"

#import "TelephoneBillViewController.h"  //话费卡充值
#import "CrashChargeController.h"  //现金充值
#import "ChangeMoneyController.h"  //零钱

#import "UIColor+My.h"

@interface MyAccountViewController () <MyAccountHeaderViewDelegate>

@property (nonatomic, weak) MyAccountHeaderView *headerView;

@property (nonatomic, weak) MyAccountHeaderView *headerView2;

@property (nonatomic, strong) MyAccountModel *model;

@end


@implementation MyAccountViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupNav];
    
    [self registNotification];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
//    if (self.model.ID.length == 0) {
    [self request];
//    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupNav {
    [self setCustomTitle:@"我的账户"];
}

- (void)registNotification {
    [[NSNotificationCenter defaultCenter]  addObserver:self selector:@selector(PaySuccess) name:@"PaySuccess" object:nil];

}


- (void)setupView {
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    MyAccountHeaderView *headerView = [[MyAccountHeaderView alloc] initWithFrame:CGRectMake(0, 64, [UIScreen mainScreen].bounds.size.width, 150)];
    self.headerView = headerView;
    headerView.delegate = self;
    headerView.backgroundColor = [UIColor colorFormHexRGB:@"fd696a"];
    [headerView setButtonWithArray:@[@"MyAccount_Tick",@"MyAccount_Money",@"MyAccount_CreadCar"] andSubTitleArray:@[@"付款",@"零钱",@"银行卡"] andSubTitleColor:[UIColor whiteColor]];
    [self.view addSubview:headerView];

    
    UIView *headerView2 = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(headerView.frame) + 30, [UIScreen mainScreen].bounds.size.width, 100)];
    headerView2.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:headerView2];
    
    [self setupHeaderView:headerView2];
    
}

- (void)setupHeaderView:(UIView *)headerView2 {
    CGFloat buttonWidth = [UIScreen mainScreen].bounds.size.width * 0.5;
    CGFloat buttonHeight = CGRectGetHeight(headerView2.frame);
    for (NSInteger index = 0; index < 2 ; index++) {
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(buttonWidth * index, 0, buttonWidth, buttonHeight)];
        [headerView2 addSubview:button];
        button.tag = index;
        [button addTarget:self action:@selector(buttonDidClick:) forControlEvents:UIControlEventTouchUpInside];
        
        CGFloat imageX = (buttonWidth - 40) * 0.5;
        CGFloat imageY = 15;
        CGFloat imageW = 40;
        CGFloat imageH = 40;
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(imageX, imageY, imageW, imageH)];
        [button addSubview:imageView];
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(imageView.frame) +5, buttonWidth, 30)];
        titleLabel.font = [UIFont systemFontOfSize:15];
        titleLabel.textColor = [UIColor colorFormHexRGB:@"646464"];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        [button addSubview:titleLabel];
        
        if (index == 0) {
            imageView.image = [UIImage imageNamed:@"MyAccount_CardCharge"];
            titleLabel.text = @"话费卡充值";
            
            UIView *rightLineView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(button.frame) - 0.5, 5, 0.5, CGRectGetHeight(button.frame) - 10)];
            rightLineView.backgroundColor = [UIColor colorFormHexRGB:@"e1e1e1"];
            [button addSubview:rightLineView];
            
            
        } else if (index == 1){
            imageView.image = [UIImage imageNamed:@"MyAccount_MoneyCharge"];
            titleLabel.text = @"现金充值";
        }
    }
    
}

- (void)buttonDidClick:(UIButton *)sender {
    if (!sender.tag) {
        TelephoneBillViewController *tellPhone = [[TelephoneBillViewController alloc] init];
        tellPhone.model = self.model;
        [self.navigationController pushViewController:tellPhone animated:YES];
    } else {
        CrashChargeController *crash = [[CrashChargeController alloc] init];
        crash.model = self.model;
        [self.navigationController pushViewController:crash animated:YES];
    }
}


//头部回调
- (void)MyAccountHeaderView:(MyAccountHeaderView *)headerView DidClickButton:(UIButton *)sender {
    
    if (headerView == self.headerView) { //第一个头部
        
        switch (sender.tag) {
            case 0: {        //付款
                NSLog(@"付款");
                break;
            }
                
            case 1: {       //零钱
                NSLog(@"零钱");
                ChangeMoneyController *change = [[ChangeMoneyController alloc] init];
                change.model = self.model;
                [self.navigationController pushViewController:change animated:YES];
                break;
            }
            case 2: {        //银行卡
                NSLog(@"银行卡");
                break;
            }
            default:
                break;
        }
        
    }
    
    else if (headerView == self.headerView2) { //第二个头部
        
        switch (sender.tag) {
            case 0: {        //话费卡充值
                NSLog(@"话费卡充值");
                TelephoneBillViewController *tellPhone = [[TelephoneBillViewController alloc] init];
                tellPhone.model = self.model;
                [self.navigationController pushViewController:tellPhone animated:YES];
                break;
            }
                
            case 1: {       //现金充值
                CrashChargeController *crash = [[CrashChargeController alloc] init];
                crash.model = self.model;
                [self.navigationController pushViewController:crash animated:YES];
                NSLog(@"现金充值");
                break;
            }
            case 2:         //待用
            default:
                break;
        }
    }
    
    self.hidesBottomBarWhenPushed = YES;
}


- (void)PaySuccess {
    [self request];
}
#pragma mark - 请求
- (void)request {
//    [LCProgressHUD showLoadingText:@"正在查询账户"];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer.timeoutInterval = 30.f;
    manager.responseSerializer.acceptableContentTypes = nil;//[NSSet setWithObject:@"text/plain"];
    manager.securityPolicy = [AFSecurityPolicy defaultPolicy];
    manager.securityPolicy.allowInvalidCertificates = YES;//忽略https证书
    manager.securityPolicy.validatesDomainName = NO;//是否验证域名

    
    NSString *sign = [NSString stringWithFormat:@"uid=%@&apikey=%@",USERINFO.userID,RECHAPPKEY];
    NSString *md5Sign = [NSString md5:sign];
    
    md5Sign = [md5Sign uppercaseString];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"uid"] = USERINFO.userID;
    params[@"sign"] = md5Sign;
    
    [manager POST:[NSString stringWithFormat:@"%@/Api/Index/getuser",DFAPIURLTEST] parameters:params progress:0 success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"%@",responseObject);
        if ([responseObject[@"code"] integerValue] == 8888) {
            [LCProgressHUD hide];
            //判断是否处于审核状态
            if ([responseObject[@"data"][@"open"] integerValue] == 0) {   //处于审核状态，屏蔽该页
                UIView *cover = [[UIView alloc] initWithFrame:self.view.bounds];
                cover.backgroundColor = BGCOLOR;
                [self.view addSubview:cover];
                
                UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, (DEVICEHIGHT - 50)/2, DEVICEWITH, 30)];
                label.text = @"该功能暂未开放";
                label.textAlignment = NSTextAlignmentCenter;
                label.font = [UIFont systemFontOfSize:17];
                [cover addSubview:label];
                return ;
            }else{    //正常使用状态
                [self setupView];

                MyAccountModel *accountModel = [MyAccountModel mj_objectWithKeyValues:responseObject[@"data"]];
                self.model = accountModel;
                
                self.headerView.moneyLabel.text = [NSString stringWithFormat:@"￥%@",accountModel.amount];
                
                return ;
            }
        }
        
        [LCProgressHUD showFailureText:responseObject[@"msg"]];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
    
}

- (MyAccountModel *)model {
    if (!_model) {
        _model = [[MyAccountModel alloc] init];
    }
    return _model;
}


@end
