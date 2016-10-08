//
//  SetupFriendInfoController.m
//  YiIM_iOS
//
//  Created by liugang on 16/8/13.
//  Copyright © 2016年 ikantech. All rights reserved.
//

#import "SetupFriendInfoController.h"
#import "RemarkController.h"
#import "SocketManager.h"


@interface SetupFriendInfoController ()
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightConstraint;

@property (weak, nonatomic) IBOutlet UIButton *deleteBtn;   //删除好友
@property (weak, nonatomic) IBOutlet UILabel *nickName;     //备注
@property (weak, nonatomic) IBOutlet UISwitch *myCircle;    //不看我的朋友圈
@property (weak, nonatomic) IBOutlet UISwitch *otherCircle; //不看他的朋友圈
@property (weak, nonatomic) IBOutlet UISwitch *blackList;   //拉黑

@property (nonatomic, strong) ZhiMaFriendModel *friendInfo;     //个人资料
@end

@implementation SetupFriendInfoController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setCustomTitle:@"资料设置"];
    self.deleteBtn.layer.cornerRadius = 5;

}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self requestFriendProfile];
}

//请求好友详细资料
- (void)requestFriendProfile{
    [LGNetWorking getFriendInfo:USERINFO.sessionId userId:self.userId block:^(ResponseData *responseData) {
        if (responseData.code == 0) {
            self.friendInfo = [ZhiMaFriendModel mj_objectWithKeyValues:responseData.data];
            //初始化数据
            [self setupProfile];
        }else{
            [LCProgressHUD showText:responseData.msg];
        }
    } failure:^(ErrorData *error) {
        [LCProgressHUD showText:error.msg];
    }];
}

//初始化数据
- (void)setupProfile{
    self.nickName.text = self.friendInfo.displayName;
    
    [self.myCircle setOn:self.friendInfo.notread_my_cricles];
    [self.otherCircle setOn:self.friendInfo.notread_his_cricles];
    if (self.friendInfo.friend_type == 3) {
        [self.blackList setOn:YES];
    }else{
        [self.blackList setOn:NO];
    }
}

//设置备注
- (IBAction)setupMemo:(UIButton *)sender {
    RemarkController *vc = [[RemarkController alloc] init];
    vc.userId = self.friendInfo.user_Id;
    vc.nickName = self.friendInfo.displayName;
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)deleteAction:(id)sender {
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"是否删除好友?" message:@"" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"删除", nil];
    [alert show];

}

//删除好友
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1) {
        //删除好友 删除会话 清除聊天记录
        [LCProgressHUD showLoadingText:@"请稍等..."];
        [LGNetWorking setupFriendFunction:USERINFO.sessionId function:@"friend_type" value:@"0" openfireAccount:self.friendInfo.user_Id block:^(ResponseData *responseData) {
            if (responseData.code == 0) {
                [LCProgressHUD hide];
                //从数据库删除会话 -- 删除好友列表
                [[SocketManager shareInstance] delFriend:self.friendInfo.user_Id];
                [FMDBShareManager deleteConverseWithConverseId:self.friendInfo.user_Id];
                [FMDBShareManager deleteUserMessageByUserID:self.friendInfo.user_Id];
                [self.navigationController popToRootViewControllerAnimated:YES];
                
            }else{
                [LCProgressHUD showFailureText:responseData.msg];
            }
        }];
    }
}

//加入黑名单
- (IBAction)addBlackList:(UISwitch *)sender {
    if (sender.on) {
        [LGNetWorking setupFriendFunction:USERINFO.sessionId function:@"friend_type" value:@"3" openfireAccount:self.friendInfo.user_Id block:^(ResponseData *responseData) {
            if (responseData.code == 0) {

            }else{
                [LCProgressHUD showText:responseData.msg];
            }
        }];
    }else{
        [LGNetWorking setupFriendFunction:USERINFO.sessionId function:@"friend_type" value:@"2" openfireAccount:self.friendInfo.user_Id block:^(ResponseData *responseData) {
            if (responseData.code == 0) {

            }else{
                [LCProgressHUD showText:responseData.msg];
            }
        }];
    }

}

//不让他看我的朋友圈
- (IBAction)lookMyCircle:(UISwitch *)sender {
    
    NSInteger value = sender.on;
    [LGNetWorking setupFriendFunction:USERINFO.sessionId function:@"notread_my_cricles" value:[NSString stringWithFormat:@"%ld",(long)value] openfireAccount:self.friendInfo.user_Id block:^(ResponseData *responseData) {
        if (responseData.code == 0) {
            
        }else{
            [LCProgressHUD showText:responseData.msg];

        }
    }];
}

//不看他的朋友圈
- (IBAction)lookOtherCircle:(UISwitch *)sender {
    NSInteger value = sender.on;
    [LGNetWorking setupFriendFunction:USERINFO.sessionId function:@"notread_his_cricles" value:[NSString stringWithFormat:@"%ld",(long)value] openfireAccount:self.friendInfo.user_Id block:^(ResponseData *responseData) {
        if (responseData.code == 0) {
            
        }else{
            [LCProgressHUD showText:responseData.msg];
        }
    }];
}

@end