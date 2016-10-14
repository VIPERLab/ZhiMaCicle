//
//  ZMCallViewCell.h
//  ZhiMaBaoBao
//
//  Created by ios开发 on 16/10/13.
//  Copyright © 2016年 liugang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LGCallRecordModel.h"

@protocol ZMCallCellDelegate <NSObject>

- (void)checkDetailInfoWithModel:(LGCallRecordModel *)model;

@end

@interface ZMCallViewCell : UITableViewCell

@property (nonatomic, strong) LGCallRecordModel *model;
@property (nonatomic, weak) id<ZMCallCellDelegate>delegate;

@end
