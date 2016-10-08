//
//  PersonalSettingController.m
//  ZhiMaBaoBao
//
//  Created by mac on 16/9/19.
//  Copyright © 2016年 liugang. All rights reserved.
//

#import "PersonalSettingController.h"
#import "KXSettingCell.h"

#define KXSettingCellReusedID @"KXSettingCellReusedID"

@interface PersonalSettingController ()<UITableViewDelegate,UITableViewDataSource,KXSettingCellDelegate>
@property (nonatomic, strong) NSArray *dataArray;
@property (nonatomic, assign) BOOL add_me_need_ask;
@property (nonatomic, assign) BOOL hold_me_push_phonebook;

@end

@implementation PersonalSettingController {
    UITableView *_tableView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self getData];
    [self setupView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)setupView {
    [self setCustomTitle:@"新消息通知"];
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    [self.view addSubview:_tableView];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [_tableView registerClass:[KXSettingCell class] forCellReuseIdentifier:KXSettingCellReusedID];
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    KXSettingCell *cell = [tableView dequeueReusableCellWithIdentifier:KXSettingCellReusedID forIndexPath:indexPath];
    cell.delegate = self;
    cell.title = self.dataArray[indexPath.row];
    if (indexPath.row == 0) {
        cell.switchStatus = self.add_me_need_ask;
    } else if (indexPath.row == 1) {
        cell.switchStatus = self.hold_me_push_phonebook;
    }
    return cell;
}




- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 45;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 20;
}

- (void)getData {
//    /moblie/savePersonAppSet.do
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer.timeoutInterval = 30.0f;
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html",@"application/json",nil];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"sessionId"] = USERINFO.sessionId;
    params[@"userId"] = USERINFO.userID;
    [manager POST:[NSString stringWithFormat:@"%@/moblie/getPersonAppSet.do",DFAPIURL] parameters:params progress:0 success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSLog(@"%@",responseObject);
        self.add_me_need_ask = [responseObject[@"data"][@"add_me_need_ask"] integerValue];
        self.hold_me_push_phonebook = [responseObject[@"data"][@"hold_me_push_phonebook"] integerValue];
        [_tableView reloadData];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
    
}


- (void)switchValueDidChanage:(KXSettingCell *)cell andSwitch:(UISwitch *)ZhiMaSwitch {
    NSIndexPath *indexPath = [_tableView indexPathForCell:cell];
    if (indexPath.row == 0) {
        // 加我为好友的时候需要验证
        [self upLoadSettingWithFunctionName:@"add_me_need_ask" andValue:ZhiMaSwitch.on];
    } else if (indexPath.row == 1) {
        // 向我推荐通讯录朋友
        [self upLoadSettingWithFunctionName:@"hold_me_push_phonebook" andValue:ZhiMaSwitch.on];
    }
    
    
    
}

- (void)upLoadSettingWithFunctionName:(NSString *)functionName andValue:(int)value {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer.timeoutInterval = 30.0f;
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html",@"application/json",nil];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"sessionId"] = USERINFO.sessionId;
    params[@"functionName"] = functionName;
    params[@"value"] = [NSString stringWithFormat:@"%zd",value];
    
    [manager POST:[NSString stringWithFormat:@"%@/moblie/savePersonAppSet.do",DFAPIURL] parameters:params progress:0 success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        
        NSLog(@"%@",responseObject);
        
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
}


- (NSArray *)dataArray {
    if (!_dataArray) {
        _dataArray = @[@"加我为朋友时需要验证",@"向我推荐通讯录朋友"];
    }
    return _dataArray;
}


@end
