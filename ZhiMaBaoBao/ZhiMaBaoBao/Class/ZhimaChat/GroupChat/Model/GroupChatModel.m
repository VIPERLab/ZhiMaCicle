//
//  GroupChatModel.m
//  ZhiMaBaoBao
//
//  Created by mac on 16/9/28.
//  Copyright © 2016年 liugang. All rights reserved.
//

#import "GroupChatModel.h"

@implementation GroupChatModel

+ (NSDictionary *)replacedKeyFromPropertyName{
    return @{
             @"groupId" : @"id",
             @"groupName" : @"groupname",
             @"groupAvtar" : @"img"
             };
}

@end
