//
//  GroupUserModel.m
//  ZhiMaBaoBao
//
//  Created by liugang on 16/10/6.
//  Copyright © 2016年 liugang. All rights reserved.
//  群成员模型

#import "GroupUserModel.h"

@implementation GroupUserModel

+ (NSDictionary *)mj_replacedKeyFromPropertyName {
    return @{
             @"groupId" : @"uid"
             };
}

@end
