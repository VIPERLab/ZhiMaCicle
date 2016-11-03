//
//  ZMServiceMessage.h
//  ZhiMaBaoBao
//
//  Created by ios开发 on 16/10/31.
//  Copyright © 2016年 liugang. All rights reserved.
//

typedef NS_OPTIONS(NSUInteger, ServiceMessageType) {
    ServiceMessageTypePurse  = 0,     //活动红包
    ServiceMessageTypeSingle,         //单条消息
    ServiceMessageTypeMoreThanOne     //多条消息

};

#import <Foundation/Foundation.h>

@interface ZMServiceMessage : NSObject

/** 服务号id*/
@property (nonatomic, copy) NSString *cropid;
/** 服务号logo*/
@property (nonatomic, copy) NSString *croplogo;
/** 服务号名称*/
@property (nonatomic, copy) NSString *cropname;
/** 红包说明*/
@property (nonatomic, copy) NSString *text;

/** 消息类型*/
@property (nonatomic, assign) ServiceMessageType type;
/** 消息id*/
@property (nonatomic, copy) NSString *msgid;
/** 消息时间*/
@property (nonatomic, copy) NSString *msgtime;
/** 消息发送时间时间戳*/
@property (nonatomic, assign) NSInteger timeStamp;

/** 文章消息里面的时间*/
@property (nonatomic, copy) NSString *detailMsgTime;
/** 消息标题*/
@property (nonatomic, copy) NSString *msgTitle;
/** 消息内容*/
@property (nonatomic, copy) NSString *msgContent;
/** 消息图片*/
@property (nonatomic, copy) NSString *msgPicUrl;
/** 消息详情的链接*/
@property (nonatomic, copy) NSString *msgUrl;
// 多条消息（由多个ZMServiceMessage组成）
@property (nonatomic, strong) NSArray<ZMServiceMessage *>* msgArr;

// 多条消息 的json字符串
@property (nonatomic, copy) NSString *listJson;

@end
