//
//  KXCrashChargeCell.h
//  YiIM_iOS
//
//  Created by mac on 16/9/17.
//  Copyright © 2016年 ikantech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "chargeMomeyMdoel.h"
@class KXCrashChargeCell;
@protocol KXCrashChargeCellDelegate <NSObject>

- (void)KXCrashChargeCellTickDidClick:(KXCrashChargeCell *)cell;

@end

@interface KXCrashChargeCell : UITableViewCell
@property (nonatomic, weak) NSIndexPath *indexPath;

@property (nonatomic, weak) chargeMomeyMdoel *model;

@property (nonatomic, weak) id <KXCrashChargeCellDelegate> delegate;

@end
