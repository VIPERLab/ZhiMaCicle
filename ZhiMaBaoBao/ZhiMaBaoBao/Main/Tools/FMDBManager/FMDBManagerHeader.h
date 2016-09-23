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
#define ZhiMaSqlitePath [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject stringByAppendingPathComponent:@"ZhiMa.sqlite"]

#define ZhiMaCicle_Talbe_Name @"Circle "
#define ZhiMaCicleComment_Table_Name @"Circle_Comment "

//  创建朋友圈table字段
#define CircleField @"(id INTEGER PRIMARY KEY AUTOINCREMENT, friend_nick TEXT NOT NULL, fcid TEXT NOT NULL, openfireaccount TEXT NOT NULL, content TEXT NOT NULL, current_location TEXT NOT NULL, create_time TEXT NOT NULL, head_photo TEXT NOT NULL)"

// 取朋友圈table的字段名
#define CircleFiels_Name @"friend_nick, fcid, openfireaccount, content, current_location, create_time, head_photo"

// 创建评论table字段
#define Circle_CommentField @"(id INTEGER PRIMARY KEY AUTOINCREMENT, friend_nick TEXT NOT NULL, fcid TEXT NOT NULL, comment TEXT NOT NULL, reply_friend_nick TEXT NOT NULL, reply_openfireaccount TEXT NOT NULL, head_photo TEXT NOT NULL, create_time TEXT NOT NULL, circle_ID TEXT NOT NULL)"

// 取评论字段名
#define Circle_CommentFields_Name @"friend_nick, fcid, comment, reply_friend_nick, reply_openfireaccount, head_photo, create_time, circle_ID"


#endif /* FMDBManagerHeader_h */
