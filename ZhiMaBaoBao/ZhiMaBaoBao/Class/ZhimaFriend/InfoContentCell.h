//
//  InfoContentCell.h
//  YiIM_iOS
//
//  Created by liugang on 16/8/12.
//  Copyright © 2016年 ikantech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InfoContentCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *cellTitle;
@property (weak, nonatomic) IBOutlet UILabel *cellContent;
@property (weak, nonatomic) IBOutlet UIView *separtor;

@end
