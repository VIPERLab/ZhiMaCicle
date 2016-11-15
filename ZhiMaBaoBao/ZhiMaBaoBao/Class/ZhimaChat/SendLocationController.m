//
//  SendLocationController.m
//  ZhiMaBaoBao
//
//  Created by liugang on 16/10/18.
//  Copyright © 2016年 liugang. All rights reserved.
//

#import "SendLocationController.h"
#import <CoreLocation/CoreLocation.h>  //定位FrameWork
#import <BaiduMapAPI_Map/BMKMapComponent.h>
#import <BaiduMapAPI_Location/BMKLocationComponent.h>
#import <BaiduMapAPI_Search/BMKSearchComponent.h>
#import "KXCurrentLocationCell.h"
#import "KXCurrentLocationModel.h"


@interface SendLocationController ()<BMKMapViewDelegate,BMKLocationServiceDelegate,BMKGeoCodeSearchDelegate,UITableViewDelegate,UITableViewDataSource>{
    BMKMapView *_mapView;
    BMKLocationService *_locService;
    BMKGeoCodeSearch *_geocodesearch;
    UISearchBar *_searchBar;
    UITableView *_tableView;
    BMKPointAnnotation *_animatedAnnotation;
    CLLocationCoordinate2D _coordinate;
}
@property (nonatomic, assign) BOOL moveToCenter;    //第一次进去页面，地图移到定位位置
@property (nonatomic, strong) NSMutableArray *dataArr;
@property (nonatomic, assign) NSInteger lastSelectedRow;    //上一次选中行
@property (nonatomic, assign) BOOL isSeleting;  //正在选择地址， （不重新进行检索）

@end

static NSString *const reuseIdentifier = @"locationCell";

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
    
    //回到自己的位置
    UIButton *baskSelf = [[UIButton alloc] init];
    baskSelf.frame = CGRectMake(DEVICEWITH - 40 - 14, 240 - 60, 40, 40);
    baskSelf.layer.cornerRadius = 20;
    baskSelf.backgroundColor = THEMECOLOR;
    [baskSelf addTapGestureRecognizer:self forAction:@selector(backMyLocation)];
    [_mapView addSubview:baskSelf];
    
    BMKLocationViewDisplayParam *param = [[BMKLocationViewDisplayParam alloc] init];
    param.isAccuracyCircleShow = NO;
    [_mapView updateLocationViewWithParam:param];
    
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_mapView.frame), DEVICEWITH, DEVICEHIGHT - 280 - 64)];
    [_tableView registerClass:[KXCurrentLocationCell class] forCellReuseIdentifier:reuseIdentifier];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.rowHeight = 65;
    [self.view addSubview:_tableView];
    
    //周边搜索服务
    _geocodesearch = [[BMKGeoCodeSearch alloc]init];
    
    //初始化定位服务
    _locService = [[BMKLocationService alloc]init];
    [_locService startUserLocationService];
    _mapView.showsUserLocation = NO;//先关闭显示的定位图层
    _mapView.userTrackingMode = BMKUserTrackingModeNone;//设置定位的状态
    _mapView.showsUserLocation = YES;//显示定位图层
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    
    [_mapView viewWillAppear];
    _mapView.delegate = self; // 此处记得不用的时候需要置nil，否则影响内存的释放
    _locService.delegate = self;
    _geocodesearch.delegate = self;
}

-(void)viewWillDisappear:(BOOL)animated {
    [_mapView viewWillDisappear];
    _mapView.delegate = nil; // 不用时，置nil
    _locService.delegate = nil;
    _geocodesearch.delegate = nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    KXCurrentLocationCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    KXCurrentLocationModel *model = self.dataArr[indexPath.row];
    cell.model = model;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    self.isSeleting = YES;
    
    KXCurrentLocationModel *lastModel = self.dataArr[self.lastSelectedRow];
    lastModel.isShowTick = NO;
    self.lastSelectedRow = indexPath.row;
    KXCurrentLocationModel *model = self.dataArr[self.lastSelectedRow];
    model.isShowTick = YES;
    [_tableView reloadData];
    
    //地理编码
    BMKGeoCodeSearchOption *geocodeSearchOption = [[BMKGeoCodeSearchOption alloc]init];
    geocodeSearchOption.city= model.city;
    geocodeSearchOption.address = model.address;
    BOOL flag = [_geocodesearch geoCode:geocodeSearchOption];
    if(flag)
    {
        NSLog(@"geo检索发送成功");
    }
    else
    {
        NSLog(@"geo检索发送失败");
    }

}

//回到我的位置
- (void)backMyLocation{
    [_mapView setCenterCoordinate:_coordinate animated:YES];
}

//发送位置
- (void)sendLocationAction{
    UIImageView *imageview = [[UIImageView alloc] initWithImage:[_mapView takeSnapshot]];
    imageview.x = 0;
    imageview.y = 64;
    [self.view addSubview:imageview];
}

- (void)navBackAction{
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - map delegate

/**
 *地图区域改变完成后会调用此接口
 *@param mapview 地图View
 *@param animated 是否动画
 */
- (void)mapView:(BMKMapView *)mapView regionDidChangeAnimated:(BOOL)animated{
    
    CLLocationCoordinate2D coor = mapView.centerCoordinate;
    
    if (!self.isSeleting) {
        self.lastSelectedRow = 0;
        //反向地理编码
        BMKReverseGeoCodeOption *reverseGeocodeSearchOption = [[BMKReverseGeoCodeOption alloc]init];
        reverseGeocodeSearchOption.reverseGeoPoint = coor;
        BOOL flag = [_geocodesearch reverseGeoCode:reverseGeocodeSearchOption];
        if (flag) {
            NSLog(@"成功");
        } else {
            NSLog(@"失败");
        }
    }
    
    self.isSeleting = NO;

    //先移除地图上的大头针
    [_mapView removeAnnotations:_mapView.annotations];
    [self addAnimatedAnnotation:coor];
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
    [_mapView setCenterCoordinate:_coordinate animated:YES];
    
    [self addAnimatedAnnotation:_coordinate];
    BMKReverseGeoCodeOption *reverseGeocodeSearchOption = [[BMKReverseGeoCodeOption alloc]init];
    reverseGeocodeSearchOption.reverseGeoPoint = _coordinate;
    BOOL flag = [_geocodesearch reverseGeoCode:reverseGeocodeSearchOption];
    if (flag) {
        NSLog(@"成功");
    } else {
        NSLog(@"失败");
    }
    
    [_locService stopUserLocationService];
}


//正向地理编码成功回调
- (void)onGetGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKGeoCodeResult *)result errorCode:(BMKSearchErrorCode)error
{
    NSArray* array = [NSArray arrayWithArray:_mapView.annotations];
    [_mapView removeAnnotations:array];
    array = [NSArray arrayWithArray:_mapView.overlays];
    [_mapView removeOverlays:array];
    
    if (error == 0) {
        [self addAnimatedAnnotation:result.location];
        [_mapView setCenterCoordinate:result.location animated:YES];
    }
}


//反地理编码成功回调
- (void)onGetReverseGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKReverseGeoCodeResult *)result errorCode:(BMKSearchErrorCode)error {
    [LCProgressHUD hide];
    if (error == 0) {
        //先移除以前的定位数据
        [self.dataArr removeAllObjects];
        
        KXCurrentLocationModel *model = [KXCurrentLocationModel new];
        model.name = result.address;
        model.address = @"";
        model.city = @"";
        model.isShowTick = YES;
        [self.dataArr addObject:model];
        
        for (BMKPoiInfo *info in result.poiList) {
            KXCurrentLocationModel *model = [KXCurrentLocationModel new];
            model.city = info.city;
            model.address = info.address;
            model.name = info.name;
            [self.dataArr addObject:model];
        }
        [_tableView reloadData];
    }
}


/**
 *定位失败后，会调用此函数
 *@param mapView 地图View
 *@param error 错误号，参考CLError.h中定义的错误号
 */
- (void)didFailToLocateUserWithError:(NSError *)error
{
    [LCProgressHUD showFailureText:@"定位失败，请检查是否开启定位服务"];
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

//#pragma mark scrollview delegate
//- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
//    CGPoint offset = scrollView.contentOffset;
//    
//    NSLog(@"----------- %f",offset.y);
//    
//    if (offset.y > 0) {
//        [UIView animateWithDuration:.3 animations:^{
//            _tableView.y = 200;
//            _tableView.height = DEVICEHIGHT - 280  + 80;
//            _mapView.height = 160;
//        }];
//    }else{
//        [UIView animateWithDuration:.3 animations:^{
//            _tableView.y = 280;
//            _tableView.height = DEVICEHIGHT - 280;
//            _mapView.height = 240;
//        }];
//    }
//}

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

- (NSMutableArray *)dataArr{
    if (!_dataArr) {
        _dataArr = [NSMutableArray array];
    }
    return _dataArr;
}

- (void)dealloc {
    if (_mapView) {
        _mapView = nil;
    }
    
    if (_geocodesearch != nil) {
        _geocodesearch = nil;
    }
    
    if (_locService != nil) {
        _locService = nil;
    }
}

@end
