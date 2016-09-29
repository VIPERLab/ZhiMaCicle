//
//  NewFriendsListCell.h
//  ZhiMaBaoBao
//
//  Created by liugang on 16/9/28.
//  Copyright © 2016年 liugang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZhiMaFriendModel.h"

@protocol NewFriendsListCellDelegate <NSObject>
@required
/**
 *  接受好友请求
 */
- (void)acceptNewFriendRequest:(NSIndexPath *)indexPath;

@end

@interface NewFriendsListCell : UITableViewCell

@property (nonatomic, strong) ZhiMaFriendModel *friendModel;
@property (nonatomic, assign) id<NewFriendsListCellDelegate> delegate;
@property (nonatomic, strong) NSIndexPath *indexPath;
@property (weak, nonatomic) IBOutlet UIImageView *avtar;
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *subText;
@property (weak, nonatomic) IBOutlet UIButton *acceptBtn;

- (IBAction)acceptAction:(UIButton *)sender;

@end
