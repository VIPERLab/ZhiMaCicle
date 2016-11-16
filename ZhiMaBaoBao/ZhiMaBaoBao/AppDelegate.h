//
//  AppDelegate.h
//  ZhiMaBaoBao
//
//  Created by liugang on 16/9/18.
//  Copyright © 2016年 liugang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <BaiduMapAPI_Base/BMKBaseComponent.h>
#import "WXApi.h"

static NSString *appKey = @"0cd7d458ab7123f59f37359c";
static NSString *channel = @"Publish channel";
static BOOL isProduction = YES;

@interface AppDelegate : UIResponder <UIApplicationDelegate,BMKGeneralDelegate,WXApiDelegate>

@property (strong, nonatomic) UIWindow *window;

@end

