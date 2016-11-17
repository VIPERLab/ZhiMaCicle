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
#import <AudioToolbox/AudioToolbox.h>
#import "RHSocketService.h"
#import "ConverseModel.h"
#import "ChatController.h"
#import "ForwardMsgController.h"

#import "ZMCallViewController.h"
#import "JFMyPlayerSound.h"
#import "RBDMuteSwitch.h"


@interface MainViewController ()<SocketManagerDelegate,RBDMuteSwitchDelegate>
@property (nonatomic, assign) BOOL canPlayAudio;
@property(nonatomic,strong)JFMyPlayerSound *myPlaySounde;   //系统声音播放器

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    UserInfo *userInfo = [UserInfo shareInstance];
//    userInfo.mainVC = self;

    self.tabBar.barTintColor = [UIColor whiteColor];

    [self addChildVc:[[ConversationController alloc] init] title:@"芝麻聊" image:@"lgtabbar_1" selectedImage:@"lgtabbar_1_select"];
    [self addChildVc:[[FriendsController alloc] init] title:@"芝麻友" image:@"lgtabbar_2" selectedImage:@"lgtabbar_2_select"];
    [self addChildVc:[[ZMCallViewController alloc] init] title:@"芝麻通" image:@"lgtabbar_3" selectedImage:@"lgtabbar_3_select"];
    [self addChildVc:[[TimeLineController alloc] init] title:@"芝麻圈" image:@"lgtabbar_4" selectedImage:@"lgtabbar_4_select"];
    [self addChildVc:[[PersonalCenterController alloc] init] title:@"芝麻" image:@"lgtabbar_5" selectedImage:@"lgtabbar_5_select"];

    //连接socket服务器
    if (![USERINFO.sessionId isEqualToString:@"0"]) {
        [[SocketManager shareInstance] connect];
        [SocketManager shareInstance].delegate = self;
    }
    
    [self addNotifications];

    //检查更新
    [self judgeAPPVersion];
    
    //检查是否隐藏红包
    [self judgeHidePurse];
    
    self.canPlayAudio = YES;
}

//检查是否隐藏红包
- (void)judgeHidePurse{
    //bundle的版本
    NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
    NSString *bundleVersion = infoDict[@"CFBundleShortVersionString"];
    
    [LGNetWorking verfiryAppStatues:bundleVersion success:^(ResponseData *responseData) {
        if (responseData.code == 0) {
            //返回值 0 为隐藏钱包 1 为打开钱包
            UserInfo *info = [UserInfo read];
            info.hidePurse = ![responseData.data boolValue];
            [info save];
        }

    } failure:^(ErrorData *error) {
        
    }];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //更新未读消息
    [self updateUnread];
}

- (void)addNotifications{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newMessageRecieved:) name:kRecieveNewMessage object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUnread) name:kUpdateUnReadMessage object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(bigImageTransform:) name:K_ForwardPhotoNotifation object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(becomekeyWindow:) name:UIWindowDidBecomeKeyNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(activityMsgRecieved:) name:kRecieveActivityMsg object:nil];
}

#pragma mark - 通知回调
//收到新消息(其他用户发送给自己的消息)
- (void)newMessageRecieved:(NSNotification *)notification{
    
    LGMessage *message = notification.userInfo[@"message"];
    UserInfo *userinfo = [UserInfo shareInstance];
    
    //判断对发消息用户是否开启了新消息提醒 -> 播放系统消息提示音
    //1.数据库查会话模型，拿出对该用户设置的的新消息提醒 如果是yes 播放声音
    ConverseModel *conversionModel = nil;
    if (message.conversionType == ConversionTypeGroupChat) {
        conversionModel = [FMDBShareManager searchConverseWithConverseID:message.toUidOrGroupId andConverseType:message.conversionType];
    }else if (message.conversionType == ConversionTypeSingle){
        conversionModel = [FMDBShareManager searchConverseWithConverseID:message.fromUid andConverseType:message.conversionType];
    }
    
    if (!conversionModel.disturb && message.type != MessageTypeSystem) {
        if (message.conversionType == ConversionTypeGroupChat) {
            if (![userinfo.currentConversionId isEqualToString:message.toUidOrGroupId]) {
                //播放系统声音
                [[RBDMuteSwitch sharedInstance] setDelegate:self];
                [[RBDMuteSwitch sharedInstance] detectMuteSwitch];
            }
        }else if (message.conversionType == ConversionTypeSingle){
            if (![userinfo.currentConversionId isEqualToString:message.fromUid]) {
                //播放系统声音
                [[RBDMuteSwitch sharedInstance] setDelegate:self];
                [[RBDMuteSwitch sharedInstance] detectMuteSwitch];
            }
        }
    }
    
    if (conversionModel.disturb) {  //如果开启了免打扰  -- 不更新tabbar未读角标
        return;
    }
    
    //更新未读消息
    [self updateUnread];
}

//收到服务号推送消息
- (void)activityMsgRecieved:(NSNotification *)notify{
    ZMServiceMessage *message = notify.userInfo[@"message"];
    
#warning 播放声音 更新角标
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
    childVc.view.backgroundColor = BGCOLOR; // 这句代码会自动加载主页，消息，发现，我四个控制器的view，但是view要在我们用的时候去提前加载
    
    // 为子控制器包装导航控制器
    BaseNavigationController *navigationVc = [[BaseNavigationController alloc] initWithRootViewController:childVc];
    // 添加子控制器
    [self addChildViewController:navigationVc];
}


//获取未读消息提示
- (NSInteger)updateUnread{
    //获取所有会话列表
    NSArray *conversions = [FMDBShareManager getChatConverseDataInArray];
    
    //遍历所有会话
    NSInteger unRead = 0;
    for (ConverseModel *conversion in conversions) {
        //不统计设置了免打扰的会话
        if (conversion.disturb) {
            continue;
        }
        unRead += conversion.unReadCount;
    }
    
    //tabbar显示所有未读消息条数
    if (unRead > 99) {
        [[self.tabBar.items objectAtIndex:0] setBadgeValue:@"99+"];
    }else if(unRead > 0){
        [[self.tabBar.items objectAtIndex:0] setBadgeValue:[NSString stringWithFormat:@"%ld", (long)unRead]];
    }else {
        [[self.tabBar.items objectAtIndex:0] setBadgeValue:nil];
    }
    
    return unRead;
}

//收到转发大图通知
- (void)bigImageTransform:(NSNotification *)notify{
    NSDictionary *userInfo = notify.userInfo;
    NSString *imageUrl = userInfo[@"imageUrl"];
    
    //生成一条消息模型
    LGMessage *message = [[LGMessage alloc] init];
    message.text = imageUrl;
    message.type = MessageTypeImage;
    
    
    UserInfo *info = [UserInfo shareInstance];
    info.keyWindow = [UIApplication sharedApplication].keyWindow;
    info.bigImageTrans = YES;
    
    ForwardMsgController *vc = [[ForwardMsgController alloc] init];
    vc.message = message;
    BaseNavigationController *nav = [[BaseNavigationController alloc] initWithRootViewController:vc];
    
    UIWindow *topWindow = [[UIWindow alloc] init];
    info.topWindow = topWindow;
    topWindow.windowLevel = UIWindowLevelNormal;
    topWindow.rootViewController = nav;
    [topWindow makeKeyAndVisible];
    
}

#pragma mark - 成为keywindow代理方法
- (void)becomekeyWindow:(NSNotification *)notify{
    UserInfo *info = [UserInfo shareInstance];
    UIWindow *window = notify.object;
    
    if (window == info.topWindow) {
        info.topWindow.y = DEVICEHIGHT;
        [UIView animateWithDuration:.3f animations:^{
            info.topWindow.y = 0;
        }];
    }else{  //keywindow
        NSLog(@"keywindow");
        info.bigImageTrans = NO;
        info.topWindow = nil;
        
    }
}

#pragma mark - 状态栏高度改变时，修改tabbar的Y值
- (void)adapterstatusBarHeight{
    
    CGRect statusBarRect = [[UIApplication sharedApplication] statusBarFrame];
    int shouldBeSubtractionHeight = 0;
    if (statusBarRect.size.height == 40) {
        shouldBeSubtractionHeight = 20;
    }
    
    self.tabBar.frame = CGRectMake(0, DEVICEHIGHT - 49 - shouldBeSubtractionHeight, DEVICEWITH, 49);
}

//播放系统声音
- (void)isMuted:(BOOL)muted{
    if (muted) {
        //开启静音模式
        self.myPlaySounde = [[JFMyPlayerSound alloc] initSystemShake];
    }else{
        //关闭静音模式
        self.myPlaySounde = [[JFMyPlayerSound alloc] initSystemSoundWithName:@"sms-received1" SoundType:@"caf"];
    }
    
    if (USERINFO.newMessageNotify && self.canPlayAudio) {
        if (USERINFO.newMessageVoiceNotify) {
            if (USERINFO.newMessageShakeNotify) {   //声音跟振动
                if (muted) {
                    [self.myPlaySounde play];
                }else{
                    [self.myPlaySounde play];
                    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
                }
            }else{  //只有声音
                [self.myPlaySounde play];
            }
        }else{
            if (USERINFO.newMessageShakeNotify) {   //只有振动提醒
                AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
            }
        }
    }
    
    //用来解决上线收到多条消息，系统声音一直播放
    self.canPlayAudio = NO;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.canPlayAudio = YES;
    });
}

//判断appstore市场的版本 （检查更新）
- (void)judgeAPPVersion{
    
    NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
    
    NSString *oldVersion = infoDict[@"CFBundleShortVersionString"];
    
    NSString *url = [[NSString alloc] initWithFormat:@"https://itunes.apple.com/lookup?id=%@", @"1148317217"];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    //申明返回的结果是json类型
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    //申明请求的数据是json类型
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    //如果报接受类型不一致请替换一致text/html或别的
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/javascript", nil];
    
    [manager GET:url parameters:nil progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSNumber *number = responseObject[@"resultCount"];
        
        if (number.intValue == 1) {
            
            NSString *newVersion = responseObject[@"results"][0][@"version"];
            
            NSComparisonResult result = [newVersion compare:oldVersion];
            
            if (result == NSOrderedDescending) {  //市场版本高于包版本
    
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"有新版本可供更新" message:nil preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"更新" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://itunes.apple.com/cn/app/zhi-ma-bao-bao/id1148317217?mt=8"]];
                    
                }];
                
                UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil];
                
                [alertController addAction:cancleAction];
                
                [alertController addAction:okAction];
                
                [self presentViewController:alertController animated:YES completion:nil];
            }else if (result == NSOrderedAscending){      //市场版本低于包的版本
//                UserInfo *info = [UserInfo read];
//                info.hidePurse = YES;
//                [info save];
            }
            
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        NSLog(@"%@", error);
    }];
}


- (void)dealloc{
    
    //移除所有通知
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

//void UncaughtExceptionHandler(NSException *exception) {
//    NSArray *arr = [exception callStackSymbols];    //得到当前调用栈信息
//    NSString *reason = [exception reason];          //非常重要，就是崩溃的原因
//    NSString *name = [exception name];              //异常类型
//    NSLog(@"异常类型 : %@ \n 崩溃原因 : %@ \n 当前调用栈信息 : %@", name, reason, arr);
//}

@end
