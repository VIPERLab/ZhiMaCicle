//
//  NSString+MsgId.m
//  ZhiMaBaoBao
//
//  Created by liugang on 16/10/10.
//  Copyright © 2016年 liugang. All rights reserved.
//

#import "NSString+MsgId.h"

@implementation NSString (MsgId)

/** 生成随机messageID */
+ (NSString *)generateMessageID
{
    static int kNumber = 8;
    
    NSString *sourceStr = @"0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    NSMutableString *resultStr = [[NSMutableString alloc] init];
    srand((unsigned int)time(0));
    for (int i = 0; i < kNumber; i++)
    {
        unsigned index = rand() % [sourceStr length];
        NSString *oneStr = [sourceStr substringWithRange:NSMakeRange(index, 1)];
        [resultStr appendString:oneStr];
    }
    return resultStr;
}

@end
