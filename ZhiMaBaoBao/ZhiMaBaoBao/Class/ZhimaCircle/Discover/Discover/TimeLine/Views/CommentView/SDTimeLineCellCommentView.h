//
//  SDTimeLineCellCommentView.h
//  GSD_WeiXin(wechat)
//
//  Created by gsd on 16/2/25.
//  Copyright © 2016年 GSD. All rights reserved.
//


#import <UIKit/UIKit.h>

#import "GlobalDefines.h"
@class SDTimeLineCellCommentItemModel;

@protocol SDTimeLineCellCommentViewDelegate <NSObject>

@optional
- (void)SDTimeLineCellCommentViewCommentOther:(SDTimeLineCellCommentItemModel *)model andCommentView:(UIView *)commentView;

@end


@interface SDTimeLineCellCommentView : UIView

- (void)setupWithLikeItemsArray:(NSArray *)likeItemsArray commentItemsArray:(NSArray *)commentItemsArray;

@property (nonatomic, weak) id <SDTimeLineCellCommentViewDelegate> delegate;

@property (nonatomic, copy) void (^didClickCommentLabelBlock)(NSString *commentId, CGRect rectInWindow);

@end
