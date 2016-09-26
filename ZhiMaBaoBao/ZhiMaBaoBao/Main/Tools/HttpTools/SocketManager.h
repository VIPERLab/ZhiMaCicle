//
//  SocketManager.h
//  ZhiMaBaoBao
//
//  Created by liugang on 16/9/22.
//  Copyright © 2016年 liugang. All rights reserved.
//

static NSString *HOST = @"192.168.1.249"; //socket
static const uint16_t PORT = 9093;

//消息请求类型
typedef NS_OPTIONS(NSUInteger, RequestType) {
    RequestTypeLogin    = 0,   //登录
    RequestTypeHeart,          //心跳包
    RequestTypeMessage         //接收，发送消息
};

//生成签名的apikey
#define APIKEY @"apikey=yihezhaizhima20162018"


#import <Foundation/Foundation.h>
#import "GCDAsyncSocket.h"
#import "LGMessage.h"

@protocol SocketManagerDelegate <NSObject>

@optional
- (void)recievedMessage:(LGMessage *)message;

@end


@interface SocketManager : NSObject

@property (nonatomic, assign) id<SocketManagerDelegate> delegate;

+ (instancetype)shareInstance;

/**
 *  连接服务器
 */
- (void)connect;

/**
 *  断开连接
 */
- (void)disconnect;

/**
 *  发送消息
 *
 *  @param message 消息数据模型
 */
- (void)sendMessage:(LGMessage *)message;


@end
