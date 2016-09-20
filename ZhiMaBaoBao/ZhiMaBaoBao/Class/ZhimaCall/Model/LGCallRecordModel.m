//
//  LGCallRecordModel.m
//  YiIM_iOS
//
//  Created by liugang on 16/8/8.
//  Copyright © 2016年 ikantech. All rights reserved.
//

#import "LGCallRecordModel.h"

@implementation LGCallRecordModel

- (NSString *)update_time{
    NSString *time = [_update_time substringToIndex:10];
    //获取当前时间
    NSDate *date = [NSDate date];
    NSString *dateStr = [[LGCallRecordModel stringFromDate:date] substringToIndex:10];
    
    //如果是今天
    NSString *resultStr = nil;
    if ([time isEqualToString:dateStr]) {
        //返回hh:mm
        resultStr = [_update_time substringWithRange:NSMakeRange(11, 5)];
    }else{
        //返回日期
        resultStr = [_update_time substringWithRange:NSMakeRange(5, 5)];
    }
    
    return resultStr;
}

+ (NSString *)stringFromDate:(NSDate *)date
{
    if (!date) {
        return nil;
    }
    return [[self defaultDateFormatter] stringFromDate:date];
}

+ (NSDateFormatter *)defaultDateFormatter
{
    static dispatch_once_t once;
    static NSDateFormatter *dateFormatter;
    dispatch_once(&once, ^{
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"yyyy-MM-dd";
    });
    return dateFormatter;
}
@end
