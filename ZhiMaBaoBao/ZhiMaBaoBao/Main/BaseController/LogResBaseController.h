//
//  LogResBaseController.h
//  ZhiMaBaoBao
//
//  Created by liugang on 16/9/19.
//  Copyright © 2016年 liugang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LogResBaseController : UIViewController

//设置导航栏右侧按钮
- (void)setNavRightButton:(NSString *)title;

//导航栏右侧按钮点击方法
- (void)navRightBtnAction;

//导航栏左侧取消按钮点击方法
- (void)navBackAction;

//设置标题
- (void)setNavTitle:(NSString *)title;

//隐藏返回按钮
- (void)hiddenBackBtn;
@end
