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

@property (nonatomic, weak) UIButton *identifyingButton;


//定时相关
@property (nonatomic, assign) int countDown;
@property (nonatomic, weak) dispatch_source_t timer;

@end

@implementation LGResetPwdViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    [self addAllViews];
    self.countDown = 60;
    [self setCustomTitle:@"重置密码"];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
}

- (void)addAllViews{
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = [UIColor colorFormHexRGB:@"efeff4"];
    [self.view addSubview:self.tableView];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    LGPhoneUpTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ResetPasswordCellReusedID forIndexPath:indexPath];
    
    cell.titleLabel.text = self.item1[indexPath.row];
    if (indexPath.row == 0) {
        cell.Texf.placeholder = @"请输入账号";
        cell.Texf.tag = 101;
    }
    else if(indexPath.row == 1){
        cell.Texf.placeholder = @"请输入密码";
        cell.Texf.tag = 102;
    }
    else if(indexPath.row == 2){
        cell.Texf.placeholder = @"请再次输入密码";
        cell.Texf.tag = 103;
    } else if (indexPath.row == 3) {
        cell.Texf.placeholder = @"请输入验证码";
        
        if (!self.identifyingButton) {
            UIButton *identifyingButton  =[[UIButton alloc] initWithFrame:CGRectMake(ScreenWidth - 100, 0, 100, 45)];
            [identifyingButton setTitle:@"获取验证码" forState:UIControlStateNormal];
            [identifyingButton setTitleColor:THEMECOLOR forState:UIControlStateNormal];
            identifyingButton.titleLabel.font = [UIFont systemFontOfSize:12];
            [identifyingButton addTarget:self action:@selector(buttonDidClick) forControlEvents:UIControlEventTouchUpInside];
            self.identifyingButton = identifyingButton;
            [cell addSubview:identifyingButton];
        }
        
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 45;
}

//获取验证码
- (void)buttonDidClick {
    //获取验证码
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    self.timer = timer;
    dispatch_time_t start = dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC);
    uint64_t interval = (uint64_t)(1.0 * NSEC_PER_SEC);
    dispatch_source_set_timer(timer, start, interval, 0);
    dispatch_source_set_event_handler(timer, ^{
        
        dispatch_async(dispatch_get_main_queue(), ^{
            //回调或者说是通知主线程刷新，
            [self.identifyingButton setTitle:[NSString stringWithFormat:@"(%zd)秒后重新获取",self.countDown] forState:UIControlStateNormal];
            [self.identifyingButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            self.identifyingButton.backgroundColor = [UIColor lightGrayColor];
            self.identifyingButton.userInteractionEnabled = NO;
            self.countDown--;
            if (self.countDown < 0) {
                [self.identifyingButton setTitle:@"获取验证码" forState:UIControlStateNormal];
                [self.identifyingButton setTitleColor:THEMECOLOR forState:UIControlStateNormal];
                self.identifyingButton.backgroundColor = [UIColor whiteColor];
                self.identifyingButton.userInteractionEnabled = YES;
                dispatch_cancel(timer);
            }
        });
        
        
        
    });
    dispatch_resume(timer);
    
    
}

- (void)viewWillDisappear:(BOOL)animated {
    if (self.timer) {
        dispatch_cancel(self.timer);
    }
    
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
        _item1 = @[@"账号",@"新密码",@"确认密码",@"验证码"];
    }
    return _item1;
}

@end
