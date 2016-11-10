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
#import "ServiceViewController.h"


#define ConverseCellReusedID @"ConverseCellReusedID"
#define ConverseWithoutNetworkCellReusedID @"ConverseWithoutNetworkCellReusedID"

@interface ConversationController () <UITableViewDelegate,UITableViewDataSource>{
    dispatch_source_t timer1;
}

@property (nonatomic, strong) dispatch_source_t timer;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, assign) CGFloat timeCount;

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
    
    self.timeCount = -1;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self getDataFormSqlist];
    
    //发送更新未读消息通知
    [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateUnReadMessage object:nil];
}


- (void)notification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshConversionList:) name:kRecieveNewMessage object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshConversionList:) name:kSendMessageStateCall object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshConversionList:) name:kRecieveActivityMsg object:nil];
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
- (void)getDataFormSqlist{
    
    //用来删除拉黑好友的会话列表
    UserInfo *info = [UserInfo shareInstance];
    if (info.blackUserId) {
        // 删除该会话
        [FMDBShareManager deleteConverseWithConverseId:info.blackUserId];
        info.blackUserId = nil;
    }
    
    //先清空会话数组
    [self.dataArray removeAllObjects];
    
    NSArray *dataArray = [FMDBShareManager getChatConverseDataInArray];
    
    self.dataArray = [dataArray mutableCopy];
    
    [_tableView reloadData];
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

//收到新消息-从数据库加载最新数据刷新列表
- (void)refreshConversionList:(NSNotification *)notify{
//    LGMessage *recieveMsg = notify.userInfo[@"message"];
//    
//    //刷新消息对应的会话
//    //1.从数据取出最新的会话模型
//    NSString *conversionId = nil;
//    if (recieveMsg.isGroup) {
//        conversionId = recieveMsg.toUidOrGroupId;
//    }else{
//        conversionId = recieveMsg.fromUid;
//    }
//    ConverseModel *conversion = [FMDBShareManager searchConverseWithConverseID:conversionId andConverseType:recieveMsg.isGroup];
//    //2.根据需要更新的会话id,找到数据源数组对应的会话  删除旧的，将新的插入第一个
//    for (int i = 0; i < self.dataArray.count; i ++) {
//        ConverseModel *model = self.dataArray[i];
//        if ([model.converseId isEqualToString:conversionId]) {
//            [self.dataArray removeObjectAtIndex:i];
//
//            break;
//        }
//    }
//    [self.dataArray insertObject:conversion atIndex:0];
//    [_tableView reloadData];
//    
//    CGFloat time = 0;
//    __block
//    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
//    timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,queue);
//    dispatch_source_set_timer(timer,dispatch_walltime(NULL, 0),0.1*NSEC_PER_SEC, 0); //每0.1秒执行
//    dispatch_source_set_event_handler(timer, ^{
////        time += 0.1;
//    });
//    dispatch_resume(timer);
//    if (self.timeCount > 0.4 || self.timeCount == -1) {
//        //先清空会话数组
//        [self.dataArray removeAllObjects];
//        
//        NSArray *dataArray = [FMDBShareManager getChatConverseDataInArray];
//        
//        self.dataArray = [dataArray mutableCopy];
//        [_tableView reloadData];
//    }
//    
//    self.timeCount = 0;
//    
//    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
//    self.timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,queue);
//    dispatch_source_set_timer(self.timer,dispatch_walltime(NULL, 0),0.1*NSEC_PER_SEC, 0); //每0.1秒执行
//    dispatch_source_set_event_handler(self.timer, ^{
//        self.timeCount += 0.1;
//    });
//    dispatch_resume(self.timer);
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
    
    //没有网络显示的cell
    ConverseWithouNetworkCell *cell = [tableView dequeueReusableCellWithIdentifier:ConverseWithoutNetworkCellReusedID forIndexPath:indexPath];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ((netWorkStatus && indexPath.section == 0) || indexPath.section == 1) {
        return 75;
    }
    return 43;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.5;
}

- (CGFloat)tableView:(UITableView *)tableView  heightForFooterInSection:(NSInteger)section {
    return 0.5;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if ((netWorkStatus && indexPath.section == 0) || indexPath.section == 1) {
        
        ConverseModel *model = self.dataArray[indexPath.row];
        if (model.converseType == ConversionTypeActivity) {
            //隐藏红包类型会话

//            ServiceViewController *vc = [[ServiceViewController alloc] init];
//            vc.conversionModel = model;
//            vc.hidesBottomBarWhenPushed = YES;
//            [self.navigationController pushViewController:vc animated:YES];
        }else{
        
            ChatController *vc = [[ChatController alloc] init];
            vc.conversionId = model.converseId;
            vc.conversionName = model.converseName;
            vc.converseLogo = model.converseHead_photo;
            vc.converseType = model.converseType;
            vc.numOfUnread = model.unReadCount;
            vc.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:vc animated:YES];
        }

        //清除未读消息
        [FMDBShareManager setConverseUnReadCountZero:model.converseId];

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
