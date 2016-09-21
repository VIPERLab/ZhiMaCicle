//
//  KXLocationModel.h
//  YiIM_iOS
//
//  Created by mac on 16/8/29.
//  Copyright © 2016年 ikantech. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KXLocationModel : NSObject

//地区名字
@property (nonatomic, copy) NSString *region_name;

//地区id
@property (nonatomic, copy) NSString *region_id;

//上一级id
@property (nonatomic, copy) NSString *parent_id;

@end
