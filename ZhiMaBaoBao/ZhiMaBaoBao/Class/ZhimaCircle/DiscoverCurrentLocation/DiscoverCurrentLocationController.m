//
//  DiscoverCurrentLocationController.m
//  YiIM_iOS
//
//  Created by mac on 16/8/31.
//  Copyright © 2016年 ikantech. All rights reserved.
//

#import "DiscoverCurrentLocationController.h"
#import <CoreLocation/CoreLocation.h>  //定位FrameWork

#import "KXCurrentLocationCell.h"
#import "LCProgressHUD.h"

@class BMKPoiInfo;

#define KXCurrentLocationCellReusedID @"KXCurrentLocationCellReusedID"

@interface DiscoverCurrentLocationController () <CLLocationManagerDelegate,UITableViewDelegate,UITableViewDataSource,BMKGeoCodeSearchDelegate,BMKLocationServiceDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *dataArray;

//定位功能类
@property (nonatomic,strong) CLLocationManager *manager;
@property (nonatomic,strong) CLGeocoder *geocoder;

@end

@implementation DiscoverCurrentLocationController {
    BMKGeoCodeSearch* _geocodesearch;
    BMKLocationService *_locationService;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupView];
    //定位
    [self setCustomTitle:@"所在位置"];
    _geocodesearch = [[BMKGeoCodeSearch alloc]init];
    
    BMKLocationService *locationService = [[BMKLocationService alloc]init];
    _locationService = locationService;
    
    
}

- (void)setupView {
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.tableView];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self.tableView registerClass:[KXCurrentLocationCell class] forCellReuseIdentifier:KXCurrentLocationCellReusedID];
    
    [LCProgressHUD showLoadingText:@"正在查找附近信息"];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    _geocodesearch.delegate = self; // 此处记得不用的时候需要置nil，否则影响内存的释放
    _locationService.delegate = self;
    [_locationService startUserLocationService];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:YES];
    _geocodesearch.delegate = nil; // 不用时，置nil
    _locationService.delegate = nil;
}

- (void)dealloc {
    if (_geocodesearch != nil) {
        _geocodesearch = nil;
    }
    
    if (_locationService != nil) {
        _locationService = nil;
    }
}

#pragma mark - tableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    KXCurrentLocationCell *cell = [tableView dequeueReusableCellWithIdentifier:KXCurrentLocationCellReusedID forIndexPath:indexPath];
    KXCurrentLocationModel *model = self.dataArray[indexPath.row];
    cell.model = model;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 65;
}


#pragma mark - 定位功能
- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation {
    CLLocation *location = userLocation.location;
    [self getAddressWithCLLocationCoordinate2D:location.coordinate];
    [_locationService stopUserLocationService];
}


- (void)didFailToLocateUserWithError:(NSError *)error {
    [LCProgressHUD showFailureText:@"定位失败，请检查是否开启定位服务"];
    NSLog(@"%zd",error.code);
}

- (void)getAddressWithCLLocationCoordinate2D:(CLLocationCoordinate2D)CLLocationCoordinate2D {
    
    BMKReverseGeoCodeOption *reverseGeocodeSearchOption = [[BMKReverseGeoCodeOption alloc]init];
    reverseGeocodeSearchOption.reverseGeoPoint = CLLocationCoordinate2D;
    BOOL flag = [_geocodesearch reverseGeoCode:reverseGeocodeSearchOption];
    if (flag) {
        NSLog(@"搜索成功");
    } else {
        NSLog(@"搜索失败");
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [LCProgressHUD hide];
    });
    
}


//反地理编码
- (void)onGetReverseGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKReverseGeoCodeResult *)result errorCode:(BMKSearchErrorCode)error {
    [LCProgressHUD hide];
    if (error == 0) {
        BMKPointAnnotation* item = [[BMKPointAnnotation alloc]init];
        item.coordinate = result.location;
        item.title = result.address;
        
        NSMutableArray *addressArray = [NSMutableArray array];
        
        KXCurrentLocationModel *FistModel = [KXCurrentLocationModel new];
        FistModel.name = @"不显示位置";
        FistModel.address = @"";
        FistModel.city = @"";
        FistModel.isShowTick = YES;
        [addressArray addObject:FistModel];
        
        
        KXCurrentLocationModel *model = [KXCurrentLocationModel new];
        model.name = result.address;
        model.address = @"";
        model.city = @"";
        [addressArray addObject:model];
        
        for (BMKPoiInfo *info in result.poiList) {
            KXCurrentLocationModel *model = [KXCurrentLocationModel new];
            model.city = info.city;
            model.address = info.address;
            model.name = info.name;
            [addressArray addObject:model];
        }
        
        self.dataArray = [addressArray copy];
        [self.tableView reloadData];
    }
    
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    KXCurrentLocationModel *model = self.dataArray[indexPath.row];
    self.complitedBlock(model);
    [self.navigationController popViewControllerAnimated:YES];
}


- (CLLocationManager *)manager {
    if (!_manager) {
        _manager = [[CLLocationManager alloc] init];
        _manager.desiredAccuracy = kCLLocationAccuracyThreeKilometers;
        _manager.delegate = self;
    }
    return _manager;
}

- (CLGeocoder *)geocoder {
    if (!_geocoder) {
        _geocoder = [[CLGeocoder alloc]init];
    }
    return _geocoder;
}

- (NSArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [[NSArray alloc] init];
    }
    return _dataArray;
}

@end
