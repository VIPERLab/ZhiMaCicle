//
//  ZhiMaCollectionModel.h
//  ZhiMaBaoBao
//
//  Created by mac on 16/10/7.
//  Copyright © 2016年 liugang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZhiMaCollectionModel : NSObject

@property (nonatomic, copy) NSString *head;

@property (nonatomic, copy) NSString *name;

@property (nonatomic, copy) NSString *time;

@property (nonatomic, copy) NSString *content;

@property (nonatomic, assign) int type;

@property (nonatomic, copy) NSString *pic_name;

@property (nonatomic, assign) CGFloat cellHeight;

@end