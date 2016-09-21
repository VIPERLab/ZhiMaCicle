//
//  UserMessageModel.h
//  YiIM_iOS
//
//  Created by mac on 16/8/24.
//  Copyright © 2016年 ikantech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MJExtension.h"

@interface UserMessageModel : NSObject

@property (nonatomic, copy) NSString *content;          //内容

@property (nonatomic, assign) int ID;

@property (nonatomic, assign) int type;                 //消息类型:1朋友圈的评论,2点赞

@property (nonatomic, copy) NSString *imgurl;           //朋友圈第一张图片

@property (nonatomic, copy) NSString *create_time;      //创建时间

@property (nonatomic, copy) NSString *orderMainNo;      //主订单编号,

@property (nonatomic, copy) NSString *comment_userName;  //评论人的用户名

@property (nonatomic, copy) NSString *comment_headPhoto; //评论人的头像

@property (nonatomic, assign) int comment_type_Id;   //朋友圈的ID

//  ---

@property (nonatomic, copy) NSString *head_photo;


@property (nonatomic, copy) NSString *comment;  //朋友圈评论内容

@property (nonatomic, copy) NSString *circle_content;  //朋友圈内容

@property (nonatomic, copy) NSString *friend_nick;

@property (nonatomic, copy) NSString *reply_openfireaccount;

@property (nonatomic, assign) CGFloat cellHight;
@end
