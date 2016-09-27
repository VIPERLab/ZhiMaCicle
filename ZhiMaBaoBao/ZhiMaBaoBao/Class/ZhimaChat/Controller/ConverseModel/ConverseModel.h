//
//  ConverseModel.h
//  ZhiMaBaoBao
//
//  Created by mac on 16/9/26.
//  Copyright © 2016年 liugang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ConverseModel : NSObject

/**
 *  时间
 */
@property (nonatomic, copy) NSString *time;

/**
 *  会话类型  0:单聊  1:群聊
 */
@property (nonatomic, copy) NSString *converseType;

/**
 *  会话id:收到消息=fromUid , 发送消息=toUid
 */
@property (nonatomic, copy) NSString *converseId;

/**
 *  未读消息数
 */
@property (nonatomic, copy) NSString *unReadCount;


/**
 *  是否置顶 - 1:置顶  0:不置顶
 */
@property (nonatomic, assign) BOOL topChat;

/**
 *  是否免打扰 1:是免打扰 0:不是免打扰
 */
@property (nonatomic, assign) BOOL disturb;

/**
 *  会话名称
 */
@property (nonatomic, copy) NSString *converseName;

/**
 *  会话头像
 */
@property (nonatomic, copy) NSString *converseHead_photo;

/**
 *  最后一条消息的内容
 */
@property (nonatomic, copy) NSString *lastConverse;

@end
