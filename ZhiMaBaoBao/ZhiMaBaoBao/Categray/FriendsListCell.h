//
//  FriendsListCell.h
//  ZhiMaBaoBao
//
//  Created by liugang on 16/9/28.
//  Copyright © 2016年 liugang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZhiMaFriendModel.h"

@interface FriendsListCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *avtar;
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *unreadLabel;

@property (nonatomic, strong) ZhiMaFriendModel *friendModel;
@end
