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
#import "WXApi.h"
#import "LCProgressHUD.h"

#import "KXCrashChargeCell.h"
#import "UIColor+My.h"

#import "chargeMomeyMdoel.h"

#define CrashChargeTableViewCellReusedID @"CrashChargeTableViewCellReusedID"
@interface CrashChargeController () <UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) NSMutableArray *dataArray;

@property (nonatomic, weak) UITableView *tableView;

@property (nonatomic, weak) KXCrashChargeCell *currentCell;

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

- (void)viewWillAppear:(BOOL)animated {
    [_tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:YES scrollPosition:UITableViewScrollPositionNone];
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
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    KXCrashChargeCell *cell = [tableView dequeueReusableCellWithIdentifier:CrashChargeTableViewCellReusedID forIndexPath:indexPath];
    chargeMomeyMdoel *model = self.dataArray[indexPath.row];
    cell.model = model;
    
    if (indexPath.row == 0 && !self.currentCell) {
        cell.selected = YES;
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
//    if (1) {
//        [LCProgressHUD showFailureText:@"正在开发中"];
//        return;
//    }
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

    [manager POST:[NSString stringWithFormat:@"%@/Api/Index/getpay",DFAPIURLTEST] parameters:parms progress:0 success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        if ([responseObject[@"code"] intValue] != 8888) {
            [LCProgressHUD showFailureText:@"支付失败"];
            return ;
        }
        if (type) {
            [self AliPay:responseObject];
        } else {
            [self WXPay:responseObject[@"data"]];
        }
        
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];

}


- (void)AliPay:(id)responseObject {
    NSString *order = responseObject[@"data"];
    NSString *appScheme = @"ZhiMaBaoBao";
    // NOTE: 调用支付结果开始支付
    [[AlipaySDK defaultService] payOrder:order fromScheme:appScheme callback:^(NSDictionary *resultDic) {
        NSLog(@"reslut = %@",resultDic);
        if ([resultDic[@"resultStatus"] integerValue] == 4000) {
            [LCProgressHUD showFailureText:@"订单支付失败"];
        } else if ([resultDic[@"resultStatus"] integerValue] == 6001) {
            [LCProgressHUD showFailureText:@"用户取消支付"];
        } else if ([resultDic[@"resultStatus"] integerValue] == 6001) {
            [LCProgressHUD showFailureText:@"网络连接出错"];
        } else if ([resultDic[@"resultStatus"] integerValue] == 8000) {
            [LCProgressHUD showFailureText:@"正在处理中"];
        } else if ([resultDic[@"resultStatus"] integerValue] == 9000) {
            [LCProgressHUD showSuccessText:@"支付成功"];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"PaySuccess" object:nil];
            [self.navigationController popViewControllerAnimated:YES];
        }
        
    }];
}

//微信支付
- (void)WXPay:(id)responseObject {
    NSMutableString *stamp  = [responseObject objectForKey:@"timestamp"];
    //调起微信支付
    PayReq* req             = [[PayReq alloc] init];
    req.partnerId           = [responseObject objectForKey:@"partnerid"];
    req.prepayId            = [responseObject objectForKey:@"prepayid"];
    req.nonceStr            = [responseObject objectForKey:@"noncestr"];
    req.timeStamp           = stamp.intValue;
    req.package             = [responseObject objectForKey:@"package"];
    req.sign                = [responseObject objectForKey:@"sign"];
    [WXApi sendReq:req];
}

- (void)WXPayFailed {
    [LCProgressHUD showFailureText:@"支付失败"];
}


- (void)WXPaySuccess {
    [LCProgressHUD showSuccessText:@"支付成功"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"PaySuccess" object:nil];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)bottomButtonDidClick {
    
    int type = 3;
    for (NSInteger index = 0; index < self.dataArray.count; index++) {
        chargeMomeyMdoel *model = self.dataArray[index];
        if (index == 0) {
            type = model.isSelected == YES ? 1 : 3;
            if (type == 1) {
                [self payMoenyByType:type];
                break;
            }
        } else {
            type = model.isSelected == YES ? 0 : 3;
            if (type == 0) {
                [self payMoenyByType:type];
                break;
            }
        }
    }
    
    if (type == 3) {
        [LCProgressHUD showFailureText:@"请选择支付方式"];
        return;
    }
    
    
//    [self payMoenyByType:type];
}


- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
        for (NSInteger index = 0; index < 2; index++) {
            chargeMomeyMdoel *model = [[chargeMomeyMdoel alloc] init];
            if (index == 0) {
                model.iconName = @"AliPay";
                model.titleName = @"支付宝支付";
                model.isSelected = NO;
            } else {
                model.iconName = @"WXPay";
                model.titleName = @"微信支付";
                model.isSelected = NO;
            }
            [_dataArray addObject:model];
        }
    }
    return _dataArray;
}


@end
