//
//  Constant.h
//  ZhiMaBaoBao
//
//  Created by liugang on 16/9/19.
//  Copyright © 2016年 liugang. All rights reserved.
//

#ifndef Constant_h
#define Constant_h

//颜色宏定义
#define RGB(a,b,c)      [UIColor colorWithRed:a/255.0 green:b/255.0 blue:c/255.0 alpha:1]
#define WHITECOLOR      RGB(255,255,255)
#define THEMECOLOR      RGB(249,80,87)
#define SEPARTORCOLOR   RGB(228, 229, 230)
#define BGCOLOR         RGB(230, 230, 230)

//字体宏定义
#define MAINFONT        [UIFont systemFontOfSize:16];
#define SUBFONT         [UIFont systemFontOfSize:14];

//屏幕宽高
#define DEVICEWITH   [UIScreen mainScreen].bounds.size.width
#define DEVICEHIGHT  [UIScreen mainScreen].bounds.size.height

//正式网络环境
#define DFAPIURL @"http://app.zhima11.com:8080"

//常用头文件
#import "AFNetworking.h"
#import "Masonry.h"
#import "MJExtension.h"
#import "MJRefresh.h"
#import "FMDB.h"
#import "MBProgressHUD.h"


#endif /* Constant_h */
