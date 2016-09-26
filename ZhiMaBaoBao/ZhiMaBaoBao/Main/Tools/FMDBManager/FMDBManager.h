//
//  FMDBManager.h
//  FMDBTestDemo
//
//  Created by mac on 16/9/22.
//  Copyright © 2016年 mac. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDB.h"
@class SDTimeLineCellModel;

typedef void(^ResultBlock)(FMDatabaseQueue *db_Queue, NSString *operationStr);

typedef enum : NSUInteger {
    ZhiMa_Circle_Table,             //朋友圈内容的表
    ZhiMa_Circle_Comment_Table,     //朋友圈评论的表
    ZhiMa_Circle_Pic_Table,         //朋友圈图片的表
    ZhiMa_Circle_Like_Table         //朋友圈点赞的表
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
- (void)saveCircleDataWithDataArray:(NSArray *)dataArray;

// 获取朋友圈所有消息
- (NSArray *)getCirCleDataInArray;

// 根据某条朋友圈的id 去删除其对应的数据
- (void)deleteCircleDataWithCircleID:(NSString *)circleID;

@end
