//
//  SelectedAreaController.m
//  YiIM_iOS
//
//  Created by mac on 16/8/29.
//  Copyright © 2016年 ikantech. All rights reserved.
//

#import "SelectedAreaController.h"
#import "MJExtension.h"
#import "LGNetWorking.h"
#import "KXLocationModel.h"
//#import "YiUserInfo.h"

#import "KXPersonalMessageSettingController.h"

#define KXAreaTableViewCellReusedID @"KXAreaTableViewCellReusedID"

@interface SelectedAreaController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, strong) NSArray *datasArray;
//@property (nonatomic, strong) YiXmppVCard *vcard;

@end

@implementation SelectedAreaController


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self requestAreaMessage];
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
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    self.tableView = tableView;
    [self.view addSubview:tableView];
//    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.delegate = self;
    tableView.dataSource = self;
    
    [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:KXAreaTableViewCellReusedID];
    
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.datasArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    KXLocationModel *model = self.datasArray[indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:KXAreaTableViewCellReusedID forIndexPath:indexPath];
    cell.textLabel.text = model.region_name;
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    KXLocationModel *areaModel = self.datasArray[indexPath.row];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"KKXSelectedLocationNotification" object:nil userInfo:@{  @"areaModel" : areaModel, @"provinceModel" : self.provinceModel }];
    [self saveLocation:self.provinceModel andAreaModel:areaModel];
}




#pragma mark - 网络请求
- (void)requestAreaMessage {
    [LGNetWorking getAreaWithSessionID:USERINFO.sessionId andProvinceID:self.provinceID block:^(ResponseData *responseData) {
        NSMutableArray *dataArray = [KXLocationModel mj_objectArrayWithKeyValuesArray:responseData.data];
        self.datasArray = dataArray;
        [self.tableView reloadData];
    }];
    
}

#pragma mark - 网络请求
//保存地区信息
- (void)saveLocation:(KXLocationModel *)provinceModel andAreaModel:(KXLocationModel *)areaModel {
    NSString *location = [NSString stringWithFormat:@"%@ %@",provinceModel.region_name,areaModel.region_name];
    [LGNetWorking upLoadUserDataWithSessionID:USERINFO.sessionId andOpenFirAccount:USERINFO.userID andFunctionName:@"area" andChangeValue:location success:^(ResponseData *responseData) {
        if (responseData.code != 0) {
            return ;
        }
        
        UserInfo *info = [UserInfo read];
        info.area = [provinceModel.region_name stringByAppendingString:[NSString stringWithFormat:@" %@",areaModel.region_name]];
        [info save];
        
        [LCProgressHUD showSuccessText:@"修改成功"];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            for (UIViewController *vc in self.navigationController.viewControllers) {
                if ([vc isKindOfClass:[KXPersonalMessageSettingController class]]) {
                    [self.navigationController popToViewController:vc animated:NO];
                    return ;
                }
            }
            
        });
    } failure:^(ErrorData *error) {
        
    }];
}

- (NSArray *)datasArray {
    if (!_datasArray) {
        _datasArray = [[NSArray alloc] init];
    }
    return _datasArray;
}

@end
