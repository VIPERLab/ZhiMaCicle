//
//  UserInfo.h
//  ZhiMaBaoBao
//
//  Created by liugang on 16/9/19.
//  Copyright © 2016年 liugang. All rights reserved.
//  用户数据本地存储

#import <Foundation/Foundation.h>
@interface UserInfo : NSObject<NSCoding>

 /** 用户已经登录过app*/
@property (nonatomic, assign) BOOL hasLogin;

 /** uid*/
@property (nonatomic, copy) NSString *uid;

 /** 即时聊天帐号 -- 废弃入口,更换为userID*/
//@property (nonatomic, copy) NSString *openfireaccount;

/**
 *  用户ID --- 唯一标识
 */
@property (nonatomic, copy) NSString *userID;

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

 /** 键盘振动*/
@property (nonatomic, assign, getter=isKeyboardShake) BOOL keyboardShake;

 /** 键盘按键音*/
@property (nonatomic, assign, getter=isKeyboardVoice) BOOL keyboardVoice;



/**
 *  位置信息
 */
@property (nonatomic, copy) NSString *location;

#pragma mark - 判断时候超过15天
/**
 *  注册时间
 */
@property (nonatomic, copy) NSString *create_time;

/**
 *  是否显示设置邀请码，0不显示， 1显示
 */
@property (nonatomic, copy) NSString *is_self_reg;

/**
 *  是否超过设置有效期 0超过了15天有效期，1没超过15有效期
 */
@property (nonatomic, assign,getter=isPassingBy) BOOL passingBy;

#pragma mark ------  从后台唤醒之后
/** 最后一条消息的ID */
@property (nonatomic, copy) NSString *lastFcID;
/** 是否要展示更新的头像 */
@property (nonatomic, assign) BOOL isShowHeader;
/** 未读消息数 */
@property (nonatomic, assign) int unReadCount;

/** 已经注册通话sdk*/
@property (nonatomic, assign) BOOL hasRegisteCall;

/** 是否有网络*/
@property (nonatomic, assign) BOOL hasNetworking;

/** 当前删除好友jid*/
@property (nonatomic, copy) NSString *deleteJid;


+ (instancetype)shareInstance;

//保存数据
- (void)save;

//读取数据
+ (instancetype)read;

@end
