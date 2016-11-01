//
//  ZMServiceMessage.m
//  ZhiMaBaoBao
//
//  Created by ios开发 on 16/10/31.
//  Copyright © 2016年 liugang. All rights reserved.
//

#import "ZMServiceMessage.h"

@implementation ZMServiceMessage

//存储时间字符串时 转时间戳存一份
- (void)setMsgtime:(NSString *)msgtime{
    _msgtime = msgtime;
    NSInteger stamp = [NSDate cTimestampFromString:msgtime format:@"yyyy-MM-dd HH:mm:ss"];
    self.timeStamp = stamp;
}


@end
