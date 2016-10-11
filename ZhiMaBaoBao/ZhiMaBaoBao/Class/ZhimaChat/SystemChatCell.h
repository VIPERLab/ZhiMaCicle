//
//  SystemChatCell.h
//  ZhiMaBaoBao
//
//  Created by ios开发 on 16/10/10.
//  Copyright © 2016年 liugang. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SystemChatCell : UITableViewCell

@property (nonatomic, strong) UILabel *topLabel;     //顶部的label，如时间
@property (nonatomic, strong) UILabel *systemLabel;  //系统消息内容label

+ (CGFloat)getHeightWithMessage:(NSString *)message topText:(NSString *)topText nickName:(NSString *)nickName;


@end
