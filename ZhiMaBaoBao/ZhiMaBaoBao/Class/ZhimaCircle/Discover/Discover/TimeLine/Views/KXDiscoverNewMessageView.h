//
//  KXDiscoverNewMessageView.h
//  YiIM_iOS
//
//  Created by mac on 16/9/7.
//  Copyright © 2016年 ikantech. All rights reserved.
//

#import <UIKit/UIKit.h>
@class KXDiscoverNewMessageView;
@protocol KXDiscoverNewMessageViewDelegate <NSObject>

@optional
- (void)SDTimeLineTableHeaderViewTipsViewDidClick:(KXDiscoverNewMessageView *)messageView;

@end

@interface KXDiscoverNewMessageView : UIView

@property (nonatomic, weak) id <KXDiscoverNewMessageViewDelegate> delegate;



- (void)showNewMessageViewWith:(NSString *)iconURL andNewMessageCount:(int)count;

@end
