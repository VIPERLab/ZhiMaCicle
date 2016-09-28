//
//  FriendsController.m
//  ZhiMaBaoBao
//
//  Created by liugang on 16/9/18.
//  Copyright © 2016年 liugang. All rights reserved.
//  好友列表

#import "FriendsController.h"

@interface FriendsController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;

@end

@implementation FriendsController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setCustomRightItems];

    [self requestFriendsList];
    [self addSubviews];
}
//请求好友列表
- (void)requestFriendsList{
    [LGNetWorking getFriendsList:USERINFO.sessionId friendType:FriendTypeFriends success:^(ResponseData *responseData) {
        
    } failure:^(ErrorData *error) {
        
    }];
}

- (void)addSubviews{
    UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    tableView.delegate = self;
    tableView.dataSource = self;
    [self.view addSubview:tableView];
    self.tableView = tableView;
}



@end
