//
//  ComplainViewController.m
//  YiIM_iOS
//
//  Created by mac on 16/9/9.
//  Copyright © 2016年 ikantech. All rights reserved.
//

#import "ComplainViewController.h"
#import "ComplainSubViewController.h"
#import "KXWebViewController.h"

#import "UIColor+My.h"
#import "LGNetWorking.h"

#define ComplainCellReusedID @"ComplainCellReusedID"

@interface ComplainViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSArray *dataArray;

@end

@implementation ComplainViewController {
    UITableView *_tableView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setCustomTitle:@"投诉"];
    
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [self.view addSubview:_tableView];
    _tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:ComplainCellReusedID];
    
    
    CGFloat buttonW = 100;
    CGFloat buttonH = 30;
    CGFloat buttonX = ([UIScreen mainScreen].bounds.size.width - buttonW) * 0.5;
    CGFloat buttonY = [UIScreen mainScreen].bounds.size.height - buttonH - 20;
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(buttonX, buttonY, buttonW, buttonH)];
    
    [button setTitle:@"投诉须知" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor colorFormHexRGB:@"576b95"] forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:13];
    [button addTarget:self action:@selector(buttonDidClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    [self.view bringSubviewToFront:button];
    
    
    
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *reasonStr = self.dataArray[indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ComplainCellReusedID forIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.text = reasonStr;
    cell.textLabel.font = [UIFont boldSystemFontOfSize:15];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 40;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 40)];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, CGRectGetWidth(headerView.frame), CGRectGetHeight(headerView.frame))];
        label.text = @"请选择投诉该朋友圈的原因:";
        label.font = [UIFont systemFontOfSize:13];
        label.textColor = [UIColor lightGrayColor];
        [headerView addSubview:label];
        return headerView;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self complainReason:self.dataArray[indexPath.row]];
}




- (void)complainReason:(NSString *)reason {
    [LGNetWorking ComplainsUserWithSessionID:USERINFO.sessionId andTheOpenFireAccount:self.model.userId andComplainsReason:reason andComplainFriendCicle:self.model.circle_ID block:^(ResponseData *responseData) {
        
        if (responseData.code != 0) {
            return ;
        }
        
        ComplainSubViewController *subView = [[ComplainSubViewController alloc] init];
        [self.navigationController pushViewController:subView animated:YES];
        NSLog(@"投诉成功");
        
    }];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)buttonDidClick {
    KXWebViewController *web = [[KXWebViewController alloc] init];
    web.navTitleName = @"投诉须知";
    web.htmlURL = [NSString stringWithFormat:@"%@/complaints_reread.html",DFAPIURL];
    [self.navigationController pushViewController:web animated:YES];
}

- (NSArray *)dataArray {
    if (!_dataArray) {
        _dataArray = @[@"发布不适当内容对我造成骚扰",@"发布带诱导分享性质的内容",@"传播谣言信息",@"存在侵权行为",@"发布仿冒品信息"];
    }
    return _dataArray;
}

@end
