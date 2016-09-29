//
//  SetupFriendInfoController.m
//  YiIM_iOS
//
//  Created by liugang on 16/8/13.
//  Copyright © 2016年 ikantech. All rights reserved.
//

#import "SetupFriendInfoController.h"
//#import "RemarkController.h"
//#import "LBXAlertAction.h"
//#import "NSString+YiIM.h"


@interface SetupFriendInfoController ()
@property (weak, nonatomic) IBOutlet UIButton *deleteBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightConstraint;

@property (weak, nonatomic) IBOutlet UISwitch *addBlacklistSwitch;

@property (weak, nonatomic) IBOutlet UISwitch *myCircle;
@property (weak, nonatomic) IBOutlet UISwitch *otherCircle;
@property (weak, nonatomic) IBOutlet UISwitch *blackList;

@end

@implementation SetupFriendInfoController

- (void)viewDidLoad {
    [super viewDidLoad];
    if (USERINFO) {
//        self.addBlacklistSwitch.on = ![[YiIMSDK defaultCore]isBlockedMessage:_jid];
    }
    
    if (self.isFromSearch) {
        self.heightConstraint.constant = 84;
    }
    
    [self setCustomTitle:@"资料设置"];
    self.deleteBtn.layer.cornerRadius = 5;
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    //设置备注
    self.nickName.text = self.nickNametext;
    
//    [self.myCircle setOn:self.frienfInfo.notread_my_cricles];
//    [self.otherCircle setOn:self.frienfInfo.notread_his_cricles];
//    if (self.frienfInfo.friend_type == 3) {
//        [self.blackList setOn:YES];
//    }else{
//        [self.blackList setOn:NO];
//    }
}

//设置备注
- (IBAction)setupMemo:(UIButton *)sender {
//    RemarkController *vc = [[RemarkController alloc] init];
//    vc.nickName = self.nickNametext;
//    vc.jid = _jid;
//    vc.isFromSearch = self.isFromSearch;
//    vc.block = ^(NSString *text){
//        self.nickName.text = text;
//    };
//    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)deleteAction:(id)sender {
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"是否删除好友" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"删除", nil];
    [alert show];

}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1) {
        //删除好友 删除会话 清除聊天记录

        
        //存储删除好友jid
        USERINFO.deleteJid = _jid;
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.navigationController popToRootViewControllerAnimated:YES];
        });
    }
}
- (IBAction)addBlackList:(id)sender {
    
    if (sender == self.addBlacklistSwitch) {
    }
    
}

//不让他看我的朋友圈
- (IBAction)lookMyCircle:(UISwitch *)sender {
    
    NSInteger value = sender.on;
//    [LGNetWorking setupFriendFunction:USERINFO.sessionId function:@"notread_my_cricles" value:value openfireAccount:[_jid escapeHost] block:^(ResponseData *responseData) {
//        if (responseData.code == 0) {
//            
//        }else{
//            [LCProgressHUD showText:responseData.msg];
//
//        }
//    }];
}

//不看他的朋友圈
- (IBAction)lookOtherCircle:(UISwitch *)sender {
    NSInteger value = sender.on;
//    [LGNetWorking setupFriendFunction:USERINFO.sessionId function:@"notread_his_cricles" value:value openfireAccount:[_jid escapeHost] block:^(ResponseData *responseData) {
//        if (responseData.code == 0) {
//            
//        }else{
//            [LCProgressHUD showText:responseData.msg];
//        }
//    }];
}

//加入黑名单
- (IBAction)drugToBlackList:(UISwitch *)sender {
//    if (sender.on) {
//        [LGNetWorking setupFriendFunction:USERINFO.sessionId function:@"friend_type" value:3 openfireAccount:[_jid escapeHost] block:^(ResponseData *responseData) {
//            if (responseData.code == 0) {
//                
//            }else{
//                [LCProgressHUD showText:responseData.msg];
//            }
//        }];
//    }else{
//        [LGNetWorking setupFriendFunction:USERINFO.sessionId function:@"friend_type" value:2 openfireAccount:[_jid escapeHost] block:^(ResponseData *responseData) {
//            if (responseData.code == 0) {
//                
//            }else{
//                [LCProgressHUD showText:responseData.msg];
//            }
//        }];
//    }

}


@end
