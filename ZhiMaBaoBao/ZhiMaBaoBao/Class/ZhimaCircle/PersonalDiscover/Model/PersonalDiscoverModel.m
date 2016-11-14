//
//  PersonalDiscoverPhotoModel.m
//  YiIM_iOS
//
//  Created by mac on 16/8/23.
//  Copyright © 2016年 ikantech. All rights reserved.
//

#import "PersonalDiscoverModel.h"

@implementation PersonalDiscoverModel

+ (NSDictionary *)mj_replacedKeyFromPropertyName {
    return @{
             @"ID" : @"id"
             };
}

- (CGFloat)cellHight {
    CGFloat cellHeight = 0;
    if (![self.img_s isEqualToString:@""]) {
        cellHeight = 80;
    } else {
        CGFloat cellHight = [self.content sizeWithFont:[UIFont systemFontOfSize:15] maxSize:CGSizeMake(300, 70)].height;
        cellHeight = cellHight + 15;
    }
    return cellHeight;
}

@end
