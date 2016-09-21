//
//  NewDiscoverController.h
//  YiIM_iOS
//
//  Created by mac on 16/8/22.
//  Copyright © 2016年 ikantech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

typedef void(^returnBlock)();

@interface NewDiscoverController : BaseViewController

@property (nonatomic, copy) returnBlock block;

@end
