//
//  NSString+Extension.h
//  CBExtension
//
//  Created by ly on 13-6-29.
//  Copyright (c) 2013年 Lei Yan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Extension)

/*** 返回符合 pattern 的所有 items */
- (NSMutableArray *)itemsForPattern:(NSString *)pattern;

/*** 返回符合 pattern 的 捕获分组为 index 的所有 items */
- (NSMutableArray *)itemsForPattern:(NSString *)pattern captureGroupIndex:(NSUInteger)index;

/*** 返回符合 pattern 的第一个 item */
- (NSString *)itemForPatter:(NSString *)pattern;

/*** 返回符合 pattern 的 捕获分组为 index 的第一个 item */
- (NSString *)itemForPattern:(NSString *)pattern captureGroupIndex:(NSUInteger)index;

/*** 按 format 格式化字符串生成 NSDate 类型的对象，返回 timeString 时间与 1970年1月1日的时间间隔
 * @discussion 格式化后的 NSDate 类型对象为 +0000 时区时间
 */
- (NSTimeInterval)timeIntervalFromString:(NSString *)timeString withDateFormat:(NSString *)format;

/*** 按 format 格式化字符串生成 NSDate 类型的对象，返回当前时间距给定 timeString 之间的时间间隔
 * @discussion 格式化后的 NSDate 类型对象为本地时间
 */
- (NSTimeInterval)localTimeIntervalFromString:(NSString *)timeString withDateFormat:(NSString *)format;

- (BOOL)contains:(NSString *)piece;

//删除所有的空格键
- (NSString *)replaceAllblank;

// 删除字符串开头与结尾的空白符与换行
- (NSString *)trim;

//把字符串解析成json对象
- (id)jsonObject;

//把指字格式的字符串转换成NSDate
- (NSDate *)convertToDateWithFormat:(NSString *)format;

//获取字符串的size: 求长度就固定高度，就高度就固定长度
- (CGSize)sizeGwWithFont:(UIFont *)font Size:(CGSize)size;

//是否为空字符串 （空格也算空字符串）
- (BOOL)isBlankString;

@end
