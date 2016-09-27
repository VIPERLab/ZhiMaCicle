//
//  FMDBManager.h
//  FMDBTestDemo
//
//  Created by mac on 16/9/22.
//  Copyright © 2016年 mac. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDB.h"
@class ConverseModel,LGMessage,ZhiMaFriendModel;
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
    ZhiMa_User_Message_Table,
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
// 把数据存放到数据库
- (BOOL)saveCircleDataWithDataArray:(NSArray <SDTimeLineCellModel *>*)dataArray;

// 获取朋友圈所有消息
- (NSArray <SDTimeLineCellModel *> *)getCirCleDataInArray;

// 根据某条朋友圈的id 去删除其对应的数据
- (BOOL)deleteCircleDataWithCircleID:(NSString *)circleID;


#pragma mark - 聊天相关
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


//                    ------------   消息表  ----------------

/**
 *  插入消息->消息表，并 更新/创建 会话表
 *
 *  @param message      消息模型
 *  @param converseMode 会话模型
 */
- (BOOL)saveMessage:(LGMessage *)message toConverseID:(ConverseModel *)converseMode;

/**
 *  根据会话id 获取消息列表
 *
 *  @param converseID 会话id
 *
 *  @return 一个消息模型数组 <LGMessage *>
 */
- (NSArray <LGMessage *> *)getMessageDataWithConverseID:(NSString *)converseID;

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

@end
