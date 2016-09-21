//
//  SDTimeLineCellModel.h
//  GSD_WeiXin(wechat)
//
//  Created by gsd on 16/2/25.
//  Copyright © 2016年 GSD. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SDTimeLineCellLikeItemModel, SDTimeLineCellCommentItemModel , SDTimeLineCellPicItemModel;

@interface SDTimeLineCellModel : NSObject

@property (nonatomic, copy) NSString *head_photo;     //用户头像
@property (nonatomic, copy) NSString *friend_nick;  //用户名
@property (nonatomic, copy) NSString *openfireaccount; //当前用户的聊天账号
@property (nonatomic, copy) NSString *content;   //朋友圈内容
@property (nonatomic, copy) NSString *ID;  //朋友圈ID
@property (nonatomic, copy) NSString *current_location; //地区信息

@property (nonatomic, strong) NSArray <SDTimeLineCellPicItemModel *> *imglist;  //朋友圈图片存放数组

@property (nonatomic, strong) NSMutableArray <SDTimeLineCellLikeItemModel *> *likeItemsArray;  //点赞数组

@property (nonatomic, strong) NSMutableArray <SDTimeLineCellCommentItemModel *> *commentList;  //评论数组

@property (nonatomic, copy) NSString *create_time;

@property (nonatomic, assign) BOOL isOpening;

//是否已经点赞
@property (nonatomic, assign, getter = isLiked) BOOL liked;

@property (nonatomic, assign) BOOL shouldShowMoreButton;


@end


@interface SDTimeLineCellLikeItemModel : NSObject //点赞

@property (nonatomic, copy) NSString *userName;   //点赞人的名字
@property (nonatomic, copy) NSString *userId;     //点赞人的ID
@property (nonatomic, copy) NSString *userPhoto;

@property (nonatomic, copy) NSAttributedString *attributedContent;

@end


@interface SDTimeLineCellCommentItemModel : NSObject   //评论模型

@property (nonatomic, copy) NSString *comment;  //评论

@property (nonatomic, copy) NSString *friend_nick; //第一个用户
@property (nonatomic, copy) NSString *openfireaccount;  //第一个用户id

@property (nonatomic, copy) NSString *reply_friend_nick; //第二个用户
@property (nonatomic, copy) NSString *reply_openfireaccount;  //第二个用户id

@property (nonatomic, assign) BOOL type; // 1是点赞  0是评论

@property (nonatomic, copy) NSString *ID; //这条评论的ID

@property (nonatomic, copy) NSAttributedString *attributedContent;

@property (nonatomic, assign) CGFloat textHight;

@property (nonatomic, copy) NSString *head_photo;//评论或者点赞的头像

@property (nonatomic, copy) NSString *create_time; //创建时间

@end


@interface SDTimeLineCellPicItemModel : NSObject  //图片数组

@property (nonatomic, copy) NSString *cricles_id; //朋友圈id

@property (nonatomic, copy) NSString *weuser_id; //用户id

@property (nonatomic, copy) NSString *img_url; //缩略图URL

@property (nonatomic, copy) NSString *bigimg_url;  //大图URL

@end