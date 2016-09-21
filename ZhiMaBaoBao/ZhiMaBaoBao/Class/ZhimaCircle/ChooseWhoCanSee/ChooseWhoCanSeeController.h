//
//  ChooseWhoCanSeeController.h
//  YiIM_iOS
//
//  Created by mac on 16/8/24.
//  Copyright © 2016年 ikantech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

typedef void(^ReturnBlock)(BOOL PrivateClass);

@interface ChooseWhoCanSeeController : BaseViewController

@property (nonatomic, assign)BOOL isPrivate; //0是公开，1是私密

@property (nonatomic, copy) ReturnBlock returnBlock;

@end
