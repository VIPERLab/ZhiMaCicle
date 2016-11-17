//
//  LGSearchController.h
//  YiIM_iOS
//
//  Created by liugang on 16/8/11.
//  Copyright © 2016年 ikantech. All rights reserved.
//

#import "BaseViewController.h"

typedef void(^returnBlock)(ZhiMaFriendModel *model);

@interface LGSearchController : BaseViewController

@property (nonatomic, strong) UIViewController *fatherVC;

@property (nonatomic, copy) returnBlock block;

@end
