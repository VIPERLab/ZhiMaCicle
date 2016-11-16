//
//  SetupCircleLimitController.m
//  YiIM_iOS
//
//  Created by liugang on 16/9/12.
//  Copyright © 2016年 ikantech. All rights reserved.
//  设置朋友圈权限

#import "SetupCircleLimitController.h"
#import "ZhiMaFriendModel.h"

@interface SetupCircleLimitController ()
@property (nonatomic, strong) ZhiMaFriendModel *friendInfo;   //存放好友信息数据
@property (nonatomic, strong) UISwitch *switch1;
@property (nonatomic, strong) UISwitch *switch2;

@end

@implementation SetupCircleLimitController

- (void)viewDidLoad {
    [super viewDidLoad];

    //请求好友朋友圈权限状态
    
    [self addAllSubviews];
    [self requestData];
}

//请求好友朋友圈权限状态
- (void)requestData{
    //调用本地好友信息接口
    [LGNetWorking getFriendInfo:USERINFO.sessionId userId:self.model.userId block:^(ResponseData *responseData) {
        if (responseData.code != 0) {
            return ;
        }
        
        self.switch1.on = [responseData.data[@"notread_my_cricles"] intValue];
        self.switch2.on = [responseData.data[@"notread_his_cricles"] intValue];
        
    } failure:^(ErrorData *error) {
        
    }];
}

//添加所有子试图
- (void)addAllSubviews{
    self.view.backgroundColor = BGCOLOR;
    //顶栏
    UIView *topBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, DEVICEWITH, 64)];
    topBar.backgroundColor = RGB(245, 245, 245);
    [self.view addSubview:topBar];
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake((DEVICEWITH - 200)/2, (44 - 30)/2 + 20, 200, 30)];
    title.text = @"设置朋友圈权限";
    title.textAlignment = NSTextAlignmentCenter;
    title.textColor = THEMECOLOR;
    title.font = [UIFont systemFontOfSize:17];
    [topBar addSubview:title];
    
    UIButton *closeBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 20, 50, 44)];
    [closeBtn setTitle:@"关闭" forState:UIControlStateNormal];
    [closeBtn setTitleColor:THEMECOLOR forState:UIControlStateNormal];
    [closeBtn addTarget:self action:@selector(closeAction) forControlEvents:UIControlEventTouchUpInside];
    closeBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [topBar addSubview:closeBtn];
    
    
    //内容试图
    UIView *item1 = [[UIView alloc] initWithFrame:CGRectMake(0, topBar.bottom, DEVICEWITH, 100)];
    [self.view addSubview:item1];
    UIView *container1 = [[UIView alloc] initWithFrame:CGRectMake(0, 20, DEVICEWITH, 44)];
    container1.backgroundColor = WHITECOLOR;
    [item1 addSubview:container1];
    UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(14, 0, 200, 44)];
    label1.text = @"不让他(她)看我的朋友圈";
    label1.font = MAINFONT;
    [container1 addSubview:label1];
    UISwitch *switch1 = [[UISwitch alloc] initWithFrame:CGRectMake((DEVICEWITH - 51 - 20), (44 - 31)/2, 51, 33)];
    switch1.onTintColor = THEMECOLOR;
    [switch1 addTarget:self action:@selector(notLookMyCircle:) forControlEvents:UIControlEventValueChanged];
    [container1 addSubview:switch1];
    self.switch1 = switch1;
    UILabel *subLabel1 = [[UILabel alloc] initWithFrame:CGRectMake(12, 70, DEVICEWITH - 24, 30)];
    subLabel1.backgroundColor = [UIColor clearColor];
    subLabel1.text = @"打开后，你在朋友圈发的照片，对方将无法看到";
    subLabel1.font = [UIFont systemFontOfSize:14];
    subLabel1.textColor = GRAYCOLOR;
    [item1 addSubview:subLabel1];
    
    UIView *item2 = [[UIView alloc] initWithFrame:CGRectMake(0, item1.bottom, DEVICEWITH, 100)];
    [self.view addSubview:item2];
    UIView *container2 = [[UIView alloc] initWithFrame:CGRectMake(0, 20, DEVICEWITH, 44)];
    container2.backgroundColor = WHITECOLOR;
    [item2 addSubview:container2];
    UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(14, 0, 200, 44)];
    label2.text = @"不看他(她)的朋友圈";
    label2.font = MAINFONT;
    [container2 addSubview:label2];
    UISwitch *switch2 = [[UISwitch alloc] initWithFrame:CGRectMake((DEVICEWITH - 51 - 20), (44 - 31)/2, 51, 33)];
    switch2.onTintColor = THEMECOLOR;
    [switch2 addTarget:self action:@selector(notLookHisCircle:) forControlEvents:UIControlEventValueChanged];
    self.switch2 = switch2;
    [container2 addSubview:switch2];
    UILabel *subLabel2 = [[UILabel alloc] initWithFrame:CGRectMake(12, 70, DEVICEWITH - 24, 30)];
    subLabel2.backgroundColor = [UIColor clearColor];
    subLabel2.text = @"打开后，对方在朋友圈发的照片，你将无法看到";
    subLabel2.font = [UIFont systemFontOfSize:14];
    subLabel2.textColor = GRAYCOLOR;
    [item2 addSubview:subLabel2];
    
}
//不让他看我的朋友圈
- (void)notLookMyCircle:(UISwitch *)sender{
    NSInteger value = sender.on;
    [LGNetWorking setupFriendFunction:USERINFO.sessionId function:@"notread_my_cricles" value:[NSString stringWithFormat:@"%zd",value] userId:self.model.userId block:^(ResponseData *responseData) {
        if (responseData.code == 0) {
            //通知对方用户删除我的朋友圈
            if (sender.on) { // 如果设置为YES
                [[SocketManager shareInstance] notAllowFriendCircle:self.model.userId];
            }
        }else{
            [LCProgressHUD showFailureText:responseData.msg];
            
        }
    }];

}

//不看他的朋友圈
- (void)notLookHisCircle:(UISwitch *)sender{
    NSInteger value = sender.on;
    [LGNetWorking setupFriendFunction:USERINFO.sessionId function:@"notread_his_cricles" value:[NSString stringWithFormat:@"%zd",value] userId:self.model.userId block:^(ResponseData *responseData) {
        if (responseData.code == 0) {
            // 删除朋友圈数据库中关于他的朋友圈
            if (sender.on) { // 如果设置为YES
                dispatch_async(dispatch_get_global_queue(0, 0), ^{
                    [FMDBShareManager deletedCircleWithUserId:self.model.userId];
                    [[NSNotificationCenter defaultCenter] postNotificationName:K_UpDataCircleDataNotification object:nil];
                });
            }
            
        }else{
            [LCProgressHUD showFailureText:responseData.msg];
        }
    }];
}

- (void)closeAction{
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
