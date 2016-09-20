//
//  LYResponseModel.h
//  LYVoIPDemo
//
//  Created by lijia on 16/8/9.
//  Copyright © 2016年 lzy. All rights reserved.
//

#import <Foundation/Foundation.h>

@class LYResponseData;
@interface LYResponseModel : NSObject


@property (nonatomic, copy) NSString *msg;

@property (nonatomic, strong) LYResponseData *data;

@property (nonatomic, assign) NSInteger code;

@end
/**
 *  当提交类型为“查询余额”时，此model会使用
 */
@interface LYResponseData : NSObject

@property (nonatomic, copy) NSString *balance;

@property (nonatomic, copy) NSString *valid_time;

@end

