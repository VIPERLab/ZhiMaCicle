//
//  GroupAllMemberCell.h
//  ZhiMaBaoBao
//
//  Created by mac on 16/10/10.
//  Copyright © 2016年 liugang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GroupUserModel.h"

@interface GroupAllMemberCell : UITableViewCell

@property (nonatomic, weak) GroupUserModel *model;

// 是否是删除样式
@property (nonatomic, assign) BOOL isDeletedMembers;


@end
