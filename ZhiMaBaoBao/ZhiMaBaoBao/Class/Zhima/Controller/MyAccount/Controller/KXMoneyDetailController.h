//
//  KXMoneyDetailController.h
//  YiIM_iOS
//
//  Created by mac on 16/9/17.
//  Copyright © 2016年 ikantech. All rights reserved.
//

#import "BaseViewController.h"
#import "MyAccountModel.h"

@interface KXMoneyDetailController : BaseViewController

@property (nonatomic, weak) MyAccountModel *model;
@property (nonatomic, strong) NSArray *dataArray;

@end
