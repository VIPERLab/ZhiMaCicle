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
    connectParam.heartbeatInterval = 15;
    
    //设置短线后是否自动重连
    connectParam.autoReconnect = YES;
    
    //变长编解码。包体＝包头（包体的长度）＋包体数据
    RHSocketVariableLengthEncoder *encoder = [[RHSocketVariableLengthEncoder alloc] init];
    RHSocketVariableLengthDecoder *decoder = [[RHSocketVariableLengthDecoder alloc] init];
    
    [RHSocketService sharedInstance].encoder = encoder;
    [RHSocketService sharedInstance].decoder = decoder;
    
    //设置心跳包，这里的object数据，和服务端约定好
    RHSocketPacketRequest *req = [[RHSocketPacketRequest alloc] init];
    req.object = [self generateRequest:RequestTypeHeart uid:10 message:nil];
    [RHSocketService sharedInstance].heartbeat = req;
    
    [[RHSocketService sharedInstance] startServiceWithConnectParam:connectParam];
}


//手动断开socket
-(void)disconnect{
    [[RHSocketService sharedInstance] stopService];
}

//发送消息
- (void)sendMessage:(LGMessage *)message{
    //根据消息模型生成固定格式数据包
    NSData *data = [self generateRequest:RequestTypeMessage uid:10 message:message];
    RHSocketPacketRequest *req = [[RHSocketPacketRequest alloc] init];
    req.object = data;
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationSocketPacketRequest object:req];
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
        NSData *loginData = [self generateRequest:RequestTypeLogin uid:10 message:nil];
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
    LGMessage *message = [LGMessage mj_setKeyValues:rsp.object];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(recievedMessage:)]) {
        [self.delegate recievedMessage:message];
    }
    NSLog(@"detectSocketPacketResponse data: %@", [rsp object]);
}

//根据消息请求类型- 按照固定格式生成数据请求包
- (NSData *)generateRequest:(RequestType)type uid:(NSInteger)uid message:(LGMessage *)message{
    
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
            NSString *str = [NSString stringWithFormat:@"controller_name=LoginController&method_name=bind_uid&uid=%d&%@",uid,APIKEY];
            sign = [[str md5Encrypt] uppercaseString];
            //生成data
            dataDic[@"uid"] = @(uid);
            dataDic[@"sign"] = sign;

        }
            break;
            
        case RequestTypeHeart:{     //心跳包类型
            //拼接控制器和方法名
            request[@"controller_name"] = @"HeartbeatController";
            request[@"method_name"] = @"check";
            dataDic[@"uid"] = @(uid);
            
        }
            
            break;
            
        case RequestTypeMessage:{      //消息类型
            //拼接控制器和方法名
            request[@"controller_name"] = @"MessageController";
            request[@"method_name"] = @"send";
            //生成签名
            NSString *str = [NSString stringWithFormat:@"controller_name=MessageController&method_name=send&fromUid=%@&isGroup=%d&msgid=%@&text=%@&toUidOrGroupId=%@&type=%d&%@",message.fromUid,message.isGroup,message.msgid,message.text,message.toUidOrGroupId,message.type,APIKEY];
            sign = [[str md5Encrypt] uppercaseString];
            //拼接消息
            dataDic[@"msgid"] = message.msgid;
            dataDic[@"type"] = @(message.type);
            dataDic[@"isGroup"] = @(message.isGroup);
            dataDic[@"fromUid"] = message.fromUid;
            dataDic[@"toUidOrGroupId"] = message.toUidOrGroupId;
            dataDic[@"text"] = message.text;
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


- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
