//
//  ServiceMsgCell.h
//  ZhiMaBaoBao
//
//  Created by ios开发 on 16/11/1.
//  Copyright © 2016年 liugang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZMServiceMessage.h"


@interface ServiceMsgCell : UITableViewCell

@property (nonatomic, strong) UILabel *titleLabel;   // 消息标题
@property (nonatomic, strong) UIImageView *msgIV;    // 消息图片
@property (nonatomic, strong) ZMServiceMessage *message;

@end
