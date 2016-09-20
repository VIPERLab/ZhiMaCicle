//
//  PhoneContactCell.h
//  YiIM_iOS
//
//  Created by liugang on 16/8/23.
//  Copyright © 2016年 ikantech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhoneContactCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *phoneNumber;

@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UIImageView *avtar;
@end
