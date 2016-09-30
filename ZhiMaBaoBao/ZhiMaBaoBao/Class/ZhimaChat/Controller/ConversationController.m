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
#import "ConverseWithouNetworkCell.h"


#define ConverseCellReusedID @"ConverseCellReusedID"
#define ConverseWithoutNetworkCellReusedID @"ConverseWithoutNetworkCellReusedID"

@interface ConversationController () <UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) NSMutableArray *dataArray;

@end

@implementation ConversationController {
    UITableView *_tableView;
    BOOL netWorkStatus;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    netWorkStatus = YES;
    UserInfo *userInfo = [UserInfo shareInstance];
    userInfo.conversationVC = self;
    [self setCustomRightItems];
    [self setupView];

    [self notification];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self getDataFormSqlist];
}


- (void)notification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshConversionList) name:kRecieveNewMessage object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshConversionList) name:kSendMessageStateCall object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkRecovery) name:K_NetworkRecoveryNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(withoutNetwork) name:K_WithoutNetWorkNotification object:nil];
}


// 没有网的情况
- (void)withoutNetwork {
    netWorkStatus = NO;
    [_tableView reloadData];
}

// 有网的情况
- (void)networkRecovery {
    netWorkStatus = YES;
    [_tableView reloadData];
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
    [_tableView registerClass:[ConverseWithouNetworkCell class] forCellReuseIdentifier:ConverseWithoutNetworkCellReusedID];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    ChatController *vc = [[ChatController alloc] init];
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

//收到新消息-从数据库加载最新数据刷新列表
- (void)refreshConversionList{
    [self getDataFormSqlist];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (netWorkStatus) {
        return 1;
    }
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ((netWorkStatus && section == 0) || section == 1) {
        return self.dataArray.count;
    }
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ((netWorkStatus && indexPath.section == 0) || indexPath.section == 1) {
        ConverseModel *model = self.dataArray[indexPath.row];
        
        ConverseCell *cell = [tableView dequeueReusableCellWithIdentifier:ConverseCellReusedID forIndexPath:indexPath];
        cell.model = model;
        
        return cell;
    }
    
    ConverseWithouNetworkCell *cell = [tableView dequeueReusableCellWithIdentifier:ConverseWithoutNetworkCellReusedID forIndexPath:indexPath];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ((netWorkStatus && indexPath.section == 0) || indexPath.section == 1) {
        return 75;
    }
    return 45;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.5;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if ((netWorkStatus && indexPath.section == 0) || indexPath.section == 1) {
        ConverseModel *model = self.dataArray[indexPath.row];
        ChatController *vc = [[ChatController alloc] init];
        vc.conversionId = model.converseId;
        vc.conversionName = model.converseName;
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
        
        //清除未读消息
        model.unReadCount = -1;
        [FMDBShareManager saveConverseListDataWithDataArray:@[model]];
    }
    
    // 点击了没有网络
    
    
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if ((netWorkStatus && indexPath.section == 0) || indexPath.section == 1) {
        return YES;
    }
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ((netWorkStatus && indexPath.section == 0) || indexPath.section == 1) {
        if (editingStyle == UITableViewCellEditingStyleDelete) {
            // Delete the row from the data source.
            ConverseModel *model = self.dataArray[indexPath.row];
            //数据库删除该条会话
            [FMDBShareManager deleteConverseWithConverseId:model.converseId];
            
            [self getDataFormSqlist];
            
        }
    }
}

#pragma mark - lazyLoad


@end
