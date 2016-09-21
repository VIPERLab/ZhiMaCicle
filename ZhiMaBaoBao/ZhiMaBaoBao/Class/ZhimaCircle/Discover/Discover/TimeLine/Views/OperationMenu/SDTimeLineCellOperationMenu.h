//
//  SDTimeLineCellOperationMenu.h
//  GSD_WeiXin(wechat)
//
//  Created by aier on 16/4/2.
//  Copyright © 2016年 GSD. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SDTimeLineCellOperationMenu;

@interface SDTimeLineCellOperationMenu : UIView

@property (nonatomic, assign, getter = isShowing) BOOL show;

@property (nonatomic, assign) BOOL isLike;    // 0为未点赞 1为已点赞

@property (nonatomic, copy) void (^likeButtonClickedOperation)(SDTimeLineCellOperationMenu *menu);
@property (nonatomic, copy) void (^commentButtonClickedOperation)();


@end
