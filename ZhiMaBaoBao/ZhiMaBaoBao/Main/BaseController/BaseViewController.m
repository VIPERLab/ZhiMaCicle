//
//  BaseViewController.m
//  ZhiMaBaoBao
//
//  Created by mac on 16/9/19.
//  Copyright © 2016年 liugang. All rights reserved.
//

#import "BaseViewController.h"
#import "LGSearchController.h"
#import "AddFriendViewController.h"
#import <AudioToolbox/AudioToolbox.h>

@interface BaseViewController ()

@end

@implementation BaseViewController {
    BOOL isEneryForeground;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = BGCOLOR;
    self.navigationController.navigationBar.tintColor = THEMECOLOR;

    
    // 进去前台通知
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enteryForground) name:KEnteryForeground_Notification object:nil];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    UserInfo *userinfo = [UserInfo shareInstance];
    userinfo.currentVC = self;
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [LCProgressHUD hide];
}

- (void)setNaviTitle:(NSString*)title
{
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 120, 40)];
    titleLabel.text = title;
    titleLabel.textColor = THEMECOLOR;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont systemFontOfSize:17];
    self.navigationItem.titleView = titleLabel;
}

//自定义标题
- (void)setCustomTitle:(NSString *)title {
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 120, 40)];
    titleLabel.text = title;
    titleLabel.textColor = THEMECOLOR;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont systemFontOfSize:17];
    self.navigationItem.titleView = titleLabel;
    
    //自定义返回按钮
    UIButton *backBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    backBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [backBtn setImage:[UIImage imageNamed:@"nav_back"] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    self.navigationItem.leftBarButtonItem = backItem;
}

//添加右侧items
- (void)setCustomRightItems{
    UIView *rightView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 85, 40)];
    UIButton *searchBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [searchBtn setImage:[UIImage imageNamed:@"nav_search"] forState:UIControlStateNormal];
    [searchBtn addTarget:self action:@selector(searchFriendAction) forControlEvents:UIControlEventTouchUpInside];
    UIButton *addBtn = [[UIButton alloc] initWithFrame:CGRectMake(45, 0, 40, 40)];
    [addBtn setImage:[UIImage imageNamed:@"nav_add"] forState:UIControlStateNormal];
    [addBtn addTarget:self action:@selector(addFriendAction) forControlEvents:UIControlEventTouchUpInside];
    [rightView addSubview:searchBtn];
    [rightView addSubview:addBtn];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightView];
}

//返回方法
- (void)backAction {
    [self.navigationController popViewControllerAnimated:YES];
}

//搜索匹配好友
- (void)searchFriendAction{
    LGSearchController *searchVC = [[LGSearchController alloc] init];
    searchVC.fatherVC = self;
    searchVC.hidesBottomBarWhenPushed = YES;
    [self presentViewController:searchVC animated:NO completion:nil];
}

//添加新好友
- (void)addFriendAction{
    AddFriendViewController *vc = [[AddFriendViewController alloc] init];
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}


// 进入前台通知
- (void)enteryForground {
//    ForegroundManager *manager = [ForegroundManager shareManager];
//    if (manager.is_Entry_Foreground) {
//        NSLog(@"进入前台通知 !!!!");
//        manager.entry_Foreground = NO;
//    }
}

////播放消息提示音(已经判断是声音还是振动提醒)
//- (void)playSystemAudio{
//    if (USERINFO.newMessageNotify) {    //开启了接受信息消息通知
//        if (USERINFO.newMessageVoiceNotify) {   //开启了声音提醒
//            if (USERINFO.newMessageShakeNotify) {   //声音跟振动
//                //                AudioServicesPlaySystemSound(1007);
//                SystemSoundID soundID;
//                NSString *strSoundFile = [[NSBundle mainBundle] pathForResource:@"sms-received1" ofType:@"caf"];
//                AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:strSoundFile],&soundID);
//                AudioServicesPlaySystemSound(soundID);
//                AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
//                
//            }else{  //只有声音
//                SystemSoundID soundID;
//                NSString *strSoundFile = [[NSBundle mainBundle] pathForResource:@"sms-received1" ofType:@"caf"];
//                AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:strSoundFile],&soundID);
//                AudioServicesPlaySystemSound(soundID);
//            }
//        }else{
//            if (USERINFO.newMessageShakeNotify) {   //只有振动提醒
//                AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
//            }
//        }
//    }
//}

// 清除子类未消除的通知
- (void)dealloc {
    NSLog(@"%@销毁了",NSStringFromClass(self.class));
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}
@end
