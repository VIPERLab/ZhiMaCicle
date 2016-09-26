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
#import "NearByPeopleController.h"
#import "ScanQRCodeController.h"

#define ZhiMaCicleCellReusedID @"ZhiMaCicleCellReusedID"

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
    
    [_tableView registerClass:[ZhiMaCicleCell class] forCellReuseIdentifier:ZhiMaCicleCellReusedID];
    
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
    ZhiMaCicleCell *cell = [tableView dequeueReusableCellWithIdentifier:ZhiMaCicleCellReusedID forIndexPath:indexPath];
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
        timeLine.unReadCount = _unReadCount;
        timeLine.circleheadphoto = _circleheadphoto;
        timeLine.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:timeLine animated:YES];
        
    } else if (indexPath.section == 1 && indexPath.row == 0 ) {
        //扫一扫
        ScanQRCodeController *QRCode = [[ScanQRCodeController alloc] init];
        
        //创建参数对象
        LBXScanViewStyle *style = [[LBXScanViewStyle alloc]init];
        
        //矩形区域中心上移，默认中心点为屏幕中心点
        style.centerUpOffset = 44;
        
        //扫码框周围4个角的类型,设置为外挂式
        style.photoframeAngleStyle = LBXScanViewPhotoframeAngleStyle_Outer;
        
        //扫码框周围4个角绘制的线条宽度
        style.photoframeLineW = 6;
        
        //扫码框周围4个角的宽度
        style.photoframeAngleW = 24;
        
        //扫码框周围4个角的高度
        style.photoframeAngleH = 24;
        
        //扫码框内 动画类型 --线条上下移动
        style.anmiationStyle = LBXScanViewAnimationStyle_LineMove;
        
        //线条上下移动图片
        style.animationImage = [UIImage imageNamed:@"qrcode_scan_light_green"];
        
        //SubLBXScanViewController继承自LBXScanViewController
        //添加一些扫码或相册结果处理
        //    SubLBXScanViewController *vc = [SubLBXScanViewController new];
        QRCode.style = style;
        
        QRCode.isQQSimulator = YES;
        QRCode.isVideoZoom = YES;

        QRCode.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:QRCode animated:YES];
    } else if (indexPath.section == 1 && indexPath.row == 1) {
        //附近的人
        NearByPeopleController *nearBy = [[NearByPeopleController alloc] init];
        nearBy.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:nearBy animated:YES];
    }
}



#pragma mark - 未读消息
- (void)unReadCount:(NSNotification *)notification {
    int unReadCount = [notification.userInfo[@"count"] intValue];
    NSString *headphoto = notification.userInfo[@"headphoto"];
    
    _unReadCount = unReadCount;
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
