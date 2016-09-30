//
//  LGChatInfoController.h
//  YiIM_iOS
//
//  Created by liugang on 16/8/13.
//  Copyright © 2016年 ikantech. All rights reserved.
//  聊天信息

#import "BaseViewController.h"

@interface LGChatInfoController : BaseViewController

@property (nonatomic, copy) NSString *userId;
@property (nonatomic, copy) NSString *displayName;  //展示名称
@property (nonatomic, copy) NSString *avtarUrl;     //头像url
@end
