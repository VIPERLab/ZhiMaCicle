//
//  ZhiMaCollectionDetailController.h
//  ZhiMaBaoBao
//
//  Created by mac on 16/10/7.
//  Copyright © 2016年 liugang. All rights reserved.
//

#import "BaseViewController.h"
@class ZhiMaCollectionModel;

@interface ZhiMaCollectionDetailController : BaseViewController


@property (nonatomic, weak) ZhiMaCollectionModel *model;

@property (nonatomic, copy) NSString *vedioPath;

@end
