//
//  ZMQuestionView.h
//  ZhiMaBaoBao
//
//  Created by ios开发 on 16/11/3.
//  Copyright © 2016年 liugang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZMQuestionView : UIView

@property (nonatomic, strong) UIViewController *vc; // 父视图控制器
@property (nonatomic, copy) NSString *questionStr;   //芝麻问题

@end
