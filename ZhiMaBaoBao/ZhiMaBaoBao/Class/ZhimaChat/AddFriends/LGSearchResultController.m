//
//  LGSearchResultController.m
//  YiIM_iOS
//
//  Created by liugang on 16/8/12.
//  Copyright © 2016年 ikantech. All rights reserved.
//  添加好友结果列表

#import "LGSearchResultController.h"
//#import "YiUserInfoViewController.h"
#import "LGSearchResultCell.h"
#import "UIImageView+WebCache.h"

@interface LGSearchResultController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;

@end

@implementation LGSearchResultController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setCustomTitle:@"搜索结果"];

    self.view.backgroundColor = RGB(229, 229, 229);
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, DEVICEWITH, DEVICEHIGHT) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.tableView.backgroundColor = RGB(229, 229, 229);
    self.tableView.rowHeight = 53;
    [self.view addSubview:self.tableView];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    LGSearchResultCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SearchCell"];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"LGSearchResultCell" owner:nil options:nil] firstObject];
    }
    NSDictionary *dic = self.dataArr[indexPath.row];
    [cell.avtar sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",DFAPIURL,dic[@"head_photo"]]]];
    cell.name.text = dic[@"username"];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
#warning TODO:跳转到好友信息详情
    /*
    NSDictionary *dic = self.dataArr[indexPath.row];
    NSString *jid = [NSString stringWithFormat:@"%@@%@",dic[@"openfireaccount"],XMPPSERVER];
    YiUserInfoViewController *vc = [[YiUserInfoViewController alloc] init];
    vc.jid = jid;
    vc.isAddFriend = self.isAddFriend;
    [self.navigationController pushViewController:vc animated:YES];
     */
}


@end
