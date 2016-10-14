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


@interface SocketManager ()

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
        
    } else {
        UserInfo *userInfo = [UserInfo shareInstance];
        userInfo.networkUnReachable = YES;
    }
}


//手动断开socket
-(void)disconnect{
    [[RHSocketService sharedInstance] stopService];
}

//发送消息
- (void)sendMessage:(LGMessage *)message{
    
    
    //处理过后的发送给socket的message
    LGMessage *sendMsg = [[LGMessage alloc] init];
    
    //通过消息的发送状态判断是否为重发的消息
    if (!message.sendStatus) {
        
    }else{      //正常发送消息 -->发送socket消息、插入新消息到数据库
        
    }
    
    //语音消息 -- 发送base64到socket服务器，存语音路径到本地数据库
    if (message.type == MessageTypeAudio) {
        
        //通过路径拿到音频文件
        NSString *sandboxPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *path = [NSString stringWithFormat:@"%@/%@",sandboxPath,message.text];
        NSData *data = [NSData dataWithContentsOfFile:path];
        
        //转换成base64编码
//        NSString *base64 = [NSData base64StringFromData:data];
        NSString *base64 = [data base64EncodedStringWithOptions:0];
        
        //将text转换为base64 发送给socket
        sendMsg.toUidOrGroupId = message.toUidOrGroupId;
        sendMsg.fromUid = message.fromUid;
        sendMsg.type = message.type;
        sendMsg.msgid = message.msgid;
        sendMsg.isGroup = message.isGroup;
        sendMsg.timeStamp = message.timeStamp;
        sendMsg.text = base64;
        sendMsg.audioLength = message.audioLength;
        
        
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
    
    //插入消息数据库
    BOOL success = NO;
    if (message.isGroup) {
        success = [FMDBShareManager saveGroupChatMessage:message andConverseId:message.toUidOrGroupId];
    } else {
        success = [FMDBShareManager saveMessage:message toConverseID:message.toUidOrGroupId];
    }

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
    if (data.length) {
        //解析消息指令类型
        NSString *actType = responceData[@"acttype"];
        
        //有相同的用户登录
        if ([actType isEqualToString:@"kickuser"]) {
            //发送通知，执行被迫下线操作
            [[NSNotificationCenter defaultCenter] postNotificationName:kOtherLogin object:nil];
        }
        else if ([actType isEqualToString:@"normal"]) {      //普通消息 -> 插入数据库
            
            LGMessage *message = [[LGMessage alloc] init];
            message = [message mj_setKeyValues:responceData[@"data"]];
            
            //语音消息，先解码，然后根据时间戳存到本地，拿到路径存到数据库
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
            //文本消息 -> 插入数据库
            else if (message.type == MessageTypeText){
#warning 留着进行相关扩展操作

            }
            
            else if (message.type == MessageTypeImage){

            }
            
            //将消息插入数据库，并更新会话列表  (根据是否为群聊，插入不同的表)
            BOOL success = NO;
            if (message.isGroup) {  //如果是群消息 先从http请求群信息 加入本地数据库

                success = [self addGroupMessage:message groupId:message.toUidOrGroupId];
            } else {
                success = [FMDBShareManager saveMessage:message toConverseID:message.fromUid];
            }
            
            if (success) {
                //发送通知
                NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
                userInfo[@"message"] = message;
                [[NSNotificationCenter defaultCenter] postNotificationName:kRecieveNewMessage object:nil userInfo:userInfo];
            }
            
        }
        else if ([actType isEqualToString:@"addfriend"]){   //好友请求
            NSDictionary *resDic = responceData[@"data"];
            ZhiMaFriendModel *friend = [[ZhiMaFriendModel alloc] init];
            friend.user_Id = resDic[@"fromuid"];
            friend.user_Name = resDic[@"username"];
            friend.user_Head_photo = resDic[@"head_photo"];
            NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
            userInfo[@"friend"] = friend;
            //生成一个好友模型发送通知
            [[NSNotificationCenter defaultCenter] postNotificationName:kNewFriendRequest object:nil userInfo:userInfo];
        }
        else if ([actType isEqualToString:@"updatefriend"]){   //更新好友数据
            
        }
        else if ([actType isEqualToString:@"updategroupnum"]){   //更新群用户数
            NSDictionary *resDic = responceData[@"data"];
            NSString *groupId = resDic[@"groupid"];
            NSString *actuid = resDic[@"actuid"];
            NSString *uids = resDic[@"uids"];
            //拉人进群相关操作
            [self updateGroupNumber:groupId actUid:actuid uids:uids];
        }
        else if ([actType isEqualToString:@"deluserfromgroup"]){   //从群组中删除用户
            NSDictionary *resDic = responceData[@"data"];
            NSString *uids = resDic[@"uids"];   //移除好友的uid
            NSString *groupId = resDic[@"groupid"];
            NSString *actUid = resDic[@"actuid"];   //操作者uid
            
            [self deleteGroupUser:groupId actUid:actUid uids:uids];
        }
        else if ([actType isEqualToString:@"renamegroup"]){   //重命名群组
            //更新数据库群名称，添加一条系统消息"xx修改群名为"xxx""
            NSDictionary *resDic = responceData[@"data"];
            NSString *groupName = resDic[@"groupname"];
            NSString *groupId = resDic[@"groupid"];
            //修改群名的用户的ID
            NSString *userId = resDic[@"uid"];
            [self updateGroupName:groupName groupId:groupId userId:userId];
        }
        else if ([actType isEqualToString:@"undomsg"]){   //撤销消息
            NSDictionary *resDic = responceData[@"data"];
            NSString *fromUid = resDic[@"fromUid"];
            NSString *groupId = resDic[@"toUidOrGroupId"];
            
            //根据uid拿到用户名
            ZhiMaFriendModel *model = [FMDBShareManager getUserMessageByUserID:fromUid];
            NSString *userName = model.user_Name;
            //如果不是好友, 从群表查群用户
            if (!model.user_Id) {
                GroupUserModel *groupUserModel = [FMDBShareManager getGroupMemberWithMemberId:fromUid andConverseId:groupId];
                userName = groupUserModel.friend_nick;
            }
            
            //插入系统消息:"『用户名』撤回了一条消息"到数据库
            LGMessage *systemMsg = [[LGMessage alloc] init];
            systemMsg.actType = ActTypeUndomsg;
            systemMsg.text = [NSString stringWithFormat:@"\"%@\"撤回了一条消息",userName];
            systemMsg.toUidOrGroupId =  resDic[@"toUidOrGroupId"];
            systemMsg.fromUid = fromUid;
            systemMsg.type = MessageTypeSystem;
            systemMsg.msgid = resDic[@"msgid"];
            systemMsg.undoMsgid = resDic[@"msgid"];
            systemMsg.isGroup = [resDic[@"isGroup"] boolValue];
            systemMsg.timeStamp = [NSDate currentTimeStamp];
            
            //更新数据库会话 （最后一条消息显示）
            NSString *conversionId = nil;
            if (systemMsg.isGroup) {
                conversionId = systemMsg.toUidOrGroupId;
            }else{
                conversionId = systemMsg.fromUid;
            }
            [FMDBShareManager upDataMessageStatusWithMessage:systemMsg];
            FMDatabaseQueue *queue = [FMDBShareManager getQueueWithType:ZhiMa_Chat_Converse_Table];
            NSString *optionStr1 = [NSString stringWithFormat:@"converseContent = '%@'",systemMsg.text];
            NSString *upDataStr = [FMDBShareManager alterTable:ZhiMa_Chat_Converse_Table withOpton1:optionStr1 andOption2:[NSString stringWithFormat:@"converseId = '%@'",conversionId]];
            [queue inDatabase:^(FMDatabase *db) {
                [db executeUpdate:upDataStr];

            }];
            
            //发送撤销消息通知
            NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
            userInfo[@"message"] = systemMsg;
            [[NSNotificationCenter defaultCenter] postNotificationName:kRecieveNewMessage object:nil userInfo:userInfo];
        }
        else if ([actType isEqualToString:@"updategroupuser"]){ //群用户修改群昵称
#warning 更新数据库群成员列表
            NSDictionary *resDic = responceData[@"data"];
            NSString *userId = resDic[@"uid"];
            NSString *groupId = resDic[@"groupid"];
            NSString *name = resDic[@"group_user_nick"];
            
            
            
        }
        else if ([actType isEqualToString:@"nofriend"]){ //对方把你删除好友，
            //插入一条系统消息"你不是对方的朋友，请先发送朋友验证请求，对方验证通过后才能聊天。"到数据库
            NSDictionary *resDic = responceData[@"data"];
            NSString *toUid = resDic[@"toUidOrGroupId"];
            LGMessage *systemMsg = [[LGMessage alloc] init];
            systemMsg.text = @"你不是对方的朋友，请先发送朋友验证请求，对方验证通过后才能聊天。";
            systemMsg.fromUid = toUid;
            systemMsg.toUidOrGroupId = USERINFO.userID;
            systemMsg.type = MessageTypeSystem;
            systemMsg.msgid = resDic[@"msgid"];
            systemMsg.isGroup = NO;
            systemMsg.timeStamp = [NSDate currentTimeStamp];
            [FMDBShareManager saveMessage:systemMsg toConverseID:toUid];
            
            NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
            userInfo[@"message"] = systemMsg;
            [[NSNotificationCenter defaultCenter] postNotificationName:kRecieveNewMessage object:nil userInfo:userInfo];

        }
        else if ([actType isEqualToString:@"inblacklist"]){ //对方把你设为黑名单
            //插入一条系统消息"消息已成功发送，但被对方拒绝。"到数据库
            NSDictionary *resDic = responceData[@"data"];
            NSString *toUid = resDic[@"toUidOrGroupId"];
            LGMessage *systemMsg = [[LGMessage alloc] init];
            systemMsg.text = @"消息已成功发送，但被对方拒绝。";
            systemMsg.fromUid = toUid;
            systemMsg.toUidOrGroupId = USERINFO.userID;
            systemMsg.type = MessageTypeSystem;
            systemMsg.msgid = resDic[@"msgid"];
            systemMsg.isGroup = NO;
            systemMsg.timeStamp = [NSDate currentTimeStamp];
            [FMDBShareManager saveMessage:systemMsg toConverseID:toUid];
            
            NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
            userInfo[@"message"] = systemMsg;
            [[NSNotificationCenter defaultCenter] postNotificationName:kRecieveNewMessage object:nil userInfo:userInfo];
        }
        else if ([actType isEqualToString:@"dofriend"]){    //对方同意我的好友请求
            
            NSDictionary *resDic = responceData[@"data"];
            NSString *friendId = resDic[@"frienduid"];
            
            //从网络加载新好友资料，存入数据库好友表  ->  然后添加系统消息 "xx通过了你的朋友验证请求,现在可以开始聊天了。" 到数据库
            [self addNewFriendToSqilt:friendId];
        }
        else if ([actType isEqualToString:@"noallow"]){     //收到 不让对方看自己朋友圈 回调  （本地删除uid对应的朋友圈）
            NSDictionary *resDic = responceData[@"data"];
            NSString *friendId = resDic[@"delUid"];
            NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
            userInfo[@"deleteUid"] = friendId;
            [[NSNotificationCenter defaultCenter] postNotificationName:K_NotLookMyCircleNotification object:nil userInfo:userInfo];
        }
    }
}

//收到从群组删除用户 actuid:操作者id   uids:被删除用户的id
- (void)deleteGroupUser:(NSString *)groupId actUid:(NSString *)actUid uids:(NSString *)uids{
    LGMessage *systemMsg = [[LGMessage alloc] init];
    //从群表去用户数据
    if ([actUid isEqualToString:USERINFO.userID]) { //如果自己是操作者
        GroupUserModel *model = [FMDBShareManager getGroupMemberWithMemberId:uids andConverseId:groupId];
        systemMsg.text = [NSString stringWithFormat:@"你将\"%@\"移出了群聊",model.friend_nick];
    }else{
        GroupUserModel *model = [FMDBShareManager getGroupMemberWithMemberId:actUid andConverseId:groupId];
        systemMsg.text = [NSString stringWithFormat:@"你被\"%@\"移出了群聊",model.friend_nick];
    }
    
    //发送系统消息 你邀请"xx"加入群聊
    systemMsg.actType = ActTypeDeluserfromgroup;
    systemMsg.fromUid = USERINFO.userID;
    systemMsg.toUidOrGroupId = groupId;
    systemMsg.type = MessageTypeSystem;
    systemMsg.msgid = [NSString generateMessageID];
    systemMsg.isGroup = YES;
    systemMsg.timeStamp = [NSDate currentTimeStamp];
    [FMDBShareManager saveGroupChatMessage:systemMsg andConverseId:groupId];
    
    //发送通知，即时更新相应的页面
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    userInfo[@"message"] = systemMsg;
    [[NSNotificationCenter defaultCenter] postNotificationName:kRecieveNewMessage object:nil userInfo:userInfo];

}


//收到拉人进群消息  actuid:操作者id   uids:被邀请用户的id
- (void)updateGroupNumber:(NSString *)groupId actUid:(NSString *)actUid uids:(NSString *)uids{

    LGMessage *systemMsg = [[LGMessage alloc] init];
    //拼接被邀请者的姓名
    NSString *userNames = nil;
    if ([actUid isEqualToString:USERINFO.userID] && ![actUid isEqualToString:uids]) { //如果自己是操作者
        NSArray *copyArr = [uids componentsSeparatedByString:@","];     //拷贝一份
        NSMutableArray *uidsArr = [copyArr mutableCopy];
        
        NSMutableArray *namesArr = [NSMutableArray array];
        //剔除自己的id
        for (NSString *userid in copyArr) {
            if ([userid isEqualToString:USERINFO.userID]) {
                [uidsArr removeObject:userid];
            }
        }
        //拼接被邀请者名字
        for (NSString *userId in uidsArr) {
            ZhiMaFriendModel *friend = [FMDBShareManager getUserMessageByUserID:userId];
            [namesArr addObject:friend.user_Name];
        }
        userNames = [namesArr componentsJoinedByString:@","];
        systemMsg.text = [NSString stringWithFormat:@"你邀请\"%@\"加入了群聊",userNames];
    }
    else if ([actUid isEqualToString:uids]){   //通过扫描二维码进群
        if ([actUid isEqualToString:USERINFO.userID]) { //自己
            systemMsg.text = [NSString stringWithFormat:@"你通过扫描二维码加入了群聊"];
        }else{
            GroupUserModel *model = [FMDBShareManager getGroupMemberWithMemberId:actUid andConverseId:groupId];
            systemMsg.text = [NSString stringWithFormat:@"\"%@\"通过扫描你分享的二维码加入了群聊",model.friend_nick];
        }
    }
    else{
//        ZhiMaFriendModel *actUserModel = [FMDBShareManager getUserMessageByUserID:actUid];
        //修改为从群表查用户资料
        GroupUserModel *actUserModel = [FMDBShareManager getGroupMemberWithMemberId:actUid andConverseId:groupId];
        userNames = actUserModel.friend_nick;
        systemMsg.text = [NSString stringWithFormat:@"\"%@\"邀请你加入了群聊",userNames];
    }
    
    //发送系统消息 你邀请"xx"加入群聊 
    systemMsg.actType = ActTypeUpdategroupnum;
    systemMsg.fromUid = USERINFO.userID;
    systemMsg.toUidOrGroupId = groupId;
    systemMsg.type = MessageTypeSystem;
    systemMsg.msgid = [NSString generateMessageID];
    systemMsg.isGroup = YES;
    systemMsg.timeStamp = [NSDate currentTimeStamp];
    [FMDBShareManager saveGroupChatMessage:systemMsg andConverseId:groupId];
    
    //发送通知，即时更新相应的页面
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    userInfo[@"message"] = systemMsg;
    [[NSNotificationCenter defaultCenter] postNotificationName:kRecieveNewMessage object:nil userInfo:userInfo];
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
                groupChatModel.myGroupName = USERINFO.username;
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
                systemMsg.isGroup = YES;
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
        systemMsg.isGroup = YES;
        systemMsg.timeStamp = [NSDate currentTimeStamp];
        [FMDBShareManager saveGroupChatMessage:systemMsg andConverseId:groupId];
        
        //发送通知，即时更新相应的页面
        NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
        userInfo[@"message"] = systemMsg;
        userInfo[@"otherMsg"] = groupName;
        [[NSNotificationCenter defaultCenter] postNotificationName:kRecieveNewMessage object:nil userInfo:userInfo];
    }
}

//从网络加载新好友资料，存入数据库好友表  ->  然后添加系统消息 "xx通过了你的朋友验证请求,现在可以开始聊天了。" 到数据库
- (void)addNewFriendToSqilt:(NSString *)friendId{
    [LGNetWorking getFriendInfo:USERINFO.sessionId userId:friendId block:^(ResponseData *responseData) {
        if (responseData.code == 0) {
            ZhiMaFriendModel *friend = [ZhiMaFriendModel mj_objectWithKeyValues:responseData.data];
            
            //插入好友到数据库
            [FMDBShareManager saveUserMessageWithMessageArray:@[friend]];
            
            //添加系统消息
            [self addSystemMsgToSqlite:friend];
            
            [self playSystemAudio];
            
        }else{
            [LCProgressHUD showText:responseData.msg];
        }
    } failure:^(ErrorData *error) {
        [LCProgressHUD showText:error.msg];
    }];

}

//添加系统消息"xx通过了你的朋友验证请求,现在可以开始聊天了。"
- (void)addSystemMsgToSqlite:(ZhiMaFriendModel *)friend{
    
    LGMessage *systemMsg = [[LGMessage alloc] init];
    systemMsg.text = [NSString stringWithFormat:@"%@通过了你的朋友验证请求,现在可以开始聊天了。",friend.user_Name];
    systemMsg.fromUid = USERINFO.userID;
    systemMsg.toUidOrGroupId = friend.user_Id;
    systemMsg.type = MessageTypeSystem;
    systemMsg.msgid = [NSString generateMessageID];
    systemMsg.isGroup = NO;
    systemMsg.timeStamp = [NSDate currentTimeStamp];
    [FMDBShareManager saveMessage:systemMsg toConverseID:friend.user_Id];
    
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    userInfo[@"message"] = systemMsg;
    [[NSNotificationCenter defaultCenter] postNotificationName:kRecieveNewMessage object:nil userInfo:userInfo];
}

//插入一条群消息到本地数据库
- (BOOL)addGroupMessage:(LGMessage *)message groupId:(NSString *)groupId{
    
    //判断数据库是否存在该群会话 -> 不存在 从网络加载数据  存到数据库
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
                groupChatModel.myGroupName = USERINFO.username;
                //新建一个群会话，插入数据库
                [FMDBShareManager saveGroupChatInfo:groupChatModel andConverseID:groupChatModel.groupId];
                
                //保存群消息到数据库
                [FMDBShareManager saveGroupChatMessage:message andConverseId:message.toUidOrGroupId];
                                
                //发送通知，刷新会话列表
                NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
                userInfo[@"message"] = message;
                [[NSNotificationCenter defaultCenter] postNotificationName:kRecieveNewMessage object:nil userInfo:userInfo];
                
            }
        } failure:^(ErrorData *error) {
            
        }];
    }else{
        //保存群消息到数据库
        [FMDBShareManager saveGroupChatMessage:message andConverseId:message.toUidOrGroupId];
    }
    return YES;
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
        sendMsg.isGroup = message.isGroup;
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
    
    //先从数据库删除该条消息
    
    
    //插入系统消息:"你撤回了一条消息"到数据库
    LGMessage *systemMsg = [[LGMessage alloc] init];
    systemMsg.text = @"你撤回了一条消息";
    systemMsg.toUidOrGroupId =  message.toUidOrGroupId;
    systemMsg.fromUid = USERINFO.userID;
    systemMsg.type = MessageTypeSystem;
    systemMsg.msgid = [NSString stringWithFormat:@"%@%@",USERINFO.userID,[self generateMessageID]];
    systemMsg.isGroup = message.isGroup;
    systemMsg.timeStamp = [NSDate currentTimeStamp];
    
    if (message.isGroup) {  //群消息和单聊消息 分开进行更新消息表操作(主要是会话列表展示)
        [FMDBShareManager saveGroupChatMessage:systemMsg andConverseId:message.toUidOrGroupId];
    }else{
        [FMDBShareManager saveMessage:systemMsg toConverseID:message.toUidOrGroupId];
    }
}

//建群
- (void)createGtoup:(NSString *)groupId uids:(NSString *)uids{
    NSData *data = [self generateGroupActType:GroupActTypeAddUser groupId:groupId uids:uids];
    RHSocketPacketRequest *req = [[RHSocketPacketRequest alloc] init];
    req.object = data;
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationSocketPacketRequest object:req];
}

//邀请用户到群
- (void)addUserToGroup:(NSString *)groupId uids:(NSString *)uids{
    NSData *data = [self generateGroupActType:GroupActTypeAddUser groupId:groupId uids:uids];
    RHSocketPacketRequest *req = [[RHSocketPacketRequest alloc] init];
    req.object = data;
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationSocketPacketRequest object:req];
}

//从群组删除用户
- (void)delUserFromGroup:(NSString *)groupId uids:(NSString *)uids{
    NSData *data = [self generateGroupActType:GroupActTypeDelUser groupId:groupId uids:uids];
    RHSocketPacketRequest *req = [[RHSocketPacketRequest alloc] init];
    req.object = data;
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationSocketPacketRequest object:req];
}

//退出群
- (void)delGroup:(NSString *)groupId uid:(NSString *)uid{
    NSData *data = [self generateGroupActType:GroupActTypeDelGroup groupId:groupId uids:uid];
    RHSocketPacketRequest *req = [[RHSocketPacketRequest alloc] init];
    req.object = data;
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationSocketPacketRequest object:req];
}

//群重命名
- (void)renameGroup:(NSString *)groupId name:(NSString *)name{
    NSData *data = [self generateGroupActType:GroupActTypeReName groupId:groupId uids:name];
    RHSocketPacketRequest *req = [[RHSocketPacketRequest alloc] init];
    req.object = data;
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationSocketPacketRequest object:req];
}

//添加好友
- (void)addFriend:(NSString *)friendId{
    NSData *data = [self generateFriendActType:FriendActTypeAdd friendId:friendId];
    RHSocketPacketRequest *req = [[RHSocketPacketRequest alloc] init];
    req.object = data;
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationSocketPacketRequest object:req];
}

//同意好友请求
- (void)agreeFriendRequest:(NSString *)friendId{
    NSData *data = [self generateFriendActType:FriendActTypeAgreee friendId:friendId];
    RHSocketPacketRequest *req = [[RHSocketPacketRequest alloc] init];
    req.object = data;
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationSocketPacketRequest object:req];
}

//加入黑名单
- (void)dragToBlack:(NSString *)friendId{
    NSData *data = [self generateFriendActType:FriendActTypeBlack friendId:friendId];
    RHSocketPacketRequest *req = [[RHSocketPacketRequest alloc] init];
    req.object = data;
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationSocketPacketRequest object:req];
}

//用户修改资料
- (void)updateProfile{
    NSData *data = [self generateFriendActType:FriendActTypeUpdate friendId:USERINFO.userID];
    RHSocketPacketRequest *req = [[RHSocketPacketRequest alloc] init];
    req.object = data;
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationSocketPacketRequest object:req];
}

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
            NSString *str = [NSString stringWithFormat:@"controller_name=LoginController&method_name=bind_uid&uid=%@&%@",uid,APIKEY];
            sign = [[str md5Encrypt] uppercaseString];
            //生成data
            dataDic[@"uid"] = uid;
            dataDic[@"sign"] = sign;

        }
            break;
            
        case RequestTypeHeart:{     //心跳包类型
            //拼接控制器和方法名
            request[@"controller_name"] = @"HeartbeatController";
            request[@"method_name"] = @"check";
            dataDic[@"uid"] = uid;
            
        }
            
            break;
            
        case RequestTypeMessage:{      //消息类型
            //拼接控制器和方法名
            request[@"controller_name"] = @"MessageController";
            request[@"method_name"] = @"sendmsg";
            //生成签名
            NSString *str = [NSString stringWithFormat:@"controller_name=MessageController&method_name=sendmsg&fromUid=%@&isGroup=%d&msgid=%@&text=%@&time=%ld&toUidOrGroupId=%@&type=%zd&%@",message.fromUid,message.isGroup,message.msgid,message.text,(long)message.audioLength,message.toUidOrGroupId,message.type,APIKEY];
            sign = [[str md5Encrypt] uppercaseString];
            //拼接消息
            NSInteger isgroup = message.isGroup;
            dataDic[@"msgid"] = message.msgid;
            dataDic[@"type"] = @(message.type);
            dataDic[@"isGroup"] = @(isgroup);
            dataDic[@"fromUid"] = message.fromUid;
            dataDic[@"toUidOrGroupId"] = message.toUidOrGroupId;
            dataDic[@"text"] = message.text;
            dataDic[@"time"] = @(message.audioLength);
            dataDic[@"sign"] = sign;
            
        }
            
            break;
            
        case RequestTypeUndo:{      //撤销消息
            //拼接控制器和方法名
            request[@"controller_name"] = @"MessageController";
            request[@"method_name"] = @"undo";
            //生成签名
            NSString *str = [NSString stringWithFormat:@"controller_name=MessageController&method_name=undo&fromUid=%@&isGroup=%d&msgid=%@&toUidOrGroupId=%@&type=%lu&%@",message.fromUid,message.isGroup,message.msgid,message.toUidOrGroupId,(unsigned long)message.type,APIKEY];
            sign = [[str md5Encrypt] uppercaseString];
            //拼接消息
            dataDic[@"msgid"] = message.msgid;
            dataDic[@"type"] = @(message.type);
            if (message.isGroup) {
                dataDic[@"isGroup"] = @"1";
            }else{
                dataDic[@"isGroup"] = @"0";
            }
//            dataDic[@"isGroup"] = @(message.isGroup);
            dataDic[@"fromUid"] = message.fromUid;
            dataDic[@"toUidOrGroupId"] = message.toUidOrGroupId;
            dataDic[@"sign"] = sign;
        }
            break;
            
        case RequestTypeNotLookCircle:{
            //拼接控制器和方法名
            request[@"controller_name"] = @"MessageController";
            request[@"method_name"] = @"noAllowFriendCircle";
            //生成签名
            NSString *str = [NSString stringWithFormat:@"controller_name=MessageController&method_name=noAllowFriendCircle&fromUid=%@&toUid=%@",USERINFO.userID,uid];
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
- (NSData *)generateGroupActType:(GroupActType)type groupId:(NSString *)groupId uids:(NSString *)uids{
    
    NSMutableDictionary *request = [NSMutableDictionary dictionary];
    //data字段里面的数据
    NSMutableDictionary *dataDic = [NSMutableDictionary dictionary];
    
    NSString *controllerName = @"UserController";
    NSString *methodName = nil;
    
    switch (type) {
            
        case GroupActTypeCreate:{       //建群
            methodName = @"addUserToGroup";
        }
            
            break;
        case GroupActTypeAddUser:{      //邀请用户到群
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
    
    //拼接消息 (如果是群重命名 dataDic拼接"groupname" ，其他拼接"uids"）
    if (type == GroupActTypeReName) {
        dataDic[@"groupname"] = uids;
        dataDic[@"uid"] = USERINFO.userID;
        str = [NSString stringWithFormat:@"controller_name=%@&method_name=%@&groupid=%@&groupname=%@&uid=%@&%@",controllerName,methodName,groupId,uids,USERINFO.userID,APIKEY];
    }
    else if (type == GroupActTypeAddUser || type == GroupActTypeCreate || type == GroupActTypeDelUser){
        dataDic[@"uids"]= uids;
        dataDic[@"actuid"] = USERINFO.userID; //操作者的uid
        str = [NSString stringWithFormat:@"controller_name=%@&method_name=%@&actuid=%@&groupid=%@&uids=%@&%@",controllerName,methodName,USERINFO.userID,groupId,uids,APIKEY];
    }
    else if (type == GroupActTypeDelGroup){
        dataDic[@"uid"] = uids;
        str = [NSString stringWithFormat:@"controller_name=%@&method_name=%@&groupid=%@&uid=%@&%@",controllerName,methodName,groupId,uids,APIKEY];
    }
    else {
        dataDic[@"uids"]= uids;
        str = [NSString stringWithFormat:@"controller_name=%@&method_name=%@&groupid=%@&uids=%@&%@",controllerName,methodName,groupId,uids,APIKEY];
    }
    //生成签名
    NSString *sign = [[str md5Encrypt] uppercaseString];
    dataDic[@"groupid"] = groupId;
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
- (NSData *)generateFriendActType:(FriendActType)type friendId:(NSString *)friendId{
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
    if (type == FriendActTypeUpdate) {
        str = [NSString stringWithFormat:@"controller_name=%@&method_name=%@&uid=%@&%@",controllerName,methodName,USERINFO.userID,APIKEY];
        dataDic[@"uid"] = USERINFO.userID;

    }
//    else if (type == FriendActTypeAgreee){
//        str = [NSString stringWithFormat:@"controller_name=%@&method_name=%@&frienduid=%@&uid=%@&%@",controllerName,methodName,USERINFO.userID,friendId,APIKEY];
//        dataDic[@"frienduid"] = USERINFO.userID;
//        dataDic[@"uid"] = friendId;
//    }
    else{
        str = [NSString stringWithFormat:@"controller_name=%@&method_name=%@&frienduid=%@&uid=%@&%@",controllerName,methodName,friendId,USERINFO.userID,APIKEY];
        dataDic[@"frienduid"] = friendId;
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

//播放消息提示音(已经判断是声音还是振动提醒)
- (void)playSystemAudio{
    if (USERINFO.newMessageNotify) {    //开启了接受信息消息通知
        if (USERINFO.newMessageVoiceNotify) {   //开启了声音提醒
            AudioServicesPlaySystemSound(1007);
        }else{
            if (USERINFO.newMessageShakeNotify) {   //只有振动提醒
                AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
            }
        }
    }
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
