//
//  LGMessage.m
//  ZhiMaBaoBao
//
//  Created by liugang on 16/9/21.
//  Copyright © 2016年 liugang. All rights reserved.
//

#import "LGMessage.h"

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

//计算时间的宽高
- (void)setTime:(NSString *)time{
    _time = time;
    
    self.timeWH = [time sizeWithFont:MSG_TIME_FONT maxSize:CGSizeMake(MAXFLOAT, MAXFLOAT)];
}
@end
