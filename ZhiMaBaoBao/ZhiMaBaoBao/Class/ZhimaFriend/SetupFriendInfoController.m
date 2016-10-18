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
#import "KXActionSheet.h"


@interface SetupFriendInfoController ()<KXActionSheetDelegate>
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
    
    if (self.friendInfo.user_NickName.length) {
        self.nickName.text = self.friendInfo.user_NickName;
    } else {
        self.nickName.text = @"";
    }
    
    
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
    
    KXActionSheet *deleteAction = [[KXActionSheet alloc] initWithTitle:[NSString stringWithFormat:@"将好友\"%@\"删除，同时删除与该好友的聊天记录",self.friendInfo.displayName] cancellTitle:@"取消" andOtherButtonTitles:@[@"删除好友"]];
    deleteAction.delegate = self;
    deleteAction.flag = 0;
    [deleteAction show];
}

//加入黑名单
- (IBAction)addBlackList:(UISwitch *)sender {
    if (sender.on) {
        
        KXActionSheet *actionSheet = [[KXActionSheet alloc] initWithTitle:@"加入黑名单，你将不再收到对方的消息" cancellTitle:@"取消" andOtherButtonTitles:@[@"确定"]];
        actionSheet.delegate = self;
        actionSheet.flag = 1;
        [actionSheet show];
        
    }else{
        [LGNetWorking setupFriendFunction:USERINFO.sessionId function:@"friend_type" value:@"2" openfireAccount:self.friendInfo.user_Id block:^(ResponseData *responseData) {
            if (responseData.code == 0) {

            }else{
                [LCProgressHUD showText:responseData.msg];
            }
        }];
    }
}

- (void)KXActionSheet:(KXActionSheet *)sheet andIndex:(NSInteger)index{
    if (sheet.flag == 0) {      //删除好友
        if (index == 0) {
            //删除好友 删除会话 清除聊天记录
            [LCProgressHUD showLoadingText:@"请稍等..."];
            [LGNetWorking deleteFriend:USERINFO.sessionId friendId:self.friendInfo.user_Id success:^(ResponseData *responseData) {
                if (responseData.code == 0) {
                    [LCProgressHUD hide];
                    
                    //从数据库删除会话 -- 删除好友列表
                    [FMDBShareManager deleteConverseWithConverseId:self.friendInfo.user_Id];
                    [FMDBShareManager deleteUserMessageByUserID:self.friendInfo.user_Id];
                    [self.navigationController popToRootViewControllerAnimated:YES];
                    
                }else{
                    [LCProgressHUD showFailureText:responseData.msg];
                }
                
            } failure:^(ErrorData *error) {
                [LCProgressHUD showFailureText:error.msg];
            }];
        }
    }else if (sheet.flag == 1){      //加入黑名单
        if (index == 0) {
            [LGNetWorking setupFriendFunction:USERINFO.sessionId function:@"friend_type" value:@"3" openfireAccount:self.friendInfo.user_Id block:^(ResponseData *responseData) {
                if (responseData.code == 0) {
                    
                    //标记黑名单 （在会话页面删除该会话）
                    UserInfo *info = [UserInfo shareInstance];
                    info.blackUserId = self.friendInfo.user_Id;
                    
                    
                    //放到跳转到会话列表后去删除会话
                    /*
                     // 删除该会话
                     [FMDBShareManager deleteConverseWithConverseId:self.userId];
                     // 删除该好友
                     [FMDBShareManager deleteUserMessageByUserID:self.userId];
                     */
                }else{
                    [LCProgressHUD showText:responseData.msg];
                }
            }];
        }else{
            self.blackList.on = NO;
        }

    }
}


//不让他看我的朋友圈
- (IBAction)lookMyCircle:(UISwitch *)sender {
    
    NSInteger value = sender.on;
    [LGNetWorking setupFriendFunction:USERINFO.sessionId function:@"notread_my_cricles" value:[NSString stringWithFormat:@"%ld",(long)value] openfireAccount:self.friendInfo.user_Id block:^(ResponseData *responseData) {
        if (responseData.code == 0) {
            if (sender.on) {
                [[SocketManager shareInstance] notAllowFriendCircle:self.userId];
            }
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
            // 删除朋友圈数据库中关于他的朋友圈
            if (sender.on) { // 如果设置为YES
                dispatch_async(dispatch_get_global_queue(0, 0), ^{
                    [FMDBShareManager deletedCircleWithUserId:self.userId];
                    [[NSNotificationCenter defaultCenter] postNotificationName:K_UpDataCircleDataNotification object:nil];
                });
            }
        }else{
            [LCProgressHUD showText:responseData.msg];
        }
    }];
}

@end
