//
//  MainViewController.m
//  ZhiMaBaoBao
//
//  Created by liugang on 16/9/18.
//  Copyright © 2016年 liugang. All rights reserved.
//

#import "MainViewController.h"
#import "ConversationController.h"
#import "FriendsController.h"
#import "CallViewController.h"
#import "TimeLineController.h"
#import "PersonalCenterController.h"
#import "BaseViewController.h"
#import "LGGuideController.h"
#import "BaseNavigationController.h"
#import "SocketManager.h"

#import "RHSocketService.h"
//#import "RHSocketUtils.h"

@interface MainViewController ()<SocketManagerDelegate>

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tabBar.barTintColor = [UIColor whiteColor];
    
    [self addChildVc:[[ConversationController alloc] init] title:@"芝麻聊" image:@"lgtabbar_1" selectedImage:@"lgtabbar_1_select"];
    [self addChildVc:[[FriendsController alloc] init] title:@"芝麻友" image:@"lgtabbar_2" selectedImage:@"lgtabbar_2_select"];
    [self addChildVc:[[CallViewController alloc] init] title:@"芝麻通" image:@"lgtabbar_3" selectedImage:@"lgtabbar_3_select"];
    [self addChildVc:[[TimeLineController alloc] init] title:@"芝麻圈" image:@"lgtabbar_4" selectedImage:@"lgtabbar_4_select"];
    [self addChildVc:[[PersonalCenterController alloc] init] title:@"芝麻" image:@"lgtabbar_5" selectedImage:@"lgtabbar_5_select"];
    
    //连接socket服务器
    [[SocketManager shareInstance] connect];
    [SocketManager shareInstance].delegate = self;
    
    //添加异常捕获
    NSSetUncaughtExceptionHandler(&UncaughtExceptionHandler);
}

#pragma mark - socket接收到消息 
- (void)recievedMessage:(LGMessage *)message{
    NSLog(@"message : %@",message);
}


//添加子控制器
- (void)addChildVc:(BaseViewController *)childVc title:(NSString *)title image:(NSString *)image selectedImage:(NSString *)selectedImage
{   
    // 设置子控制器的文字(可以设置tabBar和navigationBar的文字)
//    [childVc setCustomTitle:title];
    
    // 设置子控制器的tabBarItem图片
    childVc.tabBarItem.image = [[UIImage imageNamed:image] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    // 禁用图片渲染
    childVc.tabBarItem.selectedImage = [[UIImage imageNamed:selectedImage] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    // 设置文字的样式
    [childVc.tabBarItem setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor grayColor]} forState:UIControlStateNormal];
    [childVc.tabBarItem setTitleTextAttributes:@{NSForegroundColorAttributeName : THEMECOLOR} forState:UIControlStateSelected];
    childVc.tabBarItem.title = title;
    //    childVc.view.backgroundColor = RandomColor; // 这句代码会自动加载主页，消息，发现，我四个控制器的view，但是view要在我们用的时候去提前加载
    
    // 为子控制器包装导航控制器
    BaseNavigationController *navigationVc = [[BaseNavigationController alloc] initWithRootViewController:childVc];
    // 添加子控制器
    [self addChildViewController:navigationVc];
}


- (void)dealloc{
    
    //移除所有通知
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

void UncaughtExceptionHandler(NSException *exception) {
    NSArray *arr = [exception callStackSymbols];    //得到当前调用栈信息
    NSString *reason = [exception reason];          //非常重要，就是崩溃的原因
    NSString *name = [exception name];              //异常类型
    NSLog(@"异常类型 : %@ \n 崩溃原因 : %@ \n 当前调用栈信息 : %@", name, reason, arr);
}

@end
