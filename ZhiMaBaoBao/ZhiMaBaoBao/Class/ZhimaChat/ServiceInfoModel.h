//
//  ServiceInfoModel.h
//  ZhiMaBaoBao
//
//  Created by liugang on 16/11/2.
//  Copyright © 2016年 liugang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ServiceInfoModel : NSObject

/**
 服务号id
 */
@property (nonatomic, copy) NSString *serviceId;

/**
 服务号头像
 */
@property (nonatomic, copy) NSString *serviceLogo;

/**
 服务号名称
 */
@property (nonatomic, copy) NSString *serviceName;

/**
 服务号介绍
 */
@property (nonatomic, copy) NSString *serviceIntro;

/**
 服务号主体 == 服务号公司名
 */
@property (nonatomic, copy) NSString *serviceMaster;

/**
 服务号客服电话
 */
@property (nonatomic, copy) NSString *serviceTel;

/**
 服务号经营范围
 */
@property (nonatomic, copy) NSString *serviceRange;

/**
 服务号经度
 */
@property (nonatomic, copy) NSString *serviceLongitude;

/**
 服务号纬度
 */
@property (nonatomic, copy) NSString *serviceLantitude;

/**
 是否接收该服务号消息 ，默认1
 */
@property (nonatomic, assign) int serviceReceiveMsg;

@property (nonatomic, assign) BOOL topChat;             //聊天置顶
@end
