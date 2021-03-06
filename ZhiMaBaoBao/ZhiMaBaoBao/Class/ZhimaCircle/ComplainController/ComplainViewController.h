//
//  ComplainViewController.h
//  YiIM_iOS
//
//  Created by mac on 16/9/9.
//  Copyright © 2016年 ikantech. All rights reserved.
//

#import "BaseViewController.h"

#import "SDTimeLineCellModel.h"

@interface ComplainViewController : BaseViewController
@property (nonatomic, strong) NSArray *dataArray;
@property (nonatomic, copy) NSString *converseId;
@property (nonatomic, copy) NSString *userId;
@property (nonatomic, copy) NSString *circleId;
@property (nonatomic, assign) int type;
@property (nonatomic, weak) SDTimeLineCellModel *model;

@end
