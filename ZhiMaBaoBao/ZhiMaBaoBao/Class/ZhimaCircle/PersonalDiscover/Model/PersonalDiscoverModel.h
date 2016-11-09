//
//  PersonalDiscoverPhotoModel.h
//  YiIM_iOS
//
//  Created by mac on 16/8/23.
//  Copyright © 2016年 ikantech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MJExtension.h"

@interface PersonalDiscoverModel : NSObject

@property (nonatomic, assign) NSInteger content_type; //1是文字， 2是链接

@property (nonatomic, copy) NSString *img_s;  //图片地址的字符串

@property (nonatomic, copy) NSString *content;  //朋友圈内容

@property (nonatomic, assign) NSInteger ID;

@property (nonatomic, copy) NSString *article_link; //文章链接地址

@property (nonatomic, strong) NSArray *imageList;

@property (nonatomic, assign) CGFloat cellHight;

@end
