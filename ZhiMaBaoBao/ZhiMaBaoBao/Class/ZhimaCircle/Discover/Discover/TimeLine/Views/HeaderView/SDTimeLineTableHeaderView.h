//
//  SDTimeLineTableHeaderView.h
//  GSD_WeiXin(wechat)
//
//  Created by gsd on 16/2/25.
//  Copyright © 2016年 GSD. All rights reserved.
//


#import <UIKit/UIKit.h>
@class SDTimeLineTableHeaderView;

@protocol SDTimeLineTableHeaderViewDelegate <NSObject>

@optional
- (void)SDTimeLineTableHeaderViewHeaderViewDidClick:(SDTimeLineTableHeaderView *)headerView;
- (void)SDTimeLineTableHeaderViewBackGroundViewDidClick:(SDTimeLineTableHeaderView *)header andBackGround:(UIButton *)backGround;
- (void)SDTimeLineTableHeaderViewTipsViewDidClick:(SDTimeLineTableHeaderView *)header;

@end

@interface SDTimeLineTableHeaderView : UIView
@property (nonatomic, copy) NSString *signName;
@property (nonatomic, copy) NSString *BJImage;
@property (nonatomic, copy) NSString *userImage;
@property (nonatomic, copy) NSString *userName;
@property (nonatomic, copy) NSString *sessionID;
@property (nonatomic, copy) NSString *openFirAccount;

@property (nonatomic, strong) UIButton *backgroundImageView;

@property (nonatomic, weak) id <SDTimeLineTableHeaderViewDelegate> delegate;



@end
