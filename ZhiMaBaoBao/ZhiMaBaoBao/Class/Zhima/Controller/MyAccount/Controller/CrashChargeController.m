//
//  CrashChargeController.m
//  YiIM_iOS
//
//  Created by mac on 16/8/27.
//  Copyright © 2016年 ikantech. All rights reserved.
//

#import "CrashChargeController.h"
#import "NSString+MD5.h"
#import "LCProgressHUD.h"
#import <AlipaySDK/AlipaySDK.h>
#import "Order.h"
#import "APAuthV2Info.h"
//#import "WXApi.h"
#import "LCProgressHUD.h"

#import "KXCrashChargeCell.h"
#import "UIColor+My.h"

#define CrashChargeTableViewCellReusedID @"CrashChargeTableViewCellReusedID"
@interface CrashChargeController () <UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, weak) UITableView *tableView;

@end

@implementation CrashChargeController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupNav];
    [self setupView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)setupNav {
    [self setCustomTitle:@"请选择支付方式"];
    
}

- (void)setupView {
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 60)];
    headerView.backgroundColor = [UIColor whiteColor];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 100, 60)];
    titleLabel.text = @"订单金额";
    [headerView addSubview:titleLabel];
    
    UILabel *payLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width - 20, 60)];
    payLabel.textColor = [UIColor redColor];
    payLabel.text = @"￥200";
    payLabel.textAlignment = NSTextAlignmentRight;
    [headerView addSubview:payLabel];
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    self.tableView = tableView;
    [self.view addSubview:tableView];
    
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    tableView.tableHeaderView = headerView;
    
    [tableView registerClass:[KXCrashChargeCell class] forCellReuseIdentifier:CrashChargeTableViewCellReusedID];
    
    
    //注册通知接受微信回调
    [[NSNotificationCenter defaultCenter]  addObserver:self selector:@selector(WXPayFailed) name:@"WXPayFailed" object:@"fail"];
    [[NSNotificationCenter defaultCenter]  addObserver:self selector:@selector(WXPaySuccess) name:@"WXPaySuccess" object:@"success"];
    
    UIButton *buttonView = [[UIButton alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(tableView.frame) - 45, CGRectGetWidth(tableView.frame), 45)];
    [self.view addSubview:buttonView];
    [buttonView setTitle:@"确认支付" forState:UIControlStateNormal];
    buttonView.backgroundColor = THEMECOLOR;
    [buttonView addTarget:self action:@selector(bottomButtonDidClick) forControlEvents:UIControlEventTouchUpInside];
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    KXCrashChargeCell *cell = [tableView dequeueReusableCellWithIdentifier:CrashChargeTableViewCellReusedID forIndexPath:indexPath];
    
    if (indexPath.row == 0 && indexPath.section == 0) {
        cell.iconName = @"AliPay";
        cell.titleName = @"支付宝支付";
        cell.isSelected = YES;
    } else if (indexPath.row == 1 && indexPath.section == 0) {
        cell.iconName = @"WXPay";
        cell.titleName = @"微信支付";
    }
    
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 20, [UIScreen mainScreen].bounds.size.width, 30)];
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, CGRectGetWidth(headerView.frame), 30)];
        titleLabel.backgroundColor = [UIColor whiteColor];
        titleLabel.font = [UIFont systemFontOfSize:15];
        titleLabel.textColor = [UIColor colorFormHexRGB:@"353535"];
        titleLabel.text = @"    选择支付方式";
        [headerView addSubview:titleLabel];
        
        UIView *bottomLineView = [[UIView alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(titleLabel.frame) - 1, CGRectGetWidth(headerView.frame) - 20, 0.5)];
        bottomLineView.backgroundColor = [UIColor colorFormHexRGB:@"d6d7dc"];
        [headerView addSubview:bottomLineView];
        
        return headerView;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 50;
}



//支付接口 -  type =0 微信支付  type = 1 支付宝支付
- (void)payMoenyByType:(int)type {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer.timeoutInterval = 30.f;
    manager.responseSerializer.acceptableContentTypes = nil;//[NSSet setWithObject:@"text/plain"];
    manager.securityPolicy = [AFSecurityPolicy defaultPolicy];
    manager.securityPolicy.allowInvalidCertificates = YES;//忽略https证书
    manager.securityPolicy.validatesDomainName = NO;//是否验证域名
    
    NSString *sign = [NSString stringWithFormat:@"type=%zd&uid=%@&apikey=%@",type,self.model.ID,RECHAPPKEY];
    NSString *md5Sign = [NSString md5:sign];
    md5Sign = [md5Sign uppercaseString];
    NSMutableDictionary *parms = [NSMutableDictionary dictionary];
    parms[@"uid"] = self.model.ID;
    parms[@"type"] = [NSString stringWithFormat:@"%zd",type];
    parms[@"sign"] = md5Sign;
    
    [manager POST:@"http://120.76.239.173/Api/Index/getpay" parameters:parms progress:0 success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        if ([responseObject[@"code"] intValue] != 8888) {
            [LCProgressHUD showFailureText:@"操作失败"];
        }
    
        if (type) {
            [self AliPay:responseObject];
        } else {
//            [self WXPay:responseObject];
        }
        
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];

}


- (void)AliPay:(id)responseObject {
    NSString *order = responseObject[@"data"];
    NSString *appScheme = @"ZhiMaCicle";
    // NOTE: 调用支付结果开始支付
    [[AlipaySDK defaultService] payOrder:order fromScheme:appScheme callback:^(NSDictionary *resultDic) {
        NSLog(@"reslut = %@",resultDic);
        if ([resultDic[@"resultStatus"] integerValue] == 4000) {
            [LCProgressHUD showInfoText:@"订单支付失败"];
        } else if ([resultDic[@"resultStatus"] integerValue] == 6001) {
            [LCProgressHUD showInfoText:@"用户取消支付"];
        } else if ([resultDic[@"resultStatus"] integerValue] == 6001) {
            [LCProgressHUD showInfoText:@"网络连接出错"];
        } else if ([resultDic[@"resultStatus"] integerValue] == 8000) {
            [LCProgressHUD showInfoText:@"正在处理中"];
        } else if ([resultDic[@"resultStatus"] integerValue] == 9000) {
            [LCProgressHUD showInfoText:@"支付成功"];
            [self.navigationController popViewControllerAnimated:YES];
        }
        
    }];
}

//微信支付
//- (void)WXPay:(id)responseObject {
//    NSMutableString *stamp  = [responseObject objectForKey:@"timestamp"];
//    //调起微信支付
//    PayReq* req             = [[PayReq alloc] init];
//    req.partnerId           = [responseObject objectForKey:@"partnerid"];
//    req.prepayId            = [responseObject objectForKey:@"prepayid"];
//    req.nonceStr            = [responseObject objectForKey:@"noncestr"];
//    req.timeStamp           = stamp.intValue;
//    req.package             = [responseObject objectForKey:@"package"];
//    req.sign                = [responseObject objectForKey:@"sign"];
//    [WXApi sendReq:req];
//}

- (void)WXPayFailed {
    [LCProgressHUD showFailureText:@"支付失败"];
}


- (void)WXPaySuccess {
    [LCProgressHUD showSuccessText:@"支付成功"];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)bottomButtonDidClick {
    [self payMoenyByType:1];
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
