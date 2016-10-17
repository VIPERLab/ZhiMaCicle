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

//- (void)setGroupUserVos:(NSArray<GroupUserModel *> *)groupUserVos{
//    
//    if (!self.create_usreid) {
//        return;
//    }
//    
//    NSMutableArray *array = [NSMutableArray array];
//    array = [groupUserVos mutableCopy];
//    
//    GroupUserModel *flagModel;
//    for (GroupUserModel *model in groupUserVos) {
//        if ([model.userId isEqualToString:self.create_usreid]) {
//            flagModel = model;
//        }
//    }
//    
//    [array removeObject:flagModel];
//    [array insertObject:flagModel atIndex:0];
//    
//    _groupUserVos = array;
//}

@end
