//
//  ChatInfoCell.h
//  ZhiMaBaoBao
//
//  Created by mac on 16/10/5.
//  Copyright © 2016年 liugang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChatInfoCell : UITableViewCell

// 标题名字
@property (nonatomic, copy) NSString *title;

// 是否显示开关
@property (nonatomic, assign,getter=isShowSwitch) BOOL showSwitch;

@property (nonatomic, strong) UISwitch *statusSwitch;

// 当前位置
@property (nonatomic, weak) NSIndexPath *indexPath;

// 会话id
@property (nonatomic, copy) NSString *converseID;

@end
