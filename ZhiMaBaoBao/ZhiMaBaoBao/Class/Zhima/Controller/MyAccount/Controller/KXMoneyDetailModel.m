//
//  KXMoneyDetailModel.m
//  YiIM_iOS
//
//  Created by mac on 16/9/17.
//  Copyright © 2016年 ikantech. All rights reserved.
//

#import "KXMoneyDetailModel.h"
#import "MJExtension.h"
@implementation KXMoneyDetailModel

+ (NSDictionary *)mj_replacedKeyFromPropertyName {
    return @{
             @"ID" : @"id"
             };
}

@end
