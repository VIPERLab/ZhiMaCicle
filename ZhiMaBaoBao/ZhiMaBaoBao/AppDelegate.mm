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

#import "AlipaySDK/AlipaySDK.h"

#import "RealReachability.h"
#import "SocketManager.h"
#import "ConverseModel.h"
#import "LYVoIP.h"

#import "JPUSHService.h"
#ifdef NSFoundationVersionNumber_iOS_9_x_Max
#import <UserNotifications/UserNotifications.h>
#endif
//临时用
#import "ZhiMaFriendModel.h"
#import "FMDB.h"

#import <CoreTelephony/CTCallCenter.h>
#import <CoreTelephony/CTCall.h>

#import "LGLoginController.h"
#import "LGGuideController.h"

#import "UncaughtExceptionHandler.h"

//
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import <ContactsUI/ContactsUI.h>



@interface AppDelegate () <JPUSHRegisterDelegate>
@property(nonatomic,strong)CTCallCenter *callCenter;


@end

@implementation AppDelegate {
    BMKMapManager* _mapManager;
    NSInteger netCount;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [UncaughtExceptionHandler installUncaughtExceptionHandler:YES showAlert:NO];
    
    UserInfo *userInfo = [UserInfo read];
    //用户第一次登录
    if (!userInfo.hasLogin || userInfo == nil) {
        
        if (!userInfo) {
            userInfo = [UserInfo shareInstance];
        }
        userInfo.hasLogin = YES;
        userInfo.userID = @"0";
        userInfo.sessionId = @"0";
        userInfo.head_photo = @"image/user_default_head_photo.png";
        userInfo.backgroundImg = @"image/user_default_background_image.jpg";
        userInfo.yuan_head_photo = @"image/user_default_head_photo.png";
        userInfo.signature = @"";
        userInfo.username = @"游客";
        userInfo.isVisitor = YES;
        userInfo.unReadCount = 0;
        [userInfo save];
    }
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor];
    MainViewController *mainVC = [[MainViewController alloc] init];
    self.window.rootViewController = mainVC;
    [self.window makeKeyAndVisible];
    
    //存储app的版本号
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *appVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    if (!userInfo.appVersion.length) {
        userInfo.appVersion = appVersion;
        [userInfo save];
    }

    
    NSLog(@"-----------%@",USERINFO);
    
    //打开通讯录权限
    [self addressBookJurisdiction];
    
    //初始化百度地图
    // 要使用百度地图，请先启动BaiduMapManager
    _mapManager = [[BMKMapManager alloc]init];
    BOOL ret = [_mapManager start:@"xVhVg8ZUIC3DFSh4ECZqwhk7VWMHZb9n" generalDelegate:self];
    if (!ret) {
        NSLog(@"manager start failed!");
    }
    
    //创建数据库表
    if (USERINFO.hasLogin) {
        [self creatMySQL];
    }
    
    //迁移数据库
    [self moveSQLToNew];
    
    [self notification];
    
    
    //注册本地通知
    if ([[UIDevice currentDevice].systemVersion doubleValue] >= 8.0) {
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound categories:nil];
        [application registerUserNotificationSettings:settings];
    }
    
    //注册voipSDK
    [[LYVoIP shareInstance]voipConfigWithID:@"6560" Key:@"rXk6stbTRTFMdDcyKbsfe8PZrcx8m8Za" model:LYVoIPModelAPPReView];
    
    //注册微信支付
    [WXApi registerApp:@"wx59611779e8efe8c3" withDescription:@"ZhiMaBaoBao"];
    
    [self regiestJPush:launchOptions];
    
    
    //监听电话状态，记录通话时长
    [self addCallRecordTime];
    
    //如果用户已经登录过，已经有sessionId - 判断用户登录状态
    if (userInfo.sessionId.length && ![userInfo.sessionId isEqualToString:@"0"]) {
        [self judgeLoginState];
    }
    return YES;
}


// 开启获取通讯录权限
- (void)addressBookJurisdiction {
    //IOS8授权
    CNAuthorizationStatus status = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
    if ( status == CNAuthorizationStatusAuthorized) {
        //如果已经授权，直接返回
        return;
    } else {
        ABAddressBookRef book = ABAddressBookCreateWithOptions(NULL, NULL);
        ABAddressBookRequestAccessWithCompletion(book, ^(bool granted, CFErrorRef error) {
            if (granted) {
                NSLog(@"授权成功");
            }else{
                NSLog(@"授权失败");
            }
        });
    }
    
}

- (void)judgeLoginState{
    //获取登录状态，判断sessionId是否失效
    [LGNetWorking getProvinceWithSessionID:USERINFO.sessionId block:^(ResponseData *responseData) {
        if (responseData.code == 14) {  //sessionId已经失效，不执行socket连接  发送被挤下线通知
            [[NSNotificationCenter defaultCenter] postNotificationName:kOtherLogin object:nil];
        }
    }];
}

//用户在其他地方登录
- (void)doOtherLogin{
    //断开socket
    [[SocketManager shareInstance] disconnect];
    //
    UserInfo *info = [UserInfo read];
    info.isKicker = YES;
    info.hasLogin = NO;
    [info save];
    [[NSNotificationCenter defaultCenter] postNotificationName:Show_Login object:nil];
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

//电话挂断，上传通话时长
- (void)addCallRecordTime{
    UserInfo *info = [UserInfo shareInstance];
    
    self.callCenter = [[CTCallCenter alloc] init];
    self.callCenter.callEventHandler = ^(CTCall* call) {
        
        //电话挂断
        if ([call.callState isEqualToString:CTCallStateDisconnected])
            
        {
            
            if (!info.toPhoneNum) {
                return;
            }
            
            NSLog(@"Call has been disconnected");
            
            NSDate *date = [NSDate date];
            info.endTime = date.timeIntervalSince1970*1000;
            
            [LGNetWorking saveCallTime:USERINFO.sessionId toPhone:info.toPhoneNum callTime:0 CallId:info.callRecordId startTime:info.startTime endTime:info.endTime block:^(ResponseData *responseData) {
                
                if (responseData.code == 0) {
                    
                    //清除存储时间数据
                    info.endTime = 0;
                    info.startTime = 0;
                    
                }else{
                    [LCProgressHUD showFailureText:responseData.msg];
                }
            }];
        }
    };
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
        [self checkNetwork];
    }
    //wifi
    if (status == RealStatusViaWiFi)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:K_NetworkRecoveryNotification object:nil];
        UserInfo *userInfo = [UserInfo shareInstance];
        userInfo.networkUnReachable = NO;
    }
    //蜂窝数据
    if (status == RealStatusViaWWAN)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:K_NetworkRecoveryNotification object:nil];
        UserInfo *userInfo = [UserInfo shareInstance];
        userInfo.networkUnReachable = NO;
    }
    
    //未识别的网络
    if (status == RealStatusUnknown){
        [[NSNotificationCenter defaultCenter] postNotificationName:K_WithoutNetWorkNotification object:nil];
        UserInfo *userInfo = [UserInfo shareInstance];
        userInfo.networkUnReachable = YES;
    }
}

- (void)checkNetwork{
    
    [GLobalRealReachability reachabilityWithBlock:^(ReachabilityStatus status) {
        switch (status)
        {
            case RealStatusNotReachable:
            {
                netCount ++;
                if (netCount < 10) {
                    [self performSelector:@selector(checkNetwork) withObject:nil afterDelay:1];
                }
                break;
            }
                
            case RealStatusViaWiFi:
            {
                netCount = 0;
                [[NSNotificationCenter defaultCenter] postNotificationName:K_NetworkRecoveryNotification object:nil];
                UserInfo *userInfo = [UserInfo shareInstance];
                userInfo.networkUnReachable = NO;
                break;
            }
                
            case RealStatusViaWWAN:
            {
                netCount = 0;
                [[NSNotificationCenter defaultCenter] postNotificationName:K_NetworkRecoveryNotification object:nil];
                UserInfo *userInfo = [UserInfo shareInstance];
                userInfo.networkUnReachable = NO;
                break;
            }
            default:
                break;
        }
    }];
}

// 极光推送
- (void)regiestJPush:(NSDictionary *)launchOptions {
    // 极光推送注册
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 10.0) {
#ifdef NSFoundationVersionNumber_iOS_9_x_Max
        JPUSHRegisterEntity * entity = [[JPUSHRegisterEntity alloc] init];
        entity.types = UNAuthorizationOptionAlert|UNAuthorizationOptionBadge|UNAuthorizationOptionSound;
        [JPUSHService registerForRemoteNotificationConfig:entity delegate:self];
#endif
    } else if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
        //可以添加自定义categories
        [JPUSHService registerForRemoteNotificationTypes:(UIUserNotificationTypeBadge |
                                                          UIUserNotificationTypeSound |
                                                          UIUserNotificationTypeAlert)
                                              categories:nil];
    }
    
    [JPUSHService registrationIDCompletionHandler:^(int resCode, NSString *registrationID) {
        if(resCode == 0){
            NSLog(@"registrationID获取成功：%@",registrationID);
            
        }
        else{
            NSLog(@"registrationID获取失败，code：%d",resCode);
        }
    }];
    
    [JPUSHService setupWithOption:launchOptions appKey:appKey
                          channel:channel
                 apsForProduction:isProduction];
}

#pragma mark - 数据库迁移
//数据库迁移
- (void)moveSQLToNew {
    
}

#pragma mark - 创建数据库
//创建数据库表
- (void)creatMySQL {
    [FMDBShareManager openAllSequliteTable];
}



// 注册通知
- (void)notification {
    //注册更新用户未读消息通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getUserUnReadMessageCountAndUnReadCircle:) name:K_UpdataUnReadNotification object:nil];
    
    //用户登录通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(jumpMainController) name:LOGIN_SUCCESS object:nil];
    
    //网络环境监听
    [GLobalRealReachability startNotifier];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(networkChanged:)
                                                 name:kRealReachabilityChangedNotification
                                               object:nil];
    //接收用户退出通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userLogOut) name:Show_Login object:nil];
    
    //被挤下线通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(doOtherLogin) name:kOtherLogin object:nil];
    //弹出登录注册界面通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(presentLoginRegiste) name:kPressentLoginRegiste object:nil];
    
}

- (void)presentLoginRegiste
{
    //关闭游客登录数据库
    [FMDBShareManager closeAllSquilteTable];
    //弹出登录注册界面
    LGGuideController*vc = [[LGGuideController alloc]init];
    UINavigationController *guideVC = [[UINavigationController alloc] initWithRootViewController:vc];
    [self.window.rootViewController presentViewController:guideVC animated:YES completion:nil];
}

- (void)jumpMainController{
    //已经登录过，直接跳转到主界面
    [self creatMySQL];
    [self countculatedTime];
    MainViewController *mainVC = [[MainViewController alloc] init];
    self.window.rootViewController = mainVC;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    //如果极简 SDK 不可用,会跳转支付宝钱包进行支付,需要将支付宝钱包的支付结果回传给 SDK if ([url.host isEqualToString:@"safepay"]) {
    if ([url.host isEqualToString:@"safepay"]) {
        // 支付跳转支付宝钱包进行支付，处理支付结果
        [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
            NSLog(@"result = %@",resultDic);
        }];
    }
    return [WXApi handleOpenURL:url delegate:self];
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    return  [WXApi handleOpenURL:url delegate:self];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    //获取未读消息数量，设置badgeValue
    //获取所有会话列表
    NSArray *conversions = [FMDBShareManager getChatConverseDataInArray];
    
    //遍历所有会话
    NSInteger unRead = 0;
    for (ConverseModel *conversion in conversions) {
        //设置了消息免打扰的不统计
        if (conversion.disturb) {
            continue;
        }
        unRead += conversion.unReadCount;
    }
    application.applicationIconBadgeNumber = unRead;
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // 关闭sorket
    [[SocketManager shareInstance] disconnect];
    // 进入后台时，注册极光推送
    UserInfo *info = [UserInfo read];
    if (info.userID.length && info.hasLogin) {
        [JPUSHService setTags:[NSSet setWithObject:info.userID] alias:info.userID callbackSelector:@selector(tagsAliasCallback:tags:alias:) object:self];
    }    
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    UserInfo *info = [UserInfo read];
    if (!info || !info.sessionId || [info.sessionId isEqualToString:@"0"]) {
        return;
    }
    
    //获取登录状态，判断sessionId是否失效
    [LGNetWorking getProvinceWithSessionID:USERINFO.sessionId block:^(ResponseData *responseData) {
        if (responseData.code == 14) {  //sessionId已经失效，不执行socket连接  发送被挤下线通知
            [[NSNotificationCenter defaultCenter] postNotificationName:kOtherLogin object:nil];
        }else{  //正常情况
            UserInfo *info = [UserInfo read];
            if (info.hasLogin) {
                // 开启sorket
                [[SocketManager shareInstance] connect];
            }
            

            [JPUSHService resetBadge];
            
            [self countculatedTime];
            //通知更新未读消息数
            [[NSNotificationCenter defaultCenter] postNotificationName:K_UpdataUnReadNotification object:nil];
        }
    }];
    
    /*
    UserInfo *info = [UserInfo read];
    if (info.hasLogin) {
        // 开启sorket
        [[SocketManager shareInstance] connect];
    }
    
    [JPUSHService resetBadge];
    
    [self countculatedTime];
    //通知更新未读消息数
    [[NSNotificationCenter defaultCenter] postNotificationName:K_UpdataUnReadNotification object:nil];
     */
    
}

- (void)countculatedTime {
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


#pragma mark - 用户退出（或者被挤下线）通知
- (void)userLogOut {
    
    [[SocketManager shareInstance] disconnect];
    
    // 关闭数据库
    [FMDBShareManager closeAllSquilteTable];
    
    LGLoginController *vc = [[LGLoginController alloc] init];
    vc.iskicker = YES;
//    LGGuideController *vc = [[LGGuideController alloc] init];
    UINavigationController *guideVC = [[UINavigationController alloc] initWithRootViewController:vc];
    self.window.rootViewController = guideVC;
    
    UserInfo *info = [UserInfo read];
    info.hasLogin = NO;
    //如果被挤下线
    if (info.isKicker) {
        
        info.isKicker = NO;
        [info save];
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"你的帐号已在其他设备登录。如非本人操作，则密码可能已泄露，建议尽快修改密码。" message:@"" preferredStyle:UIAlertControllerStyleAlert];

        UIAlertAction *loginOut = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        [alert addAction:loginOut];
        [guideVC presentViewController:alert animated:YES completion:nil];
    }
}

#pragma mark - 微信支付回调
- (void)onResp:(BaseResp *)resp {
    if([resp isKindOfClass:[PayResp class]]){
        //支付返回结果，实际支付结果需要去微信服务器端查询
        switch (resp.errCode) {
            case WXSuccess:
                [[NSNotificationCenter defaultCenter] postNotificationName:@"WXPaySuccess" object:@"success"];
                NSLog(@"支付成功－PaySuccess，retcode = %d", resp.errCode);
                break;
                
            default:
                [[NSNotificationCenter defaultCenter] postNotificationName:@"WXPayFailed" object:@"fail"];
                NSLog(@"错误，retcode = %d, retstr = %@", resp.errCode,resp.errStr);
                break;
        }
    }
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

// APNS 注册
- (void)application:(UIApplication *)application
didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    /// Required - 注册 DeviceToken
    [JPUSHService registerDeviceToken:deviceToken];
    UserInfo *info = [UserInfo read];
    if (info.userID) {
        [JPUSHService setTags:[NSSet setWithObject:info.userID] alias:info.userID callbackSelector:@selector(tagsAliasCallback:tags:alias:) object:self];
    }
    
}

// APNS 注册失败回调
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    //Optional
    NSLog(@"did Fail To Register For Remote Notifications With Error: %@", error);
}

// 极光注册回调
- (void)tagsAliasCallback:(int)iResCode
                     tags:(NSSet *)tags
                    alias:(NSString *)alias {
    NSString *callbackString =
    [NSString stringWithFormat:@"%d, \ntags: %@, \nalias: %@\n", iResCode,
     [self logSet:tags], alias];
//    if ([_callBackTextView.text isEqualToString:@"服务器返回结果"]) {
//        _callBackTextView.text = callbackString;
//    } else {
//        _callBackTextView.text = [NSString
//                                  stringWithFormat:@"%@\n%@", callbackString, _callBackTextView.text];
//    }
    NSLog(@"TagsAlias回调:%@", callbackString);
}

- (NSString *)logSet:(NSSet *)dic {
    if (![dic count]) {
        return nil;
    }
    NSString *tempStr1 =
    [[dic description] stringByReplacingOccurrencesOfString:@"\\u"
                                                 withString:@"\\U"];
    NSString *tempStr2 =
    [tempStr1 stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    NSString *tempStr3 =
    [[@"\"" stringByAppendingString:tempStr2] stringByAppendingString:@"\""];
    NSData *tempData = [tempStr3 dataUsingEncoding:NSUTF8StringEncoding];
    NSString *str =
    [NSPropertyListSerialization propertyListFromData:tempData
                                     mutabilityOption:NSPropertyListImmutable
                                               format:NULL
                                     errorDescription:NULL];
    return str;
}


#pragma mark- JPUSHRegisterDelegate

// iOS 10 Support
- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(NSInteger))completionHandler {
    // Required -> 本地通知
    NSDictionary * userInfo = notification.request.content.userInfo;
    if([notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        [JPUSHService handleRemoteNotification:userInfo];
    }
    completionHandler(UNNotificationPresentationOptionAlert | UNNotificationPresentationOptionSound); // 需要执行这个方法，选择是否提醒用户，有Badge、Sound、Alert三种类型可以选择设置
}

// iOS 10 Support
- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler {
    // Required
    NSDictionary * userInfo = response.notification.request.content.userInfo;
    if([response.notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        [JPUSHService handleRemoteNotification:userInfo];
    }
    completionHandler();  // 系统要求执行这个方法
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    
    // Required, iOS 7 Support
    [JPUSHService handleRemoteNotification:userInfo];
    
    completionHandler(UIBackgroundFetchResultNewData);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    
    // Required,For systems with less than or equal to iOS6
    [JPUSHService handleRemoteNotification:userInfo];
}


@end
