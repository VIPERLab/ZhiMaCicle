//
//  LGSearchResultController.h
//  YiIM_iOS
//
//  Created by liugang on 16/8/12.
//  Copyright © 2016年 ikantech. All rights reserved.
//  查询好友结果展示页

#import "BaseViewController.h"

@interface LGSearchResultController : BaseViewController

@property (nonatomic, strong) NSArray *dataArr;
/** 是否是添加好友*/
@property (nonatomic, assign) BOOL isAddFriend;


@end
