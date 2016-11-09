//
//  FMDBManager.h
//  FMDBTestDemo
//
//  Created by mac on 16/9/22.
//  Copyright © 2016年 mac. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDB.h"

typedef void(^ComplationBlock)(BOOL success);

@class ConverseModel,LGMessage,ZhiMaFriendModel,GroupChatModel,GroupUserModel;
@class SDTimeLineCellModel,SDTimeLineCellCommentItemModel,SDTimeLineCellLikeItemModel;
@class ZMServiceMessag,ServiceInfoModel;
@class ZhiMaCollectionModel;

//typedef void(^ResultBlock)(FMDatabaseQueue *db_Queue, NSString *operationStr);

typedef enum : NSUInteger {
    /* ----   朋友圈相关 ----  */
    ZhiMa_Circle_Table,             //朋友圈内容的表
    ZhiMa_Circle_Comment_Table,     //朋友圈评论的表
    ZhiMa_Circle_Pic_Table,         //朋友圈图片的表
    ZhiMa_Circle_Like_Table,        //朋友圈点赞的表
    
    /* ----   会话相关 ----  */
    ZhiMa_Chat_Converse_Table,       //会话列表 的表
    
    /* ----   聊天相关 ----  */
    ZhiMa_Chat_Message_Table,        //消息表
    
    /* ----   用户相关 ----  */
    ZhiMa_User_Message_Table,        //用户信息表
    ZhiMa_NewFriend_Message_Table,     //新好友表
    
    /* ----   群聊相关 ----  */
    ZhiMa_GroupChat_GroupMessage_Table,            //群聊表
    ZhiMa_GroupChat_GroupMenber_Table,             //群成员表
    
    /* ----  服务号相关 ----  */
    ZhiMa_Service_Table,            //服务号表
    ZhiMa_Service_Message_Table,    //服务号信息表
    
    /* ----  收藏相关 ----  */
    ZhiMa_Collection_Table          //收藏表
    
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

// 更新数据库
- (NSString *)updataTable:(ZhiMaSqliteTableType)type withColumn:(NSString *)column andColumnType:(NSString *)columnType;

// 为表新建索引
- (BOOL)creatIndexInTable:(ZhiMaSqliteTableType)type withString:(NSString *)str andIndexName:(NSString *)indexName;


/**
 把旧的数据迁移到新的数据库表上

 @param oldPath 旧的数据库路径
 @param newPath 新的数据库路径

 @return 是否迁移成功
 */
- (BOOL)moveDataToNewSQLWithOldPath:(NSString *)oldPath toNewPath:(NSString *)newPath;

/**
 *   关闭所有表
 */
- (void)closeAllSquilteTable;

#pragma mark - 朋友圈存、取操作
//                    ------------   朋友圈表  ----------------

/**
 存储朋友圈模型到数据库

 @param dataArray 模型数组
 */
- (void)saveCircleDataWithDataArray:(NSArray <SDTimeLineCellModel *>*)dataArray;

/**
 获取所有的朋友圈

 @param pageNumber 页码

 @return 朋友圈模型数组
 */
- (NSArray <SDTimeLineCellModel *> *)getCirCleDataInArrayWithPage:(int)pageNumber;


/**
 *  根据circleId 获取朋友圈模型
 *
 *  @param circleId 朋友圈ID
 *
 *  @return 朋友圈模型
 */
- (SDTimeLineCellModel *)getCircleContentWithCircleID:(NSString *)circleId;


/**
 不看某个用户的朋友圈

 @param userId 某个用户的id
 */
- (void)deletedCircleWithUserId:(NSString *)userId;

/**
 根据朋友圈ID 删除评论和点赞数据库

 @param circleID 朋友圈ID
 */
- (void)deletedCircleCommentItemsAndLikeItemsByCircleID:(NSString *)circleID;


/**
 根据朋友圈的ID 删除对应的朋友圈、点赞、评论 和图片

 @param circleID 朋友圈id

 @return 是否操作成功
 */
- (BOOL)deleteCircleDataWithCircleID:(NSString *)circleID;


/**
 *  插入一个 模型数组 到评论数据库
 *
 *  @param modelArray 模型数组
 *  @param circleID   对应的朋友圈ID
 */
- (void)saveCommentItemsInCommentTable:(NSArray <SDTimeLineCellCommentItemModel *>*)modelArray andCircleID:(NSString *)circleID;

/**
 *  插入一个 模型数组 到点赞数据库中
 *
 *  @param modelArray 模型数组
 *  @param circleID   对应的朋友圈ID
 */
- (void)saveLikeItemsInLikeTable:(NSArray <SDTimeLineCellLikeItemModel *>*)modelArray andCircleID:(NSString *)circleID;


#pragma mark - 用户相关
//                    ------------   用户表  ----------------
/**
 *  向用户表插入用户数据
 *
 *  @param userMessageArray 用户数据模型数组
 *
 *  @return 是否插入成功
 */
- (void)saveUserMessageWithMessageArray:(NSArray <ZhiMaFriendModel *> *)userMessageArray withComplationBlock:(ComplationBlock)block;

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

/**
 *  删除数据库所有用户消息
 */
- (void)deletedAllUserMessage;

#pragma mark - 新的好友相关
//                    ------------   新好友表  ----------------
/**
 *  根据用户id 取出当前用户所有的新好友列表
 *
 *  @param userID 当前用户id
 *
 *  @return 新的好友模型数组
 */
- (NSArray <ZhiMaFriendModel *> *)getAllNewFriends;


/**
 *  保存新的好友信息
 *
 *  @param dataArray 新的好友信息数组
 *  @param userId    当前用户id
 */
- (void)saveNewFirendsWithArray:(NSArray <ZhiMaFriendModel *>*)dataArray withComplationBlock:(ComplationBlock)block;

/**
 *  根据好友id删除新的好友
 *  @param userId    当前用户id
 */
- (void)deleteNewFriendByUseid:(NSString *)userId;


#pragma mark - 会话相关
//                    ------------   会话表  ----------------
/**
 *  获取会话列表
 *
 *  @return 返回一个ConverseModel数组
 */
- (NSArray <ConverseModel *> *)getChatConverseDataInArray;


/**
 *  获取所有的群聊列表
 *
 *  @return 返回一个ConverseModel数组
 */
- (NSArray <ConverseModel *> *)getAllGroupChatDataInArray;

/**
 保存会话列表 - 不执行查询操作
 
 @param dataArray 会话模型
 @param block     回调 - 主线程回调
 */
- (void)saveConverseListDataWithModel:(ConverseModel *)converseModel withComplationBlock:(ComplationBlock)block;


/**
 更新会话 - 只执行查询、更新操作，不创建会话

 @param dataArray 会话模型
 @param block     回调 - 主线程回调
 */
- (void)alertConverseListDataWithModel:(ConverseModel *)converseModel withComplationBlock:(ComplationBlock)block;

/**
 *  是否存在这个会话
 *
 *  @param 会话id
 */
- (BOOL)isConverseIsExist:(NSString *)converseId;


/**
 *  根据会话id查询会话模型
 *
 *  @param converseID 会话id
 *
 *  @return 会话模型
 */
- (ConverseModel *)searchConverseWithConverseID:(NSString *)converseID andConverseType:(NSInteger)conversetType;

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


#pragma mark - 消息相关
//                    ------------   消息表  ----------------
/**
 插入一个消息到消息表
 
 @param message    消息模型
 @param converseID 会话id/ 群ID

 @return 是否插入成功
 */
- (BOOL)saveMessage:(LGMessage *)message toConverseID:(NSString *)converseID;



/**
 *  插入一个新消息到消息列表 （群专用）已弃用  请转用 -saveMessage:toConverseID:
 *
 *  @param groupId   群id
 *
 */
- (BOOL)saveGroupChatMessage:(LGMessage *)message andConverseId:(NSString *)converseId;


/**
 根据会话id 回去消息数组

 @param converseID 会话id
 @param pageNumber 页数

 @return 消息模型数组 <LGMessage *>
 */
- (NSArray <LGMessage *> *)getMessageDataWithConverseID:(NSString *)converseID andPageNumber:(int)pageNumber;


/**
 根据会话ID删除消息

 @param converseID 会话id
 */
- (void)deleteMessageFormMessageTableByConverseID:(NSString *)converseID;


/**
 更新消息模型

 @param message 新的消息

 @return 是否更新成功
 */
- (BOOL)upDataMessageStatusWithMessage:(LGMessage *)message;

/**
 *  根据消息ID删除消息
 *
 *  @param messageID 需要删的消息id
 */
- (void)deleteMessageFormMessageTableByMessageID:(NSString *)messageID;


#pragma mark - 群聊信息表
//                    ------------   群聊信息表  ----------------
/**
 *  保存群信息
 *
 *  @param array   群信息模型
 *  @param groupId 会话ID = 群ID
 *
 */
- (BOOL)saveGroupChatInfo:(GroupChatModel *)model andConverseID:(NSString *)groupId;

/**
 *  根据群id 获取当前群的所有信息
 *
 *  @param groupId   群id
 *
 */
- (GroupChatModel *)getGroupChatMessageByGroupId:(NSString *)groupId;


/**
 *  删除群信息表 以及 对应的群成员
 *
 *  @param groupId   群id
 *
 */
- (void)deletedGroupInfoWithGroupId:(NSString *)groupId;

/**
 判断是否存在这个群

 @param groupId 群id

 @return 返回是否查询成功
 */
- (BOOL)isGroupChatExist:(NSString *)groupId;


#pragma mark - 群成员信息表
//                    ------------   群成员信息表  ----------------

/**
 保存群成员表 - 执行群成员查询和群成员插入

 @param array   GroupUserModel 模型数组
 @param groupId 群id
 @param block   回调函数
 */
- (void)saveAllGroupMemberWithArray:(NSArray <GroupUserModel *> *)array andGroupChatId:(NSString *)groupId withComplationBlock:(ComplationBlock)block;

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
- (NSArray <GroupUserModel *> *)getAllGroupMenberWithGroupId:(NSString *)groupId;


/**
 *  根据 用户id 查询群成员表是否有这个人
 *
 *  @param memberId 用户id
 *
 *  @return 群成员模型
 */
- (GroupUserModel *)getGroupMemberWithMemberId:(NSString *)memberId andConverseId:(NSString *)converseId;

/**
 *  删除某个群的所有群成员
 *
 *  @param groupId 群id
 */
- (void)deletedGroupMemberWithGroupId:(NSString *)groupId;


#pragma mark - 服务号info
//                    ------------   服务号info  ----------------
/**
 *  新增服务号
 *
 *  @infoArray 由ServiceInfoModel 组成的数组
 */
- (void)saveServiceInfoWithArray:(NSArray <ServiceInfoModel *> *)infoArray;

/**
 *  根据id查询服务号模型
 *
 *  @serviceId 服务号id
 */
- (ServiceInfoModel *)getServiceByServiceId:(NSString *)serviceId;


/**
 *  查询所有的服务号
 */
- (NSArray <ServiceInfoModel *> *)getAllServices;

/**
 *  根据id 删除服务号
 *
 *  @serviceId 服务号id
 */
- (BOOL)deletedServiceBySeviceId:(NSString *)serviecId;



#pragma mark - 服务号消息表
//                    ------------   服务号消息表  ----------------
/**
 保存服务号消息

 @param messageArray 服务号消息模型
 */
- (void)saveServiceMessage:(ZMServiceMessage *)ServiceMessage byServiceId:(NSString *)serviceId;


/**
 根据服务号id 和页数 获取消息数组 （一次5条）

 @param serviceId 服务号id
 @param page      页码

 @return ZMServiceMessage的模型数组
 */
- (NSArray <ZMServiceMessage *> *)getAllServiceMessageByServiceId:(NSString *)serviceId andPageNumber:(int)page;


/**
 根据messageId 删除服务号消息

 @param messageId messageId

 @return 是否删除成功
 */
- (BOOL)deletedServiceMessageByMessageId:(NSString *)messageId;


/**
 根据serviceId 删除服务号消息

 @param serviceId 服务号id
 */
- (void)deletedServiceMessageByServiceId:(NSString *)serviceId;


#pragma mark - 收藏表
//                    ------------   收藏表  ----------------

/**
 保存所有的收藏模型

 @param collectionArray 收藏模型数据
 */
- (void)saveCollectionWithCollectionArray:(NSArray <ZhiMaCollectionModel *>*)collectionArray;


/**
 获取所有的收藏模型

 @param userId 当前用户的用户id

 @return 收藏模型数组
 */
- (NSArray <ZhiMaCollectionModel *>*)getAllCollectionsWithUserId:(NSString *)userId;


/**
 根据收藏id获取收藏模型

 @param collecionId 收藏id

 @return 数据库中的收藏模型
 */
- (ZhiMaCollectionModel *)getCollectionModelWithModelId:(NSString *)collecionId;



/**
 根据收藏id删除收藏模型

 @param collectionId 收藏id
 */
- (void)deletedCollectionWithCollectionId:(NSString *)collectionId;


@end
