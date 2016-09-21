//
//  ChooseWhoCanSeeController.m
//  YiIM_iOS
//
//  Created by mac on 16/8/24.
//  Copyright © 2016年 ikantech. All rights reserved.
//

#import "ChooseWhoCanSeeController.h"
#import "LCProgressHUD.h"
#import "ChooseWhoCanSeeCell.h"

#define ChooseWhoCanSeeCellReusedID @"ChooseWhoCanSeeCellReusedID"

@interface ChooseWhoCanSeeController () <UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataArray;
@end

@implementation ChooseWhoCanSeeController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self creatModel];
    [self setupNav];
    [self setupView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)creatModel  {
    NSMutableArray *modelArray = [NSMutableArray array];
    for (NSInteger index = 0; index < 2; index++) {
        ChooserWhoCanSeeCellModel *model = [[ChooserWhoCanSeeCellModel alloc] init];
        if (index == 0) {
            model.title = @"公开";
            model.subTitle = @"所有人可见";
            model.isSelected = YES;
            if (self.isPrivate) {
                model.isSelected = NO;
            }
        } else if ( index == 1) {
            model.title = @"朋友";
            model.subTitle = @"仅自己朋友可见";
            model.isSelected = NO;
            if (self.isPrivate) {
                model.isSelected = YES;
            }
        }
        [modelArray addObject:model];
    }
    
    self.dataArray = modelArray;
}


- (void)setupNav {
    [self setCustomTitle:@"谁可以看"];
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStyleDone target:self action:@selector(rightBarButtonItemDidClick)];
    self.navigationItem.rightBarButtonItem = rightItem;
    
}

- (void)setupView {
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView = tableView;
    self.tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    [self.view addSubview:tableView];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.dataSource = self;
    tableView.delegate = self;
    
    [tableView registerClass:[ChooseWhoCanSeeCell class] forCellReuseIdentifier:ChooseWhoCanSeeCellReusedID];
    
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ChooseWhoCanSeeCell *cell = [tableView dequeueReusableCellWithIdentifier:ChooseWhoCanSeeCellReusedID forIndexPath:indexPath];
    
    cell.model = self.dataArray[indexPath.row];
    
    
    cell.block = ^() {
        
        for (ChooserWhoCanSeeCellModel *model in self.dataArray) {
            if (model == cell.model) {
                continue;
            }
            
            model.isSelected = NO;
        }
        
        [self.tableView reloadData];
    };
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    for (ChooserWhoCanSeeCellModel *model in self.dataArray) {
        if (model == self.dataArray[indexPath.row]) {
            model.isSelected = YES;
        } else {
            model.isSelected = NO;
        }
    }
    [tableView reloadData];
    
}



#pragma mark - 确定按钮点击事件
- (void)rightBarButtonItemDidClick {
    for (NSInteger index = 0; index < self.dataArray.count; index++) {
        ChooserWhoCanSeeCellModel *model = self.dataArray[index];
        
        if (model.isSelected == YES) {  //如果都没有选择，则提示让用户选择,有选择才进行筛选
            
            if (index == 0) {           //选择了公开项
                self.returnBlock(NO);
            } else if (index == 1) {    //选择了私有项
                self.returnBlock(YES);
            }
            [self.navigationController popViewControllerAnimated:YES];
            return;
        }
    }
    
    [LCProgressHUD showFailureText:@"请选择其中一项"];
    
}

- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

@end
