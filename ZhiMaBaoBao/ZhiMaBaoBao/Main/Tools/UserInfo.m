//
//  UserInfo.m
//  ZhiMaBaoBao
//
//  Created by liugang on 16/9/19.
//  Copyright © 2016年 liugang. All rights reserved.
//  用户数据本地存储

#import "UserInfo.h"

@implementation UserInfo

MJCodingImplementation

+ (NSDictionary *)mj_replacedKeyFromPropertyName {
    return @{
             @"userID" : @"id"
             };
}

+ (instancetype)shareInstance{
    static UserInfo *userInfo = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        userInfo = [[UserInfo alloc] init];
    });
    return userInfo;
}

//保存数据
- (void)save{
//    UserInfo *userInfo = [UserInfo shareInstance];
    
    //获取存储路径
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *path = [documentPath stringByAppendingPathComponent:@"userinfo.user"];
    
    //将自定义对象保存到文件中
    [NSKeyedArchiver archiveRootObject:self toFile:path];
}

//读取数据
+ (instancetype)read{
    //获取存储路径
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *path = [documentPath stringByAppendingPathComponent:@"userinfo.user"];
    
    //从文件中读取对象
    UserInfo *userInfo = [[UserInfo alloc] init];
    userInfo = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
    return userInfo;
}

@end
