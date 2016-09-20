//
//  LGResetPwdViewController.m
//  YiIM_iOS
//
//  Created by liugang on 16/8/20.
//  Copyright © 2016年 ikantech. All rights reserved.
//

#import "LGResetPwdViewController.h"
#import "LGPhoneUpTableViewCell.h"
#import "HttpTool.h"


#define ResetPasswordCellReusedID @"ResetPasswordCellReusedID"

@interface LGResetPwdViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *item1;

@property (nonatomic, copy) NSString *oldPwd;
@property (nonatomic, copy) NSString *onepwd;
@property (nonatomic, copy) NSString *twopwd;


@end

@implementation LGResetPwdViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    [self addAllViews];

    [self setCustomTitle:@"重置密码"];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
}

- (void)addAllViews{
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    [self.tableView registerClass:[LGPhoneUpTableViewCell class] forCellReuseIdentifier:ResetPasswordCellReusedID];
    
    
    UIButton *sureBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [sureBtn setTitle:@"确定" forState:UIControlStateNormal];
    [sureBtn setTitleColor:THEMECOLOR forState:UIControlStateNormal];
    sureBtn.titleLabel.font = MAINFONT;
    [sureBtn addTarget:self action:@selector(didClicked) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:sureBtn];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return self.item1.count;
    }
    else if(section == 1){
        return 1;
    }
    return 0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    LGPhoneUpTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ResetPasswordCellReusedID forIndexPath:indexPath];
    
    cell.titleLabel.text = self.item1[indexPath.row];
    if (indexPath.row == 0) {
        cell.Texf.placeholder = @"请输入旧密码";
        cell.Texf.tag = 101;
    }
    else if(indexPath.row == 1){
        cell.Texf.placeholder = @"请输入新密码";
        cell.Texf.tag = 102;
    }
    else if(indexPath.row == 2){
        cell.Texf.placeholder = @"请再次输入新密码";
        cell.Texf.tag = 103;
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 10;
    }
    return 0;
}


//确定修改密码
- (void)didClicked
{
    UITextField *titleF = [self.view viewWithTag:101];
    UITextField *onepwd = [self.view viewWithTag:102];
    UITextField *twopwd = [self.view viewWithTag:103];
    
    [titleF resignFirstResponder];
    [onepwd resignFirstResponder];
    [twopwd resignFirstResponder];
    self.oldPwd = titleF.text;
    self.onepwd = onepwd.text;
    self.twopwd = twopwd.text;
//    if (![self.onepwd isEqualToString:self.twopwd]) {
//        [LCProgressHUD showText:@"输入的新密码不一致"];
//
//        return;
//    }
//    
//    [LGNetWorking resetPassword:USERINFO.sessionId phone:USERINFO.phoneNumber oldPass:self.oldPwd newPass:self.onepwd reNewpass:self.twopwd block:^(ResponseData *responseData) {
//        if (responseData.code == 0) {
//            [LCProgressHUD showText:@"修改成功"];
//            YiUserInfo *userInfo = [YiUserInfo defaultUserInfo];
//            userInfo.password = self.twopwd;
//            [userInfo persist];
//            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                [self.navigationController popToRootViewControllerAnimated:YES];
//            });
//        }
//    }];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - lazyLoad
- (NSArray *)item1 {
    if (!_item1) {
        _item1 = @[@"旧密码",@"新密码",@"确认密码"];
    }
    return _item1;
}

@end
