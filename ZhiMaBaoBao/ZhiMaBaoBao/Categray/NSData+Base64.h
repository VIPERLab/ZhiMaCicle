//
//  NSData+Base64.h
//  ZhiMaBaoBao
//
//  Created by liugang on 16/9/29.
//  Copyright © 2016年 liugang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (Base64)


/**
*  将文本转换为base64格式字符串
*/
+ (NSString *)base64StringFromText:(NSString *)text;

/**
 *  将data转换为base64格式字符串
 */
+ (NSString *)base64StringFromData:(NSData *)data;

/**
 *  将base64格式字符串转换为文本
 */
+ (NSString *)textFromBase64String:(NSString *)base64;

/**
 *  将base64格式字符串转换为data
 */
+ (NSData *)dataTromBase64String:(NSString *)base64;

@end
