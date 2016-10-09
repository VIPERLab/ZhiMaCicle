//
//  AppDelegate.m
//  ZhiMaBaoBao
//
//  Created by liugang on 16/9/18.
//  Copyright © 2016年 liugang. All rights reserved.
//

#import "AppDelegate.h"
#import "MainViewController.h"
#import "LGGuideController.h"
#import "FMDBManager.h"
#import <AlipaySDK/AlipaySDK.h>
#import "RealReachability.h"
#import "SocketManager.h"
#import "ConverseModel.h"
#import "LYVoIP.h"
//临时用
#import "ZhiMaFriendModel.h"


@interface AppDelegate ()

@end

@implementation AppDelegate {
    BMKMapManager* _mapManager;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    NSLog(@"%@",NSHomeDirectory());
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(jumpMainController) name:LOGIN_SUCCESS object:nil];
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    UserInfo *userInfo = [UserInfo read];
    //用户第一次登录
    if (!userInfo.hasLogin || userInfo == nil) {
        LGGuideController *vc = [[LGGuideController alloc] init];
        UINavigationController *guideVC = [[UINavigationController alloc] initWithRootViewController:vc];
        self.window.rootViewController = guideVC;
    }else{
        //已经登录过，直接跳转到主界面
        MainViewController *mainVC = [[MainViewController alloc] init];
        self.window.rootViewController = mainVC;
    }
    
    //初始化百度地图
    // 要使用百度地图，请先启动BaiduMapManager
    _mapManager = [[BMKMapManager alloc]init];
    BOOL ret = [_mapManager start:@"xVhVg8ZUIC3DFSh4ECZqwhk7VWMHZb9n" generalDelegate:self];
    if (!ret) {
        NSLog(@"manager start failed!");
    }
    
    //创建数据库表
    if (USERINFO.sessionId) {
        [self creatMySQL];
    }
    [self notification];
    
    
    //注册本地通知
    if ([[UIDevice currentDevice].systemVersion doubleValue] >= 8.0) {
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound categories:nil];
        [application registerUserNotificationSettings:settings];
    }
    
    //注册voipSDK
    [[LYVoIP shareInstance]voipConfigWithID:@"6560" Key:@"rXk6stbTRTFMdDcyKbsfe8PZrcx8m8Za" model:LYVoIPModelAPPReView];
    
    
    return YES;
}

/*
 应用程序在进入前台,或者在前台的时候都会执行该方法
 */
- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    // 必须要监听--应用程序在后台的时候进行的跳转
    if (application.applicationState == UIApplicationStateInactive) {
        NSLog(@"进行界面的跳转");
        // 如果在上面的通知方法中设置了一些，可以在这里打印额外信息的内容，就做到监听，也就可以根据额外信息，做出相应的判断
        NSLog(@"%@", notification.userInfo);
        
    }
}

//网络环境改变
- (void)networkChanged:(NSNotification *)notification
{
    RealReachability *reachability = (RealReachability *)notification.object;
    //当前网络状态
    ReachabilityStatus status = [reachability currentReachabilityStatus];
    //上一网络状态
    ReachabilityStatus previousStatus = [reachability previousReachabilityStatus];
    NSLog(@"networkChanged, currentStatus:%@, previousStatus:%@", @(status), @(previousStatus));
    //网络连接不可用
    if (status == RealStatusNotReachable)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:K_WithoutNetWorkNotification object:nil];
        UserInfo *userInfo = [UserInfo shareInstance];
        userInfo.networkUnReachable = YES;
    }
    //wifi
    if (status == RealStatusViaWiFi)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:K_NetworkRecoveryNotification object:nil];
    }
    //蜂窝数据
    if (status == RealStatusViaWWAN)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:K_NetworkRecoveryNotification object:nil];
    }
    
}


//创建数据库表
- (void)creatMySQL {
    // 朋友圈相关的表
    [FMDBShareManager creatTableWithTableType:ZhiMa_Circle_Table];
    [FMDBShareManager creatTableWithTableType:ZhiMa_Circle_Comment_Table];
    [FMDBShareManager creatTableWithTableType:ZhiMa_Circle_Pic_Table];
    [FMDBShareManager creatTableWithTableType:ZhiMa_Circle_Like_Table];
    
    // 聊天相关表
    [FMDBShareManager creatTableWithTableType:ZhiMa_Chat_Converse_Table];
    [FMDBShareManager creatTableWithTableType:ZhiMa_Chat_Message_Table];
    
    //用户相关的表
    [FMDBShareManager creatTableWithTableType:ZhiMa_User_Message_Table];
    [FMDBShareManager creatTableWithTableType:ZhiMa_NewFriend_Message_Table];
    
    //群聊相关的表
    [FMDBShareManager creatTableWithTableType:ZhiMa_GroupChat_GroupMenber_Table];
}

// 注册通知
- (void)notification {
    //注册更新用户未读消息通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getUserUnReadMessageCountAndUnReadCircle:) name:K_UpdataUnReadNotification object:nil];
    
    //网络环境监听
    [GLobalRealReachability startNotifier];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(networkChanged:)
                                                 name:kRealReachabilityChangedNotification
                                               object:nil];
    //接收用户退出通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userLogOut) name:Show_Login object:nil];
}

- (void)jumpMainController{
    //已经登录过，直接跳转到主界面
    [self creatMySQL];
    MainViewController *mainVC = [[MainViewController alloc] init];
    self.window.rootViewController = mainVC;

}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    //如果极简 SDK 不可用,会跳转支付宝钱包进行支付,需要将支付宝钱包的支付结果回传给 SDK if ([url.host isEqualToString:@"safepay"]) {
    [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
        NSLog(@"result = %@",resultDic);
    }];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    //获取未读消息数量，设置badgeValue
    //获取所有会话列表
    NSArray *conversions = [FMDBShareManager getChatConverseDataInArray];
    
    //遍历所有会话
    NSInteger unRead = 0;
    for (ConverseModel *conversion in conversions) {
        unRead += conversion.unReadCount;
    }
    application.applicationIconBadgeNumber = unRead;
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    
    //计算是否超过设置邀请码的有效期
    if (USERINFO.sessionId && ![USERINFO.create_time isEqualToString:@""] && USERINFO.create_time!= nil) {
        //登录过的用户且有注册时间的才需要计算失效时间
        NSLog(@"%@",USERINFO.create_time);
        
        // 格式化时间
        NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
        formatter.timeZone = [NSTimeZone timeZoneWithName:@"shanghai"];
        [formatter setDateStyle:NSDateFormatterMediumStyle];
        [formatter setTimeStyle:NSDateFormatterShortStyle];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        
        NSDate* date = [formatter dateFromString:USERINFO.create_time];
        
        //失效时间
        CGFloat time = 3600 * 24 * 15;
        CGFloat timeSp = [date timeIntervalSince1970] + time;
        
        //当前时间
        NSTimeInterval interval = [[NSDate date] timeIntervalSince1970];
        
        
        UserInfo *info = [UserInfo read];
        
        //判断是否失效
        if (interval > timeSp) {
            info.passingBy = 0;
        } else {
            info.passingBy = 1;
        }
        [info save];
        
        
    }
    
    //通知更新未读消息数
    [[NSNotificationCenter defaultCenter] postNotificationName:K_UpdataUnReadNotification object:nil];
    
}

#pragma mark - 请求未读消息数
- (void)getUserUnReadMessageCountAndUnReadCircle:(NSNotification *)notification {
    //请求未读消息
    if (USERINFO.sessionId) {
        //如果用户登录了，才让他去请求最新发朋友圈的用户
        if (!USERINFO.lastFcID.length) {
            UserInfo *info = [UserInfo read];
            info.lastFcID = @"0";
            [info save];
        }
        
        [LGNetWorking ApplicationWakeUpAtBackgroundWithSessionId:USERINFO.sessionId andUserID:USERINFO.userID andLastMessageID:USERINFO.lastFcID block:^(ResponseData *responseData) {
            
            if (responseData.code != 0) {
                return ;
            }
            
            UserInfo *info = [UserInfo read];
            
            NSString *circleheadphoto = responseData.data[@"circleheadphoto"];
            if (!circleheadphoto.length) {
                circleheadphoto = @"";
            }
            
            [[NSNotificationCenter defaultCenter] postNotificationName:K_UpDataHeaderPhotoNotification object:nil userInfo:@{@"headerPhoto":circleheadphoto}];
            
            int unReadCount = [responseData.data[@"count"] intValue];
                info.unReadCount = unReadCount;
                [[NSNotificationCenter defaultCenter] postNotificationName:K_UpDataUnReadCountNotification object:nil userInfo:@{@"count":responseData.data[@"count"],@"headphoto":responseData.data[@"headphoto"]}];
            [info save];
        }];
    }
}


#pragma mark - 用户退出通知
- (void)userLogOut {
    [[SocketManager shareInstance] disconnect];
    
    // 关闭数据库
    [FMDBShareManager closeAllSquilteTable];
    
    LGGuideController *vc = [[LGGuideController alloc] init];
    UINavigationController *guideVC = [[UINavigationController alloc] initWithRootViewController:vc];
    self.window.rootViewController = guideVC;
}

#pragma mark - 百度地图回调
- (void)onGetNetworkState:(int)iError
{
    if (0 == iError) {
        NSLog(@"联网成功");
    }
    else{
        NSLog(@"onGetNetworkState %d",iError);
    }
}

- (void)onGetPermissionState:(int)iError
{
    if (0 == iError) {
        NSLog(@"授权成功");
    }
    else {
        NSLog(@"onGetPermissionState %d",iError);
    }
}

//app处于活跃状态，调整tabbar高度
- (void)applicationDidBecomeActive:(UIApplication *)application {
    [application cancelAllLocalNotifications];
    UserInfo *manager = [UserInfo shareInstance];
    [manager.mainVC adapterstatusBarHeight];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
