//
//  SDTimeLineTableViewController.h
//  GSD_WeiXin(wechat)
//
//  Created by gsd on 16/2/25.
//  Copyright © 2016年 GSD. All rights reserved.
//


//#import "SDBaseTableViewController.h"
#import "BaseTableViewController.h"
#import "BaseViewController.h"

typedef void(^complitedBlock)();

@interface SDTimeLineTableViewController : BaseViewController

// -----  未读消息
@property (nonatomic, copy) NSString *headPhoto;
@property (nonatomic, assign) int unReadCount;

// -----  回调
@property (nonatomic, copy) complitedBlock block;

@end
