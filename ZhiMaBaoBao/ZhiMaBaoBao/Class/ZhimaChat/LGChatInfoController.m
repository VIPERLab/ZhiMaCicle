//
//  LGChatInfoController.m
//  YiIM_iOS
//
//  Created by liugang on 16/8/13.
//  Copyright © 2016年 ikantech. All rights reserved.
//

#import "LGChatInfoController.h"
#import "FriendProfilecontroller.h"

@interface LGChatInfoController ()

@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UIButton *avatar;

@end

@implementation LGChatInfoController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setCustomTitle:@"聊天信息"];
    self.name.text = self.displayName;
//    [self.avatar setBackgroundImage:<#(nullable UIImage *)#> forState:<#(UIControlState)#>]
}

/*
//查看聊天记录
- (IBAction)lookChatRecoder:(id)sender {
    YiChatRecordViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"YiChatRecordViewController"];
    vc.jid = _jid;
    [self.navigationController pushViewController:vc animated:YES];
}
 */

//清除聊天记录
- (IBAction)clearChatRecoder:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"您确定要清除聊天记录吗?" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1) {
        [FMDBShareManager deleteMessageFormMessageTableByConverseID:self.userId];
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

//头像点击，跳转到用户信息详情
- (IBAction)avatarClick:(id)sender {
    FriendProfilecontroller *vc = [[FriendProfilecontroller alloc] init];
    vc.userId = self.userId;
    [self.navigationController pushViewController:vc animated:YES];

}

@end
