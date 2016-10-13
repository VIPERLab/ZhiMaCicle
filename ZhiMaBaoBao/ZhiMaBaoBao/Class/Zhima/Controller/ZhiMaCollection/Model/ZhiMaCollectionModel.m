//
//  ZhiMaCollectionModel.m
//  ZhiMaBaoBao
//
//  Created by mac on 16/10/7.
//  Copyright © 2016年 liugang. All rights reserved.
//

#import "ZhiMaCollectionModel.h"

@implementation ZhiMaCollectionModel

+ (NSDictionary *)mj_replacedKeyFromPropertyName {
    return @{
             @"ID" : @"id",
             @"head" : @"head_photo",
             @"name" : @"friend_nick",
             @"time" : @"create_time",
             @"type" : @"collection_type",
             @"pic_name" : @"big_img"
             };
}
//@property (nonatomic, copy) NSString *head;
//
//@property (nonatomic, copy) NSString *name;
//
//@property (nonatomic, copy) NSString *time;
//
//@property (nonatomic, copy) NSString *content;
//
//@property (nonatomic, assign) int type;
//
//@property (nonatomic, copy) NSString *pic_name;


-(CGFloat)cellHeight {
    if (self.type == 1) { // 纯文字
        CGFloat contentHeight = [self.content sizeWithFont:[UIFont systemFontOfSize:15] maxSize:CGSizeMake(ScreenWidth - 30, MAXFLOAT)].height;
        return contentHeight + 70;
    } else if (self.type == 3) { // 纯图片
        return 220;
    }
    return 0;
}
@end
