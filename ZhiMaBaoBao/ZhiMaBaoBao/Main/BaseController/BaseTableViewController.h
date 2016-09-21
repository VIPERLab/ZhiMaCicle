//
//  BaseTableViewController.h
//  YiIM_iOS
//
//  Created by liugang on 16/8/12.
//  Copyright © 2016年 ikantech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BaseTableViewController : UITableViewController

- (void)setCustomTitle:(NSString *)title;

//导航栏返回方法
- (void)backAction;
@end
