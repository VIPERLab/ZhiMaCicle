//
//  SendLocationController.m
//  ZhiMaBaoBao
//
//  Created by liugang on 16/10/18.
//  Copyright © 2016年 liugang. All rights reserved.
//

#import "SendLocationController.h"
#import <BaiduMapAPI_Map/BMKMapComponent.h>
#import <BaiduMapAPI_Location/BMKLocationComponent.h>

@interface SendLocationController ()<BMKMapViewDelegate,BMKLocationServiceDelegate>{
    BMKMapView *_mapView;
    BMKLocationService *_locService;
}

@end

@implementation SendLocationController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setCustomTitle:@"位置"];
    [self setNavCustomItems];
    
    //初始化地图图层
    _mapView = [[BMKMapView alloc] initWithFrame:self.view.bounds];
    _mapView.mapType = BMKMapTypeStandard;
    _mapView.zoomLevel = 17;
    [self.view addSubview:_mapView];
    
//    BMKLocationViewDisplayParam *param = [[BMKLocationViewDisplayParam alloc] init];
//    param.accuracyCircleStrokeColor = [UIColor colorWithRed:1 green:0 blue:0 alpha:0.5];
//    param.accuracyCircleFillColor = [UIColor colorWithRed:0 green:1 blue:0 alpha:0.3];
//    [_mapView updateLocationViewWithParam:param];
    
    
    //初始化定位服务
    _locService = [[BMKLocationService alloc]init];
    [_locService startUserLocationService];
    _mapView.showsUserLocation = NO;//先关闭显示的定位图层
    _mapView.userTrackingMode = BMKUserTrackingModeNone;//设置定位的状态
    _mapView.showsUserLocation = YES;//显示定位图层
}

-(void)viewWillAppear:(BOOL)animated {
    [_mapView viewWillAppear];
    _mapView.delegate = self; // 此处记得不用的时候需要置nil，否则影响内存的释放
    _locService.delegate = self;
}

-(void)viewWillDisappear:(BOOL)animated {
    [_mapView viewWillDisappear];
    _mapView.delegate = nil; // 不用时，置nil
    _locService.delegate = nil;
}

//设置导航栏按钮
- (void)setNavCustomItems{
    UIButton *cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 40)];
    cancelBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    [cancelBtn setTitleColor:THEMECOLOR forState:UIControlStateNormal];
    [cancelBtn addTarget:self action:@selector(navBackAction) forControlEvents:UIControlEventTouchUpInside];
    cancelBtn.titleLabel.font = MAINFONT;
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:cancelBtn];
    
    UIButton *sendBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 40)];
    sendBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [sendBtn setTitle:@"发送" forState:UIControlStateNormal];
    [sendBtn setTitleColor:THEMECOLOR forState:UIControlStateNormal];
    [sendBtn addTarget:self action:@selector(sendLocationAction) forControlEvents:UIControlEventTouchUpInside];
    sendBtn.titleLabel.font = MAINFONT;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:sendBtn];
}

//发送位置
- (void)sendLocationAction{
    
}

- (void)navBackAction{
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - map delegate
/**
 *在地图View将要启动定位时，会调用此函数
 *@param mapView 地图View
 */
- (void)willStartLocatingUser
{
    NSLog(@"start locate");
}

/**
 *用户方向更新后，会调用此函数
 *@param userLocation 新的用户位置
 */
- (void)didUpdateUserHeading:(BMKUserLocation *)userLocation
{
    [_mapView updateLocationData:userLocation];
    NSLog(@"heading is %@",userLocation.heading);
}

/**
 *用户位置更新后，会调用此函数
 *@param userLocation 新的用户位置
 */
- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation
{
        NSLog(@"didUpdateUserLocation lat %f,long %f",userLocation.location.coordinate.latitude,userLocation.location.coordinate.longitude);
    [_mapView updateLocationData:userLocation];
    _mapView.centerCoordinate = userLocation.location.coordinate;
}

/**
 *在地图View停止定位后，会调用此函数
 *@param mapView 地图View
 */
- (void)didStopLocatingUser
{
    NSLog(@"stop locate");
}

/**
 *定位失败后，会调用此函数
 *@param mapView 地图View
 *@param error 错误号，参考CLError.h中定义的错误号
 */
- (void)didFailToLocateUserWithError:(NSError *)error
{
    NSLog(@"location error");
}


- (void)dealloc {
    if (_mapView) {
        _mapView = nil;
    }
}

@end
