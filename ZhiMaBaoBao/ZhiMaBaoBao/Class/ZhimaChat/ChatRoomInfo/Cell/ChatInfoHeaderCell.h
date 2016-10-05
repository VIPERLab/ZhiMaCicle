//
//  ChatInfoHeaderCell.h
//  ZhiMaBaoBao
//
//  Created by mac on 16/10/5.
//  Copyright © 2016年 liugang. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ChatInfoHeaderCellDelegate <NSObject>

@optional
- (void)ChatInfoUserIconDidClick:(NSInteger)index;

@end

@interface ChatInfoHeaderCell : UITableViewCell

@property (nonatomic, copy) NSString *iconName;

@property (nonatomic, copy) NSString *userName;

@property (nonatomic, weak) id <ChatInfoHeaderCellDelegate> delegate;

@end
