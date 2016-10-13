//
//  ZhiMaCollectionController.m
//  ZhiMaBaoBao
//
//  Created by mac on 16/10/7.
//  Copyright © 2016年 liugang. All rights reserved.
//

#import "ZhiMaCollectionController.h"
#import "ZhiMaCollectionHeaderView.h"
#import "ZhiMaCollectionCell.h"

#import "ZhiMaCollectionDetailController.h"

#define ZhiMaCollectionCellReusedID @"ZhiMaCollectionCellReusedID"

@interface ZhiMaCollectionController () <UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) NSArray *dataArray;
@end

@implementation ZhiMaCollectionController {
    UITableView *_tableView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupView];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [self getResponData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)getResponData {
    [LGNetWorking getCollectionListWithSessionId:USERINFO.sessionId success:^(ResponseData *responseData) {
        
        if (responseData.code != 0) {
            return ;
        }
        
        self.dataArray = [ZhiMaCollectionModel mj_objectArrayWithKeyValuesArray:responseData.data];
        
        
        [_tableView reloadData];
        
    } failure:^(ErrorData *error) {
        
    }];
}

- (void)setupView {
    [self setCustomTitle:@"收藏"];
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    [self.view addSubview:_tableView];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    [_tableView registerClass:[ZhiMaCollectionCell class] forCellReuseIdentifier:ZhiMaCollectionCellReusedID];
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ZhiMaCollectionModel *model = self.dataArray[indexPath.section];
    ZhiMaCollectionCell *cell = [tableView dequeueReusableCellWithIdentifier:ZhiMaCollectionCellReusedID forIndexPath:indexPath];
    cell.model = model;
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    ZhiMaCollectionModel *model = self.dataArray[indexPath.section];
    return model.cellHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 0.1;
    }
    return 7;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.1;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    ZhiMaCollectionModel *model = self.dataArray[indexPath.section];
    ZhiMaCollectionDetailController *detail = [[ZhiMaCollectionDetailController alloc] init];
    detail.model = model;
    [self.navigationController pushViewController:detail animated:YES];
}

- (NSArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [NSArray array];
    }
    return _dataArray;
}

@end
