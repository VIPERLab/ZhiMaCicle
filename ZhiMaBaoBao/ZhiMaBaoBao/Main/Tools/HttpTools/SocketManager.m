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


                        dispatch_queue_t conCurrentGlobalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
                        dispatch_queue_t mainQueue = dispatch_get_main_queue();
                        dispatch_group_t groupQueue = dispatch_group_create();
                        dispatch_group_async(groupQueue, conCurrentGlobalQueue, ^{
                            NSArray *data = responseObject[@"data"];
                            for (NSDictionary *dic in data) {
                                LGMessage *message = [[LGMessage alloc] init];
                                message = [message mj_setKeyValues:dic];
                                [self recieveMessage:message isOffline:YES];
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
        sendMsg.converseId = message.fromUid;
        sendMsg.converseName = USERINFO.username;
        sendMsg.converseLogo = USERINFO.head_photo;
    }else if (message.conversionType == ConversionTypeGroupChat){
        sendMsg.converseId = message.toUidOrGroupId;
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
    //2.插会话表 -- 自己发的消息未读数不加1
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

//收到消息 (是否是离线消息)
- (void)recieveMessage:(LGMessage *)message isOffline:(BOOL)offline
{

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
        friend.head_photo = message.fromUserPhoto;
        //自己的群成员信息 (用于被拉进群，将自己存入群成员表)
        GroupUserModel *user = [[GroupUserModel alloc] init];
        
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
            converse.converseId = message.fromUid;
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
            
            //自己的群成员信息 (用于被拉进群，将自己存入群成员表)
            user.userId = USERINFO.userID;
            user.friend_nick = USERINFO.username;
            user.head_photo = USERINFO.head_photo;
            user.groupId = converse.converseId;
            
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
                message.msgid = [NSString generateMessageID];
                [FMDBShareManager saveMessage:message toConverseID:converse.converseId];
                [FMDBShareManager saveConverseListDataWithModel:converse withComplationBlock:nil];
                [FMDBShareManager saveUserMessageWithMessageArray:@[friend] withComplationBlock:nil andIsUpdata:NO];
            }
                break;
            case ActTypeUpdatefriend:{  //更新好友数据
                
                
            }
                break;
            case ActTypeUpdategroupnum:{    //更新群用户数 （拉人进群）
                //将自己的信息存入群成员表
                user.memberGroupState = NO;
                message.msgid = [NSString generateMessageID];
                [FMDBShareManager saveAllGroupMemberWithArray:@[user] andGroupChatId:converse.converseId withComplationBlock:nil];
                [FMDBShareManager saveMessage:message toConverseID:converse.converseId];
                [FMDBShareManager alertConverseListDataWithModel:converse withComplationBlock:nil];
            }
                break;
            case ActTypeDeluserfromgroup:{  //从群组删除用户
                user.memberGroupState = YES;
                message.msgid = [NSString generateMessageID];
                [FMDBShareManager saveAllGroupMemberWithArray:@[user] andGroupChatId:converse.converseId withComplationBlock:nil];
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
                NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
                userInfo[@"deleteUid"] = message.fromUid;
                [[NSNotificationCenter defaultCenter] postNotificationName:K_NotLookMyCircleNotification object:nil userInfo:userInfo];
            }
                break;
            case ActTypeInBlacklist:{       //被拉入黑名单
                converse.converseId = message.toUidOrGroupId;
                message.msgid = [NSString generateMessageID];
                message.timeStamp = [NSDate currentTimeStamp];
                [FMDBShareManager saveMessage:message toConverseID:converse.converseId];
                [FMDBShareManager alertConverseTextAndTimeWithConverseModel:converse];
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
    
    if (!offline) {
        //统一发送通知、更新UI
        NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
        userInfo[@"message"] = message;
        [[NSNotificationCenter defaultCenter] postNotificationName:kRecieveNewMessage object:nil userInfo:userInfo];
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
    if (responceData) {

        //解析消息
        LGMessage *message = [[LGMessage alloc] init];
        message = [message mj_setKeyValues:responceData];
        
        [self recieveMessage:message isOffline:NO];
    }
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
    message.sendStatus = !userInfo.networkUnReachable;

    
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
- (void)deleteGroup:(GroupActModel *)actModel{
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
            NSString *str = [NSString stringWithFormat:@"controller_name=MessageController&method_name=noAllowFriendCircle&fromUid=%@&toUidOrGroupId=%@&%@",USERINFO.userID,uid,APIKEY];
            sign = [[str md5Encrypt] uppercaseString];
            dataDic[@"fromUid"] = USERINFO.userID;
            dataDic[@"toUidOrGroupId"] = uid;
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
    if (type == GroupActTypeSaoma){

        dataDic[@"act"] = @"scan";
        dataDic[@"fromUid"] = model.uids;
        dataDic[@"converseLogo"] = model.converseLogo;
        dataDic[@"converseName"] = model.converseName;
        dataDic[@"fromUserName"] = model.usernames;
        dataDic[@"fromUserPhoto"] = model.fromUserPhoto;
        dataDic[@"groupid"] = model.groupId;
        dataDic[@"groupLogo"] = model.groupLogo;
        dataDic[@"groupName"] = model.groupName;
        dataDic[@"uids"] = model.fromUid;
        dataDic[@"usernames"]= model.fromUsername;
        str = [NSString stringWithFormat:@"controller_name=%@&method_name=%@&act=%@&converseLogo=%@&converseName=%@&fromUid=%@&fromUserName=%@&fromUserPhoto=%@&groupLogo=%@&groupName=%@&groupid=%@&uids=%@&usernames=%@&%@",controllerName,methodName,dataDic[@"act"],model.converseLogo,model.converseName,model.uids,model.usernames,model.fromUserPhoto,model.groupLogo,model.groupName,model.groupId,model.fromUid,model.fromUsername,APIKEY];
    }else if (type == GroupActTypeCreate || type == GroupActTypeAddUser){
        if (type == GroupActTypeCreate) {
            dataDic[@"act"]= @"create";
        }else if (type == GroupActTypeAddUser){
            dataDic[@"act"] = @"add";
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
    }
    else if (type == GroupActTypeDelUser){
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
        dataDic[@"fromUserPhoto"] = USERINFO.head_photo;
        dataDic[@"frienduid"] = friend.user_Id;
        str = [NSString stringWithFormat:@"controller_name=%@&method_name=%@&frienduid=%@&fromUid=%@&fromUserName=%@&fromUserPhoto=%@&%@",controllerName,methodName,friend.user_Id,USERINFO.userID,USERINFO.username,USERINFO.head_photo,APIKEY];
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
