//
//  SocketManager.m
//  ZhiMaBaoBao
//
//  Created by liugang on 16/9/22.
//  Copyright © 2016年 liugang. All rights reserved.
//

#import "SocketManager.h"
#import "RHSocketService.h"
#import "RHSocketVariableLengthEncoder.h"
#import "RHSocketVariableLengthDecoder.h"
#import "RHSocketUtils.h"
#import "NSString+MD5.h"
#import "NSData+Replace.h"
#import "ConverseModel.h"
#import "NSData+Base64.h"
#import "ZhiMaFriendModel.h"
#import "GroupChatModel.h"
#import "NSString+MsgId.h"
#import <AudioToolbox/AudioToolbox.h>
#import "JFMyPlayerSound.h"
#import "RBDMuteSwitch.h"

typedef void (^CompleteBlock)(id data);
@interface SocketManager ()<RBDMuteSwitchDelegate>
@property(nonatomic,strong)JFMyPlayerSound *myPlaySounde;   //播放系统声音
@property (nonatomic, strong) NSMutableArray *offlineMessages;
@end

@implementation SocketManager

static SocketManager *manager = nil;

+ (instancetype)shareInstance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!manager) {
            manager = [[SocketManager alloc] init];
        }
    });
    return manager;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(detectSocketServiceState:) name:kNotificationSocketServiceState object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(detectSocketPacketResponse:) name:kNotificationSocketPacketResponse object:nil];
    }
    return self;
}


//连接服务器
- (void)connect{
    
    //每次连接socket之前，先关闭socket
    [[RHSocketService sharedInstance] stopService];
    
    RHSocketConnectParam *connectParam = [[RHSocketConnectParam alloc] init];
    connectParam.host = HOST;
    connectParam.port = PORT;
    
    //设置心跳定时器间隔30秒
    connectParam.heartbeatInterval = 30;
    
    //设置短线后是否自动重连
    connectParam.autoReconnect = YES;
    
    //变长编解码。包体＝包头（包体的长度）＋包体数据
    RHSocketVariableLengthEncoder *encoder = [[RHSocketVariableLengthEncoder alloc] init];
    RHSocketVariableLengthDecoder *decoder = [[RHSocketVariableLengthDecoder alloc] init];
    
    [RHSocketService sharedInstance].encoder = encoder;
    [RHSocketService sharedInstance].decoder = decoder;
    
    //设置心跳包，这里的object数据，和服务端约定好
    RHSocketPacketRequest *req = [[RHSocketPacketRequest alloc] init];
    req.object = [self generateRequest:RequestTypeHeart uid:USERINFO.userID message:nil];
    [RHSocketService sharedInstance].heartbeat = req;
    
    [[RHSocketService sharedInstance] startServiceWithConnectParam:connectParam];
}

#pragma mark - socket 代理方法
//socket服务器连接状态回调
- (void)detectSocketServiceState:(NSNotification *)notif
{
    //NSDictionary *userInfo = @{@"host":host, @"port":@(port), @"isRunning":@(_isRunning)};
    //对应的连接ip和状态数据。_isRunning为YES是连接成功。
    //没有心跳超时后会自动断开。
    NSLog(@"detectSocketServiceState: %@", notif);
    
    //连接成功 发送登录消息
    id state = notif.object;
    if (state && [state boolValue]) {
        //生成登录消息数据包
        NSData *loginData = [self generateRequest:RequestTypeLogin uid:USERINFO.userID message:nil];
        RHSocketPacketRequest *req = [[RHSocketPacketRequest alloc] init];
        req.object = loginData;
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationSocketPacketRequest object:req];
        
        UserInfo *userInfo = [UserInfo shareInstance];
        userInfo.networkUnReachable = NO;
        
        //上线拉取离线消息
        [self getOfflineMessage];
        
    } else {
        UserInfo *userInfo = [UserInfo shareInstance];
        userInfo.networkUnReachable = YES;
    }
}

//获取离线消息
- (void)getOfflineMessage{
    if (USERINFO.userID.length) {
        [self.offlineMessages removeAllObjects];
//        [LCProgressHUD showLoadingText:@"收取中..."];
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        manager.requestSerializer.timeoutInterval = 30.0f;
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html",@"application/json",nil];
        
        //生成签名
        if (USERINFO.userID.length) {
            NSString *str = [NSString stringWithFormat:@"uid=%@&apikey=yihezhaizhima20162018",USERINFO.userID];
            //生成签名
            NSString *sign = [[str md5Encrypt] uppercaseString];
            NSMutableDictionary *params = [NSMutableDictionary dictionary];
            params[@"uid"] = USERINFO.userID;
            params[@"sign"] = sign;
            
            [manager POST:[NSString stringWithFormat:@"%@/Api/Offline/getmsg",CHATPICURL] parameters:params progress:0 success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                
                if (responseObject) {
                    if ([responseObject[@"code"] integerValue] == 8888) {
                        NSArray *data = responseObject[@"data"];
                        for (NSDictionary *dic in data) {
                            LGMessage *message = [[LGMessage alloc] init];
                            message = [message mj_setKeyValues:dic[@"data"]];
//                            message.actType = dic[@"acttype"];
                            [self.offlineMessages addObject:message];
                        }
                        dispatch_queue_t conCurrentGlobalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
                        dispatch_queue_t mainQueue = dispatch_get_main_queue();
                        dispatch_group_t groupQueue = dispatch_group_create();
                        NSLog(@"current task");
                        dispatch_group_async(groupQueue, conCurrentGlobalQueue, ^{
                            for (LGMessage *message in self.offlineMessages) {
                                NSLog(@"--------------- current thred %@",[NSThread currentThread]);

                                if (message.conversionType == ConversionTypeSingle) {
                                    [FMDBShareManager saveMessage:message toConverseID:message.fromUid];
                                }else if (message.conversionType == ConversionTypeGroupChat){
//                                    [FMDBShareManager saveGroupChatMessage:message andConverseId:message.toUidOrGroupId];
                                    
                                    [self addOfflineGroupMessage:message groupId:message.toUidOrGroupId];
                                }
                            }
                        });

                        dispatch_group_notify(groupQueue, mainQueue, ^{
                            NSLog(@"groupQueue中的任务 都执行完成,回到主线程更新UI");
                            [[NSNotificationCenter defaultCenter] postNotificationName:kRecieveNewMessage object:nil];
                        });

                    }else{
                        
                    }
                    NSLog(@"-------%@",responseObject);
                }else{
                    
                }
                
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                
            }];
        }
    }
}


//手动断开socket
-(void)disconnect{
    [[RHSocketService sharedInstance] stopService];
}

//发送消息
- (void)sendMessage:(LGMessage *)message{
    
    //赋值会话id
    message.converseId = message.toUidOrGroupId;
    
    //是错误信息 （在被踢出的群里发信息）
    if (message.errorMsg) {
        //直接发送 失败通知
        message.sendStatus = NO;
        [FMDBShareManager saveGroupChatMessage:message andConverseId:message.toUidOrGroupId];
        //发送消息状态回调通知
        NSDictionary *infoDic = @{@"message":message};
        [[NSNotificationCenter defaultCenter] postNotificationName:kSendMessageStateCall object:nil userInfo:infoDic];
        return;
    }
    
    //处理过后的发送给socket的message
    LGMessage *sendMsg = [[LGMessage alloc] init];
    sendMsg.toUidOrGroupId = message.toUidOrGroupId;
    sendMsg.fromUid = message.fromUid;
    sendMsg.type = message.type;
    sendMsg.msgid = message.msgid;
    sendMsg.conversionType = message.conversionType;
    sendMsg.timeStamp = message.timeStamp;
    sendMsg.fromUserPhoto = message.fromUserPhoto;
    sendMsg.fromUserName = message.fromUserName;
    sendMsg.converseId = message.converseId;
    sendMsg.text = message.text;
    sendMsg.audioLength = message.audioLength;
    sendMsg.holderImageUrlString = message.holderImageUrlString;
    sendMsg.videoDownloadUrl = message.videoDownloadUrl;
    
    //语音消息 -- 发送base64到socket服务器，存语音路径到本地数据库
    if (message.type == MessageTypeAudio) {
        
        //通过路径拿到音频文件
        NSString *sandboxPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *path = [NSString stringWithFormat:@"%@/%@",sandboxPath,message.text];
        NSData *data = [NSData dataWithContentsOfFile:path];
        //转换成base64编码
        NSString *base64 = [data base64EncodedStringWithOptions:0];
        //将text转换为base64 发送给socket
        sendMsg.text = base64;
        
    }
    else if (message.type == MessageTypeVideo){
        sendMsg.isDownLoad = NO;
        sendMsg.text = message.text;
    }
    
    if (message.conversionType == ConversionTypeSingle) {
        sendMsg.converseName = USERINFO.username;
        sendMsg.converseLogo = USERINFO.head_photo;
    }else if (message.conversionType == ConversionTypeGroupChat){
        sendMsg.converseName = message.converseName;
        sendMsg.converseLogo = message.converseLogo;
    }
    
    //根据网络状态-- 标记消息发送状态
    UserInfo *userInfo = [UserInfo shareInstance];
    message.sendStatus = !userInfo.networkUnReachable;
    
    //生成会话模型 用作创建/更新会话
    ConverseModel *converse = [[ConverseModel alloc] init];
    converse.converseHead_photo = message.converseLogo;
    converse.converseType = message.conversionType;
    converse.lastConverse = message.text;
    converse.messageType = message.type;
    converse.converseId = message.toUidOrGroupId;
    converse.converseName = message.converseName;
    converse.time = message.timeStamp;
    //插入消息数据库、更新会话(新版本)
    //1.插消息表
    [FMDBShareManager saveMessage:message toConverseID:converse.converseId];
    //2.插会话表
    [FMDBShareManager saveConverseListDataWithModel:converse withComplationBlock:nil];
    
    //发送消息状态回调通知
    NSDictionary *infoDic = @{@"message":message};
    [[NSNotificationCenter defaultCenter] postNotificationName:kSendMessageStateCall object:nil userInfo:infoDic];

    //插入数据库成功 - socket发送消息
    //根据消息模型生成固定格式数据包
    NSData *data = [self generateRequest:RequestTypeMessage uid:USERINFO.userID message:sendMsg];
    RHSocketPacketRequest *req = [[RHSocketPacketRequest alloc] init];
    req.object = data;
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationSocketPacketRequest object:req];
    
}

//收到消息
- (void)detectSocketPacketResponse:(NSNotification *)notif
{
    //解析消息模型
    NSDictionary *userInfo = notif.userInfo;
    RHSocketPacketResponse *rsp = userInfo[@"RHSocketPacket"];
    NSData *data = [rsp dataWithPacket];
    NSString *jsonStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSDictionary *responceData = [data mj_JSONObject];

    NSLog(@"\n从socket接收到的数据responceData :%@\n json:%@ \n",responceData,jsonStr);
    if (responceData) {

        //解析消息
        LGMessage *message = [[LGMessage alloc] init];
        message = [message mj_setKeyValues:responceData];
        
        //生成会话模型 用作创建/更新会话
        ConverseModel *converse = [[ConverseModel alloc] init];
        converse.converseHead_photo = message.converseLogo;
        converse.converseType = message.conversionType;
        converse.lastConverse = message.text;
        converse.messageType = message.type;
        converse.time = message.timeStamp;
        
        //生成群成员信息模型 用作插群成员表
        GroupUserModel *groupUser = [[GroupUserModel alloc] init];
        //生成群信息模型
        GroupChatModel *groupInfo = [[GroupChatModel alloc] init];
        //生成好友模型
        ZhiMaFriendModel *friend = [[ZhiMaFriendModel alloc] init];
        friend.user_Id = message.fromUid;
        friend.user_Name = message.fromUserName;
        friend.user_Head_photo = message.fromUserPhoto;
        
        //如果是语音消息和视频消息 --> 先进行解析处理
        if (message.type == MessageTypeAudio) {
            NSData *audioData = [[NSData alloc] initWithBase64EncodedString:message.text options:0];
            
            //沙盒路径
            NSString *sandboxPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
            //根据当前时间和发送者uid 拼接语音文件名
            NSInteger stamp = [NSDate currentTimeStamp];
            NSString *fileName = [NSString stringWithFormat:@"%@-%@.amr",[NSDate dateStrFromCstampTime:stamp withDateFormat:@"yyyy-MM-dd-hh-mm-ss-SSS"],message.fromUid];
            //语音文件路径
            NSString *path = [NSString stringWithFormat:@"%@/%@",sandboxPath,fileName];
            message.text = fileName;
            if ([audioData writeToFile:path atomically:YES]) {
                NSLog(@"语音写入沙盒成功");
            }else{
                NSLog(@"语音写入沙盒失败");
            }
        }
        //视频消息
        else if (message.type == MessageTypeVideo){

        }
        
        
        //根据（单聊、群聊、服务号）三种消息类型处理消息
        if (message.conversionType == ConversionTypeSingle) {
            ZhiMaFriendModel *friend = [FMDBShareManager getUserMessageByUserID:message.fromUid];
            converse.converseId = message.toUidOrGroupId;
            converse.converseName = message.converseName;
            if (friend.user_Id) {
                converse.converseName = friend.displayName;
            }
            
        }
        //群聊
        else if (message.conversionType == ConversionTypeGroupChat){
            //赋值会话id 会话名称
            converse.converseId = message.converseId;
            converse.converseName = message.converseName;
            //赋值群成员模型
            groupUser.userId = message.fromUid;
            groupUser.groupId = message.toUidOrGroupId;
            groupUser.friend_nick = message.fromUserName;
            groupUser.head_photo = message.fromUserPhoto;
            //赋值群信息模型
            groupInfo.groupId = message.toUidOrGroupId;
            groupInfo.groupName = message.converseName;
            groupInfo.groupAvtar = message.converseLogo;

        }
        //服务号
        else if (message.conversionType == ConversionTypeActivity){
            converse.converseName = message.converseName;
            converse.converseId = message.converseId;
        }
        
        //根据操作指令进行相关操作和数据库存储
        switch (message.actType) {
            case ActTypeNormal:{        //普通消息
                if (message.conversionType == ConversionTypeGroupChat) {    //保存群成员信息、保存群信息
                    groupUser.memberGroupState = NO;    //标记为出席群
                    [FMDBShareManager saveAllGroupMemberWithArray:@[groupUser] andGroupChatId:converse.converseId withComplationBlock:nil];
                    [FMDBShareManager saveGroupChatInfo:groupInfo andConverseID:converse.converseId];
                }
                [FMDBShareManager saveMessage:message toConverseID:converse.converseId];
                [FMDBShareManager saveConverseListDataWithModel:converse withComplationBlock:nil];
            }
                break;
            case ActTypeAddfriend:{     //好友请求
                NSMutableDictionary *parmas = [NSMutableDictionary dictionary];
                parmas[@"friend"] = friend;
                [[NSNotificationCenter defaultCenter] postNotificationName:kNewFriendRequest object:nil userInfo:parmas];
                
                //保存新的好友到数据库
                friend.friend_type = 1;
                [FMDBShareManager saveNewFirendsWithArray:@[friend] withComplationBlock:nil];
            }
                break;
            case ActTypeDofriend:{      //同意好友请求
                converse.converseId = message.fromUid;
                [FMDBShareManager saveMessage:message toConverseID:converse.converseId];
                [FMDBShareManager saveConverseListDataWithModel:converse withComplationBlock:nil];
            }
                break;
            case ActTypeUpdatefriend:{  //更新好友数据
                
                
            }
                break;
            case ActTypeUpdategroupnum:{    //更新群用户数 （拉人进群）
                [FMDBShareManager saveMessage:message toConverseID:converse.converseId];
                [FMDBShareManager alertConverseListDataWithModel:converse withComplationBlock:nil];
            }
                break;
            case ActTypeDeluserfromgroup:{  //从群组删除用户
                [FMDBShareManager saveMessage:message toConverseID:converse.converseId];
                [FMDBShareManager alertConverseListDataWithModel:converse withComplationBlock:nil];
            }
                break;
            case ActTypeQuitgroup:{          //退出群聊
                
            }
                break;
            case ActTypeRenamegroup:{       //修改群名称
                message.msgid = [NSString generateMessageID];
                [FMDBShareManager saveMessage:message toConverseID:converse.converseId];
                [FMDBShareManager alertConverseListDataWithModel:converse withComplationBlock:nil];
            }
                break;
            case ActTypeNofriend:{          //不是好友
                [FMDBShareManager revokeNormalMessageToSystemMessage:message];
                [FMDBShareManager alertConverseTextAndTimeWithConverseModel:converse];
            }
                break;
            case ActTypeNoallow:{           //不允许看朋友圈
                NSDictionary *resDic = responceData[@"data"];
                NSString *friendId = resDic[@"delUid"];
                NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
                userInfo[@"deleteUid"] = friendId;
                [[NSNotificationCenter defaultCenter] postNotificationName:K_NotLookMyCircleNotification object:nil userInfo:userInfo];
            }
                break;
            case ActTypeInBlacklist:{       //被拉入黑名单
                converse.converseId = message.converseId;
                message.msgid = [NSString generateMessageID];
                message.timeStamp = [NSDate currentTimeStamp];
                message.sendStatus = NO;
                [FMDBShareManager saveMessage:message toConverseID:converse.converseId];
                [FMDBShareManager alertConverseTextAndTimeWithConverseModel:converse];
                
//                [[NSNotificationCenter defaultCenter] postNotificationName:kSendMessageStateCall object:nil userInfo:@{@"message":message}];
            }
                break;
            case ActTypeUndomsg:{            //撤销消息
                [FMDBShareManager revokeNormalMessageToSystemMessage:message];
                [FMDBShareManager alertConverseTextAndTimeWithConverseModel:converse];
            }
                break;
            case ActTypeKickuser:{          //相同用户登录，剔除之前的登录用户
                [[NSNotificationCenter defaultCenter] postNotificationName:kOtherLogin object:nil];
            }
                break;
            case ActTypeNotIngroup:{        //没有出席群
                groupUser.memberGroupState = YES;
                [FMDBShareManager saveAllGroupMemberWithArray:@[groupUser] andGroupChatId:converse.converseId withComplationBlock:nil];
            }
                break;
                
            default:
                break;
        }
               
        //统一发送通知、更新UI
        NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
        userInfo[@"message"] = message;
        [[NSNotificationCenter defaultCenter] postNotificationName:kRecieveNewMessage object:nil userInfo:userInfo];
    }
    
//    else if ([actType isEqualToString:@"service"]){
//        //推送消息类型
//        NSInteger messageType = [responceData[@"data"][@"service"][@"type"] integerValue];
//        
//        //推送活动消息
//        [ZMServiceMessage mj_setupObjectClassInArray:^NSDictionary *{
//            return @{
//                     @"list":@"LGServiceList"
//                     };
//        }];
//        ZMServiceMessage *serviceMsg = [[ZMServiceMessage alloc] init];
//        serviceMsg = [serviceMsg mj_setKeyValues:responceData[@"data"]];
//        //手动设置推送消息类型（红包活动，单条文章，多条文章）
//        if (messageType == MessageTypeActivityPurse) {
//            serviceMsg.type = ServiceMessageTypePurse;
//        }else{
//            if (serviceMsg.list.count == 1) {   //只有一条文章消息
//                serviceMsg.type = ServiceMessageTypeSingle;
//            }else{
//                serviceMsg.type = ServiceMessageTypeMoreThanOne;
//            }
//        }
//        serviceMsg.service.type = serviceMsg.type;
//        
//        //推送消息list数组
//        NSArray *lists = responceData[@"data"][@"list"];
//        serviceMsg.listJson = [lists mj_JSONString];
//        
//        [FMDBShareManager saveServiceMessage:serviceMsg byServiceId:serviceMsg.cropid];
//        NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
//        userInfo[@"message"] = serviceMsg;
//        [[NSNotificationCenter defaultCenter] postNotificationName:kRecieveActivityMsg object:userInfo];
//    }
//    else if ([actType isEqualToString:@"addfriend"]){   //好友请求
//        NSDictionary *resDic = responceData[@"data"];
//        ZhiMaFriendModel *friend = [[ZhiMaFriendModel alloc] init];
//        friend.user_Id = resDic[@"fromuid"];
//        friend.user_Name = resDic[@"username"];
//        friend.user_Head_photo = resDic[@"head_photo"];
//        NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
//        userInfo[@"friend"] = friend;
//        //生成一个好友模型发送通知
//        [[NSNotificationCenter defaultCenter] postNotificationName:kNewFriendRequest object:nil userInfo:userInfo];
//    }
//    else if ([actType isEqualToString:@"updatefriend"]){   //更新好友数据
//        
//    }
//    else if ([actType isEqualToString:@"updategroupnum"]){   //更新群用户数
//        NSDictionary *resDic = responceData[@"data"];
//        NSString *groupId = resDic[@"groupid"];
//        NSString *actuid = resDic[@"actuid"];
//        NSString *uids = resDic[@"uids"];
//        NSString *jid = resDic[@"jid"];     //扫描二维码加群，生成二维码用户的id
//        //拉人进群相关操作
//        [self updateGroupNumber:groupId actUid:actuid uids:uids jid:jid];
//    }
//    else if ([actType isEqualToString:@"deluserfromgroup"]){   //从群组中删除用户
//        NSDictionary *resDic = responceData[@"data"];
//        NSString *uids = resDic[@"uids"];   //移除好友的uid
//        NSString *groupId = resDic[@"groupid"];
//        NSString *actUid = resDic[@"actuid"];   //操作者uid
//        
//        [self deleteGroupUser:groupId actUid:actUid uids:uids];
//    }
//    else if ([actType isEqualToString:@"renamegroup"]){   //重命名群组
//        //更新数据库群名称，添加一条系统消息"xx修改群名为"xxx""
//        NSDictionary *resDic = responceData[@"data"];
//        NSString *groupName = resDic[@"groupname"];
//        NSString *groupId = resDic[@"groupid"];
//        //修改群名的用户的ID
//        NSString *userId = resDic[@"uid"];
//        [self updateGroupName:groupName groupId:groupId userId:userId];
//    }
//    else if ([actType isEqualToString:@"undomsg"]){   //撤销消息
//        NSDictionary *resDic = responceData[@"data"];
//        NSString *fromUid = resDic[@"fromUid"];
//        NSString *groupId = resDic[@"toUidOrGroupId"];
//        
//        //收到自己撤销的群消息 不处理 （因为发送的时候已经处理了）
//        if ([fromUid isEqualToString:USERINFO.userID]) {
//            return;
//        }
//        
//        //根据uid拿到用户名
//        ZhiMaFriendModel *model = [FMDBShareManager getUserMessageByUserID:fromUid];
//        NSString *userName = model.user_Name;
//        //如果不是好友, 从群表查群用户
//        if (!model.user_Id) {
//            GroupUserModel *groupUserModel = [FMDBShareManager getGroupMemberWithMemberId:fromUid andConverseId:groupId];
//            userName = groupUserModel.friend_nick;
//        }
//        
//        //插入系统消息:"『用户名』撤回了一条消息"到数据库
//        LGMessage *systemMsg = [[LGMessage alloc] init];
//        systemMsg.actType = ActTypeUndomsg;
//        systemMsg.text = [NSString stringWithFormat:@"\"%@\"撤回了一条消息",userName];
//        systemMsg.toUidOrGroupId =  resDic[@"toUidOrGroupId"];
//        systemMsg.fromUid = fromUid;
//        systemMsg.type = MessageTypeSystem;
//        systemMsg.msgid = resDic[@"msgid"];
//        systemMsg.undoMsgid = resDic[@"msgid"];
//        systemMsg.conversionType = [resDic[@"isGroup"] integerValue];
//        systemMsg.timeStamp = [NSDate currentTimeStamp];
//        
//        //更新数据库会话 （最后一条消息显示）
//        NSString *conversionId = nil;
//        if (systemMsg.conversionType == ConversionTypeGroupChat) {
//            conversionId = systemMsg.toUidOrGroupId;
//        }else if (systemMsg.conversionType == ConversionTypeSingle){
//            conversionId = systemMsg.fromUid;
//        }
//        [FMDBShareManager upDataMessageStatusWithMessage:systemMsg];
//        FMDatabaseQueue *queue = [FMDBShareManager getQueueWithType:ZhiMa_Chat_Converse_Table];
//        NSString *optionStr1 = [NSString stringWithFormat:@"converseContent = '%@'",systemMsg.text];
//        NSString *upDataStr = [FMDBShareManager alterTable:ZhiMa_Chat_Converse_Table withOpton1:optionStr1 andOption2:[NSString stringWithFormat:@"converseId = '%@'",conversionId]];
//        [queue inDatabase:^(FMDatabase *db) {
//            [db executeUpdate:upDataStr];
//            
//        }];
//        
//        //发送撤销消息通知
//        NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
//        userInfo[@"message"] = systemMsg;
//        [[NSNotificationCenter defaultCenter] postNotificationName:kRecieveNewMessage object:nil userInfo:userInfo];
//    }
//    else if ([actType isEqualToString:@"updategroupuser"]){ //群用户修改群昵称
//#warning 更新数据库群成员列表
//        //            NSDictionary *resDic = responceData[@"data"];
//        //            NSString *userId = resDic[@"uid"];
//        //            NSString *groupId = resDic[@"groupid"];
//        //            NSString *name = resDic[@"group_user_nick"];
//        
//    }
//    else if ([actType isEqualToString:@"nofriend"]){ //对方把你删除好友，
//        //插入一条系统消息"你不是对方的朋友，请先发送朋友验证请求，对方验证通过后才能聊天。"到数据库
//        NSDictionary *resDic = responceData[@"data"];
//        NSString *toUid = resDic[@"toUidOrGroupId"];
//        LGMessage *systemMsg = [[LGMessage alloc] init];
//        systemMsg.text = @"你不是对方的朋友，请先发送朋友验证请求，对方验证通过后才能聊天";
//        systemMsg.fromUid = USERINFO.userID;
//        systemMsg.toUidOrGroupId = toUid;
//        systemMsg.type = MessageTypeSystem;
//        systemMsg.msgid = resDic[@"msgid"];
//        systemMsg.conversionType = ConversionTypeSingle;
//        systemMsg.timeStamp = [NSDate currentTimeStamp];
//        [FMDBShareManager saveMessage:systemMsg toConverseID:toUid];
//        
//        NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
//        userInfo[@"message"] = systemMsg;
//        [[NSNotificationCenter defaultCenter] postNotificationName:kRecieveNewMessage object:nil userInfo:userInfo];
//        
//    }
//    else if ([actType isEqualToString:@"inblacklist"]){ //对方把你设为黑名单
//        //插入一条系统消息"消息已成功发送，但被对方拒绝。"到数据库
//        NSDictionary *resDic = responceData[@"data"];
//        NSString *toUid = resDic[@"toUidOrGroupId"];
//        LGMessage *systemMsg = [[LGMessage alloc] init];
//        systemMsg.text = @"消息已成功发送，但被对方拒绝";
//        systemMsg.fromUid = toUid;
//        systemMsg.toUidOrGroupId = USERINFO.userID;
//        systemMsg.type = MessageTypeSystem;
//        systemMsg.msgid = resDic[@"msgid"];
//        systemMsg.conversionType = ConversionTypeSingle;
//        systemMsg.timeStamp = [NSDate currentTimeStamp];
//        [FMDBShareManager saveMessage:systemMsg toConverseID:toUid];
//        
//        NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
//        userInfo[@"message"] = systemMsg;
//        [[NSNotificationCenter defaultCenter] postNotificationName:kRecieveNewMessage object:nil userInfo:userInfo];
//    }
//    else if ([actType isEqualToString:@"dofriend"]){    //对方同意我的好友请求
//        
//        NSDictionary *resDic = responceData[@"data"];
//        NSString *friendId = resDic[@"frienduid"];
//        
//        //从网络加载新好友资料，存入数据库好友表  ->  然后添加系统消息 "xx通过了你的朋友验证请求,现在可以开始聊天了。" 到数据库
//        [self addNewFriendToSqilt:friendId];
//    }
//    else if ([actType isEqualToString:@"noallow"]){     //收到 不让对方看自己朋友圈 回调  （本地删除uid对应的朋友圈）
//        NSDictionary *resDic = responceData[@"data"];
//        NSString *friendId = resDic[@"delUid"];
//        NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
//        userInfo[@"deleteUid"] = friendId;
//        [[NSNotificationCenter defaultCenter] postNotificationName:K_NotLookMyCircleNotification object:nil userInfo:userInfo];
//    }
//}

}

//收到从群组删除用户 actuid:操作者id   uids:被删除用户的id
- (void)deleteGroupUser:(NSString *)groupId actUid:(NSString *)actUid uids:(NSString *)uids{
    
        LGMessage *systemMsg = [[LGMessage alloc] init];
        //从群表cha用户数据
        NSArray *uidsArr = [uids componentsSeparatedByString:@","];
        NSMutableArray *names = [NSMutableArray array];
        NSMutableArray *models = [NSMutableArray array];
        for (NSString *uid in uidsArr) {
            GroupUserModel *model = [FMDBShareManager getGroupMemberWithMemberId:uid andConverseId:groupId];
            if (!model.friend_nick.length) {
                continue ;
            }
            model.memberGroupState = YES;
            [names addObject:model.friend_nick];
            [models addObject:model];
        }
        NSString *usersName = [names componentsJoinedByString:@","];
        if ([actUid isEqualToString:USERINFO.userID]) { //如果自己是操作者
            systemMsg.text = [NSString stringWithFormat:@"你将\"%@\"移出了群聊",usersName];
        }else{
            GroupUserModel *model = [FMDBShareManager getGroupMemberWithMemberId:actUid andConverseId:groupId];
//            GroupUserModel *model = [self getGroupUser:actUid fromArr:groupUsers];
            systemMsg.text = [NSString stringWithFormat:@"你被\"%@\"移出了群聊",model.friend_nick];
            
            //将状态改为 被剔出群
            [FMDBShareManager saveAllGroupMemberWithArray:models andGroupChatId:groupId withComplationBlock:nil];
        }
        
        //发送系统消息
        systemMsg.actType = ActTypeDeluserfromgroup;
        systemMsg.fromUid = USERINFO.userID;
        systemMsg.toUidOrGroupId = groupId;
        systemMsg.type = MessageTypeSystem;
        systemMsg.msgid = [NSString generateMessageID];
        systemMsg.conversionType = ConversionTypeGroupChat;
        systemMsg.timeStamp = [NSDate currentTimeStamp];
        
        [FMDBShareManager saveGroupChatMessage:systemMsg andConverseId:groupId];
        
        //发送通知，即时更新相应的页面
        NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
        userInfo[@"message"] = systemMsg;
        [[NSNotificationCenter defaultCenter] postNotificationName:kRecieveNewMessage object:nil userInfo:userInfo];
}

//从群成员数组中取出对应id的用户数据模型
- (GroupUserModel *)getGroupUser:(NSString *)userId fromArr:(NSArray *)array{
    GroupUserModel *userModel = nil;
    for (GroupUserModel *model in array) {
        if ([model.userId isEqualToString:userId]) {
            userModel = model;
            break;
        }
    }
    return userModel;
}

//收到拉人进群消息  actuid:操作者id   uids:被邀请用户的id   //扫描二维码加群，生成二维码用户的id
- (void)updateGroupNumber:(NSString *)groupId actUid:(NSString *)actUid uids:(NSString *)uids jid:(NSString *)jid{
    
    [self gengrateGroupInfo:groupId completion:^(NSArray *groupUsers) {
        
        LGMessage *systemMsg = [[LGMessage alloc] init];
        
        //操作者名字
//        GroupUserModel *actModel = [FMDBShareManager getGroupMemberWithMemberId:actUid andConverseId:groupId];
        GroupUserModel *actModel = [self getGroupUser:actUid fromArr:groupUsers];
        NSString *actName = actModel.friend_nick;
        
        NSArray *copyArr = [uids componentsSeparatedByString:@","];     //拷贝一份
        NSMutableArray *uidsArr = [copyArr mutableCopy];
        
        //剔除操作者的id
        for (NSString *userid in copyArr) {
            if ([userid isEqualToString:actUid]) {
                [uidsArr removeObject:userid];
            }
        }
        
        NSMutableArray *namesArr = [NSMutableArray array];
        //拼接被邀请者名字
        for (NSString *userId in uidsArr) {
//            GroupUserModel *userModel = [FMDBShareManager getGroupMemberWithMemberId:userId andConverseId:groupId];
            GroupUserModel *userModel = [self getGroupUser:userId fromArr:groupUsers];
            if (!userModel.friend_nick.length) {
                continue;
            }
            [namesArr addObject:userModel.friend_nick];
        }
        NSString *usersNames = [namesArr componentsJoinedByString:@","];
        
        if ([actUid isEqualToString:uids]){   //通过扫描二维码进群
//            GroupUserModel *jModel = [FMDBShareManager getGroupMemberWithMemberId:jid andConverseId:groupId];
            GroupUserModel *jModel = [self getGroupUser:jid fromArr:groupUsers];

            if ([actUid isEqualToString:USERINFO.userID]) { //自己
                systemMsg.text = [NSString stringWithFormat:@"你通过扫描\"%@\"分享的二维码加入了群聊",jModel.friend_nick];
            }else{
                if (![jid isKindOfClass:[NSNull class]]) {
                    if ([jid isEqualToString:USERINFO.userID]) {
                        systemMsg.text = [NSString stringWithFormat:@"\"%@\"通过扫描你分享的二维码加入了群聊",actName];
                    }else{
                        systemMsg.text = [NSString stringWithFormat:@"\"%@\"通过扫描\"%@\"分享的二维码加入了群聊",actName,jModel.friend_nick];
                    }
                }else{
                    systemMsg.text = [NSString stringWithFormat:@"\"%@\"通过扫描二维码加入了群聊",actName];
                }
            }
        }else{
            if ([actUid isEqualToString:USERINFO.userID]) { //如果自己是操作者
                
                systemMsg.text = [NSString stringWithFormat:@"你邀请\"%@\"加入了群聊",usersNames];
            }else{      //被拉进群
                BOOL containMe = NO;    //被邀请人是否包含自己
                
                NSMutableArray *bondingArr = [uidsArr mutableCopy];
                
                for (NSString *auserId in uidsArr) { //被邀请人的uid
                    if ([auserId isEqualToString:USERINFO.userID]) {     //如果自己被邀请
                        containMe = YES;
                        [bondingArr removeObject:auserId];
                    }
                    
                    NSString *tbondName = nil;  //系统提示消息拼接姓名
                    if (bondingArr.count == 0) {    //被邀请者只有自己一个人
                        tbondName = @"你";
                    }else{
                        //拼接我和被邀请人的姓名
                        NSMutableArray *bondNamesArr = [NSMutableArray array];
                        for (NSString *userId in bondingArr) {
                            
                            GroupUserModel *userModel = [self getGroupUser:userId fromArr:groupUsers];
                            if (!userModel.userId.length) {
                                continue;
                            }
                            [bondNamesArr addObject:userModel.friend_nick];
                        }
                        NSString *bondName = [bondNamesArr componentsJoinedByString:@","];
                        tbondName = [NSString stringWithFormat:@"你和\"%@\"",bondName];
                    }
                    
                    if (containMe) {
                        
                        systemMsg.text = [NSString stringWithFormat:@"\"%@\"邀请%@加入了群聊",actName,tbondName];
                        
                        //标记出席了当前群
                        GroupUserModel *usermodel = [self getGroupUser:USERINFO.userID fromArr:groupUsers];
                        
                        if (usermodel.userId.length) {
                            usermodel.memberGroupState = NO;
                            [FMDBShareManager saveAllGroupMemberWithArray:@[usermodel] andGroupChatId:groupId withComplationBlock:nil];
                        }
                        
                        //发送通知，即时标记出席了当前群
                        NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
                        LGMessage *tempMsg = [[LGMessage alloc] init];
                        tempMsg.actType = ActTypeDeluserfromgroup;
                        tempMsg.type = MessageTypeSystem;
                        userInfo[@"message"] = tempMsg;
                        [[NSNotificationCenter defaultCenter] postNotificationName:kRecieveNewMessage object:nil userInfo:userInfo];

                    }
                    else{
                        systemMsg.text = [NSString stringWithFormat:@"%@邀请\"%@\"加入了群聊",actName,usersNames];
                    }
                }
            }
        }
        //发送系统消息 你邀请"xx"加入群聊
        systemMsg.actType = ActTypeUpdategroupnum;
        systemMsg.fromUid = USERINFO.userID;
        systemMsg.toUidOrGroupId = groupId;
        systemMsg.type = MessageTypeSystem;
        systemMsg.msgid = [NSString generateMessageID];
        systemMsg.conversionType = ConversionTypeGroupChat;
        systemMsg.timeStamp = [NSDate currentTimeStamp];
        [FMDBShareManager saveGroupChatMessage:systemMsg andConverseId:groupId];
        
        //发送通知，即时更新相应的页面
        NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
        userInfo[@"message"] = systemMsg;
        [[NSNotificationCenter defaultCenter] postNotificationName:kRecieveNewMessage object:nil userInfo:userInfo];

    }];
}

//收到socket消息，更新群名称  userId : 修改群名的用户id
- (void)updateGroupName:(NSString *)groupName groupId:(NSString *)groupId userId:(NSString *)userId{
    
    //如果这个时候，本地还没有生成群成员表  先从网络加载群信息  存到本地
    if (![FMDBShareManager isConverseIsExist:groupId]) {
        //加载群信息
        [LGNetWorking getGroupInfo:USERINFO.sessionId groupId:groupId success:^(ResponseData *responseData) {
            if (responseData.code == 0) {
                //生成群聊数据模型
                [GroupChatModel mj_setupObjectClassInArray:^NSDictionary *{
                    return @{
                             @"groupUserVos":@"GroupUserModel"
                             };
                }];
                
                //新建一个群会话，插入数据库  (直接修改群名称)
                GroupChatModel *groupChatModel = [GroupChatModel mj_objectWithKeyValues:responseData.data];
                
                groupChatModel.groupName = groupName;
                [FMDBShareManager saveGroupChatInfo:groupChatModel andConverseID:groupChatModel.groupId];
                
                //保存系统消息到数据库
                GroupChatModel *chatModel = [FMDBShareManager getGroupChatMessageByGroupId:groupId];
                chatModel.groupName = groupName;
                [FMDBShareManager saveGroupChatInfo:chatModel andConverseID:groupId];
                
                //根据userId,查到修改群名称的用户名
                GroupUserModel *groupUserModel = [FMDBShareManager getGroupMemberWithMemberId:userId andConverseId:groupId];
                NSString *userName = groupUserModel.friend_nick;
                
                LGMessage *systemMsg = [[LGMessage alloc] init];
                systemMsg.actType = ActTypeRenamegroup;
                systemMsg.text = [NSString stringWithFormat:@"%@修改群名为\"%@\"",userName,groupName];
                systemMsg.fromUid = USERINFO.userID;
                systemMsg.toUidOrGroupId = groupId;
                systemMsg.type = MessageTypeSystem;
                systemMsg.msgid = [NSString generateMessageID];
                systemMsg.conversionType = ConversionTypeGroupChat;
                systemMsg.timeStamp = [NSDate currentTimeStamp];
                [FMDBShareManager saveGroupChatMessage:systemMsg andConverseId:groupId];
                
                //发送通知，即时更新相应的页面
                NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
                userInfo[@"message"] = systemMsg;
                userInfo[@"otherMsg"] = groupName;
                [[NSNotificationCenter defaultCenter] postNotificationName:kRecieveNewMessage object:nil userInfo:userInfo];
                
            }
        } failure:^(ErrorData *error) {
            
        }];
    }else{
        //已经有群信息，直接更新群名称  然后插入系统消息到数据库
        GroupChatModel *chatModel = [FMDBShareManager getGroupChatMessageByGroupId:groupId];
        chatModel.groupName = groupName;
        [FMDBShareManager saveGroupChatInfo:chatModel andConverseID:groupId];
        
        //根据userId,查到修改群名称的用户名
        GroupUserModel *groupUserModel = [FMDBShareManager getGroupMemberWithMemberId:userId andConverseId:groupId];
        NSString *userName = groupUserModel.friend_nick;
        
        LGMessage *systemMsg = [[LGMessage alloc] init];
        systemMsg.actType = ActTypeRenamegroup;
        systemMsg.text = [NSString stringWithFormat:@"%@修改群名为\"%@\"",userName,groupName];
        systemMsg.fromUid = USERINFO.userID;
        systemMsg.toUidOrGroupId = groupId;
        systemMsg.type = MessageTypeSystem;
        systemMsg.msgid = [NSString generateMessageID];
        systemMsg.conversionType = ConversionTypeGroupChat;
        systemMsg.timeStamp = [NSDate currentTimeStamp];
        [FMDBShareManager saveGroupChatMessage:systemMsg andConverseId:groupId];
        
        //发送通知，即时更新相应的页面
        NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
        userInfo[@"message"] = systemMsg;
        userInfo[@"otherMsg"] = groupName;
        [[NSNotificationCenter defaultCenter] postNotificationName:kRecieveNewMessage object:nil userInfo:userInfo];
    }
}

//从网络获取用户名
- (void)getUserName:(NSString *)userId completion:(CompleteBlock)block{
    [LGNetWorking getFriendInfo:USERINFO.sessionId userId:userId block:^(ResponseData *responseData) {
        if (responseData.code == 0) {
            ZhiMaFriendModel *friend = [ZhiMaFriendModel mj_objectWithKeyValues:responseData.data];
            block(friend.user_Name);
        }else{
            [LCProgressHUD showFailureText:responseData.msg];
        }
    } failure:^(ErrorData *error) {
        [LCProgressHUD showFailureText:error.msg];
    }];
}

//从网络加载新好友资料，存入数据库好友表  ->  然后添加系统消息 "xx通过了你的朋友验证请求,现在可以开始聊天了。" 到数据库
- (void)addNewFriendToSqilt:(NSString *)friendId{
    [LGNetWorking getFriendInfo:USERINFO.sessionId userId:friendId block:^(ResponseData *responseData) {
        if (responseData.code == 0) {
            ZhiMaFriendModel *friend = [ZhiMaFriendModel mj_objectWithKeyValues:responseData.data];
            
            //插入好友到数据库
            [FMDBShareManager saveUserMessageWithMessageArray:@[friend] withComplationBlock:nil andIsUpdata:YES];
            
            //添加系统消息
            [self addSystemMsgToSqlite:friend];
            
            //播放系统声音
            [[RBDMuteSwitch sharedInstance] setDelegate:self];
            [[RBDMuteSwitch sharedInstance] detectMuteSwitch];
            
        }else{
            [LCProgressHUD showFailureText:responseData.msg];
        }
    } failure:^(ErrorData *error) {
        [LCProgressHUD showFailureText:error.msg];
    }];
}

//添加系统消息"xx通过了你的朋友验证请求,现在可以开始聊天了。"
- (void)addSystemMsgToSqlite:(ZhiMaFriendModel *)friend{
    
    LGMessage *systemMsg = [[LGMessage alloc] init];
    systemMsg.text = [NSString stringWithFormat:@"%@通过了你的朋友验证请求,现在可以开始聊天了",friend.user_Name];
    systemMsg.fromUid = USERINFO.userID;
    systemMsg.toUidOrGroupId = friend.user_Id;
    systemMsg.type = MessageTypeSystem;
    systemMsg.msgid = [NSString generateMessageID];
    systemMsg.conversionType = ConversionTypeSingle;
    systemMsg.timeStamp = [NSDate currentTimeStamp];
    [FMDBShareManager saveMessage:systemMsg toConverseID:friend.user_Id];
    
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    userInfo[@"message"] = systemMsg;
    [[NSNotificationCenter defaultCenter] postNotificationName:kRecieveNewMessage object:nil userInfo:userInfo];
}

//收到拉人进群-- 消息处理
- (void)gengrateGroupInfo:(NSString *)groupId completion:(CompleteBlock)block{
    
    //加载群信息
    [LGNetWorking getGroupInfo:USERINFO.sessionId groupId:groupId success:^(ResponseData *responseData) {
        if (responseData.code == 0) {
            //生成群聊数据模型
            [GroupChatModel mj_setupObjectClassInArray:^NSDictionary *{
                return @{
                         @"groupUserVos":@"GroupUserModel"
                         };
            }];
            GroupChatModel *groupChatModel = [GroupChatModel mj_objectWithKeyValues:responseData.data];

            //如果存在群成员信息表 （通过是否存在群信息表判断）
            ConverseModel *model = [FMDBShareManager searchConverseWithConverseID:groupId andConverseType:ConversionTypeGroupChat];
            if (!model.converseId) {
                //异步存储群成员信息
                dispatch_async(dispatch_get_global_queue(0, 0), ^{
                        [FMDBShareManager saveAllGroupMemberWithArray:groupChatModel.groupUserVos andGroupChatId:groupId withComplationBlock:^(BOOL success) {
                        //存群信息
                        [FMDBShareManager saveGroupChatInfo:groupChatModel andConverseID:groupId];
                    }];
                });
            }

            block(groupChatModel.groupUserVos);
        }
    } failure:^(ErrorData *error) {
        
    }];
}

//插入离线群消息到本地数据库
- (void)addOfflineGroupMessage:(LGMessage *)message groupId:(NSString *)groupId{
    
    //判断数据库是否存在群成员表 （通过群信息表判断） -> 不存在 从网络加载数据  存到数据库
    //    ConverseModel *model = [FMDBShareManager searchConverseWithConverseID:groupId andConverseType:ConversionTypeGroupChat];
    if (![FMDBShareManager isConverseIsExist:groupId]) {
        //加载群信息
        [LGNetWorking getGroupInfo:USERINFO.sessionId groupId:groupId success:^(ResponseData *responseData) {
            if (responseData.code == 0) {
                //生成群聊数据模型
                [GroupChatModel mj_setupObjectClassInArray:^NSDictionary *{
                    return @{
                             @"groupUserVos":@"GroupUserModel"
                             };
                }];
                GroupChatModel *groupChatModel = [GroupChatModel mj_objectWithKeyValues:responseData.data];
                
                //开线程异步存群成员信息
//                dispatch_async(dispatch_get_global_queue(0, 0), ^{
//                    [FMDBShareManager saveAllGroupMemberWithArray:groupChatModel.groupUserVos andGroupChatId:groupId withComplationBlock:^(BOOL success) {
//                        dispatch_queue_t subQueue = dispatch_queue_create("com.dullgrass.serialQueue", DISPATCH_QUEUE_CONCURRENT);
//                        dispatch_sync(subQueue, ^{
                            //群成员保存完毕，保存群信息到数据库,新建会话，保存群消息记录
                            //保存群信息
                            [FMDBShareManager saveGroupChatInfo:groupChatModel andConverseID:groupChatModel.groupId];
                            //创建会话
                            ConverseModel *converseModel  = [[ConverseModel alloc] init];
                            converseModel.time = [NSDate cTimestampFromString:groupChatModel.create_time format:@"yyyy-MM-dd HH:mm:ss"];
                            converseModel.converseType = 1;
                            converseModel.converseId = groupChatModel.groupId;
                            converseModel.unReadCount = 0;
                            converseModel.converseName = groupChatModel.groupName;
                            converseModel.converseHead_photo = groupChatModel.groupAvtar;
                            converseModel.lastConverse = @" ";
                            [FMDBShareManager saveConverseListDataWithModel:converseModel withComplationBlock:nil];
                            //保存群消息到数据库
                            [FMDBShareManager saveGroupChatMessage:message andConverseId:message.toUidOrGroupId];
                            
                            //发送通知，刷新会话列表
//                            NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
//                            userInfo[@"message"] = message;
//                            [[NSNotificationCenter defaultCenter] postNotificationName:kRecieveNewMessage object:nil userInfo:userInfo];
                
//                        });
//                    }];
//                });
            }
        } failure:^(ErrorData *error) {
            
        }];
    }else{
        //保存群消息到数据库
        [FMDBShareManager saveGroupChatMessage:message andConverseId:message.toUidOrGroupId];
        
        //发送通知，刷新会话列表
//        NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
//        userInfo[@"message"] = message;
//        [[NSNotificationCenter defaultCenter] postNotificationName:kRecieveNewMessage object:nil userInfo:userInfo];
    }
    //群消息直接在这里发通知，就不在收到新消息处发送通知了  所以返回no
}


//插入一条群消息到本地数据库
- (BOOL)addGroupMessage:(LGMessage *)message groupId:(NSString *)groupId{
    
    //判断数据库是否存在群成员表 （通过群信息表判断） -> 不存在 从网络加载数据  存到数据库
//    ConverseModel *model = [FMDBShareManager searchConverseWithConverseID:groupId andConverseType:ConversionTypeGroupChat];
    if (![FMDBShareManager isConverseIsExist:groupId]) {
        //加载群信息
        [LGNetWorking getGroupInfo:USERINFO.sessionId groupId:groupId success:^(ResponseData *responseData) {
            if (responseData.code == 0) {
                //生成群聊数据模型
                [GroupChatModel mj_setupObjectClassInArray:^NSDictionary *{
                    return @{
                             @"groupUserVos":@"GroupUserModel"
                             };
                }];
                GroupChatModel *groupChatModel = [GroupChatModel mj_objectWithKeyValues:responseData.data];
                
                //开线程异步存群成员信息
                dispatch_async(dispatch_get_global_queue(0, 0), ^{
                    [FMDBShareManager saveAllGroupMemberWithArray:groupChatModel.groupUserVos andGroupChatId:groupId withComplationBlock:^(BOOL success) {
                        dispatch_queue_t subQueue = dispatch_queue_create("com.dullgrass.serialQueue", DISPATCH_QUEUE_CONCURRENT);
                        dispatch_sync(subQueue, ^{
                            //群成员保存完毕，保存群信息到数据库,新建会话，保存群消息记录
                            //保存群信息
                            [FMDBShareManager saveGroupChatInfo:groupChatModel andConverseID:groupChatModel.groupId];
                            //创建会话
                            ConverseModel *converseModel  = [[ConverseModel alloc] init];
                            converseModel.time = [NSDate cTimestampFromString:groupChatModel.create_time format:@"yyyy-MM-dd HH:mm:ss"];
                            converseModel.converseType = 1;
                            converseModel.converseId = groupChatModel.groupId;
                            converseModel.unReadCount = 0;
                            converseModel.converseName = groupChatModel.groupName;
                            converseModel.converseHead_photo = groupChatModel.groupAvtar;
                            converseModel.lastConverse = @" ";
                            [FMDBShareManager saveConverseListDataWithModel:converseModel withComplationBlock:nil];
                            //保存群消息到数据库
                            [FMDBShareManager saveGroupChatMessage:message andConverseId:message.toUidOrGroupId];
                            
                            //发送通知，刷新会话列表
                            NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
                            userInfo[@"message"] = message;
                            [[NSNotificationCenter defaultCenter] postNotificationName:kRecieveNewMessage object:nil userInfo:userInfo];

                        });
                    }];
                });
            }
        } failure:^(ErrorData *error) {
            
        }];
    }else{
        //保存群消息到数据库
        [FMDBShareManager saveGroupChatMessage:message andConverseId:message.toUidOrGroupId];
        
        //发送通知，刷新会话列表
        NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
        userInfo[@"message"] = message;
        [[NSNotificationCenter defaultCenter] postNotificationName:kRecieveNewMessage object:nil userInfo:userInfo];
    }
    //群消息直接在这里发通知，就不在收到新消息处发送通知了  所以返回no
    return NO;
}

#pragma mark - 封装消息操作指令
/**
 *  重新发送消息 -->发送socket消息 、更新数据库该条消息数据
 */
- (void)reSendMessage:(LGMessage *)message{
    
    //处理过后的发送给socket的message
    LGMessage *sendMsg = [[LGMessage alloc] init];
    
    
    //语音消息 -- 发送base64到socket服务器，存语音路径到本地数据库
    if (message.type == MessageTypeAudio) {
        
        //通过路径拿到音频文件
        NSString *sandboxPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *path = [NSString stringWithFormat:@"%@/%@",sandboxPath,message.text];
        NSData *data = [NSData dataWithContentsOfFile:path];
        
        //转换成base64编码
        NSString *base64 = [data base64EncodedStringWithOptions:0];
        
        //将text转换为base64 发送给socket
        sendMsg.toUidOrGroupId = message.toUidOrGroupId;
        sendMsg.fromUid = message.fromUid;
        sendMsg.type = message.type;
        sendMsg.msgid = message.msgid;
        sendMsg.conversionType = message.conversionType;
        sendMsg.timeStamp = message.timeStamp;
        sendMsg.text = base64;
        
    }
    //文本消息
    else if (message.type == MessageTypeText){
        sendMsg = message;
    }
    //图片消息
    else if (message.type == MessageTypeImage){
        sendMsg = message;
    }
    
    //根据网络状态-- 标记消息发送状态
    UserInfo *userInfo = [UserInfo shareInstance];
    if (userInfo.networkUnReachable) {
        message.sendStatus = NO;
    }else{
        message.sendStatus = YES;
    }
    
    //更新数据库该条消息 、socket发送消息
    BOOL success = [FMDBShareManager upDataMessageStatusWithMessage:message];
    if (success) {
        
        //发送消息状态回调通知
        NSDictionary *infoDic = @{@"message":message};
        [[NSNotificationCenter defaultCenter] postNotificationName:kSendMessageStateCall object:nil userInfo:infoDic];
        
        //插入数据库成功 - socket发送消息
        //根据消息模型生成固定格式数据包
        NSData *data = [self generateRequest:RequestTypeMessage uid:USERINFO.userID message:sendMsg];
        RHSocketPacketRequest *req = [[RHSocketPacketRequest alloc] init];
        req.object = data;
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationSocketPacketRequest object:req];
    }
}

//删除消息
- (void)deleteMessage:(LGMessage *)message{
    if (message) {
        [FMDBShareManager deleteMessageFormMessageTableByMessageID:message.msgid];
    }
}

//撤销消息 
- (void)undoMessage:(LGMessage *)message{
    NSData *data = [self generateRequest:RequestTypeUndo uid:0 message:message];
    RHSocketPacketRequest *req = [[RHSocketPacketRequest alloc] init];
    req.object = data;
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationSocketPacketRequest object:req];
}

//建群
- (void)createGtoup:(GroupActModel *)actModel{
    NSData *data = [self generateGroupActType:GroupActTypeCreate groupActModel:actModel];
    RHSocketPacketRequest *req = [[RHSocketPacketRequest alloc] init];
    req.object = data;
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationSocketPacketRequest object:req];
}

//邀请用户到群
- (void)addUserToGroup:(GroupActModel *)actModel{
    NSData *data = [self generateGroupActType:GroupActTypeAddUser groupActModel:actModel];
    RHSocketPacketRequest *req = [[RHSocketPacketRequest alloc] init];
    req.object = data;
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationSocketPacketRequest object:req];
}

//扫码进群
- (void)scanCodeToGroup:(GroupActModel *)actModel{
    NSData *data = [self generateGroupActType:GroupActTypeSaoma groupActModel:actModel];
    RHSocketPacketRequest *req = [[RHSocketPacketRequest alloc] init];
    req.object = data;
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationSocketPacketRequest object:req];
}

//从群组删除用户
- (void)delUserFromGroup:(GroupActModel *)actModel{
    NSData *data = [self generateGroupActType:GroupActTypeDelUser groupActModel:actModel];
    RHSocketPacketRequest *req = [[RHSocketPacketRequest alloc] init];
    req.object = data;
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationSocketPacketRequest object:req];
}

//退出群
- (void)delGroup:(GroupActModel *)actModel{
    NSData *data = [self generateGroupActType:GroupActTypeDelGroup groupActModel:actModel];
    RHSocketPacketRequest *req = [[RHSocketPacketRequest alloc] init];
    req.object = data;
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationSocketPacketRequest object:req];
}

//群重命名
- (void)renameGroup:(GroupActModel *)actModel{
    NSData *data = [self generateGroupActType:GroupActTypeReName groupActModel:actModel];
    RHSocketPacketRequest *req = [[RHSocketPacketRequest alloc] init];
    req.object = data;
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationSocketPacketRequest object:req];
}

//添加好友
- (void)addFriend:(ZhiMaFriendModel *)friendModel{
    NSData *data = [self generateFriendActType:FriendActTypeAdd friendModel:friendModel];
    RHSocketPacketRequest *req = [[RHSocketPacketRequest alloc] init];
    req.object = data;
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationSocketPacketRequest object:req];
}

//同意好友请求
- (void)agreeFriendRequest:(ZhiMaFriendModel *)friendModel{
    NSData *data = [self generateFriendActType:FriendActTypeAgreee friendModel:friendModel];
    RHSocketPacketRequest *req = [[RHSocketPacketRequest alloc] init];
    req.object = data;
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationSocketPacketRequest object:req];
}
//
////加入黑名单
//- (void)dragToBlack:(NSString *)friendId{
//    NSData *data = [self generateFriendActType:FriendActTypeBlack friendId:friendId];
//    RHSocketPacketRequest *req = [[RHSocketPacketRequest alloc] init];
//    req.object = data;
//    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationSocketPacketRequest object:req];
//}
//
////用户修改资料
//- (void)updateProfile{
//    NSData *data = [self generateFriendActType:FriendActTypeUpdate friendId:USERINFO.userID];
//    RHSocketPacketRequest *req = [[RHSocketPacketRequest alloc] init];
//    req.object = data;
//    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationSocketPacketRequest object:req];
//}

//不让对方看自己的朋友圈
- (void)notAllowFriendCircle:(NSString *)friendId{
    NSData *data = [self generateRequest:RequestTypeNotLookCircle uid:friendId message:nil];
    RHSocketPacketRequest *req = [[RHSocketPacketRequest alloc] init];
    req.object = data;
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationSocketPacketRequest object:req];
}

//群用户更新昵称
- (void)groupUserUpdateName:(NSString *)name groupId:(NSString *)groupId{
    NSData *data = [self generateGroupUserUpdateName:name groupId:groupId uid:USERINFO.userID];
    RHSocketPacketRequest *req = [[RHSocketPacketRequest alloc] init];
    req.object = data;
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationSocketPacketRequest object:req];
}

//根据消息操作类型- 按照固定格式生成数据请求包 （不需要uid时直接传0，不需要message直接传nil）
- (NSData *)generateRequest:(RequestType)type uid:(NSString *)uid message:(LGMessage *)message{
    
    NSMutableDictionary *request = [NSMutableDictionary dictionary];
    //data字段里面的数据
    NSMutableDictionary *dataDic = [NSMutableDictionary dictionary];
    
    NSString *sign = nil;
    
    switch (type) {
        case RequestTypeLogin:{     //登录类型
            //拼接控制器和方法名
            request[@"controller_name"] = @"LoginController";
            request[@"method_name"] = @"bind_uid";
            
            //生成签名
            NSString *str = [NSString stringWithFormat:@"controller_name=LoginController&method_name=bind_uid&fromUid=%@&%@",uid,APIKEY];
            sign = [[str md5Encrypt] uppercaseString];
            //生成data
            dataDic[@"fromUid"] = uid;
            dataDic[@"sign"] = sign;

        }
            break;
            
        case RequestTypeHeart:{     //心跳包类型
            //拼接控制器和方法名
            request[@"controller_name"] = @"HeartbeatController";
            request[@"method_name"] = @"check";
            dataDic[@"fromUid"] = uid;
            
        }
            
            break;
            
        case RequestTypeMessage:{      //消息类型
            //拼接控制器和方法名
            request[@"controller_name"] = @"MessageController";
            request[@"method_name"] = @"sendmsg";
            //生成签名
            NSString *str = [NSString stringWithFormat:@"controller_name=MessageController&method_name=sendmsg&converseId=%@&converseLogo=%@&converseName=%@&converseType=%zd&fromUid=%@&fromUserName=%@&fromUserPhoto=%@&holderImageUrl=%@&link=%@&msgid=%@&subject=%@&text=%@&toUidOrGroupId=%@&type=%ld&videoUrl=%@&voiceLength=%ld&%@",message.converseId,message.converseLogo,message.converseName,message.conversionType,message.fromUid,message.fromUserName,message.fromUserPhoto,message.holderImageUrlString,message.link,message.msgid,message.subject,message.text,message.toUidOrGroupId,(long)message.type,message.videoDownloadUrl,(long)message.audioLength,APIKEY];
            sign = [[str md5Encrypt] uppercaseString];
            //拼接消息
            dataDic[@"converseId"] = message.converseId;
            dataDic[@"converseLogo"] = message.converseLogo;
            dataDic[@"converseName"] = message.converseName;
            dataDic[@"converseType"] = @(message.conversionType);
            dataDic[@"fromUid"] = message.fromUid;
            dataDic[@"fromUserName"] = message.fromUserName;
            dataDic[@"fromUserPhoto"] = message.fromUserPhoto;
            dataDic[@"holderImageUrl"] = message.holderImageUrlString;
            dataDic[@"link"] = message.link;
            dataDic[@"msgid"] = message.msgid;
            dataDic[@"subject"] = message.subject;
            dataDic[@"text"] = message.text;
            dataDic[@"toUidOrGroupId"] = message.toUidOrGroupId;
            dataDic[@"type"] = @(message.type);
            dataDic[@"videoUrl"] = message.videoDownloadUrl;
            dataDic[@"voiceLength"] = @(message.audioLength);
            dataDic[@"sign"] = sign;
            
        }
            
            break;
            
        case RequestTypeUndo:{      //撤销消息
            //拼接控制器和方法名
            request[@"controller_name"] = @"MessageController";
            request[@"method_name"] = @"undo";
            //生成签名
            NSString *str = [NSString stringWithFormat:@"controller_name=MessageController&method_name=undo&acttype=%zd&converseId=%@&converseType=%zd&fromUid=%@&fromUserName=%@&fromUserPhoto=%@&msgid=%@&toUidOrGroupId=%@&type=%ld&%@",message.actType,message.converseId,message.conversionType,message.fromUid,message.fromUserName,message.fromUserPhoto,message.msgid,message.toUidOrGroupId,(long)message.type,APIKEY];
            sign = [[str md5Encrypt] uppercaseString];
            //拼接消息
            dataDic[@"acttype"] = @(message.actType);
            dataDic[@"converseId"] = message.converseId;
            dataDic[@"converseType"] = @(message.conversionType);
            dataDic[@"fromUid"] = message.fromUid;
            dataDic[@"fromUserName"] = message.fromUserName;
            dataDic[@"fromUserPhoto"] = message.fromUserPhoto;
            dataDic[@"msgid"] = message.msgid;
            dataDic[@"toUidOrGroupId"] = message.toUidOrGroupId;
            dataDic[@"type"] = @(message.type);
            dataDic[@"sign"] = sign;
        }
            break;
            
        case RequestTypeNotLookCircle:{
            //拼接控制器和方法名
            request[@"controller_name"] = @"MessageController";
            request[@"method_name"] = @"noAllowFriendCircle";
            //生成签名
            NSString *str = [NSString stringWithFormat:@"controller_name=MessageController&method_name=noAllowFriendCircle&fromUid=%@&toUid=%@&%@",USERINFO.userID,uid,APIKEY];
            sign = [[str md5Encrypt] uppercaseString];
            dataDic[@"fromUid"] = USERINFO.userID;
            dataDic[@"toUid"] = uid;
            dataDic[@"sign"] = sign;
        }
            break;
            
        default:
            break;
    }
    //拼接完整的request包
    request[@"data"] = dataDic;
    //请求包转换成json字符串
    return [[request mj_JSONString] dataUsingEncoding:NSUTF8StringEncoding];
}

//生成群操作相关的消息数据请求包
- (NSData *)generateGroupActType:(GroupActType)type groupActModel:(GroupActModel *)model{
    
    NSMutableDictionary *request = [NSMutableDictionary dictionary];
    //data字段里面的数据
    NSMutableDictionary *dataDic = [NSMutableDictionary dictionary];
    
    NSString *controllerName = @"UserController";
    NSString *methodName = nil;
    
    switch (type) {
            
        //建群 邀请用户到群 扫码进群
        case GroupActTypeCreate:
        case GroupActTypeAddUser:
        case GroupActTypeSaoma:
        {
            methodName = @"addUserToGroup";
        }
            
            break;
        case GroupActTypeDelUser:{      //从群组删除用户
            methodName = @"delUserFromGroup";
        }
            
            break;
        case GroupActTypeDelGroup:{     //删除群组
            methodName = @"delGroup";
        }
            
            break;
        case GroupActTypeReName:{       //群重命名
            methodName = @"renameGroup";
            
        }
            break;
        case GroupActTypeUpdateName:{
            methodName = @"renameGroupNickname";
        }
            break;
        default:
            break;
    }
    
    //拼接控制器和方法名
    request[@"controller_name"] = controllerName;
    request[@"method_name"] = methodName;
    NSString *str = nil;
    //创群、拉人、扫码拉人
    if (type == GroupActTypeCreate || type == GroupActTypeAddUser || type == GroupActTypeSaoma){
        if (type == GroupActTypeCreate) {
            dataDic[@"act"]= @"create";
        }else if (type == GroupActTypeAddUser){
            dataDic[@"act"] = @"add";
        }else{
            dataDic[@"act"] = @"scan";
        }
        dataDic[@"fromUid"] = model.fromUid;
        dataDic[@"converseLogo"] = model.converseLogo;
        dataDic[@"converseName"] = model.converseName;
        dataDic[@"fromUserName"] = model.fromUsername;
        dataDic[@"fromUserPhoto"] = model.fromUserPhoto;
        dataDic[@"groupid"] = model.groupId;
        dataDic[@"groupLogo"] = model.groupLogo;
        dataDic[@"groupName"] = model.groupName;
        dataDic[@"uids"] = model.uids;
        dataDic[@"usernames"]= model.usernames;
        str = [NSString stringWithFormat:@"controller_name=%@&method_name=%@&act=%@&converseLogo=%@&converseName=%@&fromUid=%@&fromUserName=%@&fromUserPhoto=%@&groupLogo=%@&groupName=%@&groupid=%@&uids=%@&usernames=%@&%@",controllerName,methodName,dataDic[@"act"],model.converseLogo,model.converseName,model.fromUid,model.fromUsername,model.fromUserPhoto,model.groupLogo,model.groupName,model.groupId,model.uids,model.usernames,APIKEY];
    }else if (type == GroupActTypeDelUser){
        dataDic[@"fromUid"] = model.fromUid;
        dataDic[@"fromUserName"] = model.fromUsername;
        dataDic[@"groupid"] = model.groupId;
        dataDic[@"groupLogo"] = model.groupLogo;
        dataDic[@"groupName"] = model.groupName;
        dataDic[@"uids"] = model.uids;
        dataDic[@"usernames"]= model.usernames;
        
        str = [NSString stringWithFormat:@"controller_name=%@&method_name=%@&fromUid=%@&fromUserName=%@&groupLogo=%@&groupName=%@&groupid=%@&uids=%@&usernames=%@&%@",controllerName,methodName,model.fromUid,model.fromUsername,model.groupLogo,model.groupName,model.groupId,model.uids,model.usernames,APIKEY];
    }else if (type == GroupActTypeDelGroup || type == GroupActTypeReName){
        dataDic[@"fromUid"] = model.fromUid;
        dataDic[@"fromUserName"] = model.fromUsername;
        dataDic[@"groupid"] = model.groupId;
        dataDic[@"groupLogo"] = model.groupLogo;
        dataDic[@"groupName"] = model.groupName;

        str = [NSString stringWithFormat:@"controller_name=%@&method_name=%@&fromUid=%@&fromUserName=%@&groupLogo=%@&groupName=%@&groupid=%@&%@",controllerName,methodName,model.fromUid,model.fromUsername,model.groupLogo,model.groupName,model.groupId,APIKEY];
    }

    //生成签名
    NSString *sign = [[str md5Encrypt] uppercaseString];
    dataDic[@"sign"] = sign;
    //拼接完整的request包
    request[@"data"] = dataDic;
    //请求包转换成json字符串
    return [[request mj_JSONString] dataUsingEncoding:NSUTF8StringEncoding];
}

- (NSData *)generateGroupUserUpdateName:(NSString *)name groupId:(NSString *)groupId uid:(NSString *)uid{
    NSMutableDictionary *request = [NSMutableDictionary dictionary];
    //data字段里面的数据
    NSMutableDictionary *dataDic = [NSMutableDictionary dictionary];
    
    NSString *controllerName = @"UserController";
    NSString *methodName = @"renameGroupNickname";
    
    //拼接控制器和方法名
    request[@"controller_name"] = controllerName;
    request[@"method_name"] = methodName;
    
    dataDic[@"uid"]= uid;
    dataDic[@"groupid"] = groupId;
    dataDic[@"group_user_nick"] = name;
    NSString *str = [NSString stringWithFormat:@"controller_name=%@&method_name=%@&groupid=%@&group_user_nick=%@&%@",controllerName,methodName,groupId,name,APIKEY];
    //生成签名
    NSString *sign = [[str md5Encrypt] uppercaseString];
    dataDic[@"sign"] = sign;
    //拼接完整的request包
    request[@"data"] = dataDic;
    //请求包转换成json字符串
    return [[request mj_JSONString] dataUsingEncoding:NSUTF8StringEncoding];

}

//生成好友操作相关的消息数据包
- (NSData *)generateFriendActType:(FriendActType)type friendModel:(ZhiMaFriendModel *)friend{
    NSMutableDictionary *request = [NSMutableDictionary dictionary];
    //data字段里面的数据
    NSMutableDictionary *dataDic = [NSMutableDictionary dictionary];
    
    NSString *controllerName = @"UserController";
    NSString *methodName = nil;

    switch (type) {
        case FriendActTypeAdd:{     //添加好友
            methodName = @"addFriend";
        }
            
            break;
        case FriendActTypeAgreee:{     //同意好友请求
            methodName = @"doFriend";
        }
            
            break;
        case FriendActTypeBlack:{   //加入黑名单
            methodName = @"backlist";
        }
            
            break;
        case FriendActTypeUpdate:{  //好友资料更新
            methodName = @"update";
        }
            
            break;
            
        default:
            break;
    }
    
    //拼接控制器和方法名
    request[@"controller_name"] = controllerName;
    request[@"method_name"] = methodName;
    //生成签名
    NSString *str = nil;
    if (type == FriendActTypeAdd) {
        dataDic[@"fromUid"] = USERINFO.userID;
        dataDic[@"fromUserName"] = USERINFO.username;
        dataDic[@"fromUserPhoto"] = USERINFO.head_photo;
        dataDic[@"frienduid"] = friend.user_Id;
        dataDic[@"friendUserName"] = friend.user_Name;
        str = [NSString stringWithFormat:@"controller_name=%@&method_name=%@&friendUserName=%@&frienduid=%@&fromUid=%@&fromUserName=%@&fromUserPhoto=%@&%@",controllerName,methodName,friend.user_Name,friend.user_Id,USERINFO.userID,USERINFO.username,USERINFO.head_photo,APIKEY];
    }else if (type == FriendActTypeAgreee){
        dataDic[@"fromUid"] = USERINFO.userID;
        dataDic[@"fromUserName"] = USERINFO.username;
//        dataDic[@"fromUserPhoto"] = USERINFO.head_photo;
        dataDic[@"frienduid"] = friend.user_Id;
        str = [NSString stringWithFormat:@"controller_name=%@&method_name=%@&frienduid=%@&fromUid=%@&fromUserName=%@&%@",controllerName,methodName,friend.user_Id,USERINFO.userID,USERINFO.username,APIKEY];
    }
    else{
        str = [NSString stringWithFormat:@"controller_name=%@&method_name=%@&frienduid=%@&uid=%@&%@",controllerName,methodName,friend.user_Id,USERINFO.userID,APIKEY];
        dataDic[@"frienduid"] = friend.user_Id;
        dataDic[@"uid"] = USERINFO.userID;

    }
    NSString *sign = [[str md5Encrypt] uppercaseString];
    dataDic[@"sign"] = sign;
    //拼接完整的request包
    request[@"data"] = dataDic;
    //请求包转换成json字符串
    return [[request mj_JSONString] dataUsingEncoding:NSUTF8StringEncoding];
}

/** 生成随机messageID */
- (NSString *)generateMessageID
{
    static int kNumber = 8;
    
    NSString *sourceStr = @"0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    NSMutableString *resultStr = [[NSMutableString alloc] init];
    srand((unsigned int)time(0));
    for (int i = 0; i < kNumber; i++)
    {
        unsigned index = rand() % [sourceStr length];
        NSString *oneStr = [sourceStr substringWithRange:NSMakeRange(index, 1)];
        [resultStr appendString:oneStr];
    }
    return resultStr;
}

//播放系统声音
- (void)isMuted:(BOOL)muted{
    if (muted) {
        //开启静音模式
        self.myPlaySounde = [[JFMyPlayerSound alloc] initSystemShake];
    }else{
        //关闭静音模式
        self.myPlaySounde = [[JFMyPlayerSound alloc] initSystemSoundWithName:@"sms-received1" SoundType:@"caf"];
    }
    
    if (USERINFO.newMessageNotify) {
        if (USERINFO.newMessageVoiceNotify) {
            if (USERINFO.newMessageShakeNotify) {   //声音跟振动
                if (muted) {
                    [self.myPlaySounde play];
                }else{
                    [self.myPlaySounde play];
                    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
                }
            }else{  //只有声音
                [self.myPlaySounde play];
            }
        }else{
            if (USERINFO.newMessageShakeNotify) {   //只有振动提醒
                AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
            }
        }
    }
}

- (NSMutableArray *)offlineMessages{
    if (!_offlineMessages) {
        _offlineMessages = [NSMutableArray array];
    }
    return _offlineMessages;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
