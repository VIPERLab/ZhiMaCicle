//
//  ChatController.h
//  ZhiMaBaoBao
//
//  Created by liugang on 16/9/21.
//  Copyright © 2016年 liugang. All rights reserved.
//

#import "BaseViewController.h"

@interface ChatController : BaseViewController

@property (nonatomic, copy) NSString *conversionId;

//会话类型
@property (nonatomic, assign) ConversionType converseType;
/**
 *  会话名称
 */
@property (nonatomic, copy) NSString *conversionName;
//会话头像
@property (nonatomic, copy) NSString *converseLogo;

//未读消息条数
@property (nonatomic, assign)NSInteger numOfUnread;

@end
