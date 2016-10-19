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
#import "RegexKitLite.h"

#define ResetPasswordCellReusedID @"ResetPasswordCellReusedID"

@interface LGResetPwdViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *item1;

@property (nonatomic, weak) UITextField *oldPassword;
@property (nonatomic, weak) UITextField *password;
@property (nonatomic, weak) UITextField *password2;
@property (nonatomic, weak) UITextField *identiflyTextField;


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
    [self setCustomTitle:@"修改密码"];
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
        cell.Texf.placeholder = @"请输入旧密码";
        self.oldPassword = cell.Texf;
        cell.Texf.tag = 101;
    }
    else if(indexPath.row == 1){
        cell.Texf.placeholder = @"请输入新密码";
        self.password = cell.Texf;
        cell.Texf.tag = 102;
    }
    else if(indexPath.row == 2){
        cell.Texf.placeholder = @"请再次输入新密码";
        self.password2 = cell.Texf;
        cell.Texf.tag = 103;
    } else if (indexPath.row == 3) {
        cell.Texf.placeholder = @"请输入验证码";
        self.identiflyTextField = cell.Texf;
        
        if (!self.identifyingButton) {
            UIButton *identifyingButton  =[[UIButton alloc] initWithFrame:CGRectMake(ScreenWidth - 100, 0, 100, 45-0.5)];
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
- (void)didClicked {
    
    if ([self.oldPassword.text isEqualToString:@""] || [self.password.text isEqualToString:@""] || [self.password2.text isEqualToString:@""]) {
        [LCProgressHUD showFailureText:@"请输入正确的内容"];
        return;
    }
    
    if (![self.password.text isMatchedByRegex:@"^(?![0-9]+$)(?![a-zA-Z]+$)[0-9A-Za-z]{6,20}$"]) {
        [LCProgressHUD showFailureText:@"请输入数字和字母组成的密码"];
        return;
    }
    
    if (self.oldPassword.text.length < 6 || self.oldPassword.text.length > 18) {
        [LCProgressHUD showFailureText:@"请输入6-18位密码"];
        return;
    }
    
    NSString *titleF = self.oldPassword.text;
    NSString *onepwd = self.password.text;
    NSString *twoPsw = self.password2.text;
    if (![onepwd isEqualToString:twoPsw]) {
        [LCProgressHUD showFailureText:@"输入的新密码不一致"];
        return;
    }
    
    if ([self.oldPassword.text isEqualToString:self.password.text]) {
        [LCProgressHUD showFailureText:@"新旧密码不能一致"];
        return;
    }
    

    [LGNetWorking resetPassword:USERINFO.sessionId phone:USERINFO.uphone oldPass:titleF newPass:onepwd reNewpass:twoPsw block:^(ResponseData *responseData) {
        if (responseData.code == 0) {
            [LCProgressHUD showSuccessText:@"修改成功"];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.navigationController popToRootViewControllerAnimated:YES];
            });
        } else {
            [LCProgressHUD showFailureText:responseData.msg];
        }
    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - lazyLoad
- (NSArray *)item1 {
    if (!_item1) {
        _item1 = @[@"旧密码",@"新密码",@"确认新密码"];
    }
    return _item1;
}

@end
