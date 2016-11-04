//
//  LGServiceModel.h
//  ZhiMaBaoBao
//
//  Created by liugang on 16/11/3.
//  Copyright © 2016年 liugang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LGServiceModel : NSObject

//服务消息id
@property (nonatomic, copy) NSString *sid;
//服务消息类型
@property (nonatomic, assign) ServiceMessageType type;
//服务消息标题
@property (nonatomic, copy) NSString *text;
//服务号消息接收时间
@property (nonatomic, copy) NSString *msgtime;
@end
