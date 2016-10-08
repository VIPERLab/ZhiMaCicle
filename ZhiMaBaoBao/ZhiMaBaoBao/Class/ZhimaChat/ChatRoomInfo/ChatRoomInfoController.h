//
//  ChatRoomInfoController.h
//  ZhiMaBaoBao
//
//  Created by mac on 16/10/5.
//  Copyright © 2016年 liugang. All rights reserved.
//

#import "BaseViewController.h"

@interface ChatRoomInfoController : BaseViewController

/**
 *  用户id
 */
@property (nonatomic, copy) NSString *userId;

@property (nonatomic, copy) NSString *displayName;  //展示名称

@property (nonatomic, copy) NSString *avtarUrl;     //头像url

@end

