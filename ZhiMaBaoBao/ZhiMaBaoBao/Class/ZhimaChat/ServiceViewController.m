//
//  ServiceViewController.m
//  ZhiMaBaoBao
//
//  Created by ios开发 on 16/10/31.
//  Copyright © 2016年 liugang. All rights reserved.
//

#import "ServiceViewController.h"
#import "ServicePurseCell.h"
#import "ServiceSingleMsgCell.h"

@interface ServiceViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView; // 列表

@end

@implementation ServiceViewController

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initTableview];
}


#pragma mark - init

- (void)initTableview
{
    self.navigationItem.title = @"麦当劳";
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, DEVICEWITH, DEVICEHIGHT) style:UITableViewStylePlain];
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.dataSource = self;
    tableView.delegate = self;
    [self.view addSubview:tableView];
    self.tableView = tableView;
}

#pragma mark - tableviewDelegate DataSource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 55+(DEVICEWITH-36)*690/682;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        ServicePurseCell *servicePurseCell = [tableView dequeueReusableCellWithIdentifier:@"ServicePurseCell"];
        if(!servicePurseCell) {
            servicePurseCell = [[ServicePurseCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ServicePurseCell"];
        }
        return servicePurseCell;
    }else
    {
        ServiceSingleMsgCell *serviceSingleMsgCell = [tableView dequeueReusableCellWithIdentifier:@"ServiceSingleMsgCell"];
        if(!serviceSingleMsgCell) {
            serviceSingleMsgCell = [[ServiceSingleMsgCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ServiceSingleMsgCell"];
        }
        return serviceSingleMsgCell;
    }

}

@end
