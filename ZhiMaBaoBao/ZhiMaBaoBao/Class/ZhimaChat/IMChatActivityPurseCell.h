//
//  IMChatActivityPurseCell.h
//  ZhiMaBaoBao
//
//  Created by ios开发 on 16/10/29.
//  Copyright © 2016年 liugang. All rights reserved.
//

//活动红包cell

#import "BaseChatTableViewCell.h"

@interface IMChatActivityPurseCell : BaseChatTableViewCell

@property (nonatomic, strong) UILabel *titleLabel; // 红包标题
@property (nonatomic, strong) UILabel *contentLabel; // 红包内容

@property (nonatomic, strong) UIImageView *activityPursePopIV; // 活动红包气泡
@property (nonatomic, strong) UIImageView *activtityPurseIV; // 红包占位图

@end
