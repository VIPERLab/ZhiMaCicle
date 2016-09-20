//
//  KXLocationCell.h
//  YiIM_iOS
//
//  Created by mac on 16/8/29.
//  Copyright © 2016年 ikantech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KXLocationModel.h"

@interface KXLocationCell : UITableViewCell

@property (nonatomic, weak) KXLocationModel *model;

@property (nonatomic, assign) BOOL isShowLocation;



@end
