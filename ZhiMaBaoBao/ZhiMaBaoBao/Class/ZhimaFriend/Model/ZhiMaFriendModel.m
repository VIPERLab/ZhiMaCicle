//
//  ZhiMaFriendModel.m
//  ZhiMaBaoBao
//
//  Created by mac on 16/9/27.
//  Copyright © 2016年 liugang. All rights reserved.
//

#import "ZhiMaFriendModel.h"

@implementation ZhiMaFriendModel

- (NSString *)displayName{
    NSString *name = nil;
    if (self.user_NickName.length) {
        name = self.user_NickName;
    }else{
        name = self.user_Name;
    }
    return name;
}

+ (NSDictionary *)replacedKeyFromPropertyName{
    return @{
             @"user_Name" : @"username",
             @"user_Id" : @"id",
             @"user_NickName" : @"friend_nick",
             @"user_Head_photo":@"yuan_head_photo"
             };
}
@end
