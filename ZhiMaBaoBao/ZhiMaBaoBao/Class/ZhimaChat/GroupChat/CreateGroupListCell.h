//
//  CreateGroupListCell.h
//  ZhiMaBaoBao
//
//  Created by liugang on 16/10/5.
//  Copyright © 2016年 liugang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZhiMaFriendModel.h"

@protocol GreateGroupListCellDelegate <NSObject>

- (void)selectGroupMember:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath;

@end

@interface CreateGroupListCell : UITableViewCell

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *avtarLeftMargin;
@property (weak, nonatomic) IBOutlet UIButton *selectFlagBtn;
@property (weak, nonatomic) IBOutlet UIImageView *avtar;
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (nonatomic, strong) NSIndexPath *indexPath;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) ZhiMaFriendModel *friendModel;
@property (nonatomic, assign) id<GreateGroupListCellDelegate> delegate;

@property (nonatomic, strong) NSArray *selectedMembers;     //新建群聊时已选成员 userID
@end
