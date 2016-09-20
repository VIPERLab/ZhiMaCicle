//
//  CallBottombar.h
//  ZhiMaBaoBao
//
//  Created by liugang on 16/9/19.
//  Copyright © 2016年 liugang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CallBottombar : UIWindow

//+ (void)shareInstance;
+ (void)show;
+ (void)dismiss;

+ (instancetype)shareinstance;
- (void)show;
- (void)dismiss;
@end
