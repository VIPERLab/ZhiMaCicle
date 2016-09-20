//
//  UserInfo.h
//  ZhiMaBaoBao
//
//  Created by liugang on 16/9/19.
//  Copyright © 2016年 liugang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserInfo : NSObject<NSCoding>

 /** 用户已经登录过app*/
@property (nonatomic, assign) BOOL hasLogin;

 /** 即时聊天帐号*/
@property (nonatomic, copy) NSString *openfireaccount;

 /** 手机号*/
@property (nonatomic, copy) NSString *uphone;

 /** 名字*/
@property (nonatomic, copy) NSString *username;

 /** 头像*/
@property (nonatomic, copy) NSString *head_photo;

 /** 原头像*/
@property (nonatomic, copy) NSString *yuan_head_photo;

 /** 真实姓名*/
@property (nonatomic, copy) NSString *real_name;

 /** 总收入的钱,做记录，累加操作*/
@property (nonatomic, copy) NSString *recharg;

 /** 邀请码*/
@property (nonatomic, copy) NSString *invite_code;

 /** 坐标经度*/
@property (nonatomic, assign) double coordinateslongitude;

 /** 坐标纬度*/
@property (nonatomic, assign) double coordinateslatitude;

 /** 性别*/
@property (nonatomic, copy) NSString *sex;

 /** 生日*/
@property (nonatomic, copy) NSString *birthday;

 /** 签名*/
@property (nonatomic, copy) NSString *signature;

 /** 个人背景图片*/
@property (nonatomic, copy) NSString *backgroundImg;

 /** sessionId*/
@property (nonatomic, copy) NSString *sessionId;


+ (instancetype)shareInstance;

//保存数据
- (void)save;

//读取数据
+ (instancetype)read;

@end
