//
//  PersonalDiscoverCell.h
//  YiIM_iOS
//
//  Created by mac on 16/8/22.
//  Copyright © 2016年 ikantech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PersonalDiscoverCellModel.h"


@class PersonalDiscoverCell;
@class PersonalDiscoverPhotoModel;



@protocol PersonalDiscoverCellDelegate <NSObject>

@optional
- (void)PersonalDiscoverCellFirstCellDidClick;

@end


@interface PersonalDiscoverCell : UITableViewCell


@property (nonatomic, weak) PersonalDiscoverPhotoModel *model;
@property (nonatomic, copy) NSString *openFirAccount;

@property (nonatomic, copy) NSString *year;
@property (nonatomic, copy) NSString *month;
@property (nonatomic, copy) NSString *day;
@property (nonatomic, assign) NSIndexPath *personalIndexPath;
@property (nonatomic, assign) BOOL isShowTimeLabel;

@property (nonatomic, assign) id <PersonalDiscoverCellDelegate> delegate;
@property (nonatomic, strong) NSIndexPath *indexPath;



- (void)setupYear:(NSString *)year andMonth:(NSString *)month andDay:(NSString *)day;


@end
