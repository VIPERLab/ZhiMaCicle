//
//  GroupChatRoomInfoController.h
//  ZhiMaBaoBao
//
//  Created by mac on 16/10/5.
//  Copyright © 2016年 liugang. All rights reserved.
//

#import "BaseViewController.h"


@interface GroupChatRoomInfoController : BaseViewController
/**
 *  群聊人数
 */
@property (nonatomic, assign) int groupAmount;

@property (nonatomic, copy) NSString *converseId;

@end
