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

@property (nonatomic, assign) BOOL converseType;
/**
 *  会话名称
 */
@property (nonatomic, copy) NSString *conversionName;
@end
