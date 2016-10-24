//
//  NewDiscoverDetailController.h
//  ZhiMaBaoBao
//
//  Created by mac on 16/10/21.
//  Copyright © 2016年 liugang. All rights reserved.
//

#import "BaseViewController.h"

@interface NewDiscoverDetailController : BaseViewController

@property (nonatomic, copy) NSString *ID; //要查看的朋友圈ID
@property (nonatomic, weak) NSIndexPath *indexPath;
@property (nonatomic, copy) NSString *sessionId;  //用户ID

@end
