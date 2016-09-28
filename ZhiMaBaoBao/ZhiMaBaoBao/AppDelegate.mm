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

//临时用
#import "ZhiMaFriendModel.h"

@interface AppDelegate ()

@end

@implementation AppDelegate {
    BMKMapManager* _mapManager;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    
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
    [self notification];
    return YES;
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
        
    }
    //wifi
    if (status == RealStatusViaWiFi)
    {
        
    }
    //蜂窝数据
    if (status == RealStatusViaWWAN)
    {
        
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
    
    ZhiMaFriendModel *model = [[ZhiMaFriendModel alloc] init];
    model.user_Name = @"大雄";
    model.user_Head_photo = @"xxxx";
    model.user_NickName = @"";
    model.user_Id = @"11594";
    
    ZhiMaFriendModel *model1 = [[ZhiMaFriendModel alloc] init];
    model1.user_Name = @"汉章";
    model1.user_Head_photo = @"xxxx";
    model1.user_NickName = @"";
    model1.user_Id = @"12784";
    
    ZhiMaFriendModel *model2 = [[ZhiMaFriendModel alloc] init];
    model2.user_Name = @"刘刚";
    model2.user_Head_photo = @"xxxx";
    model2.user_NickName = @"";
    model2.user_Id = @"11596";
    [FMDBShareManager saveUserMessageWithMessageArray:@[model,model1,model2]];
    
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
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
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



- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
