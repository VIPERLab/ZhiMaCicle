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


- (NSString *)photoUrl {
    if (self.small_img.length) {
        return self.small_img;
    } else if (self.pic_name.length) {
        return self.pic_name;
    }
    return @"";
}

-(CGFloat)cellHeight {
    if (self.type == 1) { // 纯文字
        CGFloat contentHeight = [self.content sizeWithFont:[UIFont systemFontOfSize:15] maxSize:CGSizeMake(ScreenWidth - 60, MAXFLOAT)].height;
        return contentHeight + 80;
    } else if (self.type == 3) { // 纯图片
        return 220;
    } else if (self.type == 5) { // 语音
        return 150;
    } else if (self.type == 4) { // 视频类型
        return 250;
    }
    return 0;
}
@end
