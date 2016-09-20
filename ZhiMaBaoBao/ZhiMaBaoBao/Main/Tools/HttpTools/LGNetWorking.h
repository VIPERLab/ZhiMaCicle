//
//  LGNetWorking.h
//  YiIM_iOS
//
//  Created by liugang on 16/8/5.
//  Copyright © 2016年 ikantech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HttpTool.h"

@interface LGNetWorking : NSObject

+(LGNetWorking *)shareInstance;


/**
 *  获取注册验证码
 *
 *  @param phone 手机号码
 *  @param flag  reg带表示注册验证码 ;forget表示忘记密码等;reset表示重置密码;editphone代表修改手机号码
 */
+ (void)getCodeWithPhone:(NSString *)phone flag:(NSString *)flag SuccessfulBlock:(SuccessfulBlock)block;

/**
 *  注册
 *
 *  @param phone    手机号码
 *  @param code     验证码
 *  @param password 密码
 */
+ (void)registerWithPhone:(NSString *)phone verCode:(NSString *)code passWord:(NSString *)password SuccessfulBlock:(SuccessfulBlock)block;

/**
 *  对比验证码
 *
 *  @param phone 手机号码
 *  @param code  验证码
 *  @param block
 */
+ (void)checkVerCode:(NSString *)phone verCode:(NSString *)code block:(SuccessfulBlock)block;

/**
 *  登录
 *
 *  @param phone    手机号码
 *  @param password 密码
 *  @param block
 */
+ (void)loginWithPhone:(NSString *)phone password:(NSString *)password success:(SuccessfulBlock)success failure:(FailureBlock)FailureBlock;

/**
 *  保存头像，昵称，邀请码
 *
 *  @param headerUrl 头像url
 *  @param nickName  昵称
 *  @param code      邀请码
 *  @param block
 */
+ (void)saveUserInfo:(NSString *)sessionId headUrl:(NSString *)headerUrl nickName:(NSString *)nickName inviteCode:(NSString *)code block:(SuccessfulBlock)block;

/**
 *  忘记密码，重置密码
 *
 *  @param phone    手机号码
 *  @param code     手机验证码
 *  @param password 用户密码
 *  @param block
 */
+ (void)forgetPassword:(NSString *)phone verCode:(NSString *)code password:(NSString *)password block:(SuccessfulBlock)block;

/**
 *  所有上传图片
 *
 *  @param sessindId 用户sessionId
 *  @param imageData 图片数据
 *  @param fileName  文件夹名称   头像：headPhoto
 身份证照片：idcardPhoto
 证件照片：certificatePhoto
 背景:backgroundImg
 
 *  @param block
 */
+ (void)uploadPhoto:(NSString *)sessindId image:(id)imageData fileName:(NSString *)fileName andFuctionName:(NSString *)functionName block:(SuccessfulBlock)block;

/**
 *  获取所有通话记录
 *
 *  @param sessionId sessionId
 *  @param block
 */
+ (void)getAllCallRecords:(NSString *)sessionId block:(SuccessfulBlock)block;

/**
 *  添加通话记录
 *
 *  @param sessionId sessionId
 *  @param phoneNum  拨打过去的电话号码
 *  @param block
 */
+ (void)addCallRecord:(NSString *)sessionId toPhone:(NSString *)phoneNum block:(SuccessfulBlock)block;

/**
 *  记录通话时长
 *
 *  @param sessionId sessionId
 *  @param phoneNum  电话号码
 *  @param callTime  通话时间
 *  @param callId    通话记录id
 *  @param startTime    开始时间戳
 *  @param endTime    结束时间戳
 */
+ (void)saveCallTime:(NSString *)sessionId toPhone:(NSString *)phoneNum callTime:(NSInteger)callTime CallId:(NSInteger)callId startTime:(long long)startTime endTime:(long long)endTime block:(SuccessfulBlock)block;

/**
 *  删除通话记录
 *
 *  @param sessionId sessionId
 *  @param account   openfire帐号
 *  @param block
 */
+ (void)deleteCallRecord:(NSString *)sessionId openfireAccount:(NSString *)account block:(SuccessfulBlock)block;

/**
 *  退出
 *
 *  @param sessionId sessionId
 */
+ (void)logout:(NSString *)sessionId block:(SuccessfulBlock)block;

/**
 *  查找用户  根据输入内容模糊查找用户
 *
 *  @param sessionId sessionID
 *  @param content   查找内容
 *  @param type      查现有好友:now		查找新好友:new
 *  @param block
 */
+ (void)searchFriend:(NSString *)sessionId content:(NSString *)content type:(NSString *)type block:(SuccessfulBlock)block;

/**
 *  修改用户坐标 -- 获取附近的人
 *
 *  @param sessionId sessionId
 *  @param lat       纬度
 *  @param lng       经度
 *  @param near      near
 *  @param block
 */
+ (void)changeUserLocation:(NSString *)sessionId langtitude:(double)lat longtitude:(double)lng near:(NSString *)near block:(SuccessfulBlock)block;


#pragma mark - 朋友圈内容
//------                   加载我的朋友圈内容接口
+ (void)loadMyDiscoverWithSectionID:(NSString *)sectionID andMyCheatAcount:(NSString *)openfireaccount andPageCount:(NSString *)pageNumber block:(SuccessfulBlock)block;


//朋友圈详情接口
+ (void)loadDiscoverDetailWithSessionID:(NSString *)sessionId andDetailID:(NSString *)ID block:(SuccessfulBlock)block;

//-------------------------------------------群组---------------------------------------
/**
 *  添加用户到群组
 *
 *  @param sessionId sessionid
 *  @param accounts  openfire帐号，多人用逗号隔开
 *  @param roomId    xmpp群id
 *  @param roomName  群地址
 *  @param block
 */
+(void)addUserToGroup:(NSString *)sessionId accounts:(NSString *)accounts roomId:(NSString *)roomId roomName:(NSString *)roomName block:(SuccessfulBlock)block;

/**
 *  查看群组列表
 *
 *  @param sessionId sessionId
 *  @param account   openfire帐号
 *  @param block
 */
+(void)getGroupList:(NSString *)sessionId account:(NSString *)account block:(SuccessfulBlock)block;

/**
 *  查看群详情
 *
 *  @param sessionId sessionId
 *  @param account   当前登录者的即时聊天账号
 *  @param roomId    房间ID
 *  @param name      群的地址
 *  @param block     至少传一个,name和roomid
 */
+(void)getGroupInfo:(NSString *)sessionId account:(NSString *)account roomId:(NSString *)roomId name:(NSString *)name block:(SuccessfulBlock)block;

//加载个人朋友圈主页
+ (void)loadPersonalDiscoverDetailWithSessionID:(NSString *)sessionID andTargetOpenFirAccount:(NSString *)openFirAccount andPageNumber:(NSString *)pageNumber block:(SuccessfulBlock)block;

//点赞入口
+ (void)LikeOrCommentDiscoverWithSessionID:(NSString *)sessionID andFcId:(NSString *)fcId andComment:(NSString *)comment andOpenFirAccount:(NSString *)openFirAccount block:(SuccessfulBlock)block;

//发布新的说说入口
+ (void)AddNewDiscoverWithSessionID:(NSString *)sessionID andOpenFirAccount:(NSString *)openFirAccount andContent_type:(NSString *)content_type andContent:(NSString *)content andLink:(NSString *)link andType:(NSString *)type andCurrent_location:(NSString *)current_location andImgs:(NSString *)imgs block:(SuccessfulBlock)block;


//加载未读消息
+ (void)getUnReadMessageWithSessionID:(NSString *)sessionID andOpenFirAccount:(NSString *)openFirAccount block:(SuccessfulBlock)block;


//请求消息列表
+ (void)LoadUserMessageListWithSessionID:(NSString *)sessionID andOpenFirAccount:(NSString *)openFirAccount andLastFccid:(NSString *)lastFccid andPageCount:(NSString *)pageCount block:(SuccessfulBlock)block;

//清空消息列表
+ (void)ClearMessageListWithSessionID:(NSString *)sessionID andOpenFirAccount:(NSString *)openfirAccount block:(SuccessfulBlock)block;

//删除自己的朋友圈
+ (void)DeletedMyDiscoverWithSessionID:(NSString *)sessionID andOpenFirAccount:(NSString *)openfirAccount andFcid:(NSString *)fcid block:(SuccessfulBlock)block;

//获取我的账户信息
+ (void)RequeatMyAccountWithOpenFirAccount:(NSString *)openFirAccount andApikey:(NSString *)apikey block:(SuccessfulBlock)block;

//点击头像查看好友详情
+ (void)getFriendInfo:(NSString *)sessionId openfire:(NSString *)account block:(SuccessfulBlock)block;

//上传用户个人信息
+ (void)upLoadUserDataWithSessionID:(NSString *)sessionID andOpenFirAccount:(NSString *)openFirAccount andFunctionName:(NSString *)functionName andChangeValue:(NSString *)value block:(SuccessfulBlock)block;

//返回所有的省
+ (void)getProvinceWithSessionID:(NSString *)sessionID block:(SuccessfulBlock)block;

//根据省id 返回市id
+ (void)getAreaWithSessionID:(NSString *)sessionID andProvinceID:(NSString *)provinceID block:(SuccessfulBlock)block;

//设置好友功能
+ (void)setupFriendFunction:(NSString *)sessionId function:(NSString *)functionName value:(NSInteger)value openfireAccount:(NSString *)account block:(SuccessfulBlock)block;

//查询手机联系人是否开通活芝麻、 或已添加
+ (void)queryPhoneBook:(NSString *)sessionId openfire:(NSString *)openfire flag:(NSString *)action phonedata:(NSString *)jsonData block:(SuccessfulBlock)block;

//从后台唤醒的时候，加载是否有未读消息
+ (void)ApplicationWakeUpAtBackgroundWithSessionId:(NSString *)sessionId andOpenFirAccount:(NSString *)openFirAccount andLastMessageID:(NSString *)fcID block:(SuccessfulBlock)block;

//删除自己的评论
+ (void)DeletedMyCommentWithSessionID:(NSString *)sessionID andOpenFirAccount:(NSString *)openFirAccount andFcid:(NSString *)fcid block:(SuccessfulBlock)block;

//投诉用户
+ (void)ComplainsUserWithSessionID:(NSString *)sessionID andTheOpenFireAccount:(NSString *)openfirAccount andComplainsReason:(NSString *)reason andComplainFriendCicle:(NSString *)firendCicle block:(SuccessfulBlock)block;

/**
 *  添加通话日志
 *
 *  @param fromPhone 主叫
 *  @param toPhone   被叫
 *  @param status    状态码
 *  @param errorInfo 错误信息
 */
+ (void)addCallLog:(NSString *)sessionId fromPhone:(NSString *)fromPhone toPhone:(NSString *)toPhone status:(NSInteger)status errorInfo:(NSString *)errorInfo block:(SuccessfulBlock)block;

//重置密码 -- 需要验证旧密码
+ (void)resetPassword:(NSString *)sessionId phone:(NSString *)phone oldPass:(NSString *)oldPass newPass:(NSString *)newPass reNewpass:(NSString *)reNewpass block:(SuccessfulBlock)block;

//查询手机联系人是否开通芝麻
+ (void)queryContacts:(NSString *)sessionId phone:(NSString *)phone success:(SuccessfulBlock)success failure:(FailureBlock)failure;




@end
