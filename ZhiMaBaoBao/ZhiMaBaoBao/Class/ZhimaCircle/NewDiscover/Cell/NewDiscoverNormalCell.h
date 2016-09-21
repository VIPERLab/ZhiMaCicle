//
//  NewDiscoverNormalCell.h
//  YiIM_iOS
//
//  Created by mac on 16/8/22.
//  Copyright © 2016年 ikantech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NewDiscoverNormalCell : UITableViewCell


@property (nonatomic, copy) NSString *tipsName;
@property (nonatomic, copy) NSString *subTitleName;

@property (nonatomic, assign) BOOL isSelected;

- (void)setIconViewWithImageName:(NSString *)imageName Status:(UIControlState)status;

@end
