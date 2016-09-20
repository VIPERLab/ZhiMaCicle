//
//  MyAccountHeaderView.h
//  YiIM_iOS
//
//  Created by mac on 16/8/25.
//  Copyright © 2016年 ikantech. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MyAccountHeaderView;

@protocol MyAccountHeaderViewDelegate <NSObject>

@optional
- (void)MyAccountHeaderView:(MyAccountHeaderView *)headerView DidClickButton:(UIButton *)sender;

@end

@interface MyAccountHeaderView : UIView


@property (nonatomic, weak) UILabel *moneyLabel;  //零钱数

@property (nonatomic, weak) id <MyAccountHeaderViewDelegate> delegate;


- (void)setButtonWithArray:(NSArray *)imageArray andSubTitleArray:(NSArray *)subTitleArray andSubTitleColor:(UIColor *)titleColor;
@end
