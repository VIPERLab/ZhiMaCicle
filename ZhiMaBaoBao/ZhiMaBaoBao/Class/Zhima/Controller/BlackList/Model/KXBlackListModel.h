//
//  KXBlackListModel.h
//  YiIM_iOS
//
//  Created by mac on 16/8/31.
//  Copyright © 2016年 ikantech. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KXBlackListModel : NSObject

@property (nonatomic, assign) int friend_type;  //好友类型 1:新朋友， 2:好友 3:黑名单

@property (nonatomic, copy) NSString *friend_nick; //备注名字

@property (nonatomic, copy) NSString *openfireaccount;

@property (nonatomic, copy) NSString *head_photo;

@property (nonatomic, copy) NSString *username; //用户名字

@end
