//
//  ResponseData.h
//  YiIM_iOS
//
//  Created by liugang on 16/8/6.
//  Copyright © 2016年 ikantech. All rights reserved.
//

#import <Foundation/Foundation.h>




@interface ResponseData : NSObject
 /** 状态码*/
@property (nonatomic, assign) NSInteger code;
 /** 响应数据*/
@property (nonatomic, copy) id data;
 /** 服务器返回消息*/
@property (nonatomic, copy) NSString *msg;
@end


@interface ErrorData : NSObject

@property (nonatomic, copy) NSString *msg;

@property (nonatomic, assign) NSInteger code;

@end
