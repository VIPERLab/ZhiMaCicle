//
//  GetPurseView.h
//  ZhiMaBaoBao
//
//  Created by ios开发 on 16/11/2.
//  Copyright © 2016年 liugang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GetPurseView : UIView

@property (nonatomic, copy) NSString *logoUrlString;   //logo图片路径
@property (nonatomic, copy) NSString *money;   //金钱数额
@property (nonatomic, strong) UIViewController *vc; // 父视图控制器

@end
