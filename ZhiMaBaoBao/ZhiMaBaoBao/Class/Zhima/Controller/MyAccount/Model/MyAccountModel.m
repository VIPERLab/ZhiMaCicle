//
//  MyAccountModel.m
//  YiIM_iOS
//
//  Created by mac on 16/8/26.
//  Copyright © 2016年 ikantech. All rights reserved.
//

#import "MyAccountModel.h"
#import "MJExtension.h"

@implementation MyAccountModel

+ (NSDictionary *)mj_replacedKeyFromPropertyName {
    return @{
             @"ID" : @"id"
             };
}

@end
