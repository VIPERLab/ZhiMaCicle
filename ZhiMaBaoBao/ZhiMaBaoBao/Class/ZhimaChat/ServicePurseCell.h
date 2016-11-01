//
//  ServicePurseCell.h
//  ZhiMaBaoBao
//
//  Created by ios开发 on 16/10/31.
//  Copyright © 2016年 liugang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZMServiceMessage.h"

@interface ServicePurseCell : UITableViewCell

@property (nonatomic, strong) UILabel *timeLabel; // 时间label
@property (nonatomic, strong) UILabel *titleLabel;   // 红包标题
@property (nonatomic, strong) UILabel *contentLabel; // 红包文字内容
@property (nonatomic, strong) UIImageView *purseIV;  // 红包图片
@property (nonatomic, strong) ZMServiceMessage *message;


@end
