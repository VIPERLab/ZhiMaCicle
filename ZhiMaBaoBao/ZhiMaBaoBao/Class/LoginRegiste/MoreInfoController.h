//
//  MoreInfoController.h
//  ZhiMaBaoBao
//
//  Created by liugang on 16/10/20.
//  Copyright © 2016年 liugang. All rights reserved.
//

#import "BaseViewController.h"

@interface MoreInfoController : BaseViewController

@property (nonatomic, assign) BOOL isResgiste;  //注册流程 （展示跳过按钮）

@property (nonatomic, copy) NSString *password;     //登录密码

@end
