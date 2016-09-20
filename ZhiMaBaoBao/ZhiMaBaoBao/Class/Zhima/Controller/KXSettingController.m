//
//  KXSettingController.m
//  ZhiMaBaoBao
//
//  Created by mac on 16/9/19.
//  Copyright © 2016年 liugang. All rights reserved.
//

#import "KXSettingController.h"


#import "KXWebViewController.h" //webView
#import "LGResetPwdViewController.h"  //重置密码
#import "LGBlackListViewController.h" //黑名单
#import "NewMessageSettingController.h" //新消息提醒
#import "PersonalSettingController.h" //隐私设置

#define KXUserSettingCellReusedID @"KXUserSettingCellReusedID"
#define cellHeight 45

@interface KXSettingController () <UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataArray;
@end

@implementation KXSettingController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setCustomTitle:@"设置"];
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    [self.view addSubview:self.tableView];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:KXUserSettingCellReusedID];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *titleArray = self.dataArray[section];
    return titleArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:KXUserSettingCellReusedID forIndexPath:indexPath];
    NSArray *titleArray = self.dataArray[indexPath.section];
    cell.textLabel.text = titleArray[indexPath.row];
    cell.textLabel.font = [UIFont systemFontOfSize:15];
    if (indexPath.section == 0 && indexPath.row == 5) {
        UILabel *subTileLabel = [[UILabel alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width - 100, 0, 80, 40)];
        subTileLabel.textAlignment = NSTextAlignmentRight;
        subTileLabel.textColor = [UIColor lightGrayColor];
        subTileLabel.font = [UIFont systemFontOfSize:14];
        NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
        NSString *app_Version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
        subTileLabel.text = app_Version;
        [cell addSubview:subTileLabel];
    }
    
    UIView *bottomLineView = [[UIView alloc] initWithFrame:CGRectMake(10, cellHeight - 0.5, ScreenWidth - 10, 0.5)];
    bottomLineView.backgroundColor = [UIColor colorFormHexRGB:@"e1e1e1"];
    [cell addSubview:bottomLineView];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return cellHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 20;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 1;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSTimeInterval interval = [[NSDate date] timeIntervalSince1970] * 1000;
    
    if (indexPath.section == 1 && indexPath.row == 0) {
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"确定退出？" message:@"" preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action){
            NSLog(@"用户取消登陆");
        }]];
        [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action){
//            [self exit];
        }]];
        [self presentViewController:alertController animated:YES completion:nil];
        
    }
    else if (indexPath.section == 0 && indexPath.row == 3){
        //重置密码
        LGResetPwdViewController *resetPwdVC = [[LGResetPwdViewController alloc]init];
        [self.navigationController pushViewController:resetPwdVC animated:YES];
    }
    else if(indexPath.section == 0  && indexPath.row == 2){
        // 黑名单
        LGBlackListViewController *blackLVC = [[LGBlackListViewController alloc]init];
        [self.navigationController pushViewController:blackLVC animated:YES];
        
    } else if (indexPath.section == 0 && indexPath.row == 4) {
        //版本公告
        KXWebViewController *aboutUs = [[KXWebViewController alloc] init];
        aboutUs.navTitleName = @"版本公告";
        aboutUs.htmlURL = @"https://www.baidu.com";
//        aboutUs.htmlURL = [NSString stringWithFormat:@"%@/web/getNoticeListBytype.do?sessionId=%@&openfireaccount=%@&type=2",DFAPIURL,USERINFO.sessionId,USERINFO.openfireAccount];
        [self.navigationController pushViewController:aboutUs animated:YES];
    } else if (indexPath.section == 0 && indexPath.row == 5) {
        //关于我们
        KXWebViewController *aboutUs = [[KXWebViewController alloc] init];
        aboutUs.navTitleName = @"关于我们";
        aboutUs.htmlURL = @"https://www.baidu.com";
//        aboutUs.htmlURL = [NSString stringWithFormat:@"%@/company_info.html?%f",DFAPIURL,interval];
        [self.navigationController pushViewController:aboutUs animated:YES];
    } else if (indexPath.section == 0 && indexPath.row == 6) {
        //联系我们
        KXWebViewController *aboutUs = [[KXWebViewController alloc] init];
        aboutUs.navTitleName = @"联系我们";
        aboutUs.htmlURL = @"https://www.baidu.com";
//        aboutUs.htmlURL = [NSString stringWithFormat:@"%@/contact_us.html?%f",DFAPIURL,interval];
        [self.navigationController pushViewController:aboutUs animated:YES];
    } else if (indexPath.section == 0 && indexPath.row == 0) {
        //新消息提醒
        NewMessageSettingController *message = [[NewMessageSettingController alloc] init];
        [self.navigationController pushViewController:message animated:YES];
        
    } else if (indexPath.section == 0 && indexPath.row == 1) {
        //隐私设置
        PersonalSettingController *personalSetting = [[PersonalSettingController alloc] init];
        [self.navigationController pushViewController:personalSetting animated:YES];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}



#pragma mark - lazyLoad
- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
        [_dataArray addObject:@[@"新消息提醒",@"隐私设置",@"黑名单",@"重置密码",@"版本公告",@"关于我们",@"联系我们"]];
        [_dataArray addObject:@[@"退出"]];
    }
    return _dataArray;
}

@end
