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

// 数据库路径
#define ZhiMa_SqlitePath [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject stringByAppendingPathComponent:[NSString stringWithFormat:@"ZhiMa%@.sqlite",USERINFO.userID]]
// 新的数据库路径
#define ZhiMa_NEW_SqlitePath [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject stringByAppendingPathComponent:[NSString stringWithFormat:@"ZhiMa-%@.sqlite",USERINFO.userID]]

//  表名
/*朋友圈表*/
#define ZhiMaCicle_Talbe_Name @"Circle "
#define ZhiMaCicleComment_Table_Name @"Circle_Comment "
#define ZhiMaCirclePic_Table_Name @"Circle_Pic "
#define ZhiMaCircleLike_Table_Name @"Circle_Like "

/*消息表*/
#define ZhiMaChatConvence_Table_Name @"ChatConverse "
#define ZhiMaChatMessage_Table_Name @"ChatMessage "

/*用户表*/
#define ZhiMaUserMessage_Table_Name @"Friends "
#define ZhiMaNewFriend_Table_Name @"NewFriends "

/*群聊信息表*/
#define ZhiMaGroupChat_Table_Name @"GroupInfo "
#define ZhiMaGroupChatMember_Table_Name @"GroupMember "

/*服务号表*/
#define ZhiMaService_TableName @"ServiceInfo "
#define ZhiMaService_Message_TableName @"ServiceMessage "
/*收藏表*/
#define ZhiMaCollection_TableName @"Collection "

//  创建朋友圈table字段
#define CircleField @"( friend_nick TEXT NOT NULL, circle_ID INTEGER, userID TEXT NOT NULL, content TEXT NOT NULL, current_location TEXT NOT NULL, create_time TEXT NOT NULL, head_photo TEXT NOT NULL, content_type INTEGER, article_link TEXT, PRIMARY KEY ('circle_ID') ON CONFLICT REPLACE)"
// 取朋友圈table的字段名
#define CircleFiels_Name @"friend_nick, circle_ID, userID, content, current_location, create_time, head_photo, content_type, article_link"



// 创建 --- 评论字段
#define Circle_CommentField @"( friend_nick TEXT NOT NULL, fcid TEXT NOT NULL, comment TEXT NOT NULL, reply_friend_nick TEXT NOT NULL, reply_id TEXT NOT NULL, head_photo TEXT NOT NULL, create_time TEXT NOT NULL, circle_ID TEXT NOT NULL, userID TEXT NOT NULL, PRIMARY KEY ('fcid') ON CONFLICT REPLACE)"
// 取 ----  评论字段 -- 名
#define Circle_CommentFields_Name @"friend_nick, fcid, comment, reply_friend_nick, reply_id, head_photo, create_time, circle_ID, userID"



// 创建朋友圈图片 --- 字段名
#define CirCle_PicField @"(id INTEGER PRIMARY KEY AUTOINCREMENT, img_url TEXT NOT NULL, bigimg_url TEXT NOT NULL, circle_ID TEXT NOT NULL, weuser_id TEXT NOT NULL, picId TEXT)"
// 取朋友圈图片 -- 字段
#define CirCle_PicFields_Name @"img_url, bigimg_url, circle_ID, weuser_id, picId"


// 创建朋友圈点赞 ----- 字段名
#define CirCle_LikeField @"(userName TEXT NOT NULL, userId TEXT NOT NULL, userPhoto TEXT NOT NULL, circle_ID TEXT NOT NULL)"
// 取 ----  点赞字段 -- 名
#define CirCle_LikeFields_Name @"userName, userId, userPhoto, circle_ID"

#pragma mark - 会话
// 创建 聊天会话 table 字段
#define Chat_ConverseField @"(converseId TEXT, converseType INTEGER, converseName TEXT, converseLogo TEXT, converseContent TEXT, unReadCount INTEGER, topChat INTEGER, noDisturb INTEGER, time INTEGER,serviceMessageType INTEGER,messageType INTEGER DEFAULT 0, PRIMARY KEY ('converseId') ON CONFLICT REPLACE)"
#define Chat_ConverseFields_Name @"converseId,converseType,converseName,converseLogo,converseContent,unReadCount,topChat,noDisturb,time,serviceMessageType,messageType"


#pragma mark - 消息
// 创建 消息表 字段
#define Chat_MessageField @"(converseId TEXT, msgid TEXT NOT NULL, converseType INTEGER DEFAULT 0, type INTEGER DEFAULT 0, fromUid TEXT, toUidOrGroupId TEXT, subject TEXT, text TEXT, sendStatus INTEGER DEFAULT 1, isRead INTEGER DEFAULT 0, link TEXT, holderImageUrl TEXT, isDownLoad INTEGER DEFAULT 0, videoUrl TEXT, time INTEGER, PRIMARY KEY ('msgid') ON CONFLICT REPLACE)"
#define Chat_MessageFields_name @"converseId ,msgid,converseType ,type ,fromUid ,toUidOrGroupId ,subject ,text ,sendStatus ,isRead,link ,holderImageUrl ,isDownLoad ,videoUrl ,time"


#pragma mark - 好友信息表
// 好友信息表
#define User_MessageField @"(userId TEXT NOT NULL, userName TEXT NOT NULL, defineName TEXT, userPhoto TEXT,pinyin TEXT, PRIMARY KEY ('userId') ON CONFLICT REPLACE)"
#define User_MessageFields_name @"userId, userName, defineName, userPhoto, pinyin";


#pragma mark - 新好友
// 新的好友 表
#define NewFrend_MessageField @"(userId TEXT NOT NULL, userPhoto TEXT, userName TEXT, status INTEGER DEFAULT 0,  PRIMARY KEY ('userId') ON CONFLICT REPLACE)"
#define NewFriend_MessageFields_Name @"userId, userPhoto, userName, status"



#pragma mark - 群信息
//群聊信息表
#define GroupChat_MessageField @"(groupId TEXT NOT NULL, groupName TEXT NOT NULL, notice TEXT, groupPhoto TEXT, topChat INTEGER DEFAULT 0, noDisutrb INTEGER DEFAULT 0, saveToMailList INTEGER DEFAULT 0, showMemberName INTEGER DEFAULT 0, PRIMARY KEY ('groupId' ASC) ON CONFLICT REPLACE)"
#define GroupChat_MessageFields_name @"groupId, groupName, notice, groupPhoto, topChat, noDisutrb, saveToMailList, showMemberName"

#pragma mark - 群成员
//群成员表
#define GroupChat_MemberField @"(groupId TEXT NOT NULL, memberId TEXT NOT NULL, memberName TEXT NOT NULL, memberGroupName TEXT, memberPhoto TEXT, memberGroupState INTEGER)"
#define GroupChat_MemberFields_Name @"groupId, memberId, memberName, memberGroupName, memberPhoto,memberGroupState"


#pragma mark - 服务号信息
// 服务号基础信息 表
#define Service_MemberField @"(serviceId TEXT NOT NULL, serviceName TEXT NOT NULL, serviceLogo TEXT NOT NULL, serviceIntro TEXT, serviceMaster TEXT NOT NULL, serviceTel TEXT, serviceRange TEXT, serviceLongitude  TEXT, serviceLantitude TEXT, serviceReceiveMsg INTEGER DEFAULT 1, PRIMARY KEY ('serviceId' ASC))"
#define Service_MemberFields_Name @"serviceId, serviceName, serviceLogo, serviceIntro, serviceMaster, serviceTel, serviceRange, serviceLongitude, serviceLantitude, serviceReceiveMsg"

#pragma mark - 服务号消息
//服务号消息 表
#define Service_Message_MemberField @"(serviceId TEXT NOT NULL, time INTEGER ,sid TEXT NOT NULL, msgType INTEGER NOT NULL,listJson TEXT NOT NULL, PRIMARY KEY ('serviceId' ASC) ON CONFLICT REPLACE)"
#define Service_Message_MemberFields_Name @"serviceId, time, sid, msgType, listJson"


#pragma mark - 收藏
// 收藏相关
#define Collection_MemberField @"(id INTEGER PRIMARY KEY AUTOINCREMENT, head TEXT NOT NULL, name TEXT NOT NULL, time TEXT NOT NULL, content TEXT, collectionId TEXT NOT NULL, type INTEGER, pic_name TEXT, small_img TEXT, isDownload INTEGER, locationUrl TEXT)"
#define Collection_MemberFields_Name @"head, name, time, content, collectionId, type, pic_name, small_img, isDownload, locationUrl"


#endif /* FMDBManagerHeader_h */
