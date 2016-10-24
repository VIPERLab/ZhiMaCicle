//
//  NewDiscoverDetailCommentView.h
//  ZhiMaBaoBao
//
//  Created by mac on 16/10/22.
//  Copyright © 2016年 liugang. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SDTimeLineCellCommentItemModel;
@interface NewDiscoverDetailCommentView : UIView

@property (nonatomic, strong) NSArray *commentListArray;

@property (nonatomic, weak) SDTimeLineCellCommentItemModel *model;

@end
