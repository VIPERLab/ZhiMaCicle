//
//  BaseNavigationController.m
//  ZhiMaBaoBao
//
//  Created by liugang on 16/9/20.
//  Copyright © 2016年 liugang. All rights reserved.
//

#import "BaseNavigationController.h"

@interface BaseNavigationController ()<UIGestureRecognizerDelegate>

@end

@implementation BaseNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //右滑返回手势
    self.interactivePopGestureRecognizer.delegate = self;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    
    //如果是根控制器，则禁用
    if (self.childViewControllers.count == 1) {
        return NO;
    }
    return YES;
}

@end
