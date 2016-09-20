//
//  LGQueryCell.h
//  YiIM_iOS
//
//  Created by liugang on 16/8/31.
//  Copyright © 2016年 ikantech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LGQueryResModel.h"

@protocol LGQueryCellDelegate <NSObject>

- (void)addNewFriend:(NSInteger)row;

@end

@interface LGQueryCell : UITableViewCell

@property (nonatomic, strong) LGQueryResModel *model;
@property (nonatomic, assign) id<LGQueryCellDelegate> delegate;
@property (nonatomic, assign) NSInteger row;
@end
