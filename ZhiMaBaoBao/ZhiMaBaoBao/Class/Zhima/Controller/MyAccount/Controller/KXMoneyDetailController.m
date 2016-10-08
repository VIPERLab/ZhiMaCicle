//
//  KXMoneyDetailController.m
//  YiIM_iOS
//
//  Created by mac on 16/9/17.
//  Copyright © 2016年 ikantech. All rights reserved.
//

#import "KXMoneyDetailController.h"
#import "KXMoneyDetailCell.h"
#import "KXMoneyController.h"

#import "NSString+MD5.h"

#define KXMoneyDetailCellReusedID @"KXMoneyDetailCellReusedID"

@interface KXMoneyDetailController () <UITableViewDelegate,UITableViewDataSource>

@end

@implementation KXMoneyDetailController {
    UITableView *_tableView;
    int pageNumber;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    pageNumber = 1;
    [self setCustomTitle:@"明细列表"];
    [self setupView];
    [self loadRequest];
}

- (void)setupView {
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    [self.view addSubview:_tableView];
    [_tableView registerClass:[KXMoneyDetailCell class] forCellReuseIdentifier:KXMoneyDetailCellReusedID];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    KXMoneyDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:KXMoneyDetailCellReusedID forIndexPath:indexPath];
    cell.model = self.dataArray[indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70;
}


//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    [tableView deselectRowAtIndexPath:indexPath animated:YES];
//    KXMoneyController *money = [[KXMoneyController alloc] init];
//    money.model = self.dataArray[indexPath.row];
//    [self.navigationController pushViewController:money animated:YES];
//}


- (void)loadRequest {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer.timeoutInterval = 15.f;
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html",@"application/json",nil];
    
    NSString *enCodeString = [NSString stringWithFormat:@"p=%zd&uid=%@&apikey=%@",pageNumber,self.model.ID,RECHAPPKEY];
    
    enCodeString = [NSString md5:enCodeString];
    enCodeString = [enCodeString uppercaseString];
    
    NSMutableDictionary *params = [NSMutableDictionary  dictionary];
    params[@"uid"] = self.model.ID;
    params[@"p"] = [NSString stringWithFormat:@"%zd",pageNumber];
    params[@"sign"] = enCodeString;
    
    [manager POST:[NSString stringWithFormat:@"http://120.76.239.173/Api/Index/getmoneyrec"] parameters:params progress:0 success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        if ([responseObject[@"code"] intValue] != 8888) {
            [LCProgressHUD showFailureText:responseObject[@"msg"]];
            return ;
        }
        
        pageNumber++;
        NSMutableArray *dataArray = [KXMoneyDetailModel mj_objectArrayWithKeyValuesArray:responseObject[@"data"]];
        self.dataArray = dataArray;
        [_tableView reloadData];
        
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
}


@end
