//
//  ZhiMaFriendModel.h
//  ZhiMaBaoBao
//
//  Created by mac on 16/9/27.
//  Copyright © 2016年 liugang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZhiMaFriendModel : NSObject
 /** 用户昵称*/
@property (nonatomic, copy) NSString *user_Name;
 /** 用户Id*/
@property (nonatomic, copy) NSString *user_Id;
 /** 用户头像*/
@property (nonatomic, copy) NSString *user_Head_photo;
 /** 用户备注*/
@property (nonatomic, copy) NSString *user_NickName;

/**
 *  如果这个用户是群成员，则会有这个值，否则无
 */
@property (nonatomic, copy) NSString *groupId;

 /** 显示名称 （有备注显示备注，无备注显示昵称）*/
@property (nonatomic, copy) NSString *displayName;
 /** 显示名称的大写拼音缩写*/
@property (nonatomic, copy) NSString *pinyin;


@end
