//
//  ServiceMoreThanOneMsgCell.h
//  ZhiMaBaoBao
//
//  Created by ios开发 on 16/10/31.
//  Copyright © 2016年 liugang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZMServiceMessage.h"

@protocol MoreThanOneCellDelegate <NSObject>

- (void)havetouchCell:(ZMServiceMessage*)message;

@end

@interface ServiceMoreThanOneMsgCell : UITableViewCell

@property (nonatomic, strong) UILabel *timeLabel;     // 时间label
@property (nonatomic, strong) UITableView *tableview; // 消息列表
@property (nonatomic, strong) UIImageView *headIV; // headview图片
@property (nonatomic, strong) UILabel *headLabel;  // headview 标题
@property (nonatomic, weak) id<MoreThanOneCellDelegate>delegate;

@property (nonatomic, strong) ZMServiceMessage *message;

@end
