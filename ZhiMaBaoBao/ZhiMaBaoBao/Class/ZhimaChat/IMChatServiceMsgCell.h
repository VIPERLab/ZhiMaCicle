//
//  IMChatServiceMsgCell.h
//  ZhiMaBaoBao
//
//  Created by ios开发 on 16/11/2.
//  Copyright © 2016年 liugang. All rights reserved.
//

#import "BaseChatTableViewCell.h"

@interface IMChatServiceMsgCell : BaseChatTableViewCell

@property (nonatomic, strong) UILabel *titleLabel; // 标题
@property (nonatomic, strong) UILabel *contentLabel; // 内容
@property (nonatomic, strong) UIImageView *serviceMsgPopIV; // 服务号信息气泡
@property (nonatomic, strong) UIImageView *serviceMsgIV; // 图片

@end
