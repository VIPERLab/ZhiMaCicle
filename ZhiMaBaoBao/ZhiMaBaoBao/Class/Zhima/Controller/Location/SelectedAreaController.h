//
//  SelectedAreaController.h
//  YiIM_iOS
//
//  Created by mac on 16/8/29.
//  Copyright © 2016年 ikantech. All rights reserved.
//

#import "BaseViewController.h"
@class KXLocationModel;
@interface SelectedAreaController : BaseViewController
@property (nonatomic, weak) KXLocationModel *provinceModel;
@property (nonatomic, copy) NSString *provinceID;
@end
