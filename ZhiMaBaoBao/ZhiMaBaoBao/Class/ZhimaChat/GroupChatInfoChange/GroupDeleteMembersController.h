//
//  GroupDeleteMembersController.h
//  ZhiMaBaoBao
//
//  Created by liugang on 16/10/25.
//  Copyright © 2016年 liugang. All rights reserved.
//

#import "BaseViewController.h"
#import "GroupUserModel.h"

@interface GroupDeleteMembersController : BaseViewController

@property (nonatomic, strong) NSMutableArray<GroupUserModel *> *membersArr;  //群成员数组
@property (nonatomic, copy) NSString *groupId;  //群id
@end
