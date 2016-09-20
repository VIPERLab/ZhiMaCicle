//
//  LGCallRecordModel.h
//  YiIM_iOS
//
//  Created by liugang on 16/8/8.
//  Copyright © 2016年 ikantech. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LGCallRecordModel : NSObject

//通话记录id
@property (nonatomic, assign) NSInteger id;
//拨打电话用户
@property (nonatomic, copy) NSString *from_weuser;
//接听电话用户
@property (nonatomic, copy) NSString *to_weuser;
//接听的电话
@property (nonatomic, copy) NSString *from_phone;
//拨打过去的电话
@property (nonatomic, copy) NSString *to_phone;
//通话时长		单位:秒
@property (nonatomic, copy) NSString *call_time;
//打电话类型:1呼出,2呼入,3未接
@property (nonatomic, assign) NSInteger call_type;
//手机号归属地
@property (nonatomic, copy) NSString *phone_attribution;
//更新时间(也是结束时间)
@property (nonatomic, copy) NSString *update_time;
//创建时间
@property (nonatomic, copy) NSString *create_time;
@end
