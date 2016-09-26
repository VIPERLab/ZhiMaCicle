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
        //socket收到数据监听
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(detectSocketServiceState:) name:kNotificationSocketServiceState object:nil];
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
    req.object = [@"Heartbeat" dataUsingEncoding:NSUTF8StringEncoding];
    [RHSocketService sharedInstance].heartbeat = req;
    
    [[RHSocketService sharedInstance] startServiceWithConnectParam:connectParam];
}


//手动断开socket
-(void)disconnect{
    [[RHSocketService sharedInstance] stopService];
}

#pragma mark - socket 代理方法
//socket服务器连接状态
- (void)detectSocketServiceState:(NSNotification *)notif
{
    //NSDictionary *userInfo = @{@"host":host, @"port":@(port), @"isRunning":@(_isRunning)};
    //对应的连接ip和状态数据。_isRunning为YES是连接成功。
    //没有心跳超时后会自动断开。
    NSLog(@"detectSocketServiceState: %@", notif);
    
    id state = notif.object;
    if (state && [state boolValue]) {
        //连接成功后，发送数据包
        RHSocketPacketRequest *req = [[RHSocketPacketRequest alloc] init];
        req.object = [@"变长编码器和解码器测试数据包1" dataUsingEncoding:NSUTF8StringEncoding];
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationSocketPacketRequest object:req];
        
        req = [[RHSocketPacketRequest alloc] init];
        req.object = [@"变长编码器和解码器测试数据包20" dataUsingEncoding:NSUTF8StringEncoding];
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationSocketPacketRequest object:req];
        
        req = [[RHSocketPacketRequest alloc] init];
        req.object = [@"变长编码器和解码器测试数据包300" dataUsingEncoding:NSUTF8StringEncoding];
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationSocketPacketRequest object:req];
        
        //2016-03-30 11:28:21.217 RHSocketVariableLengthCodecDemo[31043:3057289] timeout: -1.000000, sendData: <002be58f 98e995bf e7bc96e7 a081e599 a8e5928c e8a7a3e7 a081e599 a8e6b58b e8af95e6 95b0e68d aee58c85 31>
        //2016-03-30 11:28:21.217 RHSocketVariableLengthCodecDemo[31043:3057289] timeout: -1.000000, sendData: <002ce58f 98e995bf e7bc96e7 a081e599 a8e5928c e8a7a3e7 a081e599 a8e6b58b e8af95e6 95b0e68d aee58c85 3230>
        //2016-03-30 11:28:21.217 RHSocketVariableLengthCodecDemo[31043:3057289] timeout: -1.000000, sendData: <002de58f 98e995bf e7bc96e7 a081e599 a8e5928c e8a7a3e7 a081e599 a8e6b58b e8af95e6 95b0e68d aee58c85 333030>
        //观察发送的数据，其实就是把获取object的长度当做［包头］，然后再接上［包体］，发送就ok了
        //3个包的长度分别是，002b，002c，002d，都在sendData的最前面两个字节［包头］
        //后面就是包体，前面都是一样的，就是1，20，300的数据的区别
        
        //解码<002be58f 98e995bf e7bc96e7 a081e599 a8e5928c e8a7a3e7 a081e599 a8e6b58b e8af95e6 95b0e68d aee58c85 31>
        //例如得到上面这数据值后，先读区包头的长度字节，为002b。将002b转为10进制就是43，然后读区后续的43个字节，就是包体的内容。
        //这样一个包就解码完成了。
        
    } else {
        //
    }//if
}


@end
