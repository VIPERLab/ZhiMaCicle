//
//  ServiceSingleMsgCell.h
//  ZhiMaBaoBao
//
//  Created by ios开发 on 16/10/31.
//  Copyright © 2016年 liugang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ServiceSingleMsgCell : UITableViewCell

@property (nonatomic, strong) UILabel *timeLabel;    // 时间label
@property (nonatomic, strong) UILabel *titleLabel;   // 消息标题
@property (nonatomic, strong) UILabel *contentLabel; // 消息文字内容
@property (nonatomic, strong) UIImageView *msgIV;    // 消息图片
@property (nonatomic, strong) UILabel *msgTimeLabel; // 消息里面的时间label

@end
