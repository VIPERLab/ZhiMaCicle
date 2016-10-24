//
//  newDiscoverDetailMenu.h
//  ZhiMaBaoBao
//
//  Created by mac on 16/10/24.
//  Copyright © 2016年 liugang. All rights reserved.
//

#import <UIKit/UIKit.h>
@class newDiscoverDetailMenu;

@interface newDiscoverDetailMenu : UIView

@property (nonatomic, assign, getter = isShowing) BOOL show;

@property (nonatomic, assign) BOOL isLike;    // 0为未点赞 1为已点赞

@property (nonatomic, copy) void (^likeButtonClickedOperation)(newDiscoverDetailMenu *menu);
@property (nonatomic, copy) void (^commentButtonClickedOperation)();

@end
