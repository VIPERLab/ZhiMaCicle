//
//  BaseViewController.h
//  ZhiMaBaoBao
//
//  Created by mac on 16/9/19.
//  Copyright © 2016年 liugang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BaseViewController : UIViewController

//设置标题
- (void)setCustomTitle:(NSString *)title;

//添加右侧items
- (void)setCustomRightItems;
@end
