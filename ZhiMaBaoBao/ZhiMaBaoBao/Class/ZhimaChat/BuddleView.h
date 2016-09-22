//
//  BuddleView.h
//  ZhiMaBaoBao
//
//  Created by liugang on 16/9/22.
//  Copyright © 2016年 liugang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LGMessage.h"

@interface BuddleView : UIImageView

/** 消息模型*/
@property (nonatomic, strong) LGMessage *message;
@end
