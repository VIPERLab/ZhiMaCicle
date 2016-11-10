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

+ (NSDictionary *)mj_replacedKeyFromPropertyName{
    return @{
             @"conversionType":@"converseType",
             @"actType":@"acttype",
             @"holderImageUrlString":@"holderImageUrl",
             @"videoDownloadUrl":@"videoUrl",
             @"timeStamp":@"time"
             };
}

//判断消息是否未用户自己发送
- (BOOL)isUser{
//    if ([self.from isEqualToString:USERINFO.uphone]) {
//        return YES;
//    }
    return NO;
}

//默认发送给安卓的时间为0，语音消息手动赋值
- (instancetype)init{
    self = [super init];
    if (self) {
        self.audioLength = 0;
        self.link = @"";
        self.videoDownloadUrl = @"";
        self.holderImageUrlString = @"";
        self.subject = @"";
    }
    return self;
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

//储存时间戳时，转成时间格式字符串
- (void)setTimeStamp:(NSInteger)timeStamp{
    _timeStamp = timeStamp;
    self.msgtime = [NSDate dateStrFromCstampTime:timeStamp withDateFormat:@"yyyy-MM-dd HH:mm:ss"];
}

////存储时间字符串时 转时间戳存一份
//- (void)setMsgtime:(NSString *)msgtime{
//    _msgtime = msgtime;
//    NSInteger stamp = [NSDate cTimestampFromString:msgtime format:@"yyyy-MM-dd HH:mm:ss"];
//    self.timeStamp = stamp;
//}

@end
