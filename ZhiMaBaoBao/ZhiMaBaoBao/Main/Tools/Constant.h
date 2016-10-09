//
//  Constant.h
//  ZhiMaBaoBao
//
//  Created by liugang on 16/9/19.
//  Copyright © 2016年 liugang. All rights reserved.
//

#ifndef Constant_h
#define Constant_h

//加载数据显示文本
#define LODINGTEXT @"请稍等..."

//用户本地资料
#define USERINFO        [UserInfo read]



//颜色宏定义
#define RGB(a,b,c)      [UIColor colorWithRed:a/255.0 green:b/255.0 blue:c/255.0 alpha:1]
#define WHITECOLOR      RGB(255,255,255)
#define BLACKCOLOR      RGB(0,0,0)
#define THEMECOLOR      RGB(249,80,87)
#define SEPARTORCOLOR   RGB(228, 229, 230)
#define BGCOLOR         RGB(230, 230, 230)
#define GRAYCOLOR       RGB(154,154,154)
#define ClearColor      [UIColor clearColor]


//字体宏定义
#define MAINFONT        [UIFont systemFontOfSize:16];
#define SUBFONT         [UIFont systemFontOfSize:14];

//屏幕宽高
#define DEVICEWITH   [UIScreen mainScreen].bounds.size.width
#define DEVICEHIGHT  [UIScreen mainScreen].bounds.size.height
//屏幕跟iphone的宽高比
#define SCLACEH     DEVICEHIGHT/(667.0)
#define SCLACEW     DEVICEWITH/(375.0)

// 需要显示时间的间隔最少分钟
#define DiffTimeThreeMins  5
// 沙盒路径
#define AUDIOPATH  [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]

//充值Appkey
#define RECHAPPKEY @"yihezhai20152016"

// ----  AES加密秘钥
#define APP_PUBLIC_PASSWORD     @"yihezhai16816888"

//本地测试环境
//#define DFAPIURL @"http://192.168.1.243:8088"

//测试环境
#define DFAPIURL @"http://zhimachat.yihezhai.cc"
#define DFAPIURLTEST @"http://zm.yihezhai.cc"


//正式网络环境
//#define DFAPIURL @"http://app.zhima11.com:8080"
//#define DFAPIURLTEST @"http://wx.zhima11.com"
<<<<<<< HEAD
=======

//测试支付，打电话余额
#define DFAPIURLTEST @"http://zm.yihezhai.cc"

>>>>>>> developer

//常用头文件
#import "AFNetworking.h"
#import "Masonry.h"
#import "MJExtension.h"
#import "MJRefresh.h"
#import "FMDB.h"
#import "LCProgressHUD.h"
#import "LogResBaseController.h"
#import "LGNetWorking.h"
#import "UserInfo.h"
#import "UIView+x.h"
#import "UIView+Helpers.h"
#import "NSString+Helpers.h"
#import "NSString+Extension.h"

#import "KXCodingManager.h"

#import "UIImageView+WebCache.h"
#import "BaseViewController.h"
#import "NSDate+TimeCategory.h"

#import "KXActionSheet.h"


//FMDB管理头文件
#import "FMDBManager.h"


//通知头文件
#import "KNotificationManager.h"


#endif /* Constant_h */
