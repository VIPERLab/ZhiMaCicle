//
//  LGCallingControllerViewController.h
//  YiIM_iOS
//
//  Created by liugang on 16/8/9.
//  Copyright © 2016年 ikantech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LGCallingController : UIViewController
 /** 电话号码*/
@property (nonatomic, copy) NSString *phoneNum;
 /** 昵称*/
@property (nonatomic, copy) NSString *name;
 /** 头像url*/
@property (nonatomic, copy) NSString *avtarUrl;
//通话记录id
@property (nonatomic, assign) NSInteger recordId;

//切换通话状态
- (void)changeCallingState;
@end
