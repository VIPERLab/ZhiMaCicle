//
//  FMDBManagerHeader.h
//  FMDBTestDemo
//
//  Created by mac on 16/9/22.
//  Copyright © 2016年 mac. All rights reserved.
//

#ifndef FMDBManagerHeader_h
#define FMDBManagerHeader_h


#define Sqlite 的路径

// 朋友圈数据库路径
#define ZhiMaCircle_SqlitePath [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject stringByAppendingPathComponent:@"ZhiMa_Circle.sqlite"]

// 聊天数据库路径
#define ZhiMaChat_SqlitePath [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject stringByAppendingPathComponent:@"ZhiMa_Chat.sqlite"]

//  表名
/*朋友圈表*/
#define ZhiMaCicle_Talbe_Name @"Circle "
#define ZhiMaCicleComment_Table_Name @"Circle_Comment "
#define ZhiMaCirclePic_Table_Name @"Circle_Pic "
#define ZhiMaCircleLike_Table_Name @"Circle_Like "
/*消息表*/
#define ZhiMaChatConvence_Table_Name @"ChatConverse "
#define ZhiMaChatMessage_Table_Name @"ChatMessage "

//  创建朋友圈table字段
#define CircleField @"(id INTEGER PRIMARY KEY AUTOINCREMENT, friend_nick TEXT NOT NULL, circle_ID TEXT NOT NULL, userID TEXT NOT NULL, content TEXT NOT NULL, current_location TEXT NOT NULL, create_time TEXT NOT NULL, head_photo TEXT NOT NULL)"
// 取朋友圈table的字段名
#define CircleFiels_Name @"friend_nick, circle_ID, userID, content, current_location, create_time, head_photo"



// 创建 --- 评论字段
#define Circle_CommentField @"(id INTEGER PRIMARY KEY AUTOINCREMENT, friend_nick TEXT NOT NULL, fcid TEXT NOT NULL, comment TEXT NOT NULL, reply_friend_nick TEXT NOT NULL, reply_id TEXT NOT NULL, head_photo TEXT NOT NULL, create_time TEXT NOT NULL, circle_ID TEXT NOT NULL, userID TEXT NOT NULL)"
// 取 ----  评论字段 -- 名
#define Circle_CommentFields_Name @"friend_nick, fcid, comment, reply_friend_nick, reply_id, head_photo, create_time, circle_ID, userID"



// 创建朋友圈图片 --- 字段名
#define CirCle_PicField @"(id INTEGER PRIMARY KEY AUTOINCREMENT, img_url TEXT NOT NULL, bigimg_url TEXT NOT NULL, circle_ID TEXT NOT NULL)"
// 取朋友圈图片 -- 字段
#define CirCle_PicFields_Name @"img_url, bigimg_url, circle_ID"


// 创建朋友圈点赞 ----- 字段名
#define CirCle_LikeField @"(id INTEGER PRIMARY KEY AUTOINCREMENT, userName TEXT NOT NULL, userId TEXT NOT NULL, userPhoto TEXT NOT NULL, circle_ID TEXT NOT NULL)"
// 取 ----  点赞字段 -- 名
#define CirCle_LikeFields_Name @"userName, userId, userPhoto, circle_ID"


// 创建 聊天会话 table 字段
#define Chat_ConverseField @"(id INTEGER PRIMARY KEY AUTOINCREMENT, time TEXT NOT NULL, converseType TEXT NOT NULL, converseId TEXT NOT NULL, unReadCount TEXT NOT NULL, topChat INTEGER, disturb INTEGER, converseName TEXT NOT NULL, converseHead_photo TEXT NOT NULL, converseContent TEXT NOT NULL)"
#define Chat_ConverseFields_Name @"time,converseType,converseId,unReadCount,topChat,disturb,converseName,converseHead_photo,converseContent"


// 创建 消息表 字段
#define Chat_MessageField @"(id INTEGER PRIMARY KEY AUTOINCREMENT, msgid TEXT NOT NULL, type INTEGER, fromUid TEXT NOT NULL, toUidOrGroupId TEXT NOT NULL, time TEXT NOT NULL, text TEXT NOT NULL, isGroup INTEGER, converseId TEXT NOT NULL)"
#define Chat_MessageFields_name @"msgid,type,fromUid,toUidOrGroupId,time,text,isGroup,converseId"



#endif /* FMDBManagerHeader_h */
