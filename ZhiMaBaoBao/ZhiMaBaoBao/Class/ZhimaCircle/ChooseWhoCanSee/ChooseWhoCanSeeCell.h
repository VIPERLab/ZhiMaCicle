//
//  ChooseWhoCanSeeCell.h
//  YiIM_iOS
//
//  Created by mac on 16/8/24.
//  Copyright © 2016年 ikantech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChooserWhoCanSeeCellModel.h"

typedef void(^BlockType)();

@interface ChooseWhoCanSeeCell : UITableViewCell

@property (nonatomic, weak) UILabel *titleLabel;
@property (nonatomic, weak) UILabel *subTitleLabel;

@property (nonatomic, weak) ChooserWhoCanSeeCellModel *model;

@property (nonatomic, copy) BlockType block;

@property (nonatomic, assign) BOOL isPrivate; //0是公开，1是私密


@end
