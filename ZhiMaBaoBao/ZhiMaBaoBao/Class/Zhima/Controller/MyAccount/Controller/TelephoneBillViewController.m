//
//  TelephoneBillViewController.m
//  YiIM_iOS
//
//  Created by mac on 16/8/26.
//  Copyright © 2016年 ikantech. All rights reserved.
//

#import "TelephoneBillViewController.h"
#import "MyAccountModel.h"
#import "TelephoneBillCell.h"
#import "NSString+MD5.h"
#import "LCProgressHUD.h"
#define TelephoneBilCellReusedID @"TelephoneBilCellReusedID"

@interface TelephoneBillViewController () <UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, weak) UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *tipsArray; //标题

@property (nonatomic, strong) NSMutableArray *subTipsArray;

@property (nonatomic, weak) UITextField *cardNumber;
@property (nonatomic, weak) UITextField *cardPassword;

@end

@implementation TelephoneBillViewController

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
    [self setCustomTitle:@"话费卡充值"];
}

- (void)setupView {
    UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    self.tableView = tableView;
    [self.view addSubview:tableView];
    
    tableView.delegate = self;
    tableView.dataSource = self;
    
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 70)];
    CGFloat marge = 30;
    CGFloat buttonW = [UIScreen mainScreen].bounds.size.width - marge * 2;
    CGFloat buttonX = ([UIScreen mainScreen].bounds.size.width - buttonW) * 0.5;
    CGFloat buttonH = 40;
    CGFloat buttonY = ( CGRectGetHeight(bottomView.frame) - buttonH ) * 0.5;
    UIButton *chargeButton = [[UIButton alloc] initWithFrame:CGRectMake(buttonX , buttonY, buttonW, buttonH)];
    [chargeButton addTarget:self action:@selector(chargeButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
    chargeButton.layer.cornerRadius = 5;
    [chargeButton setTitle:@"充值" forState:UIControlStateNormal];
    [chargeButton setBackgroundColor:THEMECOLOR];
    [bottomView addSubview:chargeButton];
    tableView.tableFooterView = bottomView;
    
    [tableView registerClass:[TelephoneBillCell class] forCellReuseIdentifier:TelephoneBilCellReusedID];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *array = self.tipsArray[section];
    return array.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSArray *currentTitleArray = self.tipsArray[indexPath.section];
    NSArray *subTipsArraay = self.subTipsArray[indexPath.section];
    
    TelephoneBillCell *cell = [tableView dequeueReusableCellWithIdentifier:TelephoneBilCellReusedID forIndexPath:indexPath];
    
    cell.title = currentTitleArray[indexPath.row];
    cell.inputPlaceHolder = subTipsArraay[indexPath.row];
    
    if (indexPath.section == 0 && indexPath.row == 2) {
        if ([subTipsArraay[indexPath.row] intValue] > 0) {
            cell.inputPlaceHolder = [NSString stringWithFormat:@"%@天",subTipsArraay[indexPath.row]];
        } else {
            cell.inputPlaceHolder = @"剩余天数不足";
        }
        
    }
    
    if (indexPath.section == 1) {
        cell.inputViewTextAlignment = NSTextAlignmentLeft;
        cell.inputView.userInteractionEnabled = YES;
        cell.inputView.keyboardType = UIKeyboardTypeNumberPad;
        if (indexPath.row == 0) {  //卡号TextField
            self.cardNumber = cell.inputView;
        } else if (indexPath.row == 1) {   //密码TextField
            self.cardPassword = cell.inputView;
        }
        
    }
    
    
    
    
    return cell;
}


#pragma mark - 充值点击事件
- (void)chargeButtonDidClick:(UIButton *)sender {
    if (self.cardNumber.text.length == 0 || self.cardPassword.text.length == 0) {
        [LCProgressHUD showFailureText:@"请填写正确的卡号或密码"];
        return;
    }
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer.timeoutInterval = 30.f;
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html",@"application/json",nil];
    
    NSString *sign = [NSString stringWithFormat:@"cardno=%@&cardpass=%@&uid=%@&apikey=%@",self.cardNumber.text,self.cardPassword.text,self.model.ID,RECHAPPKEY];
    NSString *md5Sign = [NSString md5:sign];
    md5Sign = [md5Sign uppercaseString];
    
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"uid"] = self.model.ID;
    params[@"cardno"] = self.cardNumber.text;
    params[@"cardpass"] = self.cardPassword.text;
    params[@"sign"] = md5Sign;
    
    [manager POST:[NSString stringWithFormat:@"%@/Api/Index/cardpay",DFAPIURLTEST] parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject[@"code"] intValue] != 8888) {
            [LCProgressHUD showFailureText:responseObject[@"msg"]];
            return ;
        }
        
        [LCProgressHUD showFailureText:responseObject[@"msg"]];
        self.model.phoneusetime = responseObject[@"data"][@"phoneusetime"];
        [self.tableView reloadData];
        [self.navigationController popViewControllerAnimated:YES];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
    
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.cardPassword resignFirstResponder];
    [self.cardNumber resignFirstResponder];
}

#pragma mark - lazyLoad
- (NSMutableArray *)tipsArray {
    if (!_tipsArray) {
        _tipsArray = [NSMutableArray array];
        [_tipsArray addObject:@[@"账户号码",@"账户余额",@"有效天数"]];
        [_tipsArray addObject:@[@"卡号",@"密码"]];
        
    }
    return _tipsArray;
}

- (NSMutableArray *)subTipsArray {
    if (!_subTipsArray) {
        _subTipsArray = [NSMutableArray array];
        NSString *first = self.model.uphone;
        NSString *sec = self.model.amount;
        NSString *third = self.model.phoneusetime;
        [_subTipsArray addObject:@[first,sec,third]];
        [_subTipsArray addObject:@[@"请输入充值卡号码",@"请输入充值密码"]];
    }
    return _subTipsArray;
}

@end
