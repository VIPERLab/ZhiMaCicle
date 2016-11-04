//
//  ZhiMaCollectionCell.h
//  ZhiMaBaoBao
//
//  Created by mac on 16/10/7.
//  Copyright © 2016年 liugang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZhiMaCollectionModel.h"
@class ZhiMaCollectionModel;

@protocol ZhiMaCollectionCellDelegate <NSObject>

@optional
- (void)vedioButtonDidClick:(ZhiMaCollectionModel *)model;


@end

@interface ZhiMaCollectionCell : UITableViewCell

@property (nonatomic, weak) ZhiMaCollectionModel *model;

@property (nonatomic, weak) id <ZhiMaCollectionCellDelegate> delegate;

@end
