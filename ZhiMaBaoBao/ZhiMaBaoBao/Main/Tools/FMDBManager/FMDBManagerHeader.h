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

//  表名
#define ZhiMaCicle_Talbe_Name @"Circle "
#define ZhiMaCicleComment_Table_Name @"Circle_Comment "
#define ZhiMaCirclePic_Table_Name @"Circle_Pic "
#define ZhiMaCircleLike_Table_Name @"Circle_Like "

//  创建朋友圈table字段
#define CircleField @"(id INTEGER PRIMARY KEY AUTOINCREMENT, friend_nick TEXT NOT NULL, fcid TEXT NOT NULL, openfireaccount TEXT NOT NULL, content TEXT NOT NULL, current_location TEXT NOT NULL, create_time TEXT NOT NULL, head_photo TEXT NOT NULL)"
// 取朋友圈table的字段名
#define CircleFiels_Name @"friend_nick, fcid, openfireaccount, content, current_location, create_time, head_photo"



// 创建 --- 评论字段
#define Circle_CommentField @"(id INTEGER PRIMARY KEY AUTOINCREMENT, friend_nick TEXT NOT NULL, fcid TEXT NOT NULL, comment TEXT NOT NULL, reply_friend_nick TEXT NOT NULL, reply_openfireaccount TEXT NOT NULL, head_photo TEXT NOT NULL, create_time TEXT NOT NULL, circle_ID TEXT NOT NULL, openfireaccount TEXT NOT NULL)"
// 取 ----  评论字段 -- 名
#define Circle_CommentFields_Name @"friend_nick, fcid, comment, reply_friend_nick, reply_openfireaccount, head_photo, create_time, circle_ID, openfireaccount"



// 创建朋友圈图片 --- 字段名
#define CirCle_PicField @"(id INTEGER PRIMARY KEY AUTOINCREMENT, img_url TEXT NOT NULL, bigimg_url TEXT NOT NULL, circle_ID TEXT NOT NULL)"
// 取朋友圈图片 -- 字段
#define CirCle_PicFields_Name @"img_url, bigimg_url, circle_ID"


// 创建朋友圈点赞 ----- 字段名
#define CirCle_LikeField @"(id INTEGER PRIMARY KEY AUTOINCREMENT, userName TEXT NOT NULL, userId TEXT NOT NULL, userPhoto TEXT NOT NULL, circle_ID TEXT NOT NULL)"
#define CirCle_LikeFields_Name @"userName, userId, userPhoto, circle_ID"


#endif /* FMDBManagerHeader_h */
