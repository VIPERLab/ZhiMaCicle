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

@interface SendLocationController ()<BMKMapViewDelegate,BMKLocationServiceDelegate,UITableViewDelegate,UITableViewDataSource>{
    BMKMapView *_mapView;
    BMKLocationService *_locService;
    UISearchBar *_searchBar;
    UITableView *_tableView;
    BMKPointAnnotation *_animatedAnnotation;
    CLLocationCoordinate2D _coordinate;
}
@property (nonatomic, assign) BOOL moveToCenter;    //第一次进去页面，地图移到定位位置

@end

@implementation SendLocationController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setCustomTitle:@"位置"];
    [self setNavCustomItems];
    [self addAllSubviews];
    
}

- (void)addAllSubviews{
    
    self.moveToCenter = YES;
    
    _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 64, DEVICEWITH, 40)];
    _searchBar.backgroundColor = SEPARTORCOLOR;
    _searchBar.placeholder = @"搜索地点";
    [self.view addSubview:_searchBar];
    
    //初始化地图图层
    _mapView = [[BMKMapView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_searchBar.frame), DEVICEWITH, 240)];
    _mapView.mapType = BMKMapTypeStandard;
    _mapView.zoomLevel = 18;
    [self.view addSubview:_mapView];
    
    BMKLocationViewDisplayParam *param = [[BMKLocationViewDisplayParam alloc] init];
    param.isAccuracyCircleShow = NO;
    [_mapView updateLocationViewWithParam:param];
    
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_mapView.frame), DEVICEWITH, DEVICEHIGHT - 280)];
    [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
    
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    return cell;
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
 *地图区域改变完成后会调用此接口
 *@param mapview 地图View
 *@param animated 是否动画
 */
- (void)mapView:(BMKMapView *)mapView regionDidChangeAnimated:(BOOL)animated{
    CLLocationCoordinate2D coor = mapView.centerCoordinate;
    NSLog(@"la --- %f \n  lo----%f",coor.latitude,coor.longitude);
    
    //先移除地图上的大头针
    [_mapView removeAnnotations:_mapView.annotations];
    [self addAnimatedAnnotation:coor];
}

/**
 *用户方向更新后，会调用此函数
 *@param userLocation 新的用户位置
 */
- (void)didUpdateUserHeading:(BMKUserLocation *)userLocation
{
//    [_mapView updateLocationData:userLocation];
//    NSLog(@"heading is %@",userLocation.heading);
}

/**
 *用户位置更新后，会调用此函数
 *@param userLocation 新的用户位置
 */
- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation
{
//        NSLog(@"didUpdateUserLocation lat %f,long %f",userLocation.location.coordinate.latitude,userLocation.location.coordinate.longitude);
    [_mapView updateLocationData:userLocation];
    _coordinate = userLocation.location.coordinate;
    
    
    if (self.moveToCenter) {
        _mapView.centerCoordinate = userLocation.location.coordinate;
        self.moveToCenter = NO;
    }
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


// 添加动画Annotation
- (void)addAnimatedAnnotation:(CLLocationCoordinate2D)coor {
    _animatedAnnotation = [[BMKPointAnnotation alloc]init];
    _animatedAnnotation.coordinate = coor;
    [_mapView addAnnotation:_animatedAnnotation];
}

//自定义大头针
- (BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id <BMKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[BMKPointAnnotation class]]) {
        BMKPinAnnotationView *newAnnotationView = [[BMKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"myAnnotation"];
        newAnnotationView.pinColor = BMKPinAnnotationColorRed;
        newAnnotationView.animatesDrop = YES;// 设置该标注点动画显示
        return newAnnotationView;
    }
    return nil;
}

- (void)dealloc {
    if (_mapView) {
        _mapView = nil;
    }
}

@end
