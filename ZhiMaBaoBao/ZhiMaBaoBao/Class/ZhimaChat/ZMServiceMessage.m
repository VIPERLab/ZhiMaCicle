//
//  ZMServiceMessage.m
//  ZhiMaBaoBao
//
//  Created by ios开发 on 16/10/31.
//  Copyright © 2016年 liugang. All rights reserved.
//

#import "ZMServiceMessage.h"

@implementation ZMServiceMessage
+ (NSDictionary *)replacedKeyFromPropertyName{
    return @{
             @"msgArr":@"list",
             @"msgTitle":@"text",
             @"msgContent":@"subject",
             @"msgPicUrl":@"picurl",
             @"msgUrl":@"link"
             };
}

////存储时间字符串时 转时间戳存一份
//- (void)setMsgtime:(NSString *)msgtime{
//    _msgtime = msgtime;
//    NSInteger stamp = [NSDate cTimestampFromString:msgtime format:@"yyyy-MM-dd HH:mm:ss"];
//    self.timeStamp = stamp;
//}

//存储时间字符串时 转时间戳存一份
- (void)setService:(LGServiceModel *)service{
    _service = service;
    NSInteger stamp = [NSDate cTimestampFromString:service.msgtime format:@"yyyy-MM-dd HH:mm:ss"];
    self.timeStamp = stamp;
}


//存消息list的时候 转json字符串用于存储到数据库
//- (void)setMsgArr:(NSArray<ZMServiceMessage *> *)msgArr{
//    _msgArr = msgArr;
//    
//    self.listJson = [msgArr mj_JSONString];
//}

@end
