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
    
    //设置心跳定时器间隔15秒
    connectParam.heartbeatInterval = 5;
    
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


//手动断开socket
-(void)disconnect{
    [[RHSocketService sharedInstance] stopService];
}

//发送消息
- (void)sendMessage:(LGMessage *)message{
    
    
    //处理过后的发送给socket的message
    LGMessage *sendMsg = [[LGMessage alloc] init];
    
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
        
    }
    //文本消息
    else if (message.type == MessageTypeText){
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
    BOOL success = [FMDBShareManager saveMessage:message toConverseID:message.toUidOrGroupId];
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

    } else {
        //
    }//if
}


//收到socket数据回调
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
                    //将消息插入数据库，并更新会话列表
                    BOOL success = [FMDBShareManager saveMessage:message toConverseID:message.fromUid];
                    
                    if (success) {
                        NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
                        userInfo[@"message"] = message;
                        [[NSNotificationCenter defaultCenter] postNotificationName:kRecieveNewMessage object:nil userInfo:userInfo];
                        
                    }

                }else{
                    NSLog(@"语音写入沙盒失败");
                }

            }
            //文本消息 -> 插入数据库
            else if (message.type == MessageTypeText){
                //将消息插入数据库，并更新会话列表
                BOOL success = [FMDBShareManager saveMessage:message toConverseID:message.fromUid];
                
                if (success) {
                    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
                    userInfo[@"message"] = message;
                    [[NSNotificationCenter defaultCenter] postNotificationName:kRecieveNewMessage object:nil userInfo:userInfo];

                }
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
            
        }
        else if ([actType isEqualToString:@"deluserfromgroup"]){   //从群组中删除用户
            
        }
        else if ([actType isEqualToString:@"renamegroup"]){   //重命名群组
            
        }
        else if ([actType isEqualToString:@"undomsg"]){   //撤销消息
            
        }
    }
}

#pragma mark - 封装消息操作指令
//撤销消息 
- (void)undoMessage:(LGMessage *)message{
    NSData *data = [self generateRequest:RequestTypeUndo uid:0 message:message];
    RHSocketPacketRequest *req = [[RHSocketPacketRequest alloc] init];
    req.object = data;
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationSocketPacketRequest object:req];
}

//建群
- (void)createGtoup:(NSString *)groupId uids:(NSString *)uids{
    NSData *data = [self generateGroupActType:GroupActTypeCreate groupId:groupId uids:uids];
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

//删除好友
- (void)delFriend:(NSString *)friendId{
    NSData *data = [self generateFriendActType:FriendActTypeDel friendId:friendId];
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
    NSData *data = [self generateFriendActType:FriendActTypeUpdate friendId:0];
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
            NSString *str = [NSString stringWithFormat:@"controller_name=MessageController&method_name=sendmsg&fromUid=%@&isGroup=%d&msgid=%@&text=%@&toUidOrGroupId=%@&type=%zd&%@",message.fromUid,message.isGroup,message.msgid,message.text,message.toUidOrGroupId,message.type,APIKEY];
            sign = [[str md5Encrypt] uppercaseString];
            //拼接消息
            NSInteger isgroup = message.isGroup;
            dataDic[@"msgid"] = message.msgid;
            dataDic[@"type"] = @(message.type);
            dataDic[@"isGroup"] = @(isgroup);
            dataDic[@"fromUid"] = message.fromUid;
            dataDic[@"toUidOrGroupId"] = message.toUidOrGroupId;
            dataDic[@"text"] = message.text;
            dataDic[@"sign"] = sign;
            
        }
            
            break;
            
        case RequestTypeUndo:{      //撤销消息
            //拼接控制器和方法名
            request[@"controller_name"] = @"MessageController";
            request[@"method_name"] = @"undo";
            //生成签名
            NSString *str = [NSString stringWithFormat:@"controller_name=MessageController&method_name=undo&fromUid=%@&isGroup=%d&msgid=%@&toUidOrGroupId=%@&type=%d&%@",message.fromUid,message.isGroup,message.msgid,message.toUidOrGroupId,message.type,APIKEY];
            sign = [[str md5Encrypt] uppercaseString];
            //拼接消息
            dataDic[@"msgid"] = message.msgid;
            dataDic[@"type"] = @(message.type);
            dataDic[@"isGroup"] = @(message.isGroup);
            dataDic[@"fromUid"] = message.fromUid;
            dataDic[@"toUidOrGroupId"] = message.toUidOrGroupId;
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
        str = [NSString stringWithFormat:@"controller_name=%@&method_name=%@&groupid=%@&groupname=%@&%@",controllerName,methodName,groupId,uids,APIKEY];
    }else{
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
        case FriendActTypeDel:{     //删除好友
            methodName = @"delFriend";
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
    }else{
        str = [NSString stringWithFormat:@"controller_name=%@&method_name=%@&frienduid=%@&uid=%@&%@",controllerName,methodName,friendId,USERINFO.userID,APIKEY];
        dataDic[@"frienduid"] = friendId;
    }
    NSString *sign = [[str md5Encrypt] uppercaseString];
    dataDic[@"uid"] = USERINFO.userID;
    dataDic[@"sign"] = sign;
    //拼接完整的request包
    request[@"data"] = dataDic;
    //请求包转换成json字符串
    return [[request mj_JSONString] dataUsingEncoding:NSUTF8StringEncoding];
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
