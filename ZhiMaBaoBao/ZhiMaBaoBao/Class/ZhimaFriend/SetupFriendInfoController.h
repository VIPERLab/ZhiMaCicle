//
//  SetupFriendInfoController.h
//  YiIM_iOS
//
//  Created by liugang on 16/8/13.
//  Copyright © 2016年 ikantech. All rights reserved.
//  设置好友资料

#import "BaseViewController.h"
#import "ZhiMaFriendModel.h"

@interface SetupFriendInfoController : BaseViewController
 /** 用户id*/
@property (nonatomic, copy) NSString *userId;
@property (nonatomic, assign) BOOL isFromSearch;

@end
