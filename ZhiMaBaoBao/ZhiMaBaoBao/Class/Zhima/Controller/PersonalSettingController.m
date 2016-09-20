//
//  PersonalSettingController.m
//  ZhiMaBaoBao
//
//  Created by mac on 16/9/19.
//  Copyright © 2016年 liugang. All rights reserved.
//

#import "PersonalSettingController.h"
#import "KXSettingCell.h"

#define KXSettingCellReusedID @"KXSettingCellReusedID"

@interface PersonalSettingController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) NSArray *dataArray;

@end

@implementation PersonalSettingController {
    UITableView *_tableView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)setupView {
    [self setCustomTitle:@"新消息通知"];
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    [self.view addSubview:_tableView];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [_tableView registerClass:[KXSettingCell class] forCellReuseIdentifier:KXSettingCellReusedID];
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    KXSettingCell *cell = [tableView dequeueReusableCellWithIdentifier:KXSettingCellReusedID forIndexPath:indexPath];
    cell.title = self.dataArray[indexPath.row];
    return cell;
}




- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 45;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 20;
}


- (NSArray *)dataArray {
    if (!_dataArray) {
        _dataArray = @[@"加我为朋友时需要验证",@"向我推荐通讯录朋友"];
    }
    return _dataArray;
}


@end
