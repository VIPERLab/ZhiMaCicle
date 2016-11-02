//
//  ServiceInfoModel.h
//  ZhiMaBaoBao
//
//  Created by liugang on 16/11/2.
//  Copyright © 2016年 liugang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ServiceInfoModel : NSObject
@property (nonatomic, copy) NSString *avtarUrl;         //头像url
@property (nonatomic, copy) NSString *serviceName;      //服务号名称
@property (nonatomic, copy) NSString *functionDes;      //功能介绍
@property (nonatomic, copy) NSString *companyName;      //公司名称
@property (nonatomic, assign) BOOL acceptMsg;           //接收消息
@property (nonatomic, assign) BOOL topChat;             //聊天置顶
@end
