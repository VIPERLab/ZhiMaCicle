//
//  AvtarAndNameCell.h
//  ZhiMaBaoBao
//
//  Created by liugang on 16/10/5.
//  Copyright © 2016年 liugang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ConverseModel.h"   //会话模型
#import "ZhiMaFriendModel.h"

@interface AvtarAndNameCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *avtar;
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (nonatomic, strong) ConverseModel *conversion;
@property (nonatomic, strong) ZhiMaFriendModel *friendModel;
@end
