//
//  LGMessage.m
//  ZhiMaBaoBao
//
//  Created by liugang on 16/9/21.
//  Copyright © 2016年 liugang. All rights reserved.
//

#import "LGMessage.h"
#import "NSDate+TimeCategory.h"

@implementation LGMessage

//判断消息是否未用户自己发送
- (BOOL)isUser{
//    if ([self.from isEqualToString:USERINFO.uphone]) {
//        return YES;
//    }
    return NO;
}



//计算消息内容高度
- (void)setText:(NSString *)text{
    _text = text;
    
    //文本size
    CGSize size = [text sizeWithFont:MSG_FONT maxSize:CGSizeMake(MSG_MAX_WIDTH, MAXFLOAT)];
    self.textWH = size;
    
    //如果文本高度加上边距小余最小高度，则返回最小高度加上边距
    CGFloat height = size.height + 2 * MSG_MARGIN;
    self.buddleHeight = height;
    if (height < MSG_MIN_HEIGHT) {
        self.buddleHeight = MSG_MIN_HEIGHT;
    }
}

//存储时间字符串时 转时间戳存一份
- (void)setMsgtime:(NSString *)msgtime{
    _msgtime = msgtime;
    NSInteger stamp = [NSDate cTimestampFromString:msgtime format:@"yyyy-MM-dd HH:mm:ss"];
    self.timeStamp = stamp;
}


/*
//将消息模型中的时间 字符串 转换为 时间戳
- (LGMessage *)messageTransToSamp{

    NSInteger stamp = [NSDate cTimestampFromString:self.msgtime format:@"yyyy-MM-dd HH:mm:ss"];
    self.msgtime = [NSString stringWithFormat:@"%d",stamp];
    return self;
}
//将消息模型中的 时间戳 转换为 字符串
- (LGMessage *)messageTransToStr{
    NSInteger stamp = [self.msgtime integerValue];
    NSString *timeStr = [NSDate dateStrFromCstampTime:stamp withDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    LGMessage *message = [[LGMessage alloc] init];
    message.msgid = self.msgid;
    message.type = self.type;
    message.fromUid = self.fromUid;
    message.isGroup = self.isGroup;
    message.toUidOrGroupId = self.toUidOrGroupId;
    message.text = self.text;
    message.is_read = self.is_read;
    message.msgtime = timeStr;
    return message;
}

//+ (LGMessage *)transMsgtimeToStr:(LGMessage *)message{
//    LGMessage *newMessage = [[LGMessage alloc] init];
//    newMessage.msgid
//
//}

//计算时间的宽高
//- (void)setTime:(NSString *)time{
//    _time = time;
//    
//    self.timeWH = [time sizeWithFont:MSG_TIME_FONT maxSize:CGSizeMake(MAXFLOAT, MAXFLOAT)];
//}
 */
@end
