//
//  GroupChatModel.h
//  ZhiMaBaoBao
//
//  Created by mac on 16/9/28.
//  Copyright © 2016年 liugang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GroupChatModel : NSObject
//converseId TEXT NOT NULL, groupId TEXT NOT NULL, groupName TEXT NOT NULL, notice TEXT NOT NULL, topChat INTEGER, disturb INTEGER, saveToMailList INTEGER, myGroupName TEXT NOT NULL, showMemberName INTEGER

/* 会话id */
@property (nonatomic, copy) NSString *converseId;

/* 群聊id */
@property (nonatomic, copy) NSString *groupId;

/* 群聊名字 */
@property (nonatomic, copy) NSString *groupName;

/* 群聊公告 */
@property (nonatomic, copy) NSString *notice;

/* 我在群聊的名称 */
@property (nonatomic, copy) NSString *myGroupName;

/* 是否展示成员名称 0：否 1：是 */
@property (nonatomic, assign) BOOL showMemberName;

/* 是否置顶 0：否 1：是 */
@property (nonatomic, assign) BOOL topChat;

/* 是否免打扰 0：否 1：是 */
@property (nonatomic, assign) BOOL disturb;

/* 是否保存到通讯录 0：否 1：是 */
@property (nonatomic, assign) BOOL saveToMailList;





@end
