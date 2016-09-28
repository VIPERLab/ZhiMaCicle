//
//  ConversationController.m
//  ZhiMaBaoBao
//
//  Created by liugang on 16/9/18.
//  Copyright © 2016年 liugang. All rights reserved.
//  会话列表

#import "ConversationController.h"
#import "ChatController.h"

#import "ConverseCell.h"


#define ConverseCellReusedID @"ConverseCellReusedID"

@interface ConversationController () <UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) NSMutableArray *dataArray;

@end

@implementation ConversationController {
    UITableView *_tableView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setCustomRightItems];
    
    [self setupView];
    [self getDataFormSqlist];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recievedNewMessage) name:kRecieveNewMessage object:nil];
}

#pragma mark - 从数据库加载会话列表
- (void)getDataFormSqlist {
    //先清空会话数组
    [self.dataArray removeAllObjects];
    
    NSArray *dataArray = [FMDBShareManager getChatConverseDataInArray];
    self.dataArray = [dataArray mutableCopy];
    [_tableView reloadData];
}

//  保存会话信息
- (void)saveDataToSqlist:(NSArray *)dataArray {
    [FMDBShareManager saveConverseListDataWithDataArray:dataArray];
}

- (void)setupView {
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    [self.view addSubview:_tableView];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [_tableView registerClass:[ConverseCell class] forCellReuseIdentifier:ConverseCellReusedID];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    ChatController *vc = [[ChatController alloc] init];
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

//收到新消息-从数据库加载最新数据刷新列表
- (void)recievedNewMessage{
    [self getDataFormSqlist];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ConverseModel *model = self.dataArray[indexPath.row];
    
    ConverseCell *cell = [tableView dequeueReusableCellWithIdentifier:ConverseCellReusedID forIndexPath:indexPath];
    cell.model = model;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 75;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.5;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    ConverseModel *model = self.dataArray[indexPath.row];
    ChatController *vc = [[ChatController alloc] init];
    vc.hidesBottomBarWhenPushed = YES;
    vc.conversionId = model.converseId;
    [self.navigationController pushViewController:vc animated:YES];
}


#pragma mark - lazyLoad


@end
