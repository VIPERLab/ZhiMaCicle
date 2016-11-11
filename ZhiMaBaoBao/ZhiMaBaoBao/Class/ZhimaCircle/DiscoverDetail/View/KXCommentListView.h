//
//  KXCommentListView.h
//  YiIM_iOS
//
//  Created by mac on 16/9/8.
//  Copyright © 2016年 ikantech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SDTimeLineCellModel.h"

@protocol KXCommentListViewDelegate <NSObject>

// 0是个人  1是网址
- (void)DidClickLinkeWithLinkValue:(NSString *)linkValue andType:(int)type;

@end

@interface KXCommentListView : UIView

@property (nonatomic, weak) SDTimeLineCellCommentItemModel *model;

@property (nonatomic, weak) id <KXCommentListViewDelegate> delegate;

@end
