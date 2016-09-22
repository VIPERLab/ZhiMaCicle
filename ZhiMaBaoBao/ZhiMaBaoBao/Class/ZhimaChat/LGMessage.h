//
//  LGMessage.h
//  ZhiMaBaoBao
//
//  Created by liugang on 16/9/21.
//  Copyright © 2016年 liugang. All rights reserved.
//

typedef NS_OPTIONS(NSUInteger, MessageType) {
    MessageTypeText    = 0,   //文本消息
    MessageTypeImage,         //图片
    MessageTypeAudio          //语音
};

#import <Foundation/Foundation.h>

#define MSG_MAX_WIDTH   DEVICEWITH - 2 * MSG_AVTAR_SIZE - 7 * MSG_MARGIN   //消息最大宽度
#define MSG_FONT [UIFont systemFontOfSize:15]       //消息字体
#define MSG_PADDING  5                              //消息内边距
#define MSG_MARGIN   10                             //消息外边距
#define MSG_AVTAR_SIZE  40                          //消息头像大小
#define MSG_MIN_HEIGHT  40                          //消息bulldeView最小高度

#define TIME_HEIGHT     40                          //固定时间试图占用高度为40  内容高20 上边距15 下边距5
#define MSG_TIME_FONT [UIFont systemFontOfSize:12]  //时间字体

@interface LGMessage : NSObject

 /** 消息类型*/
@property (nonatomic, assign) MessageType msgType;

 /** 消息发送者*/
@property (nonatomic, copy) NSString *from;

 /** 消息接收者*/
@property (nonatomic, copy) NSString *to;

 /** 消息发送时间*/
@property (nonatomic, copy) NSString *time;

 /** 消息内容*/
@property (nonatomic, copy) NSString *body;

 /** 单元格高度*/
@property (nonatomic, assign) CGFloat cellHeight;

/** 消息背景高度*/
@property (nonatomic, assign) CGFloat buddleHeight;

 /** 消息文本宽高*/
@property (nonatomic, assign) CGSize textWH;

 /** 时间的宽高*/
@property (nonatomic, assign) CGSize timeWH;

 /** 用户自身*/
@property (nonatomic, assign, readonly, getter=isUser) BOOL user;
@end
