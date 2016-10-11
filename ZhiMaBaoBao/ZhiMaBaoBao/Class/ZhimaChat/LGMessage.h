//
//  LGMessage.h
//  ZhiMaBaoBao
//
//  Created by liugang on 16/9/21.
//  Copyright © 2016年 liugang. All rights reserved.
//

//消息指令类型
typedef NS_OPTIONS(NSUInteger, ActType) {
    ActTypeKickuser = 0,        //相同用户登录，剔除之前的登录用户
    ActTypeNormal,              //普通消息
    ActTypeAddfriend,           //好友请求
    ActTypeUpdatefriend,        //更新好友数据
    ActTypeUpdategroupnum,      //更新群用户数
    ActTypeDeluserfromgroup,    //从群组删除用户
    ActTypeRenamegroup,         //修改群名片，所有群成员都会同步修改
    ActTypeUndomsg              //撤销消息，收到消息的用户都将删除消息

};

//普通消息类型
typedef NS_OPTIONS(NSUInteger, MessageType) {
    MessageTypeText  = 0,   //文本消息
    MessageTypeImage,       //图片
    MessageTypeAudio,       //语音
    MessageTypeSystem       //系统消息
};

//发送状态
typedef NS_OPTIONS(NSUInteger, SendStatus){
    IMRequesting = 1,       // 请求
    IMRequestFaile = 2,     // 请求失败
    IMRequestSuccessed = 3  // 成功
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

 /** 指令类型*/
@property (nonatomic, assign) ActType actType;
 /** 消息id*/
@property (nonatomic, copy) NSString *msgid;
 /** 消息类型*/
@property (nonatomic, assign) MessageType type;
 /** 消息发送者id*/
@property (nonatomic, copy) NSString *fromUid;
 /** 是否为群聊*/
@property (nonatomic, assign) BOOL isGroup;

 /** 消息接收者id(如果是群则是群id) */
@property (nonatomic, copy) NSString *toUidOrGroupId;

 /** 消息发送时间*/
@property (nonatomic, copy) NSString *msgtime;

 /** 消息发送时间时间戳*/
@property (nonatomic, assign) NSInteger timeStamp;


/** 语音时长 给安卓用的*/
@property (nonatomic, assign) NSInteger audioLength;

 /** 消息内容*/
@property (nonatomic, copy) NSString *text;
 /** 签名*/
//@property (nonatomic, copy) NSString *sign;

 /** 被撤销消息的id (这个字段在socket收到撤销消息时使用) */
@property (nonatomic, copy) NSString *undoMsgid;

 /** 阅读状态（0未读，1已读'*/
@property (nonatomic, assign) BOOL is_read;
 /** 消息发送状态 0 发送失败  1 发送成功*/
@property (nonatomic,assign) BOOL sendStatus;

// 是否正在发送中
@property (nonatomic, assign) BOOL isSending;
/** 图片本地路径*/
@property (nonatomic, copy) NSString *picUrl;

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
