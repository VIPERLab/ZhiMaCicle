//
//  GroupChatAllMembersController.h
//  ZhiMaBaoBao
//
//  Created by mac on 16/10/10.
//  Copyright © 2016年 liugang. All rights reserved.
//

#import "BaseViewController.h"

@interface GroupChatAllMembersController : BaseViewController

@property (nonatomic, strong) NSMutableArray *membersArray;

@property (nonatomic, copy) NSString *groupId;

@property (nonatomic, assign) BOOL isDeletedMembers;

@end
