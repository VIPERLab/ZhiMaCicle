//
//  GroupChatChangeGroupNameController.h
//  ZhiMaBaoBao
//
//  Created by mac on 16/10/9.
//  Copyright © 2016年 liugang. All rights reserved.
//

#import "BaseViewController.h"
@class GroupChatModel;
@interface GroupChatChangeGroupNameController : BaseViewController

@property (nonatomic, weak) GroupChatModel *groupModel;

@property (nonatomic, copy) NSString *tipsTitle;

@end
