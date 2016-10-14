//
//  GroupChatListController.h
//  ZhiMaBaoBao
//
//  Created by liugang on 16/10/5.
//  Copyright © 2016年 liugang. All rights reserved.
//

#import "BaseViewController.h"
#import "LGMessage.h"
@interface GroupChatListController : BaseViewController

@property (nonatomic, assign) BOOL isBigImageTrans; //是大图转发
@property (nonatomic, strong) LGMessage *transMsg;   //转发消息
@end
