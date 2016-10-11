//
//  GroupChatInfoHeaderCell.h
//  ZhiMaBaoBao
//
//  Created by mac on 16/10/5.
//  Copyright © 2016年 liugang. All rights reserved.
//

#import <UIKit/UIKit.h>
@class GroupUserModel;

@protocol GroupChatInfoHeaderCellDelegate <NSObject>

- (void)GroupChatInfoHeaderCellDidClickMemberIcon:(NSString *)menberId;

- (void)GroupChatInfoHeaderCellDelegateDidClickAddMember;

- (void)GroupChatInfoHeaderCellDelegateDidClickDeletedMembers;

@end


@interface GroupChatInfoHeaderCell : UITableViewCell

@property (nonatomic, strong) NSArray <GroupUserModel *>* modelArray;

@property (nonatomic, assign) BOOL isGroupCreater;

@property (nonatomic, weak) id <GroupChatInfoHeaderCellDelegate> delegate;

@end
