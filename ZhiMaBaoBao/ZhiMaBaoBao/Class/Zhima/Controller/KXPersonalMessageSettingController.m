//
//  KXPersonalMessageSettingController.m
//  ZhiMaBaoBao
//
//  Created by mac on 16/9/20.
//  Copyright © 2016年 liugang. All rights reserved.
//

#import "KXPersonalMessageSettingController.h"
#import "PersonalSettingCell.h"

#define KXPersonalSettingCellReusedID @"KXPersonalSettingCellReusedID"

@interface KXPersonalMessageSettingController () <UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) NSArray *titleArray;
@property (nonatomic, strong) NSArray *subTitleArray;

@end

@implementation KXPersonalMessageSettingController {
    UITableView *_tableView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setCustomTitle:@"个人信息"];
    [self setupView];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupView {
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    [self.view addSubview:_tableView];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    [_tableView registerClass:[PersonalSettingCell class] forCellReuseIdentifier:KXPersonalSettingCellReusedID];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSArray *titleArray = self.titleArray[section];
    if (section == 2) {
        if ([USERINFO.is_self_reg isEqualToString:@"1"]) {
            if (USERINFO.passingBy) {
                return 2;
            }
#warning 这里要记得设置为1
            return 2;
        }
        return 2;
    }
    return titleArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *nameArray = self.titleArray[indexPath.section];
    NSArray *subArray = self.subTitleArray[indexPath.section];
    PersonalSettingCell *cell = [tableView dequeueReusableCellWithIdentifier:KXPersonalSettingCellReusedID forIndexPath:indexPath];
    if (indexPath.section == 0 && indexPath.row == 0) {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.imageName = USERINFO.head_photo;
    } else {
        cell.titleName = nameArray[indexPath.row];
    }
    
    if (indexPath.section == 2 && indexPath.row == 0) {
        cell.showQRCode = YES;
    }
    
    cell.subTitle = subArray[indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && indexPath.row == 0) {
        return 100;
    }
    return 50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 20;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0 && indexPath.row == 1) {
        //修改用户名
        
    } else if (indexPath.section == 1 && indexPath.row == 0) {
        //修改性别
    } else if (indexPath.section == 1 && indexPath.row == 1) {
        //修改地区
    } else if (indexPath.section == 1 && indexPath.row == 2) {
        //修改个性签名
    } else if (indexPath.section == 2 && indexPath.row == 0) {
        //我的二维码名片
    } else if (indexPath.section == 2 && indexPath.row == 1) {
        //设置邀请码
    }
}



#pragma mark - lazyLoad
- (NSArray *)titleArray {
    if (!_titleArray) {
        _titleArray = @[@[@"",@"昵称"],@[@"性别",@"地区",@"个性签名"],@[@"二维码名片",@"设置邀请码"]];
    }
    return _titleArray;
}

- (NSArray *)subTitleArray {
    if (!_subTitleArray) {
//        _subTitleArray = @[@[@"",USERINFO.username],@[USERINFO.sex,USERINFO.location,USERINFO.signature],@[@"",@""]];
        _subTitleArray = @[@[@"编辑",@"kit"],@[@"男",@"深圳 南山",@"我就是我"],@[@"",@""]];
    }
    return _subTitleArray;
}



@end
