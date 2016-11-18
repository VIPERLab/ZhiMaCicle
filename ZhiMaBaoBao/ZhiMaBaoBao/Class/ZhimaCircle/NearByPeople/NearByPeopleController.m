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

@interface NearByPeopleController () <BMKGeoCodeSearchDelegate,BMKLocationServiceDelegate,UITableViewDelegate,UITableViewDataSource,UIAlertViewDelegate>
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
    [_locationService startUserLocationService];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    _geocodesearch.delegate = self; // 此处记得不用的时候需要置nil，否则影响内存的释放
    _locationService.delegate = self;
}

-(void)viewWillDisappear:(BOOL)animated {
    [LCProgressHUD hide];
    _geocodesearch.delegate = nil; // 不用时，置nil
    _locationService.delegate = nil;
}



#pragma mark - 定位功能
- (void)willStartLocatingUser {
    [LCProgressHUD showLoadingText:@"正在查找附近信息"];
}

- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation {
    [LCProgressHUD hide];
    CLLocation *location = userLocation.location;
    [self loadNearByMessageData:location.coordinate];
    [_locationService stopUserLocationService];
}


- (void)loadNearByMessageData:(CLLocationCoordinate2D)locationCoordinate2D {
    //请求附近的人
    [LCProgressHUD showLoadingText:@"正在加载附近的人..."];
    [LGNetWorking changeUserLocation:USERINFO.sessionId langtitude:locationCoordinate2D.latitude longtitude:locationCoordinate2D.longitude near:@"near" block:^(ResponseData *responseData) {
        if (responseData.code == 0) {
            [LCProgressHUD hide];
            self.dataArr = [NearByModel mj_objectArrayWithKeyValuesArray:responseData.data];
            [self.tableView reloadData];
        }else{
            [LCProgressHUD showFailureText:responseData.msg];
        }
    }];

}

- (void)didFailToLocateUserWithError:(NSError *)error {
    [LCProgressHUD hide];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"请在IPhone的”设置 - 隐私 - 定位服务“选项中，允许芝麻宝宝访问您的位置" delegate:self cancelButtonTitle:@"好" otherButtonTitles:nil];
    [alertView show];
    NSLog(@"%zd",error.code);
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [self.navigationController popViewControllerAnimated:YES];
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
    cell.signature = model.signature;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NearByModel *model = self.dataArr[indexPath.row];
    FriendProfilecontroller *vc = [[FriendProfilecontroller alloc] init];
    vc.userId = model.uid;
    [self.navigationController pushViewController:vc animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 65;
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
