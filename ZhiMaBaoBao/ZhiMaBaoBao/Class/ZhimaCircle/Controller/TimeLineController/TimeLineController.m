//
//  TimeLineController.m
//  ZhiMaBaoBao
//
//  Created by liugang on 16/9/18.
//  Copyright © 2016年 liugang. All rights reserved.
//  芝麻圈

#import "TimeLineController.h"
#import "ZhiMaCicleCell.h"
#import "SDTimeLineTableViewController.h"

@interface TimeLineController () <UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) NSArray *titleArray;
@property (nonatomic, strong) NSArray *iconArray;
@end

@implementation TimeLineController {
    UITableView *_tableView;
    int _unReadCount;
    NSString *_unReadHeadphoto;
    NSString *_circleheadphoto;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setCustomRightItems];
    [self setupView];
    [self notification];
}

- (void)viewDidAppear:(BOOL)animated {
    //发送消息更新未读朋友圈和未读消息数
    
    if (USERINFO.unReadCount == 0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:K_UpdataUnReadNotification object:nil];
    }
}

// ----  通知
- (void)notification {
    //未读消息数
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(unReadCount:) name:K_UpDataUnReadCountNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(unReadCircle:) name:K_UpDataHeaderPhotoNotification object:nil];
}


- (void)setupView {
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    [self.view addSubview:_tableView];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [_tableView registerClass:[ZhiMaCicleCell class] forCellReuseIdentifier:@"CircleCell"];
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.titleArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *arr = self.titleArray[section];
    return arr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *titleArr = self.titleArray[indexPath.section];
    NSArray *iconArr = self.iconArray[indexPath.section];
    ZhiMaCicleCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CircleCell" forIndexPath:indexPath];
    cell.title = titleArr[indexPath.row];
    cell.imageName = iconArr[indexPath.row];
    cell.unReadCount = 0;
    
    if (indexPath.section == 0 && indexPath.row == 0) {
        cell.unReadCount = _unReadCount;
        cell.unReadImage = _circleheadphoto;
    }
    
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 45;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 20;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0 && indexPath.row == 0) {
        //朋友圈
        SDTimeLineTableViewController *timeLine = [[SDTimeLineTableViewController alloc] init];
        timeLine.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:timeLine animated:YES];
        
    } else if (indexPath.section == 1 && indexPath.row == 0 ) {
        //扫一扫
        
    } else if (indexPath.section == 1 && indexPath.row == 1) {
        //附近的人
        
    }
}



#pragma mark - 未读消息
- (void)unReadCount:(NSNotification *)notification {
    int unReadCount = [notification.userInfo[@"count"] intValue];
    _unReadCount = unReadCount;
    NSString *headphoto = notification.userInfo[@"headphoto"];
    _unReadHeadphoto = headphoto;
    [_tableView reloadData];
    NSLog(@"未读消息数:%zd  ----- 未读消息头像 %@",unReadCount,headphoto);
}

#pragma mark - 未读朋友圈
- (void)unReadCircle:(NSNotification *)notification {
    NSString *circleheadphoto = notification.userInfo[@"headerPhoto"];
    _circleheadphoto = circleheadphoto;
    [_tableView reloadData];
    NSLog(@"未读朋友圈头像 %@",circleheadphoto);
}

#pragma mark - lazyLoad
- (NSArray *)titleArray {
    if (!_titleArray) {
        _titleArray = @[@[@"朋友圈"],@[@"扫一扫",@"附近的人"]];
    }
    return _titleArray;
}

- (NSArray *)iconArray {
    if (!_iconArray) {
        _iconArray = @[@[@"Circle"],@[@"saoyisao",@"nearBy"]];
    }
    return _iconArray;
}

@end
