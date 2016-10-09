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

@property (nonatomic, copy) NSString *titleName;

// 0 是修改群名称  1 是修改自己在本群的昵称
@property (nonatomic, assign) BOOL type;

@end
