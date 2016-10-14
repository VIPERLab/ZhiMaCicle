//
//  TransPopView.h
//  ZhiMaBaoBao
//
//  Created by liugang on 16/10/9.
//  Copyright © 2016年 liugang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LGMessage.h"

@protocol TransPopViewDelegate <NSObject>

- (void)transformMessage:(LGMessage *)message toUserId:(NSString *)userId;

@end

@interface TransPopView : UIView

@property (nonatomic, assign) id<TransPopViewDelegate> delegate;

//初始化popView
- (instancetype)initWithMessage:(LGMessage *)message toUserId:(NSString *)userId isGroup:(BOOL)isGroup;

- (void)show;


@end
