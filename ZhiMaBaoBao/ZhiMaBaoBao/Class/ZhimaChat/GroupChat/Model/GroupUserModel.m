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

@implementation GroupActModel

- (instancetype)init{
    self = [super init];
    if (self) {
        self.fromUsername = USERINFO.username;
        self.fromUserPhoto = USERINFO.head_photo;
        self.fromUid = USERINFO.userID;
    }
    return self;
}

- (void)setGroupLogo:(NSString *)groupLogo{
    _groupLogo = groupLogo;
    self.converseLogo = groupLogo;
}

- (void)setGroupName:(NSString *)groupName{
    _groupName = groupName;
    self.converseName = groupName;
}

@end
