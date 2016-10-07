//
//  NearByPeopleController.m
//  ZhiMaBaoBao
//
//  Created by mac on 16/9/23.
//  Copyright © 2016年 liugang. All rights reserved.
//

#import "NearByPeopleController.h"
#import "NearByModel.h"
#import "NearByPeopleCell.h"
#import "FriendProfilecontroller.h"
#import <BaiduMapAPI_Map/BMKMapComponent.h>
#import <BaiduMapAPI_Search/BMKSearchComponent.h>
#import <BaiduMapAPI_Location/BMKLocationService.h>

#define NearByPeopleCellReusedID @"NearByPeopleCellReusedID"

@interface NearByPeopleController () <BMKGeoCodeSearchDelegate,BMKLocationServiceDelegate,UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) NSMutableArray *dataArr;
@property (nonatomic, weak) UITableView *tableView;
@end

@implementation NearByPeopleController{
    BMKGeoCodeSearch* _geocodesearch;
    BMKLocationService *_locationService;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setCustomTitle:@"附近的人"];
    [self setupView];
    _geocodesearch = [[BMKGeoCodeSearch alloc]init];
    
    BMKLocationService *locationService = [[BMKLocationService alloc]init];
    _locationService = locationService;
    
    
}

-(void)viewWillAppear:(BOOL)animated {
    [LCProgressHUD showLoadingText:@"正在加载附近的人..."];
    _geocodesearch.delegate = self; // 此处记得不用的时候需要置nil，否则影响内存的释放
    _locationService.delegate = self;
    [_locationService startUserLocationService];
}

-(void)viewWillDisappear:(BOOL)animated {
    _geocodesearch.delegate = nil; // 不用时，置nil
    _locationService.delegate = nil;
}



#pragma mark - 定位功能
- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation {
    CLLocation *location = userLocation.location;
    [self loadNearByMessageData:location.coordinate];
    [_locationService stopUserLocationService];
}


- (void)loadNearByMessageData:(CLLocationCoordinate2D)locationCoordinate2D {
    //请求附近的人
    
    [LGNetWorking changeUserLocation:USERINFO.sessionId langtitude:locationCoordinate2D.latitude longtitude:locationCoordinate2D.longitude near:@"near" block:^(ResponseData *responseData) {
        if (responseData.code == 0) {
            [LCProgressHUD hide];
            self.dataArr = [NearByModel mj_objectArrayWithKeyValuesArray:responseData.data];
            [self.tableView reloadData];
        }else{
            [LCProgressHUD showText:responseData.msg];
        }
    }];

}

- (void)didFailToLocateUserWithError:(NSError *)error {
    [LCProgressHUD showFailureText:@"定位失败，请检查是否开启定位服务"];
    NSLog(@"%zd",error.code);
}


- (void)setupView {
    UITableView *tableView =[[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    self.tableView = tableView;
    [self.view addSubview:tableView];
    
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [tableView registerClass:[NearByPeopleCell class] forCellReuseIdentifier:NearByPeopleCellReusedID];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NearByModel *model = self.dataArr[indexPath.row];
    NearByPeopleCell *cell = [tableView dequeueReusableCellWithIdentifier:NearByPeopleCellReusedID forIndexPath:indexPath];
    
    cell.name = model.username;
    cell.iconName = model.head_photo;
    cell.distance = model.distance;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NearByModel *model = self.dataArr[indexPath.row];

    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 55;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 10;
}


#pragma mark - lazyLoad 
- (NSMutableArray *)dataArr {
    if (!_dataArr) {
        _dataArr = [NSMutableArray array];
    }
    return _dataArr;
}

@end
