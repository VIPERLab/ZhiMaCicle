//
//  LGSearchResultController.m
//  YiIM_iOS
//
//  Created by liugang on 16/8/12.
//  Copyright © 2016年 ikantech. All rights reserved.
//

#import "LGSearchResultController.h"
#import "FriendProfilecontroller.h"
#import "LGSearchResultCell.h"


@interface LGSearchResultController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;

@end

static NSString *const reuseIdentifier = @"LGSearchResultCell";
@implementation LGSearchResultController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setCustomTitle:@"搜索结果"];

    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, DEVICEWITH, DEVICEHIGHT) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.tableView.backgroundColor = BGCOLOR;
    self.tableView.rowHeight = 53;
    [self.tableView registerNib:[UINib nibWithNibName:@"LGSearchResultCell" bundle:nil] forCellReuseIdentifier:reuseIdentifier];
    [self.view addSubview:self.tableView];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    LGSearchResultCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];

    NSDictionary *dic = self.dataArr[indexPath.row];
    NSString *urlStr = [NSString stringWithFormat:@"%@%@",DFAPIURL,dic[@"head_photo"]];
    [cell.avtar sd_setImageWithURL:[NSURL URLWithString:urlStr] placeholderImage:[UIImage imageNamed:@"defaultContact"]];
    cell.name.text = dic[@"username"];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary *dic = self.dataArr[indexPath.row];
    NSString *userId = dic[@"id"];
    FriendProfilecontroller *vc = [[FriendProfilecontroller alloc] init];
    vc.userId = userId;
    [self.navigationController pushViewController:vc animated:YES];
}


@end
