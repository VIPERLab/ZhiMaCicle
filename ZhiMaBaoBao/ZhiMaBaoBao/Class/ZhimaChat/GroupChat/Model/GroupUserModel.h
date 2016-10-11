//
//  GroupUserModel.h
//  ZhiMaBaoBao
//
//  Created by liugang on 16/10/6.
//  Copyright © 2016年 liugang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GroupUserModel : NSObject

 /** 群成员昵称*/
@property (nonatomic, copy) NSString *friend_nick;

 /** 群成员头像*/
@property (nonatomic, copy) NSString *head_photo;

 /** 群成员uid*/
@property (nonatomic, copy) NSString *groupId;

 /** 群成员userId*/
@property (nonatomic, copy) NSString *userId;



@end
