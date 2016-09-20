//
//  KXLocationController.m
//  YiIM_iOS
//
//  Created by mac on 16/8/29.
//  Copyright © 2016年 ikantech. All rights reserved.
//

#import "KXLocationController.h"
#import "MJExtension.h"
#import "LGNetWorking.h"
#import "KXLocationCell.h"
#import <CoreLocation/CoreLocation.h>  //定位FrameWork
#import "LGNetWorking.h"
#import "KXLocationModel.h"
//#import "YiUserInfo.h"

#import "SelectedAreaController.h" //选择地区控制器
#import "LCProgressHUD.h"

#define KXLocationTableViewCellReusedID @"KXLocationTableViewCellReusedID"
#define KXLocationTableViewNormalCellReusedID @"KXLocationTableViewNormalCellReusedID"

@interface KXLocationController () <UITableViewDelegate,UITableViewDataSource,CLLocationManagerDelegate>
@property (nonatomic, weak) UITableView *tableView;
//@property (nonatomic, strong) YiXmppVCard * vcard;
@property (nonatomic, strong) NSArray *datasArray;
@property (nonatomic, weak) UILabel *subTitleLabel;
@property (nonatomic, copy) NSString *currentLoaction; //当前位置
@property (nonatomic, copy) NSString *selectedLoaction; //选择的位置

//通知回调保存的信息
@property (nonatomic, strong) KXLocationModel *provinceModel;
@property (nonatomic, strong) KXLocationModel *areaModel;

//定位功能类
@property (nonatomic,strong) CLLocationManager *manager;
@property (nonatomic,strong) CLGeocoder *geocoder;
@end

@implementation KXLocationController {
    NSString *_provinceName;
    NSString *_areaName;
}



- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self request];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setCustomTitle:@"选择地区"];
    [self setupView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupView {
//    YiUserInfo * userInfo = [YiUserInfo defaultUserInfo];
//    _vcard = [[YiXmppVCard alloc] init];
//    [_vcard load:[userInfo getJid] forceIntenet:NO success:nil failed:nil];
    
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 64) style:UITableViewStyleGrouped];
    self.tableView = tableView;
    [self.view addSubview:tableView];
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.delegate = self;
    tableView.dataSource = self;
    
    [tableView registerClass:[KXLocationCell class] forCellReuseIdentifier:KXLocationTableViewCellReusedID];
    [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:KXLocationTableViewNormalCellReusedID];
    
    //定位
    if ([UIDevice currentDevice].systemVersion.floatValue >= 8.0) {
        [self.manager requestWhenInUseAuthorization];
    } else {
        [self.manager startUpdatingLocation];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 1) {
        return self.datasArray.count;
    }
    
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section != 1) {
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:KXLocationTableViewNormalCellReusedID forIndexPath:indexPath];
        if (indexPath.section == 0) {
            cell.textLabel.text = self.currentLoaction;
        } else {
            cell.textLabel.text = self.selectedLoaction;
        }
        
        return cell;
        
    }
    
    KXLocationCell *cell = [tableView dequeueReusableCellWithIdentifier:KXLocationTableViewCellReusedID forIndexPath:indexPath];
    
    KXLocationModel *model = self.datasArray[indexPath.row];
    cell.textLabel.text = model.region_name;
    cell.model = model;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.5;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        if (!self.currentLoaction.length) {
            [LCProgressHUD showFailureText:@"请选择地区"];
            return;
        }
        [self saveLocation:self.currentLoaction];
    }
    
//    if (indexPath.section == 1) {
//        if (!self.selectedLoaction.length) {
//            [LCProgressHUD showFailureText:@"请选择地区"];
//            return;
//        }
//        _provinceName = self.provinceModel.region_name;
//        _areaName = self.areaModel.region_name;
//        
//        [self saveLocation:self.selectedLoaction];
//    }
    
    if (indexPath.section == 1) {
        //跳转到下一级页面
        KXLocationModel *model = self.datasArray[indexPath.row];
        SelectedAreaController *area = [[SelectedAreaController alloc] init];
        area.provinceModel = model;
        area.provinceID = model.region_id;
        [self.navigationController pushViewController:area animated:YES];
    }
}

//设置头部
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 30)];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 200, 30)];
        label.textColor = [UIColor lightGrayColor];
        label.text = @"当前位置";
        label.textAlignment = NSTextAlignmentLeft;
        label.font = [UIFont systemFontOfSize:13];
        [headerView addSubview:label];
        return headerView;
    } else if (section == 1) {
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 30)];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 200, 30)];
        label.textColor = [UIColor lightGrayColor];
        label.text = @"请选择位置";
        label.textAlignment = NSTextAlignmentLeft;
        label.font = [UIFont systemFontOfSize:13];
        [headerView addSubview:label];
        return headerView;
    }
    return nil;
}


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - 定位功能
//授权状态发生改变的时候调用
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if (status == kCLAuthorizationStatusDenied) {
        NSLog(@"用户拒绝");
    } else if(status == kCLAuthorizationStatusAuthorizedWhenInUse || status == kCLAuthorizationStatusAuthorizedAlways)
    {
        NSLog(@"授权成功");
        
        [self.manager startUpdatingLocation];
    }
}

//当更新到用户位置信息的时候调用
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    
    //最新用户位置数组的最后一个元素
    CLLocation *location = [locations lastObject];
    
    CLLocationCoordinate2D corrdinate = location.coordinate;
    NSLog(@"经度%f  纬度%f",corrdinate.longitude,corrdinate.latitude);
    [self getAddressByLatitude:corrdinate.latitude longitude:corrdinate.longitude];
    [self.manager stopUpdatingLocation];
}

- (void)getAddressByLatitude:(CLLocationDegrees)latitude longitude:(CLLocationDegrees)longitude {
    CLLocation *location=[[CLLocation alloc]initWithLatitude:latitude longitude:longitude];
    [self.geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        CLPlacemark *placemark=[placemarks firstObject];
        _provinceName = placemark.addressDictionary[@"City"];
        _areaName = placemark.addressDictionary[@"SubLocality"];
        self.currentLoaction = [NSString stringWithFormat:@"%@ %@",placemark.addressDictionary[@"State"],placemark.addressDictionary[@"City"]];
        [self.tableView reloadData];
    }];
}

#pragma mark - 网络请求
//保存地区信息
- (void)saveLocation:(NSString *)location {
    [LGNetWorking upLoadUserDataWithSessionID:USERINFO.sessionId andOpenFirAccount:USERINFO.openfireaccount andFunctionName:@"area" andChangeValue:location block:^(ResponseData *responseData) {
        
        if (responseData.code != 0) {
            return ;
        }
//        _vcard.country = @"中国";
//        _vcard.province = _provinceName;
//        _vcard.address = _areaName;
//        [_vcard store:nil failed:nil];
        USERINFO.location = [_provinceName stringByAppendingString:_areaName];
        [LCProgressHUD showSuccessText:@"修改成功"];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.navigationController popViewControllerAnimated:YES];
        });
        
        
        
    }];
}



//请求地区信息
- (void)request {
    [LGNetWorking getProvinceWithSessionID:USERINFO.sessionId block:^(ResponseData *responseData) {
        
        NSMutableArray *dataArray = [KXLocationModel mj_objectArrayWithKeyValuesArray:responseData.data];
        self.datasArray = dataArray;
        [self.tableView reloadData];
    }];
}

- (NSArray *)datasArray {
    if (!_datasArray) {
        _datasArray = [[NSArray alloc] init];
    }
    return _datasArray;
}


- (CLLocationManager *)manager {
    if (!_manager) {
        _manager = [[CLLocationManager alloc] init];
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

@end
