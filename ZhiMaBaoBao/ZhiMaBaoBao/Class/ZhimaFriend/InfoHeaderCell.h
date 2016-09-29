//
//  InfoHeaderCell.h
//  YiIM_iOS
//
//  Created by liugang on 16/8/12.
//  Copyright © 2016年 ikantech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SDBrowserImageView.h"
#import "ZhiMaFriendModel.h"


@interface InfoHeaderCell : UITableViewCell
@property (nonatomic, strong) ZhiMaFriendModel *friendModel;

@property (weak, nonatomic) IBOutlet SDBrowserImageView *avtar;
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *nickName;
@property (weak, nonatomic) IBOutlet UIImageView *sexBtn;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *widthConstraints;

@end
