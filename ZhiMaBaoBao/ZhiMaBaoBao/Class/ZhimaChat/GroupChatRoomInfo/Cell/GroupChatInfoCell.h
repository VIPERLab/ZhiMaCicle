//
//  GroupChatInfoCell.h
//  ZhiMaBaoBao
//
//  Created by mac on 16/10/5.
//  Copyright © 2016年 liugang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GroupChatInfoCell : UITableViewCell

@property (nonatomic, copy) NSString *title;

@property (nonatomic, copy) NSString *subTitle;

@property (nonatomic, copy) NSString *imageName;

@property (nonatomic, weak) NSIndexPath *indexPath;

@property (nonatomic, copy) NSString *converseId;

@property (nonatomic, assign) BOOL showStatuSwitch;
@property (nonatomic, strong) UISwitch *statusSwitch;

@end
