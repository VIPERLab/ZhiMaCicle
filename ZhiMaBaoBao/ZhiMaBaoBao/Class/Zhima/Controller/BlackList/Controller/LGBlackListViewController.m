//
//  LGBlackListViewController.m
//  YiIM_iOS
//
//  Created by liugang on 16/8/20.
//  Copyright © 2016年 ikantech. All rights reserved.
//

#import "LGBlackListViewController.h"
#import "KXBlackListModel.h"
//#import "YiUserInfoViewController.h"
#import "KXBlackListCell.h"


#define KXBlackListTableCellReusedID @"KXBlackListTableCellReusedID"

@interface LGBlackListViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataArray;

@end

@implementation LGBlackListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = BGCOLOR;
    [self addAllViews];
    [self setCustomTitle:@"黑名单"];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self requestData];
}

- (void)requestData
{
    if (self.dataArray) {
        [self.dataArray removeAllObjects];
    }
    
//    NSString *url = [NSString stringWithFormat:@"%@/moblie/getfriendByuserId_type.do",DFAPIURL];
//    NSString *sessionId = USERINFO.sessionId;
//    NSString *openfireaccount = USERINFO.openfireAccount;
//    
//    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
//    manager.requestSerializer.timeoutInterval = 30.f;
//    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html",@"application/json",nil];
//    
//    NSMutableDictionary *params = [NSMutableDictionary dictionary];
//    params[@"sessionId"] = sessionId;
//    params[@"openfireaccount"] = openfireaccount;
//    params[@"friend_type"] = @"3";
//    [manager GET:url parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//        
//        NSArray *dataArray = [KXBlackListModel mj_objectArrayWithKeyValuesArray:responseObject[@"data"]];
//        
//        for (KXBlackListModel *model in dataArray) {
//            if (model.friend_type == 3) {
//                [self.dataArray addObject:model];
//            }
//        }
//        [self.tableView reloadData];
//        
//    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//        
//    }];
}

- (void)addAllViews
{
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, DEVICEWITH, DEVICEHIGHT - 64) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = 53;
    self.tableView.backgroundColor = BGCOLOR;
    [self.view addSubview:self.tableView];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerClass:[KXBlackListCell class] forCellReuseIdentifier:KXBlackListTableCellReusedID];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return self.dataArray.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    KXBlackListCell *cell = [tableView dequeueReusableCellWithIdentifier:KXBlackListTableCellReusedID forIndexPath:indexPath];
    
    KXBlackListModel *model = self.dataArray[indexPath.row];
    cell.model = model;
    return cell;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 10;
    }
    return 0;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
//    KXBlackListModel *model = self.dataArray[indexPath.row];
//    NSString *jid = [NSString stringWithFormat:@"%@@localhost",model.openfireaccount];
//    YiUserInfoViewController *info = [[YiUserInfoViewController alloc] init];
//    info.jid = jid;
//    info.fromBlackList = YES;
//    [self.navigationController pushViewController:info animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}



- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [[NSMutableArray alloc] init];
    }
    return _dataArray;
}

@end
