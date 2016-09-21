//
//  UserMessageController.m
//  YiIM_iOS
//
//  Created by mac on 16/8/24.
//  Copyright © 2016年 ikantech. All rights reserved.
//

#import "UserMessageController.h"
#import "UserMessageCell.h"

#import "SDAutoLayout.h"

#import "LGNetWorking.h"

#import "DiscoverDetailController.h"
#import "MJRefresh.h"
#import "NSString+FontSize.h"

#define UserMessageCellReusedID @"UserMessageCellReusedID"

@interface UserMessageController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, weak) UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *dataArray;

@property (nonatomic, copy) NSString *lastFccid;

//页数控制
@property (nonatomic, assign) int pageNumber;

@end

@implementation UserMessageController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.pageNumber = 1;
    self.lastFccid = @"0";
    
    [self setupNav];
    [self setupView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setupRefreashFooter];
}

- (void)loadData {  //请求消息列表
    [LGNetWorking getUnReadMessageWithSessionID:USERINFO.sessionId andOpenFirAccount:USERINFO.openfireAccount block:^(ResponseData *responseData) {
        if (responseData.code != 0) {
            [LCProgressHUD showText:@"请检查网络"];

            return ;
        }
        _isShowAllMessage = YES;
        [self.tableView.mj_footer endRefreshing];
        NSArray *dataArray = [UserMessageModel mj_objectArrayWithKeyValuesArray:responseData.data[@"content"]];
        
        for (UserMessageModel *model  in dataArray) {
            if (model.type == 1) {  //1朋友圈的评论,2点赞
                CGFloat Height = [model.content sizeWithFont:[UIFont systemFontOfSize:15] maxSize:CGSizeMake([UIScreen mainScreen].bounds.size.width - 140, MAXFLOAT)].height;
                model.cellHight = Height + 60;
            } else {
                model.cellHight = 80;
            }
            
        }
        
        self.lastFccid = responseData.data[@"last_fccid"];
        self.dataArray = [dataArray mutableCopy];
        USERINFO.unReadCount = 0;
        [self.tableView reloadData];
        
    }];
    
}

- (void)setupNav {
    [self setCustomTitle:@"消息"];
    [self setCustomRightBarBUtton:@"清空"];

    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.edgesForExtendedLayout = UIRectEdgeTop;
}

- (void)setupView {
    UITableView *tableView=  [[UITableView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 64 ) style:UITableViewStylePlain];
    self.tableView = tableView;
    [self.view addSubview:tableView];
    

    tableView.separatorStyle = UITableViewCellSelectionStyleNone;
    
    tableView.dataSource = self;
    tableView.delegate = self;
    
    [tableView registerClass:[UserMessageCell class] forCellReuseIdentifier:UserMessageCellReusedID];
    
    
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UserMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:UserMessageCellReusedID];
    
    cell.model = self.dataArray[indexPath.row];
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //Cell的点击
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UserMessageCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    DiscoverDetailController *pc = [[DiscoverDetailController alloc] init];
    pc.ID = [NSString stringWithFormat:@"%zd",cell.model.comment_type_Id];
    pc.sessionId = USERINFO.sessionId;
    [self.navigationController pushViewController:pc animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    UserMessageModel *model = self.dataArray[indexPath.row];
    return model.cellHight;
}


#pragma mark - 加载更多 
- (void)setupRefreashFooter {
    self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        if (self.isShowAllMessage) {
            [self loadMoreData]; //请求所有消息数
        } else {
            [self loadData]; //请求未读消息数
        }
    }];
    
    [self.tableView.mj_footer beginRefreshing];
    
    
    
    
}

- (void)loadMoreData {
    [LGNetWorking LoadUserMessageListWithSessionID:USERINFO.sessionId andOpenFirAccount:USERINFO.openfireAccount andLastFccid:self.lastFccid andPageCount:[NSString stringWithFormat:@"%zd",self.pageNumber] block:^(ResponseData *responseData) {
        if (responseData == nil || responseData.data == nil || !responseData.data) {
            NSLog(@"数据请求失败");
            return ;
        }
        
        //没有更多数据
        if (responseData.code == 23 || responseData.code == 29) {
            [self.tableView.mj_footer endRefreshingWithNoMoreData];
            return;
        }
        
        self.pageNumber++;
        NSArray *dataArray = [UserMessageModel mj_objectArrayWithKeyValuesArray:responseData.data];
        
        for (UserMessageModel *model  in dataArray) {
            if (model.type == 1) {  //1朋友圈的评论,2点赞
                CGFloat Height = [model.content sizeWithFont:[UIFont systemFontOfSize:15] maxSize:CGSizeMake([UIScreen mainScreen].bounds.size.width - 140, MAXFLOAT)].height;
                model.cellHight = Height + 60;
            } else {
                model.cellHight = 80;
            }
            
        }
        
        [self.dataArray addObjectsFromArray:dataArray];
        [self.tableView.mj_footer endRefreshing];
        [self.tableView reloadData];
    }];
}

#pragma mark - 清空按钮
- (void)rightBarButtonAction {
    [LGNetWorking ClearMessageListWithSessionID:USERINFO.sessionId andOpenFirAccount:USERINFO.openfireAccount block:^(ResponseData *responseData) {
        
        if (responseData.code != 0) {
            return ;
            NSLog(@"请求失败");
        }
        
        [self.navigationController popViewControllerAnimated:YES];
        
    }];
}



#pragma mark - LazyLoad
- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [[NSMutableArray alloc] init];
    }
    return _dataArray;
}


@end
