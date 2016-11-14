//
//  NSDate+TimeCategory.m
//  ZhiMaBaoBao
//
//  Created by liugang on 16/9/27.
//  Copyright © 2016年 liugang. All rights reserved.
//

#import "NSDate+TimeCategory.h"

static NSDateFormatter *dateFormatter;

@implementation NSDate (TimeCategory)

+(NSDateFormatter *)defaultFormatter
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dateFormatter = [[NSDateFormatter alloc]init];
    });
    return dateFormatter;
}

+ (NSDate *)dateFromString:(NSString *)timeStr
                    format:(NSString *)format
{
    NSDateFormatter *dateFormatter = [NSDate defaultFormatter];
    [dateFormatter setDateFormat:format];
    NSDate *date = [dateFormatter dateFromString:timeStr];
    return date;
}

+ (long long)cTimestampFromDate:(NSDate *)date
{
    long long recordTime = [date timeIntervalSince1970]*1000;
    return recordTime;
}


+(long long)cTimestampFromString:(NSString *)timeStr
                          format:(NSString *)format
{
    NSDate *date = [NSDate dateFromString:timeStr format:format];
    return [NSDate cTimestampFromDate:date];
}

+ (NSString *)dateStrFromCstampTime:(long long)timeStamp
                     withDateFormat:(NSString *)format
{
    
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timeStamp/1000];
    return [NSDate datestrFromDate:date withDateFormat:format];
}

+ (NSString *)datestrFromDate:(NSDate *)date
               withDateFormat:(NSString *)format
{
    NSDateFormatter* dateFormat = [NSDate defaultFormatter];
    [dateFormat setDateFormat:format];
    return [dateFormat stringFromDate:date];
}

+ (long long)currentTimeStamp{
    NSDate *date = [NSDate date];
    return [NSDate cTimestampFromDate:date];
}

@end
