//
//  KXDiscoverDetailCommentView.h
//  YiIM_iOS
//
//  Created by mac on 16/9/8.
//  Copyright © 2016年 ikantech. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SDTimeLineCellCommentItemModel;
@class SDTimeLineCellLikeItemModel;

@protocol KXDiscoverDetailCommentViewDelegate <NSObject>

@optional
// -- 点击评论框
- (void)KXDiscoverDetailCommentViewDidClickCommentView:(UIView *)commentView andCommentModel:(SDTimeLineCellCommentItemModel *)commentModel;

// -- 点击头像
- (void)KXDiscoverDetailCommentViewDidClickLikeView:(UIView *)likeView andLikeModel:(SDTimeLineCellLikeItemModel *)likeItemModel;

- (void)commentViewDidClickMLLink:(NSString *)linkValue andLinkType:(int)type;
@end


@interface KXDiscoverDetailCommentView : UIView

@property (nonatomic, weak) id <KXDiscoverDetailCommentViewDelegate> delegate;

- (void)setupWithLikeItemsArray:(NSArray *)likeItemsArray commentItemsArray:(NSArray *)commentItemsArray;

@end
