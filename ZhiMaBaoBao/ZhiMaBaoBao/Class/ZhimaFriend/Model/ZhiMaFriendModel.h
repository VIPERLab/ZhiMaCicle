//
//  ZhiMaFriendModel.h
//  ZhiMaBaoBao
//
//  Created by mac on 16/9/27.
//  Copyright © 2016年 liugang. All rights reserved.
//

//好友类型
typedef NS_OPTIONS(NSUInteger, FriendType) {
    FriendTypeNotFriend = 0,     //不是好友
    FriendTypeNew,              //新的好友
    FriendTypeFriends,          //好友
    FriendTypeBlack            //黑名单
//    FriendTypeSelf              //用户自己
};

#import <Foundation/Foundation.h>

@interface ZhiMaFriendModel : NSObject
 /** 用户昵称*/
@property (nonatomic, copy) NSString *user_Name;
 /** 用户Id*/
@property (nonatomic, copy) NSString *user_Id;
 /** 用户原头像*/
@property (nonatomic, copy) NSString *user_Head_photo;
 /** 用户头像*/
@property (nonatomic, copy) NSString *head_photo;
 /** 用户备注*/
@property (nonatomic, copy) NSString *user_NickName;

/**
 *  如果这个用户是群成员，则会有这个值，否则无
 */
@property (nonatomic, copy) NSString *groupId;

/**
 *  用户状态，0 未添加好友 -  1 已添加好友
 */
@property (nonatomic, assign) BOOL status;

 /** 显示名称 （有备注显示备注，无备注显示昵称）*/
@property (nonatomic, copy) NSString *displayName;
 /** 服务器返回大写首字母*/
@property (nonatomic, copy) NSString *headchar;
 /** 显示名称的大写拼音缩写*/
@property (nonatomic, copy) NSString *pinyin;
 /** 手机号码*/
@property (nonatomic, copy) NSString *uphone;
 /** 性别*/
@property (nonatomic, copy) NSString *sex;
 /** 地区*/
@property (nonatomic, copy) NSString *area;
 /** 个性签名*/
@property (nonatomic, copy) NSString *signature;
 /** 不看他的朋友圈*/
@property (nonatomic, assign) BOOL notread_his_cricles;
 /** 不让他看我的朋友圈*/
@property (nonatomic, assign) BOOL notread_my_cricles;
/** 好友类型 //好友类型,1新朋友,2为好友,3为黑名单*/
@property (nonatomic, assign) NSInteger friend_type;
 /** 相册第一张*/
@property (nonatomic, copy) NSString *album1;
 /** 相册第二张*/
@property (nonatomic, copy) NSString *album2;
 /** 相册第三张*/
@property (nonatomic, copy) NSString *album3;
@end
