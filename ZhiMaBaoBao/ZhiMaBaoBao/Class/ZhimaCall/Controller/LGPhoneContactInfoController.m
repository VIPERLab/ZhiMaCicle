//
//  LGPhoneContactInfoController.m
//  YiIM_iOS
//
//  Created by liugang on 16/9/7.
//  Copyright © 2016年 ikantech. All rights reserved.
//

#import "LGPhoneContactInfoController.h"
#import "LGPhoneHeaderCell.h"
#import "LGPhoneNumberCell.h"
#import "LGCallingController.h"

@interface LGPhoneContactInfoController ()<UITableViewDelegate,UITableViewDataSource,LGPhoneNumberCellDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *titleArr;
@property (nonatomic, assign) BOOL notFriend;
@property (nonatomic, copy) NSString *openfire;
@end

@implementation LGPhoneContactInfoController

- (NSArray *)titleArr{
    if (!_titleArr) {
        _titleArr = @[@"住宅",@"工作",@"iPhone",@"手机",@"主要"];
    }
    return _titleArr;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
//    [self setCustomTitle:@"联系人详情"];
    [self addSubViews];
    //判断联系人手机号是否开通芝麻好友
    [self requestData];
}

- (void)requestData{
    NSArray *phones = self.contact.allPhones;
    NSString *phoneStr = [phones componentsJoinedByString:@","];
    [LGNetWorking queryContacts:USERINFO.sessionId phone:phoneStr success:^(ResponseData *responseData) {
        //还不是芝麻好友
        if (responseData.code == 0) {
            self.notFriend = YES;
            self.openfire = responseData.data[@"openfireaccount"];
            [self.tableView reloadData];
        }
    } failure:^(ErrorData *error) {
//        [LCProgressHUD showFailureText:error.msg];
    }];
}

- (void)addSubViews{
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, DEVICEWITH, DEVICEHIGHT - 64) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerNib:[UINib nibWithNibName:@"LGPhoneHeaderCell" bundle:nil] forCellReuseIdentifier:@"LGPhoneHeaderCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"LGPhoneNumberCell" bundle:nil] forCellReuseIdentifier:@"LGPhoneNumberCell"];
    self.tableView.tableFooterView = [[UIView alloc] init];
    [self.view addSubview:self.tableView];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (self.notFriend) {
        return 2;
    }else{
        return 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return self.contact.allPhones.count + 1;
    }else{
        return 2;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            LGPhoneHeaderCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LGPhoneHeaderCell"];
            if (self.contact.avtar) {
                cell.avtar.image = [UIImage imageWithData:self.contact.avtar];
            }
            else{
                cell.avtar.image = [UIImage imageNamed:@"defaultContact@3x"];
            }
            cell.name.text = self.contact.name;
            return cell;
        }
        else{
            LGPhoneNumberCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LGPhoneNumberCell"];
            NSString *phoneNumber = self.contact.allPhones[indexPath.row - 1];
            if ([phoneNumber hasPrefix:@"1"]) {
                cell.titleLabel.text = @"手机";
            }else{
                cell.titleLabel.text = @"其他";
            }
            cell.phoneNumber.text = self.contact.allPhones[indexPath.row - 1];
            cell.row = indexPath.row;
            cell.delegate = self;
            return cell;
        }
    }
    else{
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"secondCell"];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"secondCell"];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.font = MAINFONT
        if (indexPath.row == 0) {
            cell.textLabel.text = @"TA还不是你的芝麻好友，你可以：";
            cell.textLabel.textColor = GRAYCOLOR;
        }
        else{
            cell.textLabel.text = @"添加芝麻好友";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 1) {
        if (indexPath.row == 1) {
#warning TODO:跳转到好友详情
            //跳转到好友详情页
            /*
            NSString *jid = [NSString stringWithFormat:@"%@@localhost",self.openfire];
            YiUserInfoViewController *vc = [[YiUserInfoViewController alloc] init];
            vc.jid = jid;
            [self.navigationController pushViewController:vc animated:YES];
             */
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 1) {
        return 30;
    }else{
        return 0.1;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView * header = [[UIView alloc] init];
    header.height = 30;
    header.backgroundColor = WHITECOLOR;
    return header;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            return 200;
        }
        else{
            return 60;
        }
    }
    else{
        return 70;
    }

}

#pragma 拨号按钮点击代理方法
- (void)makeCall:(NSInteger)row{
    NSString *phoneNumber = self.contact.allPhones[row - 1];
    LGCallingController *vc = [[LGCallingController alloc] init];
    vc.phoneNum = phoneNumber;
    vc.name = self.contact.name;
    [self presentViewController:vc animated:YES completion:nil];
}


@end
