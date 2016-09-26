//
//  SocketManager.h
//  ZhiMaBaoBao
//
//  Created by liugang on 16/9/22.
//  Copyright © 2016年 liugang. All rights reserved.
//

static NSString *HOST = @"192.168.1.249"; //socket
static const uint16_t PORT = 9093;


#import <Foundation/Foundation.h>
#import "GCDAsyncSocket.h"

@interface SocketManager : NSObject



+ (instancetype)shareInstance;

/**
 *  连接服务器
 */
- (void)connect;

/**
 *  手动断开socket
 */
-(void)disconnect;
@end
