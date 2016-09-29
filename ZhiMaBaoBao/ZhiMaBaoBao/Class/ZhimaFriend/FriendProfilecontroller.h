//
//  FriendProfilecontroller.h
//  ZhiMaBaoBao
//
//  Created by liugang on 16/9/29.
//  Copyright © 2016年 liugang. All rights reserved.
//

//好友类型

#import "BaseViewController.h"

@interface FriendProfilecontroller : BaseViewController

@property (nonatomic, copy) NSString *userId;           //用户id
@property (nonatomic, assign) FriendType friendType;    //好友类型

@end
