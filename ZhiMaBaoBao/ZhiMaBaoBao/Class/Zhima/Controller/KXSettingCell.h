//
//  KXSettingCell.h
//  ZhiMaBaoBao
//
//  Created by mac on 16/9/19.
//  Copyright © 2016年 liugang. All rights reserved.
//

#import <UIKit/UIKit.h>
@class KXSettingCell;
@protocol KXSettingCellDelegate <NSObject>

@optional
- (void)switchValueDidChanage:(KXSettingCell *)cell andSwitch:(UISwitch *)ZhiMaSwitch;

@end

@interface KXSettingCell : UITableViewCell

@property (nonatomic, copy) NSString *title;

@property (nonatomic, assign) BOOL switchStatus;

@property (nonatomic, weak) id <KXSettingCellDelegate> delegate;

@end
