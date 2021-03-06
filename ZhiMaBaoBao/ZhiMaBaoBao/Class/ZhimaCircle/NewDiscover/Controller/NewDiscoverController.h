//
//  NewDiscoverController.h
//  YiIM_iOS
//
//  Created by mac on 16/8/22.
//  Copyright © 2016年 ikantech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
@class SDTimeLineCellModel;

typedef void(^returnBlock)(SDTimeLineCellModel *model);

@interface NewDiscoverController : BaseViewController

// 这条朋友圈的性质 1文字 , 2链接
@property (nonatomic, assign) int circleType;

@property (nonatomic, copy) NSString *linkValue;

@property (nonatomic, copy) returnBlock block;

@end
