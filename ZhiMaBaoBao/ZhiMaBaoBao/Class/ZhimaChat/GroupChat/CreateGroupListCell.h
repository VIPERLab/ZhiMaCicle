//
//  CreateGroupListCell.h
//  ZhiMaBaoBao
//
//  Created by liugang on 16/10/5.
//  Copyright © 2016年 liugang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZhiMaFriendModel.h"

@interface CreateGroupListCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIButton *selectFlagBtn;
@property (weak, nonatomic) IBOutlet UIImageView *avtar;
@property (weak, nonatomic) IBOutlet UILabel *name;

@property (nonatomic, strong) ZhiMaFriendModel *friendModel;
@end
