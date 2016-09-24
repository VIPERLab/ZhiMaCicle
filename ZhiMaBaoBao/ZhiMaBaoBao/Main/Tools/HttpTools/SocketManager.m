//
//  SocketManager.m
//  ZhiMaBaoBao
//
//  Created by liugang on 16/9/22.
//  Copyright © 2016年 liugang. All rights reserved.
//

#import "SocketManager.h"

@interface SocketManager ()<GCDAsyncSocketDelegate>{
    dispatch_source_t timer; //定时器，发送心跳包
}
@property (nonatomic, strong) NSTimer *connectTimer;    //定时器，发送心跳包

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


//连接服务器
- (void)connect{
    self.socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    // 在连接前先进行手动断开
//    [self disconnect];
    
    // 确保断开后再连，如果对一个正处于连接状态的socket进行连接，会出现崩溃  -- 将userData设置为SocketOfflineByServer 在自动断开的情况下实现重连
    self.socket.userData = SocketOfflineByServer;
    
    NSError *error = nil;
    if (![self.socket connectToHost:HOST onPort:9093 withTimeout:3 error:&error]) {
        NSLog(@"socket连接错误 error : %@",error);
    }
}

/**
 *  手动断开socket
 */
-(void)disconnect{
    
    self.socket.userData = SocketOfflineByUser;// 声明是由用户主动切断
    
    //关闭定时器
    if (timer) {
        dispatch_source_cancel(timer);
    }
    
    [self.socket disconnect];
}

#pragma mark - AsyncSocketDelegate


//建立连接   每隔3s向服务器发送心跳包 在longConnectToSocket方法中进行长连接需要向服务器发送的讯息
- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port{
    NSLog(@"socket 连接成功");
    //创建一个timer放到队列
    timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0));
    //设置timer的开始时间，时间间隔，精确度
    dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, 3.0 * NSEC_PER_SEC, 0.1 * NSEC_PER_SEC);
    //设置timer执行的事件
    __weak typeof(self) weakSelf = self;
    dispatch_source_set_event_handler(timer, ^{
        [weakSelf longConnectToSocket];
    });
    //激活timer
    dispatch_resume(timer);
}

//失去连接
-(void)socketDidDisconnect:(GCDAsyncSocket *)sock
{
    //关闭定时器
    if (timer) {
        dispatch_source_cancel(timer);
    }
    
    NSLog(@"sorry the connect is failure %@",sock.userData);
    if (sock.userData == SocketOfflineByServer) {
        // 服务器掉线，重连
        [self connect];
    }
    else if (sock.userData == SocketOfflineByUser) {
        // 如果由用户断开，不进行重连
        return;
    }
    
}

//将要失去连接
- (void)socket:(GCDAsyncSocket *)sock willDisconnectWithError:(NSError *)err{
    
}


//接受消息进度
- (void)socket:(GCDAsyncSocket *)sock didReadPartialDataOfLength:(NSUInteger)partialLength tag:(long)tag{
    NSLog(@"stream length %lu",(unsigned long)partialLength);
}

//收到消息
-(void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    // 对得到的data值进行解析与转换即可

    
    [self.socket readDataWithTimeout:5 tag:0];
}


//长连接 - 发送心跳包
- (void)longConnectToSocket{


    //在长连接中读取数据
    [self.socket readDataWithTimeout:5 tag:0];
}


@end
