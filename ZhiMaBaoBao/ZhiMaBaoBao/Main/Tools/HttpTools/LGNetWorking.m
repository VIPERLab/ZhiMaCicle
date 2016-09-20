//
//  LGNetWorking.m
//  YiIM_iOS
//
//  Created by liugang on 16/8/5.
//  Copyright © 2016年 ikantech. All rights reserved.
//

#import "LGNetWorking.h"

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
+ (void)loginWithPhone:(NSString *)phone password:(NSString *)password success:(SuccessfulBlock)success failure:(void (^)(ErrorData *json))error {
    
    [HttpTool POST:@"/moblie/user_login.do" params:@{@"phone":phone,@"password":password,@"version":@(2.0),@"appSystem":@"ios"} success:^(ResponseData *json) {
        
        success(json);
                
    } failure:^(ErrorData *error) {
//        failure(error);
        
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
+ (void)loadMyDiscoverWithSectionID:(NSString *)sectionID andMyCheatAcount:(NSString *)openfireaccount andPageCount:(NSString *)pageNumber block:(SuccessfulBlock)block {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"sessionId"] = sectionID;
    params[@"openfireaccount"] = openfireaccount;
    params[@"pageNumber"] = pageNumber;
    [HttpTool POST:@"/moblie/getFriendCircleByLoginer.do" params:params success:^(ResponseData *json) {
        
        block(json);
        
    } failure:^(ErrorData *error) {
        
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

//-------------------------------------------群组---------------------------------------
/**
 *  添加用户到群组
 *
 *  @param sessionId sessionid
 *  @param accounts  openfire帐号，多人用逗号隔开
 *  @param roomId    xmpp群id
 *  @param roomName  群地址
 *  @param name和roomid至少传一个
 */
+(void)addUserToGroup:(NSString *)sessionId accounts:(NSString *)accounts roomId:(NSString *)roomId roomName:(NSString *)roomName block:(SuccessfulBlock)block{
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    param[@"sessionId"] = sessionId;
    param[@"openfireaccount_s"] = accounts;
    param[@"roomid"] = roomId;
    param[@"name"] = roomName;
    [HttpTool POST:@"/moblie/addusertoGroup.do" params:param success:^(ResponseData *responseData) {
        block(responseData);
    } failure:^(ErrorData *error) {
        
    }];
}

/**
 *  查看群组列表
 *
 *  @param sessionId sessionId
 *  @param account   openfire帐号
 *  @param block
 */
+(void)getGroupList:(NSString *)sessionId account:(NSString *)account block:(SuccessfulBlock)block{
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    param[@"sessionId"] = sessionId;
    param[@"openfireaccount"] = account;
    [HttpTool POST:@"/moblie/getGroupByuserId.do" params:param success:^(ResponseData *responseData) {
        block(responseData);
    } failure:^(ErrorData *error) {
        
    }];
}

/**
 *  查看群详情
 *
 *  @param sessionId sessionId
 *  @param account   当前登录者的即时聊天账号
 *  @param roomId    房间ID
 *  @param name      群的地址
 *  @param block     至少传一个,name和roomid
 */
+(void)getGroupInfo:(NSString *)sessionId account:(NSString *)account roomId:(NSString *)roomId name:(NSString *)name block:(SuccessfulBlock)block{
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    param[@"sessionId"] = sessionId;
    param[@"openfireaccount"] = account;
    param[@"roomid"] = roomId;
    param[@"name"] = name;
    [HttpTool POST:@"/moblie/getGroupDetail.do" params:param success:^(ResponseData *json) {
        block(json);
    } failure:^(ErrorData *error) {
    
        
    }];
}


+ (void)loadPersonalDiscoverDetailWithSessionID:(NSString *)sessionID andTargetOpenFirAccount:(NSString *)openFirAccount andPageNumber:(NSString *)pageNumber block:(SuccessfulBlock)block {
    
    NSMutableDictionary *parms = [NSMutableDictionary dictionary];
    parms[@"sessionId"] = sessionID;
    parms[@"openfireaccount"] = openFirAccount;
    parms[@"pageNumber"] = pageNumber;
    
    [HttpTool POST:@"/moblie/getFriendCircleByUserId.do" params:parms success:^(ResponseData *responseData) {
        block(responseData);
    } failure:^(ErrorData *error) {
//        responseData
    }];
}


+ (void)LikeOrCommentDiscoverWithSessionID:(NSString *)sessionID andFcId:(NSString *)fcId andComment:(NSString *)comment andOpenFirAccount:(NSString *)openFirAccount block:(SuccessfulBlock)block{
    
    NSMutableDictionary *parms = [NSMutableDictionary dictionary];
    parms[@"sessionId"] = sessionID;
    parms[@"fcId"] = fcId;
    parms[@"openfireaccount"] = openFirAccount;
    parms[@"comment"] = comment;
    
    [HttpTool POST:@"/moblie/addFriend_circles_comment.do" params:parms success:^(ResponseData *json) {
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
    params[@"openfireaccount"] = openfirAccount;
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
+ (void)getFriendInfo:(NSString *)sessionId openfire:(NSString *)account block:(SuccessfulBlock)block{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"sessionId"] = sessionId;
    params[@"openfireaccount"] = account;
    
    [HttpTool POST:@"/moblie/getWeuserFriendDetail.do" params:params success:^(ResponseData *json) {
        block(json);
    } failure:^(ErrorData *error) {
    
        
    }];
}

//上传用户个人信息
+ (void)upLoadUserDataWithSessionID:(NSString *)sessionID andOpenFirAccount:(NSString *)openFirAccount andFunctionName:(NSString *)functionName andChangeValue:(NSString *)value block:(SuccessfulBlock)block {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"sessionId"] = sessionID;
    params[@"openfireaccount"] = openFirAccount;
    params[@"functionName"] = functionName;
    params[@"value"] = value;
    
    [HttpTool POST:@"/moblie/savePersonInfo.do" params:params success:^(ResponseData *json) {
        block(json);
    } failure:^(ErrorData *error) {
    
        
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
+ (void)setupFriendFunction:(NSString *)sessionId function:(NSString *)functionName value:(NSInteger )value openfireAccount:(NSString *)account block:(SuccessfulBlock)block{
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    param[@"sessionId"] = sessionId;
    param[@"functionName"] = functionName;
    param[@"value"] = @(value);
    param[@"openfireaccount"] = account;
    [HttpTool POST:@"/moblie/setfriend.do" params:param success:^(ResponseData *json) {
        block(json);
    } failure:^(ErrorData *error) {
    
        
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
+ (void)ApplicationWakeUpAtBackgroundWithSessionId:(NSString *)sessionId andOpenFirAccount:(NSString *)openFirAccount andLastMessageID:(NSString *)fcID block:(SuccessfulBlock)block{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"sessionId"] = sessionId;
    params[@"openfireaccount"] = openFirAccount;
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
+ (void)ComplainsUserWithSessionID:(NSString *)sessionID andTheOpenFireAccount:(NSString *)openfirAccount andComplainsReason:(NSString *)reason andComplainFriendCicle:(NSString *)firendCicle block:(SuccessfulBlock)block {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"sessionId"] = sessionID;
    dic[@"openfireaccount"] = openfirAccount;
    dic[@"reason"] = reason;
    dic[@"friendcircleid"] = firendCicle;
    dic[@"appSystem"] = @"ios";
    
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

@end
