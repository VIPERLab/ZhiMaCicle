//
//  LGNetWorking.m
//  YiIM_iOS
//
//  Created by liugang on 16/8/5.
//  Copyright © 2016年 ikantech. All rights reserved.
//

#import "LGNetWorking.h"
#import "NSString+MD5.h"


@implementation LGNetWorking

+ (LGNetWorking *)shareInstance{
    
    static LGNetWorking *_networking;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        _networking = [[LGNetWorking alloc]init];
    });
    return _networking;
}

/**
 *  获取注册验证码
 *
 *  @param phone 手机号码
 *  @param flag  reg带表示注册验证码 ;forget表示忘记密码等;reset表示重置密码;editphone代表修改手机号码
 */
+ (void)getCodeWithPhone:(NSString *)phone flag:(NSString *)flag SuccessfulBlock:(SuccessfulBlock)block{
    
    [HttpTool POST:@"/moblie/send_sms_for_register.do" params:@{@"phone":phone,@"flag":flag} success:^(ResponseData *json) {
        
        block(json);
    } failure:^(ErrorData *error) {
    
        
    }];
}

/**
 *  注册
 *
 *  @param phone    手机号码
 *  @param code     验证码
 *  @param password 密码
 */
+ (void)registerWithPhone:(NSString *)phone verCode:(NSString *)code passWord:(NSString *)password SuccessfulBlock:(SuccessfulBlock)block{
    
    [HttpTool POST:@"/moblie/add_new_user.do" params:@{@"phone":phone,@"phone_code":code,@"password":password} success:^(ResponseData *json) {
        block(json);
    } failure:^(ErrorData *error) {
    
        
    }];
}

/**
 *  对比验证码
 *
 *  @param phone 手机号码
 *  @param code  验证码
 *  @param block
 */
+ (void)checkVerCode:(NSString *)phone verCode:(NSString *)code block:(SuccessfulBlock)block{
    
    [HttpTool POST:@"/moblie/check_verifycode.do" params:@{@"phone":phone,@"phone_code":code} success:^(ResponseData *json) {
        block(json);
    } failure:^(ErrorData *error) {
    
        
    }];
}

/**
 *  登录
 *
 *  @param phone    手机号码
 *  @param password 密码
 *  @param block  version	版本号	数字类型,	格式:1.0以上
 *                appSystem手机系统类型:ios	android

 */
+ (void)loginWithPhone:(NSString *)phone password:(NSString *)password success:(SuccessfulBlock)success failure:(FailureBlock)failure {
    
    [HttpTool POST:@"/moblie/user_login.do" params:@{@"phone":phone,@"password":password,@"version":@(2.0),@"appSystem":@"ios"} success:^(ResponseData *json) {
        
        success(json);
                
    } failure:^(ErrorData *error) {
        failure(error);
        
    }];
}

/**
 *  保存头像，昵称，邀请码
 *
 *  @param headerUrl 头像url
 *  @param nickName  昵称
 *  @param code      邀请码
 *  @param block
 */
+ (void)saveUserInfo:(NSString *)sessionId headUrl:(NSString *)headerUrl nickName:(NSString *)nickName inviteCode:(NSString *)code block:(SuccessfulBlock)block{
    [HttpTool POST:@"/moblie/savehead_nick_invite.do"
           params:@{@"sessionId":sessionId,
                    @"headphoto":headerUrl,
                    @"nickname":nickName,
                    @"invite_code":code}
          success:^(ResponseData *json) {
        
        block(json);
    } failure:^(ErrorData *error) {
        
    }];
}

/**
 *  忘记密码
 *
 *  @param phone    手机号码
 *  @param code     手机验证码
 *  @param password 用户密码
 *  @param block
 */
+ (void)forgetPassword:(NSString *)phone verCode:(NSString *)code password:(NSString *)password block:(SuccessfulBlock)block{
    
    [HttpTool POST:@"/moblie/forget_ResetPasswd.do"
           params:@{@"phone":phone,
                    @"phone_code":code,
                    @"password":password}
          success:^(ResponseData *json) {
              
              block(json);
          } failure:^(ErrorData *error) {
              
          }];
}

//重置密码 -- 需要验证旧密码
+ (void)resetPassword:(NSString *)sessionId phone:(NSString *)phone oldPass:(NSString *)oldPass newPass:(NSString *)newPass reNewpass:(NSString *)reNewpass block:(SuccessfulBlock)block{
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"sessionId"] = sessionId;
    params[@"phone"] = phone;
    params[@"oldpass"] = oldPass;
    params[@"newpass"] = newPass;
    params[@"renewpass"] = reNewpass;
    
    [HttpTool POST:@"/moblie/tochangePasswd.do" params:params success:^(ResponseData *json) {
        
        block(json);
        
    } failure:^(ErrorData *error) {
        
    }];
}

/**
 *  所有上传图片
 *
 *  @param sessindId 用户sessionId
 *  @param imageData 图片数据
 *  @param fileName  文件夹名称   头像：headPhoto
                                身份证照片：idcardPhoto
                                证件照片：certificatePhoto
                                背景:backgroundImg
                                朋友圈图片:quan
 功能:functionName:   "个人背景图片:backgroundImg"  ,  "用户头像:headPhoto" , "朋友圈图片:quan"

 *  @param block
 */
+ (void)uploadPhoto:(NSString *)sessindId image:(id)imageData fileName:(NSString *)fileName andFuctionName:(NSString *)functionName block:(SuccessfulBlock)block {
    
    [HttpTool getImage:@"/moblie/uploadImage.do"
                params:@{@"sessionId":sessindId,
                         @"fileName":fileName,
                         @"functionName":functionName}
              formData:imageData success:^(ResponseData *json) {
        
        block(json);
    } failure:^(ErrorData *error) {
        

    }];
    
}

+ (void)chatUploadPhoto:(NSString *)sessindId image:(id)imageData fileName:(NSString *)fileName andFuctionName:(NSString *)functionName block:(ChatSuccessfulBlock)block failure:(ChatFailureBlock)FailureBlock{
    
    NSString* str = [NSString stringWithFormat:@"fileName=%@&%@",fileName,APIKEY];
    NSString *sign = [[str md5Encrypt] uppercaseString];

    [HttpTool chatGetImage:nil
                    params:@{@"sign":sign,
                             @"fileName":fileName}
                  formData:imageData
                   success:^(NSDictionary *json) {
                  
                  block(json);
              } failure:^(NSError *error) {
                  
                  FailureBlock(error);
                  
              }];
    
}

+ (void)chatUploadVideo:(NSString *)sessindId image:(id)imageData fileName:(NSString *)fileName andFuctionName:(NSString *)functionName block:(ChatSuccessfulBlock)block progress:(ChatProgressBlock)progressBlock failure:(ChatFailureBlock)FailureBlock{
    
    NSString* str = [NSString stringWithFormat:@"fileName=%@&%@",fileName,APIKEY];
    NSString *sign = [[str md5Encrypt] uppercaseString];
    
    [HttpTool chatGetVideo:nil
                    params:@{@"sign":sign,
                             @"fileName":fileName}
                  formData:imageData
                   success:^(NSDictionary *json) {
                       
                       block(json);
                   }progress:^(NSProgress *pro) {
                       progressBlock(pro);
                   }failure:^(NSError *error) {
                       
                       FailureBlock(error);
                       
                   }];
    
}

+ (void)chatDownloadVideo:(NSString *)path urlStr:(NSString*)urlStr block:(ChatSuccessfulBlock)block progress:(ChatProgressBlock)progressBlock failure:(ChatFailureBlock)FailureBlock
{
    [HttpTool chatDownLoadVideo:path urlStr:urlStr success:^(NSDictionary *json) {
        block(json);
    } progress:^(NSProgress *pro) {
        progressBlock(pro);
    } failure:^(NSError *error) {
        FailureBlock(error);

    }];
}

//---------------------------------------------- 项目 -------------------------------------------------
/**
 *  获取所有通话记录
 *
 *  @param sessionId sessionId
 *  @param block     
 */
+ (void)getAllCallRecords:(NSString *)sessionId block:(SuccessfulBlock)block{
    
    [HttpTool POST:@"/moblie/getCallRecords.do"
           params:@{@"sessionId":sessionId }
          success:^(ResponseData *json) {

              block(json);
          } failure:^(ErrorData *error) {
              
          }];
}

/**
 *  添加通话记录
 *
 *  @param sessionId sessionId
 *  @param phoneNum  拨打过去的电话号码
 *  @param block
 */
+ (void)addCallRecord:(NSString *)sessionId toPhone:(NSString *)phoneNum block:(SuccessfulBlock)block{
    [HttpTool POST:@"/moblie/addCallRecord.do"
           params:@{@"sessionId":sessionId,
                    @"appSystem":@"ios",
                    @"to_phone":phoneNum
                    }
          success:^(ResponseData *json) {
              
              block(json);
          } failure:^(ErrorData *error) {
              
          }];
}

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
+ (void)saveCallTime:(NSString *)sessionId toPhone:(NSString *)phoneNum callTime:(NSInteger)callTime CallId:(NSInteger)callId startTime:(long long)startTime endTime:(long long)endTime block:(SuccessfulBlock)block{
    [HttpTool POST:@"/moblie/markCallRecordTime.do"
           params:@{@"sessionId":sessionId,
                    @"appSystem":@"ios",
                    @"to_phone":phoneNum,
                    @"call_time":@(callTime),
                    @"crid":@(callId),
                    @"starttime":@(startTime),
                    @"endttime":@(endTime)
                    }
          success:^(ResponseData *json) {
              
              block(json);
          } failure:^(ErrorData *error) {
              
          }];
}

/**
 *  删除通话记录
 *
 *  @param sessionId sessionId
 *  @param account   openfire帐号
 *  @param block
 */
+ (void)deleteCallRecord:(NSString *)sessionId openfireAccount:(NSString *)account block:(SuccessfulBlock)block{
    [HttpTool POST:@"/moblie/deteleCallRecords.do"
           params:@{@"sessionId":sessionId,
                    @"openfireaccount":account
                    }
          success:^(ResponseData *json) {
              
              block(json);
          } failure:^(ErrorData *error) {
              
          }];
}

/**
 *  退出
 *
 *  @param sessionId sessionId
 */
+ (void)logout:(NSString *)sessionId block:(SuccessfulBlock)block{
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    param[@"sessionId"] = sessionId;
    [HttpTool POST:@"/moblie/logout.do"
           params:param
          success:^(ResponseData *json) {
              
              block(json);
          } failure:^(ErrorData *error) {
              
          }];
}

/**
 *  修改用户坐标 -- 获取附近的人
 *
 *  @param sessionId sessionId
 *  @param lat       纬度
 *  @param lng       经度
 *  @param near      near
 *  @param block
 */
+ (void)changeUserLocation:(NSString *)sessionId langtitude:(double)lat longtitude:(double)lng near:(NSString *)near block:(SuccessfulBlock)block{
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"sessionId"] = sessionId;
    params[@"lat"] = [NSNumber numberWithDouble:lat];
    params[@"lng"] = [NSNumber numberWithDouble:lng];
    params[@"near"] = near;

    [HttpTool POST:@"/moblie/updateUserLatAndLng.do" params:params success:^(ResponseData *json) {
        
        block(json);
        
    } failure:^(ErrorData *error) {
        
    }];

}

//-------------------------------------------个人中心---------------------------------------

/**
 *  查找用户  根据输入内容模糊查找用户
 *
 *  @param sessionId sessionID
 *  @param content   查找内容
 *  @param type      查现有好友:now		查找新好友:new
 *  @param block
 */
+ (void)searchFriend:(NSString *)sessionId content:(NSString *)content type:(NSString *)type block:(SuccessfulBlock)block{
    [HttpTool POST:@"/moblie/findUser.do"
           params:@{@"sessionId":sessionId,
                    @"value":content,
                    @"type":type
                    }
          success:^(ResponseData *json) {
              
              block(json);
          } failure:^(ErrorData *error) {
              
          }];
}

//加载我的朋友圈内容接口
+ (void)loadMyDiscoverWithSectionID:(NSString *)sectionID andMyCheatAcount:(NSString *)userId andPageCount:(NSString *)pageNumber block:(SuccessfulBlock)block failure:(FailureBlock)failure {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"sessionId"] = sectionID;
    params[@"userId"] = userId;
    params[@"pageNumber"] = pageNumber;
    [HttpTool POST:@"/moblie/getFriendCircleByLoginer.do" params:params success:^(ResponseData *json) {
        
        block(json);
        
    } failure:^(ErrorData *error) {
        
        failure(error);
        
    }];
}


+ (void)loadDiscoverDetailWithSessionID:(NSString *)sessionId andDetailID:(NSString *)ID block:(SuccessfulBlock)block{
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    param[@"sessionId"] = sessionId;
    param[@"fcid"] = ID;
    [HttpTool POST:@"/moblie/getFriendCircleDetailByfcid.do" params:param success:^(ResponseData *responseData) {
        block(responseData);
    } failure:^(ErrorData *error) {
        
    }];
}

//-------------------------------------------群组-------------------------------------
/**
 *  创建群组/添加用户到群组
 *
 *  @param sessionId sessionId
 *  @param userIds   朋友的userId(可以是以逗号隔开的字符串)
 */
+ (void)addUserToGroup:(NSString *)sessionId userIds:(NSString *)userIds groupId:(NSString *)groupId success:(SuccessfulBlock)success failure:(FailureBlock)failure{
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    param[@"sessionId"] = sessionId;
    param[@"userId_s"] = userIds;
    param[@"groupid"] = groupId;
    [HttpTool POST:@"/moblie/addusertoGroup.do" params:param success:^(ResponseData *responseData) {
        success(responseData);
    } failure:^(ErrorData *error) {
        failure(error);
    }];
}

/**
 *  查看群组列表
 *
 *  @param sessionId sessionId
 */
+(void)getGroupList:(NSString *)sessionId block:(SuccessfulBlock)block failure:(FailureBlock)failure{
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    param[@"sessionId"] = sessionId;
    [HttpTool POST:@"/moblie/getGroupByuserId.do" params:param success:^(ResponseData *responseData) {
        block(responseData);
    } failure:^(ErrorData *error) {
        failure(error);
    }];
}

/**
 *  查看群详情
 *
 *  @param sessionId sessionId
 *  @param groupId   群组房间id
 */
+ (void)getGroupInfo:(NSString *)sessionId groupId:(NSString *)groupId success:(SuccessfulBlock)success failure:(FailureBlock)failure{
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    param[@"sessionId"] = sessionId;
    param[@"groupid"] = groupId;

    [HttpTool POST:@"/moblie/getGroupDetail.do" params:param success:^(ResponseData *json) {
        success(json);
    } failure:^(ErrorData *error) {
        failure(error);
    }];
}

/**
 *  设置群信息
 *
 *  @param sessionId    sessionId
 *  @param groupId      群组房间id
 *  @param functionName 保存相应的功能:functionName  固定值固定值("聊天置顶","set_chat_top"),("用户在群的昵称","group_nick"),("新消息提示","new_msg_tip"),("保存群到通讯录","save_to_contacts"),("quit_group","退出群聊")
 *  @param value        1 为是 0 为否
 */
+ (void)setupGroup:(NSString *)sessionId groupId:(NSString *)groupId functionName:(NSString *)functionName value:(NSString *)value success:(SuccessfulBlock)success failure:(FailureBlock)failure{
    NSMutableDictionary *parms = [NSMutableDictionary dictionary];
    parms[@"sessionId"] = sessionId;
    parms[@"groupid"] = groupId;
    parms[@"functionName"] = functionName;
    parms[@"value"] = value;
    
    [HttpTool POST:@"/moblie/setGroupRoomTop.do" params:parms success:^(ResponseData *responseData) {
        success(responseData);
    } failure:^(ErrorData *error) {
        failure(error);
    }];
}

//设置好友消息置顶和消息免打扰
+ (void)setFriend:(NSString *)sessionID functionName:(NSString *)functionName value:(NSString *)value success:(SuccessfulBlock)success failure:(FailureBlock)failure{
    NSMutableDictionary *parms = [NSMutableDictionary dictionary];
    parms[@"sessionId"] = sessionID;
    parms[@"functionName"] = functionName;
    parms[@"value"] = value;
    
    [HttpTool POST:@"/moblie/getsetChatTop_newMsgTip.do" params:parms success:^(ResponseData *responseData) {
        success(responseData);
    } failure:^(ErrorData *error) {
        failure(error);
    }];
}


+ (void)loadPersonalDiscoverDetailWithSessionID:(NSString *)sessionID andTargetOpenFirAccount:(NSString *)openFirAccount andPageNumber:(NSString *)pageNumber block:(SuccessfulBlock)block {
    
    NSMutableDictionary *parms = [NSMutableDictionary dictionary];
    parms[@"sessionId"] = sessionID;
    parms[@"userId"] = openFirAccount;
    parms[@"pageNumber"] = pageNumber;
    
    [HttpTool POST:@"/moblie/getFriendCircleByUserId.do" params:parms success:^(ResponseData *responseData) {
        block(responseData);
    } failure:^(ErrorData *error) {

    }];
}


+ (void)LikeOrCommentDiscoverWithSessionID:(NSString *)sessionID andFcId:(NSString *)fcId andComment:(NSString *)comment andReply_userId:(NSString *)reply_userID block:(SuccessfulBlock)block{
    
    NSMutableDictionary *parms = [NSMutableDictionary dictionary];
    parms[@"sessionId"] = sessionID;
    parms[@"fcId"] = fcId;
    parms[@"userId"] = reply_userID;
    parms[@"comment"] = comment;
    
    [HttpTool POST:@"/moblie/addFriend_circles_comment_new.do" params:parms success:^(ResponseData *json) {
        block(json);
    } failure:^(ErrorData *error) {
    
        
    }];
}


+ (void)AddNewDiscoverWithSessionID:(NSString *)sessionID andOpenFirAccount:(NSString *)openFirAccount andContent_type:(NSString *)content_type andContent:(NSString *)content andLink:(NSString *)link andType:(NSString *)type andCurrent_location:(NSString *)current_location andImgs:(NSString *)imgs block:(SuccessfulBlock)block {
    
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"sessionId"] = sessionID;
    params[@"openfireaccount"] = openFirAccount;
    params[@"content_type"] = content_type;
    params[@"content"] = content;
    params[@"link"] = link;
    params[@"type"] = type;
    params[@"current_location"] = current_location;
    params[@"img_s"] = imgs;
    
    [HttpTool POST:@"/moblie/addFirndCircle.do" params:params success:^(ResponseData *json) {
        block(json);
    } failure:^(ErrorData *error) {
    
        
    }];
    
}



//加载未读消息
+ (void)getUnReadMessageWithSessionID:(NSString *)sessionID andOpenFirAccount:(NSString *)openFirAccount block:(SuccessfulBlock)block {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"sessionId"] = sessionID;
    params[@"openfireaccount"] = openFirAccount;
    
    [HttpTool POST:@"/moblie/getUnreadMessageContent.do" params:params success:^(ResponseData *json) {
        block(json);
    } failure:^(ErrorData *error) {
    
        
    }];
}



+ (void)LoadUserMessageListWithSessionID:(NSString *)sessionID andOpenFirAccount:(NSString *)openFirAccount andLastFccid:(NSString *)lastFccid andPageCount:(NSString *)pageCount block:(SuccessfulBlock)block {
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"sessionId"] = sessionID;
    params[@"openfireaccount"] = openFirAccount;
    params[@"last_fccid"] = lastFccid;
    params[@"appSystem"] = @"ios";
    params[@"pageNumber"] = pageCount;
    
    [HttpTool POST:@"/moblie/getMessageByUserId.do" params:params success:^(ResponseData *json) {
        block(json);
    } failure:^(ErrorData *error) {
    
        
    }];
    
    
}


//清空消息列表
+ (void)ClearMessageListWithSessionID:(NSString *)sessionID andOpenFirAccount:(NSString *)openfirAccount block:(SuccessfulBlock)block {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"sessionId"] = sessionID;
    params[@"openfireaccount"] = openfirAccount;
    params[@"appSystem"] = @"ios";
    
    [HttpTool POST:@"/moblie/batchClearMessage.do" params:params success:^(ResponseData *json) {
        block(json);
    } failure:^(ErrorData *error) {
    
        
    }];
}


//删除自己的朋友圈
+ (void)DeletedMyDiscoverWithSessionID:(NSString *)sessionID andOpenFirAccount:(NSString *)openfirAccount andFcid:(NSString *)fcid block:(SuccessfulBlock)block {
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"sessionId"] = sessionID;
    params[@"userId"] = openfirAccount;
    params[@"fcid"] = fcid;
    
    [HttpTool POST:@"/moblie/delete_circles.do" params:params success:^(ResponseData *json) {
        block(json);
    } failure:^(ErrorData *error) {
        
        
    }];
}

//获取我的账户信息
+ (void)RequeatMyAccountWithOpenFirAccount:(NSString *)openFirAccount andApikey:(NSString *)apikey block:(SuccessfulBlock)block {
    
   
    
}

//点击头像查看好友详情
+ (void)getFriendInfo:(NSString *)sessionId userId:(NSString *)userId block:(SuccessfulBlock)block failure:(FailureBlock)failure{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"sessionId"] = sessionId;
    params[@"userId"] = userId;
    
    [HttpTool POST:@"/moblie/getWeuserFriendDetail.do" params:params success:^(ResponseData *json) {
        block(json);
    } failure:^(ErrorData *error) {
        failure(error);
    }];
}

//上传用户个人信息
+ (void)upLoadUserDataWithSessionID:(NSString *)sessionID andOpenFirAccount:(NSString *)openFirAccount andFunctionName:(NSString *)functionName andChangeValue:(NSString *)value success:(SuccessfulBlock)successBlock failure:(FailureBlock)failureBlock {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"sessionId"] = sessionID;
    params[@"userId"] = openFirAccount;
    params[@"functionName"] = functionName;
    params[@"value"] = value;
    
    [HttpTool POST:@"/moblie/savePersonInfo.do" params:params success:^(ResponseData *json) {
        successBlock(json);
    } failure:^(ErrorData *error) {
        failureBlock(error);
    }];
}

//返回所有的省
+ (void)getProvinceWithSessionID:(NSString *)sessionID block:(SuccessfulBlock)block{
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    param[@"sessionId"] = sessionID;
    [HttpTool POST:@"/moblie/getAllProvinces.do" params:param success:^(ResponseData *json) {
        block(json);
    } failure:^(ErrorData *error) {
    
        
    }];
}


+ (void)getAreaWithSessionID:(NSString *)sessionID andProvinceID:(NSString *)provinceID block:(SuccessfulBlock)block {
    NSMutableDictionary *parm = [NSMutableDictionary dictionary];
    parm[@"sessionId"] = sessionID;
    parm[@"provinceid"] = provinceID;
    [HttpTool POST:@"/moblie/getAllCitiesByProvince.do" params:parm success:^(ResponseData *json) {
        block(json);
    } failure:^(ErrorData *error) {
    
        
    }];
}

/**
 *  设置好友功能
 *
 *  @param sessionId    sessionId
 *  @param functionName 保存相应的功能:functionName  固定值("聊天置顶","set_chat_top"),("好友备注昵称","friend_nick"),
 ("好友类型","friend_type"),("新消息提示","new_msg_tip"),("不看他的朋友圈","notread_his_cricles"),("不让他看我的朋友圈","notread_my_cricles")

 *  @param value        private int friend_type 		//好友类型,1新朋友,2为好友,3为黑名单
                        private int notread_his_cricles 	//不看他的朋友圈(1为是,0为否)
                        private int notread_my_cricles 		//不让他看我的朋友圈(1为是,0为否)
                        private int set_chat_top 	//是否聊天置顶(1为是,0为否)
                        private int new_msg_tip 		//是否新消息提示(1为是,0为否)

 *  @param account      即时聊天账号
 *  @param block
 */
+ (void)setupFriendFunction:(NSString *)sessionId function:(NSString *)functionName value:(NSString *)value openfireAccount:(NSString *)account block:(SuccessfulBlock)block{
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    param[@"sessionId"] = sessionId;
    param[@"functionName"] = functionName;
    param[@"value"] = value;
    param[@"userId"] = account;
    [HttpTool POST:@"/moblie/setfriend.do" params:param success:^(ResponseData *json) {
        block(json);
    } failure:^(ErrorData *error) {
        
    }];
}

//删除好友
+ (void)deleteFriend:(NSString *)sessionId friendId:(NSString *)friendId success:(SuccessfulBlock)success failure:(FailureBlock)failure{
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    param[@"sessionId"] = sessionId;
    param[@"friendid"] = friendId;

    [HttpTool POST:@"/moblie/detelefriend.do" params:param success:^(ResponseData *json) {
        success(json);
    } failure:^(ErrorData *error) {
        failure(error);
    }];

}

/**
 *   查询手机联系人是否开通活芝麻、 或已添加
 *
 *  @param sessionId sessionId
 *  @param action    action固定值:login(登录的时候查询),check(点击手机联系人时查询)
 *  @param jsonData
 *  @param block
 */
+ (void)queryPhoneBook:(NSString *)sessionId openfire:(NSString *)openfire flag:(NSString *)action phonedata:(NSString *)jsonData block:(SuccessfulBlock)block{
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    param[@"sessionId"] = sessionId;
    param[@"openfireaccount"] = openfire;
    param[@"action"] = action;
    param[@"phonedata"] = jsonData;
    [HttpTool POST:@"/moblie/getPhoneContacts.do" params:param success:^(ResponseData *json) {
        block(json);
    } failure:^(ErrorData *error) {
    
        
    }];
}

//从后台唤醒的时候，加载是否有未读消息
+ (void)ApplicationWakeUpAtBackgroundWithSessionId:(NSString *)sessionId andUserID:(NSString *)userID andLastMessageID:(NSString *)fcID block:(SuccessfulBlock)block{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"sessionId"] = sessionId;
    params[@"userId"] = userID;
    params[@"fcid"] = fcID;
    params[@"appSystem"] = @"ios";
    
    [HttpTool POST:@"/moblie/getUnreadMessageNum.do" params:params success:^(ResponseData *json) {
        block(json);
    } failure:^(ErrorData *error) {
    
        
    }];
}

//删除自己的评论
+ (void)DeletedMyCommentWithSessionID:(NSString *)sessionID andOpenFirAccount:(NSString *)openFirAccount andFcid:(NSString *)fcid block:(SuccessfulBlock)block {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"sessionId"] = sessionID;
    params[@"openfireaccount"] = openFirAccount;
    params[@"fccid"] = fcid;
    
    [HttpTool POST:@"/moblie/delete_comment.do" params:params success:^(ResponseData *json) {
        block(json);
    } failure:^(ErrorData *error) {
    
        
    }];
}

/**
 *  添加通话日志
 *
 *  @param fromPhone 主叫
 *  @param toPhone   被叫
 *  @param status    状态码
 *  @param errorInfo 错误信息
 */
+ (void)addCallLog:(NSString *)sessionId fromPhone:(NSString *)fromPhone toPhone:(NSString *)toPhone status:(NSInteger)status errorInfo:(NSString *)errorInfo block:(SuccessfulBlock)block{
//    UserInfoManager *manager = [UserInfoManager shareInstance];
    //手机型号和系统版本信息
//    NSString *phoneInfo = [NSString stringWithFormat:@"%@iOS%@",manager.phoneType,manager.systemVersion];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"sessionId"] = sessionId;
    params[@"appSystem"] = @"ios";
    params[@"from_phone"] = fromPhone;
    params[@"to_phone"] = toPhone;
    params[@"status"] = @(status);
    params[@"errordata"] = errorInfo;
//    params[@"phone_info"] = phoneInfo;
    
    [HttpTool POST:@"/moblie/addCallRecordData.do" params:params success:^(ResponseData *json) {
        block(json);
    } failure:^(ErrorData *error) {
        
    }];
}


//投诉用户
+ (void)ComplainsUserWithSessionID:(NSString *)sessionID andComplaintsUserId:(NSString *)complaintsUserId andComplainsReason:(NSString *)reason andComplainFriendCicle:(NSString *)firendCicle andComplatinType:(int)complaintType block:(SuccessfulBlock)block {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"sessionId"] = sessionID;
    dic[@"reason"] = reason;
    dic[@"friendcircleid"] = firendCicle;
    dic[@"appSystem"] = @"ios";
    dic[@"complaintsUserId"] = complaintsUserId;
    dic[@"type"] = @(complaintType);
    
    [HttpTool POST:@"/moblie/addComplaints.do" params:dic success:^(ResponseData *json) {
        block(json);
    } failure:^(ErrorData *error) {
        
    }];
}

//查询手机联系人是否开通芝麻
+ (void)queryContacts:(NSString *)sessionId phone:(NSString *)phone success:(SuccessfulBlock)success failure:(FailureBlock)failure {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"sessionId"] = sessionId;
    dic[@"phone"] = phone;
    
    [HttpTool POST:@"/moblie/findWeuserByphone.do" params:dic success:^(ResponseData *json) {
        success(json);
    } failure:^(ErrorData *error) {
        
    }];
}

//获取好友列表
+ (void)getFriendsList:(NSString *)sessionId friendType:(FriendType)type success:(SuccessfulBlock)success failure:(FailureBlock)failure{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"sessionId"] = sessionId;
    dic[@"friend_type"] = @(type);
    [HttpTool POST:@"/moblie/getFirendListByfriend_type.do" params:dic success:^(ResponseData *json) {
        success(json);
    } failure:^(ErrorData *error) {
        failure(error);
    }];
}

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
+ (void)collectionCircleListWithCollectionType:(int)collectionType andSessionId:(NSString *)sessionId andConent:(NSString *)content andSmallImg:(NSString *)smallImg andBigImage:(NSString *)big_img andSource:(NSString *)source andAccount:(NSString *)account andMsgId:(NSString *)msgId andFcId:(NSString *)fcid andUsertype:(NSString *)userType success:(SuccessfulBlock)successBlock failure:(FailureBlock)failureBlock {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"sessionId"] = sessionId;
    params[@"collection_type"] = [NSString stringWithFormat:@"%zd",collectionType];
    params[@"content"] = content;
    params[@"small_img"] = smallImg;
    params[@"big_img"] = big_img;
    params[@"source"] = source;
    params[@"oppositeId"] = account;
    params[@"msgid"] = msgId;
    params[@"fcid"] = fcid;
    params[@"userType"] = userType;
    
    [HttpTool POST:@"/moblie/addLoveCollection.do" params:params success:^(ResponseData *responseData) {
        successBlock(responseData);
    } failure:^(ErrorData *error) {
        failureBlock(error);
    }];
}

// 获取收藏列表接口
+ (void)getCollectionListWithSessionId:(NSString *)sessionId success:(SuccessfulBlock)successBlock failure:(FailureBlock)failureBlock {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"sessionId"] = sessionId;
    [HttpTool POST:@"/moblie/getLoveCollectionByUserId.do" params:params success:^(ResponseData *responseData) {
        successBlock(responseData);
    } failure:^(ErrorData *error) {
        failureBlock(error);
    }];
}

// 删除收藏接口
+ (void)deletedCircleCollectionWithSessionId:(NSString *)sessionId andCollectionId:(NSString *)collectionId success:(SuccessfulBlock)successBlock failure:(FailureBlock)failureBlock {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"sessionId"] = sessionId;
    params[@"collectionId"] = collectionId;
    [HttpTool POST:@"/moblie/deleteLoveCollectionByCollectionId.do" params:params success:^(ResponseData *responseData) {
        successBlock(responseData);
    } failure:^(ErrorData *error) {
        failureBlock(error);
    }];
}

// 群组信息
+ (void)setGroupInfoMessageWithFunctionName:(NSString *)functionName andSessionId:(NSString *)sessionId andValue:(NSString *)value andGroupId:(NSString *)groupId success:(SuccessfulBlock)successBlock failure:(FailureBlock)failureBlock {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"sessionId"] = sessionId;
    params[@"groupid"] = groupId;
    params[@"functionName"] = functionName;
    params[@"value"] = value;
    [HttpTool POST:@"/moblie/setGroupRoomTop.do" params:params success:^(ResponseData *responseData) {
        successBlock(responseData);
    } failure:^(ErrorData *error) {
        failureBlock(error);
    }];
}

//根据邀请码获取用户Id
+ (void)getUserIdWithInvitedCode:(NSString *)invitedCode success:(SuccessfulBlock)successBlock failure:(FailureBlock)failureBlock {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"inviteCode"] = invitedCode;
    [HttpTool POST:@"/moblie/getUserIdByInviteCode.do" params:params success:^(ResponseData *responseData) {
        successBlock(responseData);
    } failure:^(ErrorData *error) {
        failureBlock(error);
    }];
}

//获取个人更多详细信息
+ (void)getMoreUserInfo:(NSString *)sessionId success:(SuccessfulBlock)successBlock failure:(FailureBlock)failureBlock{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"sessionId"] = sessionId;
    [HttpTool POST:@"/moblie/getAllRedbag_items.do" params:params success:^(ResponseData *responseData) {
        successBlock(responseData);
    } failure:^(ErrorData *error) {
        failureBlock(error);
    }];
}

//保存个人更多详细信息
+ (void)saveMoreUserInfo:(NSString *)sessionId moreData:(NSString *)jsonStr success:(SuccessfulBlock)successBlock failure:(FailureBlock)failureBlock{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"sessionId"] = sessionId;
    params[@"values"] = jsonStr;
    [HttpTool POST:@"/moblie/saveWeuserDetail.do" params:params success:^(ResponseData *responseData) {
        successBlock(responseData);
    } failure:^(ErrorData *error) {
        failureBlock(error);
    }];
}

//获取群二维码
+ (void)getGroupChatQRCodeWithSessionId:(NSString *)sessionId andGroupId:(NSString *)groupId success:(SuccessfulBlock)successBlock failure:(FailureBlock)failureBlock {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"sessionId"] = sessionId;
    params[@"groupid"] = groupId;
    [HttpTool POST:@"/moblie/createQRCode.do" params:params success:^(ResponseData *responseData) {
        successBlock(responseData);
    } failure:^(ErrorData *error) {
        failureBlock(error);
    }];
}

//获取当前登录用户的二维码
+ (void)getMyQRCodeWithSessionId:(NSString *)sessionId success:(SuccessfulBlock)successBlock failure:(FailureBlock)failureBlock {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"sessionId"] = sessionId;
    [HttpTool POST:@"/moblie/createQRCode_user.do" params:params success:^(ResponseData *responseData) {
        successBlock(responseData);
    } failure:^(ErrorData *error) {
        failureBlock(error);
    }];
}


// 文件上传
+ (void)upLoadFileWithSeccessId:(NSString *)seccessId andCollectionType:(NSString *)collectionType andOppositeId:(NSString *)oppositeId andMsgId:(NSString *)msgId andUserType:(NSString *)userType andPath:(NSString *)filePath success:(SuccessfulBlock)successBlock failure:(FailureBlock)failureBlock {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"sessionId"] = seccessId;
    params[@"file"] = @"voice.amr";
    params[@"fileName"] = @"voice";
    params[@"collection_type"] = collectionType;
    params[@"oppositeId"] = oppositeId;
    params[@"msgid"] = msgId;
    params[@"usertype"] = userType;
    params[@"functionName"] = @"voice";
    
    [HttpTool upLoadFileWithURL:@"/moblie/upload_file.do" andParams:params andFilePath:filePath success:^(ResponseData *json) {
        successBlock(json);
    } failure:^(ErrorData *json) {
        failureBlock(json);
    }];
}

// 文件下载
+ (void)downloadFileWithUrl:(NSString *)url success:(SuccessfulBlock)successBlock failure:(FailureBlock)failureBlock {
    [HttpTool downloadFileWithURL:url success:^(ResponseData *json) {
        successBlock(json);
    } failure:^(ErrorData *json) {
        failureBlock(json);
    }];
}

//查看加好友是否需要验证
+ (void)lookAddFriendShouldAskSuccess:(SuccessfulBlock)successBlock failure:(FailureBlock)failureBlock{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"sessionId"] = USERINFO.sessionId;
    params[@"userId"] = USERINFO.userID;
    [HttpTool POST:@"/moblie/getPersonAppSet.do" params:params success:^(ResponseData *responseData) {
        successBlock(responseData);
    } failure:^(ErrorData *error) {
        failureBlock(error);
    }];
}

//删除群成员的时候调用，用来获取最新的群头像
+ (void)getGroupHeadGroupId:(NSString *)groupId success:(SuccessfulBlock)successBlock failure:(FailureBlock)failureBlock{

    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"sessionId"] = USERINFO.sessionId;
    params[@"groupid"] = groupId;
    [HttpTool POST:@"/moblie/setGroupHeadphoto.do" params:params success:^(ResponseData *responseData) {
        successBlock(responseData);
    } failure:^(ErrorData *error) {
        failureBlock(error);
    }];
}

//如果是审核状态-- 隐藏『钱包』
+ (void)verfiryAppStatues:(NSString *)verion success:(SuccessfulBlock)successBlock failure:(FailureBlock)failureBlock{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"version"] = verion;
    [HttpTool POST:@"/moblie/openPhonePay.do" params:params success:^(ResponseData *responseData) {
        successBlock(responseData);
    } failure:^(ErrorData *error) {
        failureBlock(error);
    }];
}

//获取离线消息
+ (void)getOfflineMessage:(NSString *)userId success:(SuccessfulBlock)successBlock failure:(FailureBlock)failureBlock{
    //生成签名
    NSString *sign = [NSString stringWithFormat:@"uid=%@&apikey=yihezhaizhima20162018",userId];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"uid"] = userId;
    params[@"sign"] = sign;
    [HttpTool POST:@"/Api/Offline/getmsg" params:params success:^(ResponseData *responseData) {
        successBlock(responseData);
    } failure:^(ErrorData *error) {
        failureBlock(error);
    }];
}


@end
