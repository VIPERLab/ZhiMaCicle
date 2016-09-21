//
//  MyAccountModel.h
//  YiIM_iOS
//
//  Created by mac on 16/8/26.
//  Copyright © 2016年 ikantech. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MyAccountModel : NSObject

@property (nonatomic, copy) NSString *ID;           //用户id

@property (nonatomic, copy) NSString *uphone;       //用户的电话

@property (nonatomic, copy) NSString *phoneusetime; //使用时间

@property (nonatomic, copy) NSString *amount;   //分润金额

@property (nonatomic, copy) NSString *code;

@property (nonatomic, copy) NSString *user_type;

@end
