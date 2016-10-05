//
//  GroupChatInfoFooterView.h
//  ZhiMaBaoBao
//
//  Created by mac on 16/10/5.
//  Copyright © 2016年 liugang. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol GroupChatInfoFooterViewDelegate <NSObject>

@optional
- (void)GroupChatInfoFooterViewDidClick;

@end

@interface GroupChatInfoFooterView : UIView

@property (nonatomic, weak) id <GroupChatInfoFooterViewDelegate> delegate;

@end
