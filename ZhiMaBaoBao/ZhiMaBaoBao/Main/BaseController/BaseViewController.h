//
//  BaseViewController.h
//  ZhiMaBaoBao
//
//  Created by mac on 16/9/19.
//  Copyright © 2016年 liugang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BaseViewController : UIViewController

//不带返回按钮
- (void)setNaviTitle:(NSString *)title;

//设置标题 (带返回按钮)
- (void)setCustomTitle:(NSString *)title;

//添加右侧items
- (void)setCustomRightItems;

//导航栏返回方法
- (void)backAction;

//播放系统提示音
//- (void)playSystemAudio;
@end
