//
//  ServiceDetailInfoViewController.h
//  ZhiMaBaoBao
//
//  Created by liugang on 16/11/1.
//  Copyright © 2016年 liugang. All rights reserved.
//

#import "BaseViewController.h"

@interface ServiceDetailInfoViewController : BaseViewController
//服务号名称
@property (nonatomic, copy) NSString *serviceName;
//服务号id
@property (nonatomic, copy) NSString *serviceId;
//是否关注该服务号
@property (nonatomic, assign) BOOL isAttention;
@end
