//
//  LGNetWorking.h
//  YiIM_iOS
//
//  Created by liugang on 16/8/5.
//  Copyright © 2016年 ikantech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HttpTool.h"
#import "ZhiMaFriendModel.h"

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

//图片上传图、视频 ，下载视频
+ (void)chatUploadPhoto:(NSString *)sessindId image:(id)imageData fileName:(NSString *)fileName andFuctionName:(NSString *)functionName block:(ChatSuccessfulBlock)block failure:(ChatFailureBlock)FailureBlock;
+ (void)chatUploadVideo:(NSString *)sessindId image:(id)imageData fileName:(NSString *)fileName andFuctionName:(NSString *)functionName block:(ChatSuccessfulBlock)block progress:(ChatProgressBlock)progressBlock failure:(ChatFailureBlock)FailureBlock;
+ (void)chatDownloadVideo:(NSString *)path urlStr:(NSString*)urlStr block:(ChatSuccessfulBlock)block progress:(ChatProgressBlock)progressBlock failure:(ChatFailureBlock)FailureBlock;

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
+ (void)loadMyDiscoverWithSectionID:(NSString *)sectionID andMyCheatAcount:(NSString *)userId andPageCount:(NSString *)pageNumber block:(SuccessfulBlock)block failure:(FailureBlock)failure;


//朋友圈详情接口
+ (void)loadDiscoverDetailWithSessionID:(NSString *)sessionId andDetailID:(NSString *)ID block:(SuccessfulBlock)block;

//-------------------------------------------群组---------------------------------------
/**
 *  创建群组/添加用户到群组
 *
 *  @param sessionId sessionId
 *  @param userIds   朋友的userId(可以是以逗号隔开的字符串)
 *  @param groupId   如果是拉人进群需要传群id  , 新建群传空
 */
+ (void)addUserToGroup:(NSString *)sessionId userIds:(NSString *)userIds groupId:(NSString *)groupId success:(SuccessfulBlock)success failure:(FailureBlock)failure;

/**
 *  查看群组列表
 *
 *  @param sessionId sessionId
 */
+(void)getGroupList:(NSString *)sessionId block:(SuccessfulBlock)block failure:(FailureBlock)failure;

/**
 *  查看群详情
 *
 *  @param sessionId sessionId
 *  @param groupId   群组房间id
 */
+ (void)getGroupInfo:(NSString *)sessionId groupId:(NSString *)groupId success:(SuccessfulBlock)success failure:(FailureBlock)failure;

/**
 *  设置群信息
 *
 *  @param sessionId    sessionId
 *  @param groupId      群组房间id
 *  @param functionName 保存相应的功能:functionName  固定值固定值("聊天置顶","set_chat_top"),("用户在群的昵称","group_nick"),("新消息提示","new_msg_tip"),("保存群到通讯录","save_to_contacts"),("设置群民称","group_name"),("quit_group","退出群聊 传 1")
 *  @param value        1 为是 0 为否
 */
+ (void)setupGroup:(NSString *)sessionId groupId:(NSString *)groupId functionName:(NSString *)functionName value:(NSString *)value success:(SuccessfulBlock)success failure:(FailureBlock)failure;

//加载个人朋友圈主页
+ (void)loadPersonalDiscoverDetailWithSessionID:(NSString *)sessionID andTargetOpenFirAccount:(NSString *)openFirAccount andPageNumber:(NSString *)pageNumber block:(SuccessfulBlock)block;

//点赞入口
+ (void)LikeOrCommentDiscoverWithSessionID:(NSString *)sessionID andFcId:(NSString *)fcId andComment:(NSString *)comment andReply_userId:(NSString *)reply_userId block:(SuccessfulBlock)block;

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
+ (void)getFriendInfo:(NSString *)sessionId userId:(NSString *)userId block:(SuccessfulBlock)block failure:(FailureBlock)failure;

//上传用户个人信息
+ (void)upLoadUserDataWithSessionID:(NSString *)sessionID andOpenFirAccount:(NSString *)openFirAccount andFunctionName:(NSString *)functionName andChangeValue:(NSString *)value success:(SuccessfulBlock)successBlock failure:(FailureBlock)failureBlock;

//返回所有的省
+ (void)getProvinceWithSessionID:(NSString *)sessionID block:(SuccessfulBlock)block;

//根据省id 返回市id
+ (void)getAreaWithSessionID:(NSString *)sessionID andProvinceID:(NSString *)provinceID block:(SuccessfulBlock)block;

//设置好友功能
+ (void)setupFriendFunction:(NSString *)sessionId function:(NSString *)functionName value:(NSString *)value openfireAccount:(NSString *)account block:(SuccessfulBlock)block;

//查询手机联系人是否开通活芝麻、 或已添加
+ (void)queryPhoneBook:(NSString *)sessionId openfire:(NSString *)openfire flag:(NSString *)action phonedata:(NSString *)jsonData block:(SuccessfulBlock)block;

//从后台唤醒的时候，加载是否有未读消息
+ (void)ApplicationWakeUpAtBackgroundWithSessionId:(NSString *)sessionId andUserID:(NSString *)userID andLastMessageID:(NSString *)fcID block:(SuccessfulBlock)block;

//删除自己的评论
+ (void)DeletedMyCommentWithSessionID:(NSString *)sessionID andOpenFirAccount:(NSString *)openFirAccount andFcid:(NSString *)fcid block:(SuccessfulBlock)block;

//投诉用户
+ (void)ComplainsUserWithSessionID:(NSString *)sessionID andComplaintsUserId:(NSString *)complaintsUserId andComplainsReason:(NSString *)reason andComplainFriendCicle:(NSString *)firendCicle andComplatinType:(int)complaintType block:(SuccessfulBlock)block;

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

//删除好友
+ (void)deleteFriend:(NSString *)sessionId friendId:(NSString *)friendId success:(SuccessfulBlock)success failure:(FailureBlock)failure;

/**
 *  获取好友列表
 *  @param type      好友类型
 */
+ (void)getFriendsList:(NSString *)sessionId friendType:(FriendType)type success:(SuccessfulBlock)success failure:(FailureBlock)failure;

/**
 *  收藏接口
 *
 *  @param collectionType 1：文字 2：链接 3：图片 4：视频 5：语音 6：文件
 *  @param sessionId      登录者的sessionId
 *  @param content        文字内容，链接标题
 *  @param smallImg       小图地址、
 *  @param source         来源 目前给nil
 *  @param account        被收藏者的userID
 */
+ (void)collectionCircleListWithCollectionType:(int)collectionType andSessionId:(NSString *)sessionId andConent:(NSString *)content andSmallImg:(NSString *)smallImg andBigImage:(NSString *)big_img andSource:(NSString *)source andAccount:(NSString *)account success:(SuccessfulBlock)successBlock failure:(FailureBlock)failureBlock;

// 获取收藏列表接口
+ (void)getCollectionListWithSessionId:(NSString *)sessionId success:(SuccessfulBlock)successBlock failure:(FailureBlock)failureBlock;

// 删除收藏接口
+ (void)deletedCircleCollectionWithSessionId:(NSString *)sessionId andCollectionId:(NSString *)collectionId success:(SuccessfulBlock)successBlock failure:(FailureBlock)failureBlock;

// 设置群信息
+ (void)setGroupInfoMessageWithFunctionName:(NSString *)functionName andSessionId:(NSString *)seccessId andValue:(NSString *)value andGroupId:(NSString *)groupId success:(SuccessfulBlock)successBlock failure:(FailureBlock)failureBlock;

//根据邀请码获取用户Id
+ (void)getUserIdWithInvitedCode:(NSString *)invitedCode success:(SuccessfulBlock)successBlock failure:(FailureBlock)failureBlock;

//获取个人更多详细信息
+ (void)getMoreUserInfo:(NSString *)sessionId success:(SuccessfulBlock)successBlock failure:(FailureBlock)failureBlock;

//保存更多详细信息
+ (void)saveMoreUserInfo:(NSString *)sessionId moreData:(NSString *)jsonStr success:(SuccessfulBlock)successBlock failure:(FailureBlock)failureBlock;

//获取群二维码
+ (void)getGroupChatQRCodeWithSessionId:(NSString *)sessionId andGroupId:(NSString *)groupId success:(SuccessfulBlock)successBlock failure:(FailureBlock)failureBlock;

@end
