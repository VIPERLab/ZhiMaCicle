//
//  PesonalDiscoverController.m
//  YiIM_iOS
//
//  Created by mac on 16/8/22.
//  Copyright © 2016年 ikantech. All rights reserved.
//

#import "PesonalDiscoverController.h"
#import "MJRefresh.h"   //下拉刷新
#import "SDTimeLineTableHeaderView.h"   //头部控件

#import "PersonalDiscoverCell.h"
#import "NSString+FontSize.h"
#import "LGNetWorking.h"   //网络请求工具类

#import "UserMessageController.h" //个人消息
#import "DiscoverDetailController.h"  //朋友圈详情
#import "NewDiscoverController.h"  //发布新的说说
#import "YiUserInfoViewController.h" //详情

@interface PesonalDiscoverController () <UITableViewDelegate,UITableViewDataSource,SDTimeLineTableHeaderViewDelegate,PersonalDiscoverCellDelegate,DiscoverDetailControllerDelegate>

@property (nonatomic, weak) UITableView *tableView;

@property (nonatomic, weak) SDTimeLineTableHeaderView *headerView;

@property (nonatomic, strong) NSMutableArray *dataArray;

@property (nonatomic, assign) int pageNumber;

@end

#define PersonalDiscoverTableViewCellReusedID @"PersonalDiscoverTableViewCellReusedID"

@implementation PesonalDiscoverController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.pageNumber = 0;
    [self setupView];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setupHeaderAndFooterRefresh];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupView {
    
    if ([USERINFO.openfireAccount isEqualToString:self.openFirAccount]) {
        [self setCustomRightBarBUtton:@"消息"];

    }
    
    [self setCustomTitle:@"相册"];
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 64) style:UITableViewStyleGrouped];
    self.tableView = tableView;
    [self.view addSubview:tableView];
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.backgroundColor = [UIColor whiteColor];
    
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.edgesForExtendedLayout = UIRectEdgeTop;
    
    [tableView registerClass:[PersonalDiscoverCell class] forCellReuseIdentifier:PersonalDiscoverTableViewCellReusedID];
    
    
    //设置头部
    SDTimeLineTableHeaderView *headerView = [SDTimeLineTableHeaderView new];
    headerView.delegate = self;
    self.headerView = headerView;
    headerView.frame = CGRectMake(0, 0, 0, 260);
    self.tableView.tableHeaderView = headerView;
    
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    PersonalDiscoverCellModel *model = self.dataArray[section];
    
    return model.imglist.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    PersonalDiscoverCellModel *model = self.dataArray[indexPath.section];
    
    PersonalDiscoverPhotoModel *photoModel = model.imglist[indexPath.row];
    
    PersonalDiscoverCell *cell = [tableView dequeueReusableCellWithIdentifier:PersonalDiscoverTableViewCellReusedID forIndexPath:indexPath];
    cell.openFirAccount = self.openFirAccount;
    cell.model = photoModel;
    cell.personalIndexPath = indexPath;
    cell.delegate = self;
    
    if (indexPath.row == 0) {
        [cell setupYear:model.year andMonth:model.month andDay:model.day];
        cell.isShowTimeLabel = YES;
    } else {
        [cell setupYear:@"" andMonth:@"" andDay:@""];
        cell.isShowTimeLabel = NO;
    }
    
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    PersonalDiscoverCellModel *model = self.dataArray[indexPath.section];
    PersonalDiscoverPhotoModel *photoModel = model.imglist[indexPath.row];
    return photoModel.cellHight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 5;
}


- (CGFloat)cellContentViewWith
{
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    
    // 适配ios7横屏
    if ([UIApplication sharedApplication].statusBarOrientation != UIInterfaceOrientationPortrait && [[UIDevice currentDevice].systemVersion floatValue] < 8) {
        width = [UIScreen mainScreen].bounds.size.height;
    }
    return width;
}


#pragma mark - Cell的点击事件
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    PersonalDiscoverCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if ([cell.openFirAccount isEqualToString:USERINFO.openfireAccount] && indexPath.section == 0 && indexPath.row == 0) {
        return;
    }

    DiscoverDetailController *dc = [[DiscoverDetailController alloc] init];
    dc.sessionId = USERINFO.sessionId;
    dc.ID = [NSString stringWithFormat:@"%zd",cell.model.ID];
//    dc.delegate = self;
    dc.indexPath = indexPath;
    [self.navigationController pushViewController:dc animated:YES];
    
}


#pragma mark - 网络请求
- (void)loadRequest {
    
    
    [LGNetWorking loadPersonalDiscoverDetailWithSessionID:self.sessionID andTargetOpenFirAccount:self.openFirAccount andPageNumber:[NSString stringWithFormat:@"%zd",self.pageNumber] block:^(ResponseData *responseData) {
        [self.tableView.mj_footer endRefreshing];
        if (responseData == nil || responseData.data == nil || !responseData) {
            NSLog(@"网络请求失败");
            return;
        }
        
        //没有更多数据
        if (responseData.code == 23 || responseData.code == 29) {
            [self.tableView.mj_footer endRefreshingWithNoMoreData];
            return;
        }
        
        
        if (responseData.code != 0) {
            return;
        }
        
        if (responseData.data[@"backgroundImg"]) {
            self.headerView.BJImage = responseData.data[@"backgroundImg"];
        }
        
        if (responseData.data[@"headPhoto"]) {
            self.headerView.userImage = responseData.data[@"headPhoto"];
        }
        
        if (responseData.data[@"username"]) {
            self.headerView.userName = responseData.data[@"username"];
        }
        
        if (responseData.data[@"signature"]) {
            self.headerView.signName = responseData.data[@"signature"];
        }
        
        self.headerView.openFirAccount = self.openFirAccount;
        
        
        NSMutableArray *dataArray = [PersonalDiscoverCellModel mj_objectArrayWithKeyValuesArray:responseData.data[@"albumsDate"]];
        
        
        for (PersonalDiscoverCellModel *model in dataArray) {
            NSMutableArray *photoListArray = [NSMutableArray array];
            for (NSInteger index = 0; index < model.imglist.count; index ++) {
                PersonalDiscoverPhotoModel *photoList = [PersonalDiscoverPhotoModel mj_objectWithKeyValues:model.imglist[index]];
                photoList.imageList = [self changeImageStringToImageArrayWithString:photoList.img_s];
                [photoListArray addObject:photoList];
                
                if (![photoList.img_s isEqualToString:@""]) {
                    photoList.cellHight = 80;
                } else {
                    CGFloat cellHight = [self changeStationWidth:photoList.content anWidthTxtt:300 anfont:15];
                    photoList.cellHight = cellHight + 15;
                }
            }
            model.imglist = photoListArray;
        }
        
        self.dataArray = dataArray;
        [self.tableView reloadData];
        
        
    }];
}

- (NSArray *)changeImageStringToImageArrayWithString:(NSString *)imageStr {
    
    if ([imageStr isEqualToString:@""]) {
        return @[];
    }
    
    NSArray *array = [imageStr componentsSeparatedByString:@","];
    

    return [array copy];
}

#pragma mark - headerViewClick
- (void)SDTimeLineTableHeaderViewHeaderViewDidClick:(SDTimeLineTableHeaderView *)headerView {
    YiUserInfoViewController *info = [[YiUserInfoViewController alloc] init];
    info.jid = [NSString stringWithFormat:@"%@@localhost",self.openFirAccount];
    [self.navigationController pushViewController:info animated:YES];
}


- (void)setupHeaderAndFooterRefresh {
    if (!self.tableView.mj_footer) {
        self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
            self.pageNumber++;
            [self loadRequest];
        }];
        [self.tableView.mj_footer beginRefreshing];
    } else {
        [self loadRequest];
    }
    
}



#pragma mark - 照相的点击事件
- (void)PersonalDiscoverCellFirstCellDidClick {
    NewDiscoverController *new = [[NewDiscoverController alloc] init];
    new.block = ^() {
        
    };
    [self.navigationController pushViewController:new animated:YES];
}


#pragma mark - 消息按钮点击事件
- (void)rightBarButtonAction {
    UserMessageController *vc = [[UserMessageController alloc ]init];
    vc.isShowAllMessage = YES;
    [self.navigationController pushViewController:vc animated:YES];
}


#pragma mark - 计算文本高度
-(CGFloat)changeStationWidth:(NSString *)string anWidthTxtt:(CGFloat)widthText anfont:(CGFloat)fontSize{
    
    UIFont * tfont = [UIFont systemFontOfSize:fontSize];
    
    //高度估计文本大概要显示几行，宽度根据需求自己定义。 MAXFLOAT 可以算出具体要多高
    
    CGSize size =CGSizeMake(widthText,60);
    
    //    获取当前文本的属性
    
    NSDictionary * tdic = [NSDictionary dictionaryWithObjectsAndKeys:tfont,NSFontAttributeName,nil];
    
    //ios7方法，获取文本需要的size，限制宽度
    
    CGSize  actualsize =[string boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin  attributes:tdic context:nil].size;
    
    return actualsize.height;
}

- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}


@end
