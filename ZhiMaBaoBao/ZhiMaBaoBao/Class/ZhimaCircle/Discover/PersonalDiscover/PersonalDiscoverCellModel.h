//
//  PersonalDiscoverCellModel.h
//  YiIM_iOS
//
//  Created by mac on 16/8/23.
//  Copyright © 2016年 ikantech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PersonalDiscoverPhotoModel.h"
#import "MJExtension.h"

@interface PersonalDiscoverCellModel : NSObject

@property (nonatomic, weak) NSString *current_location; //当前定位

@property (nonatomic, copy) NSString *day;  //日

@property (nonatomic, copy) NSString *month;//月

@property (nonatomic, copy) NSString *year; //年

@property (nonatomic, assign) int ID;  //朋友圈ID



@property (nonatomic, strong) NSArray <PersonalDiscoverPhotoModel *> *imglist;



@end
