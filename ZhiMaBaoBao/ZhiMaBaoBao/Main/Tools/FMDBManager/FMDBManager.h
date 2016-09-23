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
    ZhiMa_Circle_Pic_Table          //朋友圈图片的表
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

@end
