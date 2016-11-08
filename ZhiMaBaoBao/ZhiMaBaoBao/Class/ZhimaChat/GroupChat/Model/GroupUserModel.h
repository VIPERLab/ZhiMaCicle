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

/**
 群成员在群聊中的自定义名字
 */
@property (nonatomic, copy) NSString *memberGroupName;

 /** 群成员头像*/
@property (nonatomic, copy) NSString *head_photo;

 /** 群成员uid*/
@property (nonatomic, copy) NSString *groupId;

 /** 群成员userId*/
@property (nonatomic, copy) NSString *userId;

/* 该群成员在这个群的状态， 0 是在群里，  1 表示异常状态（被踢、退出、删除等状态） */
@property (nonatomic, assign) BOOL memberGroupState;

//是否选中。 （用于删除群成员时，标记已选的群成员）
@property (nonatomic, assign) BOOL selectedGroup;


@end
