//
//  DiscoverDetailHeaderView.h
//  DemoDiscover
//
//  Created by kit on 16/8/21.
//  Copyright © 2016年 kit. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SDTimeLineCellModel.h"
@class DiscoverDetailHeaderView;
@class SDTimeLineCellCommentItemModel;
@protocol DiscoverDetailDelegete <NSObject>
//菜单栏点击事件
- (void)DiscoverDetailOperationButtonDidClickLike:(DiscoverDetailHeaderView *)view;
- (void)DiscoverDetailOperationButtonDidClickComment:(DiscoverDetailHeaderView *)view;
//删除朋友圈事件
- (void)DiscoverDetailDeletedButtonDidClick:(DiscoverDetailHeaderView *)view;
//点击评论别人事件
- (void)DidClickOtherComment:(DiscoverDetailHeaderView *)header andCommentItems:(SDTimeLineCellCommentItemModel *)commentItems andCommentView:(UIView *)commentView;
//点击头像事件
- (void)DidClickLikeItemButton:(SDTimeLineCellLikeItemModel *)likeModel;

- (void)commentViewDidClickMLLink:(NSString *)linkValue andLinkType:(int)type;

@end

@interface DiscoverDetailHeaderView : UIView

@property (nonatomic, copy) NSString *header_url;

@property (nonatomic, copy) NSString *userName;

@property (nonatomic, copy) NSString *contentText;

@property (nonatomic, weak) SDTimeLineCellModel *model;
@property (nonatomic, weak) id <DiscoverDetailDelegete> delegate;
@end
