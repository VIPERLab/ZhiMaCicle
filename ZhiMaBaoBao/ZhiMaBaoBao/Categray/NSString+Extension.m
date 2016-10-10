//
//  NSString+Extension.m
//  CBExtension
//
//  Created by ly on 13-6-29.
//  Copyright (c) 2013年 Lei Yan. All rights reserved.
//

#import "NSString+Extension.h"

@implementation NSString (Extension)

#pragma mark - Regular expression
- (NSMutableArray *)itemsForPattern:(NSString *)pattern
{
    return [self itemsForPattern:pattern captureGroupIndex:0];
}

- (NSMutableArray *)itemsForPattern:(NSString *)pattern captureGroupIndex:(NSUInteger)index
{
    if ( !pattern )
        return nil;
    
    NSError *error = nil;
    NSRegularExpression *regx = [[NSRegularExpression alloc] initWithPattern:pattern
        options:NSRegularExpressionCaseInsensitive error:&error];
    if (error)
    {
        NSLog(@"Error for create regular expression:\nString: %@\nPattern %@\nError: %@\n",self, pattern, error);
    }
    else
    {
        NSMutableArray *results = [[NSMutableArray alloc] init];
        NSRange searchRange = NSMakeRange(0, [self length]);
        [regx enumerateMatchesInString:self options:0 range:searchRange usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
            
            NSRange groupRange =  [result rangeAtIndex:index];
            NSString *match = [self substringWithRange:groupRange];
            [results addObject:match];
        }];
        return results;
    }
    
    return nil;
}

- (NSString *)itemForPatter:(NSString *)pattern
{
    return [self itemForPattern:pattern captureGroupIndex:0];
}

- (NSString *)itemForPattern:(NSString *)pattern captureGroupIndex:(NSUInteger)index
{
    if ( !pattern )
        return nil;
    
    NSError *error = nil;
    NSRegularExpression *regx = [[NSRegularExpression alloc] initWithPattern:pattern
        options:NSRegularExpressionCaseInsensitive error:&error];
    if (error)
    {
        NSLog(@"Error for create regular expression:\nString: %@\nPattern %@\nError: %@\n",self, pattern, error);
    }
    else
    {
        NSRange searchRange = NSMakeRange(0, [self length]);
        NSTextCheckingResult *result = [regx firstMatchInString:self options:0 range:searchRange];
        NSRange groupRange = [result rangeAtIndex:index];
        NSString *match = [self substringWithRange:groupRange];
        return match;
    }
    
    return nil;
}

#pragma mark - Time Interval
- (NSTimeInterval)timeIntervalFromString:(NSString *)timeString withDateFormat:(NSString *)format
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:format];
    return [[formatter dateFromString:timeString] timeIntervalSince1970];
}

- (NSTimeInterval)localTimeIntervalFromString:(NSString *)timeString withDateFormat:(NSString *)format
{
    NSTimeInterval timeInterval = [self timeIntervalFromString:timeString withDateFormat:format];
    NSUInteger secondsOffset = [[NSTimeZone localTimeZone] secondsFromGMT];
    return (timeInterval + secondsOffset);
}

#pragma mark - Contains
- (BOOL)contains:(NSString *)piece
{
    return ( [self rangeOfString:piece].location != NSNotFound );
}

- (NSString *)trim
{
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (NSString *)replaceAllblank
{
    return [self stringByReplacingOccurrencesOfString:@" " withString:@""];
}

- (id)jsonObject
{
    NSString *jsonStr = [self trim];
    
    jsonStr = [jsonStr stringByReplacingOccurrencesOfString:@"\r\n" withString:@"<br />"];
    
    jsonStr = [jsonStr stringByReplacingOccurrencesOfString:@"\n" withString:@"<br />"];
    jsonStr = [jsonStr stringByReplacingOccurrencesOfString:@"\n\n" withString:@"<br />"];
    
    jsonStr = [jsonStr stringByReplacingOccurrencesOfString:@"\t" withString:@"&nbsp;&nbsp;&nbsp;&nbsp;"];
    NSData *data = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error = nil;
    id jsonObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    
    return jsonObject;
}

- (NSDate *)convertToDateWithFormat:(NSString *)format;
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
   // NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"GMT"];
    [formatter setDateFormat:format];
   // [formatter setTimeZone:timeZone];
    NSDate *date = [formatter dateFromString:self];
    return date;
}


- (BOOL)isBlankString{
    if (self == nil || self == NULL) {
        return YES;
    }
    if ([self isKindOfClass:[NSNull class]]) {
        return YES;
    }
    if ([[self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length]==0) {
        return YES;
    }
    return NO;
}

/**
 *  自己写得方法来求字符串的size
 *
 *
 */
//- (CGSize)sizeGwWithFont:(UIFont *)font Size:(CGSize)size
//{
//    //----可以作为 nsstring 的扩展类：参数：字符串长度，字体大小，固定的宽度或长度 | 返回值：size或者直接返回高度或者长度
//    //----注意：ios7情况下宽度计算貌似有点问题
//    CGSize stringSize;
//    CGRect stringRect;
//    CGSize constraintSize = size;//求长度就固定高度，就高度就固定长度
//#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 70000
//    CGRect stringRect = [self boundingRectWithSize:constraintSize options:(NSStringDrawingUsesFontLeading|NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin) attributes:@{NSFontAttributeName: font} context:NULL];
//    
//    stringRect.size.width = stringRect.size.width + 1;
//#else
//    stringSize = [self sizeWithFont:font constrainedToSize:constraintSize];
//#endif
//    
//    if (stringSize.height == 0) {
//        stringSize = stringRect.size;
//    }
//    //----
//
//    return stringSize;
//}

@end
