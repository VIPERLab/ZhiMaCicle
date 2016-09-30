//
//  FMDBManager.h
//  FMDBTestDemo
//
//  Created by mac on 16/9/22.
//  Copyright © 2016年 mac. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDB.h"
@class ConverseModel,LGMessage,ZhiMaFriendModel,GroupChatModel;
@class SDTimeLineCellModel;

typedef void(^ResultBlock)(FMDatabaseQueue *db_Queue, NSString *operationStr);

typedef enum : NSUInteger {
    /* ----   朋友圈相关 ----  */
    ZhiMa_Circle_Table,             //朋友圈内容的表
    ZhiMa_Circle_Comment_Table,     //朋友圈评论的表
    ZhiMa_Circle_Pic_Table,         //朋友圈图片的表
    ZhiMa_Circle_Like_Table,        //朋友圈点赞的表
    
    /* ----   会话相关 ----  */
    ZhiMa_Chat_Converse_Table,       //会话列表 的表
    ZhiMa_Chat_Message_Table,        //消息表
    
    /* ----   用户相关 ----  */
    ZhiMa_User_Message_Table,        //用户信息表
    ZhiMa_NewFriend_Message_Table,     //新好友表
    
    /* ----   群聊相关 ----  */
//    ZhiMa_GroupChat_GroupMessage_Table,            //群聊表
    ZhiMa_GroupChat_GroupMenber_Table              //群成员表
} ZhiMaSqliteTableType;

@interface FMDBManager : NSObject


+ (instancetype)shareManager;

- (FMDatabaseQueue *)getQueueWithType:(ZhiMaSqliteTableType)type;

// 建表
- (void)creatTableWithTableType:(ZhiMaSqliteTableType)type;

// 插表
- (NSString *)InsertDataInTable:(ZhiMaSqliteTableType)type;

// 查表
- (NSString *)SearchTable:(ZhiMaSqliteTableType)type withOption:(NSString *)option;

// 改表
- (NSString *)alterTable:(ZhiMaSqliteTableType)type withOpton1:(NSString *)option1 andOption2:(NSString *)option2;

// 删表
- (NSString *)deletedTableData:(ZhiMaSqliteTableType)type withOption:(NSString *)option;



#pragma mark - 朋友圈存、取操作
//                    ------------   朋友圈表  ----------------
/**
 *  把朋友圈数据存储到数据库
 *
 *  @param dataArray 模型数组
 *
 *  @return 是否存储成功
 */
- (BOOL)saveCircleDataWithDataArray:(NSArray <SDTimeLineCellModel *>*)dataArray;

/**
 *  获取所有的朋友圈
 *
 *  @return 朋友圈数组
 */
- (NSArray <SDTimeLineCellModel *> *)getCirCleDataInArrayWithPage:(int)pageNumber;


/**
 *  根据朋友圈的ID 删除对应的朋友圈、点赞、评论 和图片
 *
 *  @param circleID 朋友圈id
 *
 *  @return 是否操作成功
 */
- (BOOL)deleteCircleDataWithCircleID:(NSString *)circleID;


#pragma mark - 用户相关
//                    ------------   用户表  ----------------
/**
 *  向用户表插入用户数据
 *
 *  @param userMessageArray 用户数据模型数组
 *
 *  @return 是否插入成功
 */
- (BOOL)saveUserMessageWithMessageArray:(NSArray <ZhiMaFriendModel *> *)userMessageArray;

/**
 *  查询所有的消息
 *
 *  @return 返回一个ZhiMaFriendModel 的数组
 */
- (NSArray <ZhiMaFriendModel *>*)getAllUserMessageInArray;


/**
 *  根据用户的id查询用户信息
 *
 *  @param userID 要查询的用户id
 *
 *  @return 用户信息模型
 */
- (ZhiMaFriendModel *)getUserMessageByUserID:(NSString *)userID;


/**
 *  根据用户id更新用户信息
 *
 *  @param userMessage 用户数据模型
 *
 *  @return 是否成功
 */
- (BOOL)upDataUserMessage:(ZhiMaFriendModel *)userMessage;

/**
 *  根据用户id 来删除数据库中的用户信息
 *
 *  @param userID 用户id
 *
 *  @return 是否操作成功
 */
- (BOOL)deleteUserMessageByUserID:(NSString *)userID;


#pragma mark - 新的好友相关
//                    ------------   新好友表  ----------------
/**
 *  根据用户id 取出当前用户所有的新好友列表
 *
 *  @param userID 当前用户id
 *
 *  @return 新的好友模型数组
 */
- (NSArray <ZhiMaFriendModel *> *)getAllNewFriendsByUserId:(NSString *)userID;


/**
 *  保存新的好友信息
 *
 *  @param dataArray 新的好友信息数组
 *  @param userId    当前用户id
 */
- (void)saveNewFirendsWithArray:(NSArray <ZhiMaFriendModel *>*)dataArray andUserId:(NSString *)userId;

/**
 *  更新新的好友模型
 *
 *  @param model 新的好友模型
 *
 *  @return 是否更新成功
 */
- (BOOL)upDataNewFriendsMessageByFriendModel:(ZhiMaFriendModel *)model;



#pragma mark - 会话相关
//                    ------------   会话表  ----------------
/**
 *  获取会话列表
 *
 *  @return 返回一个ConverseModel数组
 */
- (NSArray <ConverseModel *> *)getChatConverseDataInArray;

/**
 *  保存会话列表数据
 *
 *  @param dataArray 数据数组 <ConverseModel *>
 */
- (void)saveConverseListDataWithDataArray:(NSArray <ConverseModel *> *)dataArray;


/**
 *  根据会话id查询会话模型
 *
 *  @param converseID 会话id
 *
 *  @return 会话模型
 */
- (ConverseModel *)searchConverseWithConverseID:(NSString *)converseID;


#pragma mark - 消息相关
//                    ------------   消息表  ----------------
/**
 *  插入消息->消息表，并 更新/创建 会话表
 *
 *  @param message      消息模型
 *  @param converseMode 会话模型
 */
- (BOOL)saveMessage:(LGMessage *)message toConverseID:(NSString *)converseID;

/**
 *  根据会话id 获取消息列表
 *
 *  @param converseID 会话id
 *
 *  @return 一个消息模型数组 <LGMessage *>
 */
- (NSArray <LGMessage *> *)getMessageDataWithConverseID:(NSString *)converseID andPageNumber:(int)pageNumber;

/**
 *  设置消息的未读数量为0
 *
 *  @param converseId 会话id
 */
- (void)setConverseUnReadCountZero:(NSString *)converseId;

/**
 *  根据会话id删除会话
 *
 *  @param converseId 会话id
 */
- (void)deleteConverseWithConverseId:(NSString *)converseId;

/**
 *  根据会话ID删除消息
 *
 *  @param converseID 会话id
 */
- (void)deleteMessageFormMessageTableByConverseID:(NSString *)converseID;

/**
 *  根据消息ID删除消息
 *
 *  @param messageID 需要删的消息id
 */
- (void)deleteMessageFormMessageTableByMessageID:(NSString *)messageID;


#pragma mark - 群聊信息表
//                    ------------   群聊信息表  ----------------
//- (BOOL)saveGroupChatMessage:(GroupChatModel *)model andConverseID:(NSString *)converseID;


#pragma mark - 群成员信息表
//                    ------------   群成员信息表  ----------------
/**
 *  保存群成员信息，如果成员存在，则更新成员名称和头像
 *
 *  @param array   群成员数组
 *  @param groupId 群聊id
 *
 */
- (void)saveAllGroupMemberWithArray:(NSArray <ZhiMaFriendModel *> *)array andGroupChatId:(NSString *)groupId;

/**
 *  根据群id 和用户id 查询群成员表是否有这个人
 *
 *  @param groupId  群聊id
 *  @param memberId 用户id
 *
 *  @return 是否存在
 */
- (BOOL)isGroupMemberWithGroupChatId:(NSString *)groupId andMemberId:(NSString *)memberId;

/**
 *  取出该群聊所有群成员
 *
 *  @param groupId 群Id
 *
 *  @return 群成员数组
 */
- (NSArray <ZhiMaFriendModel *> *)getAllGroupMenberWithGroupId:(NSString *)groupId;

@end
