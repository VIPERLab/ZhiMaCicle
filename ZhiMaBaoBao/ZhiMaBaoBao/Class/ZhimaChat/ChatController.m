//
//  ChatController.m
//  ZhiMaBaoBao
//
//  Created by liugang on 16/9/21.
//  Copyright © 2016年 liugang. All rights reserved.
//  聊天页面

#import "ChatController.h"
#import "ChatKeyBoard.h"

@interface ChatController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) ChatKeyBoard *keyboard;
@end

@implementation ChatController

- (void)viewDidLoad{
    [super viewDidLoad];
    
    [self addSubviews];
}

- (void)addSubviews{
    UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    tableView.dataSource = self;
    tableView.delegate = self;
    [self.view addSubview:tableView];
    self.tableView = tableView;
    
    //初始化键盘
    ChatKeyBoard *keyboard = [ChatKeyBoard keyBoard];
    
}


@end
