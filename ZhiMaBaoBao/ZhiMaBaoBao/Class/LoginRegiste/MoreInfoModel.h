//
//  MoreInfoModel.h
//  ZhiMaBaoBao
//
//  Created by liugang on 16/10/21.
//  Copyright © 2016年 liugang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MoreInfoModel : NSObject

@property (nonatomic, assign) NSInteger idd;
@property (nonatomic, copy) NSString *item_code;
@property (nonatomic, copy) NSString *item_values;
@property (nonatomic, copy) NSString *item_name;
@property (nonatomic, assign) NSInteger pid;
@property (nonatomic, strong) NSArray<MoreInfoModel *> *list;
@property (nonatomic, copy) NSString *selectedId;
@property (nonatomic, assign) NSInteger item_type;

@end
