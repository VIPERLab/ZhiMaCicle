//
//  SocketManager.h
//  ZhiMaBaoBao
//
//  Created by liugang on 16/9/22.
//  Copyright © 2016年 liugang. All rights reserved.
//

static NSString *HOST = @"192.168.1.249"; //socket
static const uint16_t PORT = 9093;

static NSString *SocketOfflineByServer = @"SocketOfflineByServer";
static NSString *SocketOfflineByUser = @"SocketOfflineByUser";

//socket断线类型
//typedef NS_OPTIONS(NSUInteger, SocketOfflineType){
//    SocketOfflineByServer,  // 服务器掉线，默认为0
//    SocketOfflineByUser,     // 用户主动cut
//};

#import <Foundation/Foundation.h>
#import "GCDAsyncSocket.h"

@interface SocketManager : NSObject

@property (nonatomic, strong) GCDAsyncSocket *socket;       // socket

//@property (nonatomic, assign) SocketOfflineType socketOfflineType;


+ (instancetype)shareInstance;

//连接服务器
- (void)connect;

//手动断开socket
-(void)disconnect;
@end
