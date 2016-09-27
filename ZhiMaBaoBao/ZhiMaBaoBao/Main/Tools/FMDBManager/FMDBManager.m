//
//  FMDBManager.m
//  FMDBTestDemo
//
//  Created by mac on 16/9/22.
//  Copyright © 2016年 mac. All rights reserved.
//

#import "FMDBManager.h"
#import <objc/runtime.h>
#import "FMDBManagerHeader.h"

#import "SDTimeLineCellModel.h"
#import "ConverseModel.h"
#import "LGMessage.h"

@implementation FMDBManager {
    // 朋友圈相关的表
    FMDatabaseQueue *circle_DB;
    FMDatabaseQueue *circle_Comment_DB;
    FMDatabaseQueue *circle_Pic_DB;
    FMDatabaseQueue *circle_Like_Db;
    
    // 聊天相关的表
    FMDatabaseQueue *chat_Converse_DB;
    FMDatabaseQueue *chat_message_DB;
    
}

+ (instancetype)shareManager {
    return [[self alloc] initWithShareManager];
}

- (instancetype)initWithShareManager {
    static FMDBManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[FMDBManager alloc] init];
    });
    return manager;
}

- (FMDatabaseQueue *)getQueueWithType:(ZhiMaSqliteTableType)type {
    switch (type) {
        case ZhiMa_Circle_Table:
            return circle_DB;
        case ZhiMa_Circle_Comment_Table:
            return circle_Comment_DB;
        case ZhiMa_Circle_Pic_Table:
            return circle_Pic_DB;
        case ZhiMa_Circle_Like_Table:
            return circle_Like_Db;
        case ZhiMa_Chat_ConverseTable:
            return chat_Converse_DB;
        case ZhiMa_Chat_MessageTable:
            return chat_message_DB;
        default:
            NSLog(@"无效参数");
            return nil;
            break;
    }
}

#pragma mark - 建表
- (void)creatTableWithTableType:(ZhiMaSqliteTableType)type {
    
    // 1.通过路径创建数据库
    NSString *path = [NSString string];
    switch (type) {
        case ZhiMa_Circle_Table:
        case ZhiMa_Circle_Comment_Table:
        case ZhiMa_Circle_Pic_Table:
        case ZhiMa_Circle_Like_Table:
            path = ZhiMaCircle_SqlitePath;
            break;
        case ZhiMa_Chat_ConverseTable:
        case ZhiMa_Chat_MessageTable:
            path = ZhiMaChat_SqlitePath;
            break;
        default:
            break;
    }
    NSLog(@"表的路径 %@",path);
    FMDatabaseQueue *db_Queue = [FMDatabaseQueue databaseQueueWithPath:path];
    
    [db_Queue inDatabase:^(FMDatabase *db) {
       
        if ([db open]) {
            NSLog(@"打开成功");
            NSString *tableField = [NSString string];
            NSString *tableName = [NSString string];
            switch (type) {
                case ZhiMa_Circle_Table: {         //如果创建的是朋友圈表
                    tableField = CircleField;
                    tableName = ZhiMaCicle_Talbe_Name;
                    circle_DB = db_Queue;
                    break;
                }
                case ZhiMa_Circle_Comment_Table: {  //如果创建的是评论表
                    tableField = Circle_CommentField;
                    tableName = ZhiMaCicleComment_Table_Name;
                    circle_Comment_DB = db_Queue;
                    break;
                }
                case ZhiMa_Circle_Pic_Table: {      //如果创建的是朋友圈图片表
                    tableName = ZhiMaCirclePic_Table_Name;
                    tableField = CirCle_PicField;
                    circle_Pic_DB = db_Queue;
                    break;
                }
                case ZhiMa_Circle_Like_Table: {     //如果创建的是朋友圈点赞的表
                    tableName = ZhiMaCircleLike_Table_Name;
                    tableField = CirCle_LikeField;
                    circle_Like_Db = db_Queue;
                    break;
                }
                case ZhiMa_Chat_ConverseTable: {    //会话表
                    tableName = ZhiMaChatConvence_Table_Name;
                    tableField = Chat_ConverseField;
                    chat_Converse_DB = db_Queue;
                    break;
                }
                case ZhiMa_Chat_MessageTable: {     //消息表
                    tableName = ZhiMaChatMessage_Table_Name;
                    tableField = Chat_MessageField;
                    break;
                }
                default:{
                    NSLog(@"无效参数");
                    break;
                }
            }
            
            NSString *operationString = [@"CREATE TABLE IF NOT EXISTS " stringByAppendingString:tableName];
            operationString = [operationString stringByAppendingString:tableField];
            BOOL success = [db executeUpdate:operationString];
            
            if (success) {
                NSLog(@"%@创建成功",tableName);
            } else {
                NSLog(@"%@创建失败",tableName);
            }
            
        } else {
            NSLog(@"打开失败");
        }

        
    }];
}

#pragma mark - 插表
- (NSString *)InsertDataInTable:(ZhiMaSqliteTableType)type {
    
    NSString *tableName = [NSString string];  //表名
    NSString *fieldName;                      //字段名
    switch (type) {
        case ZhiMa_Circle_Table: {
            tableName = ZhiMaCicle_Talbe_Name;
            fieldName = CircleFiels_Name;
            break;
        }
        case ZhiMa_Circle_Comment_Table: {
            tableName = ZhiMaCicleComment_Table_Name;
            fieldName = Circle_CommentFields_Name;
            break;
        }
        case ZhiMa_Circle_Pic_Table: {      //如果创建的是朋友圈图片表
            tableName = ZhiMaCirclePic_Table_Name;
            fieldName = CirCle_PicFields_Name;
            break;
        }
        case ZhiMa_Circle_Like_Table: {
            tableName = ZhiMaCircleLike_Table_Name;
            fieldName = CirCle_LikeFields_Name;
            break;
        }
        case ZhiMa_Chat_ConverseTable: {
            tableName = ZhiMaChatConvence_Table_Name;
            fieldName = Chat_ConverseFields_Name;
            break;
        }
        case ZhiMa_Chat_MessageTable: {
            tableName = ZhiMaChatMessage_Table_Name;
            fieldName = Chat_MessageFields_name;
        }
        default: {
            NSLog(@"无效参数");
            return @"";
            break;
        }
    }
    
    NSString *operationString = [@"INSERT INTO " stringByAppendingString:tableName];
    NSString *valuesStr = [self getValuesString:fieldName];
    operationString = [operationString stringByAppendingString:[NSString stringWithFormat:@"(%@) VALUES %@",fieldName,valuesStr]];
    
    return operationString;
}


#pragma mark - 查表
- (NSString *)SearchTable:(ZhiMaSqliteTableType)type withOption:(NSString *)option {

    NSString *tableName = [NSString string];  //表名
    NSString *fieldName;                      //字段名
    switch (type) {
        case ZhiMa_Circle_Table: {
            tableName = ZhiMaCicle_Talbe_Name;
            fieldName = CircleFiels_Name;
            break;
        }
        case ZhiMa_Circle_Comment_Table: {
            tableName = ZhiMaCicleComment_Table_Name;
            fieldName = Circle_CommentFields_Name;
            break;
        }
        case ZhiMa_Circle_Pic_Table: {
            tableName = ZhiMaCirclePic_Table_Name;
            fieldName = CirCle_PicFields_Name;
            break;
        }
        case ZhiMa_Circle_Like_Table: {
            tableName = ZhiMaCircleLike_Table_Name;
            fieldName = CirCle_LikeFields_Name;
            break;
        }
        case ZhiMa_Chat_ConverseTable: {
            tableName = ZhiMaChatConvence_Table_Name;
            fieldName = Chat_ConverseFields_Name;
            break;
        }
        case ZhiMa_Chat_MessageTable: {
            tableName = ZhiMaChatMessage_Table_Name;
            fieldName = Chat_MessageFields_name;
            break;
        }
        default: {
            NSLog(@"无效参数");
            return @"";
            break;
        }
    }
    
    NSString *operationString = @"SELECT ";
    operationString = [operationString stringByAppendingString:fieldName];
    operationString = [operationString stringByAppendingString:[NSString stringWithFormat:@" FROM %@ WHERE %@;",tableName,option]];
    
    return operationString;
}


// 改表
- (NSString *)alterTable:(ZhiMaSqliteTableType)type withOpton1:(NSString *)option1 andOption2:(NSString *)option2 {
    
    NSString *tableName = [NSString string];  //表名
    switch (type) {
        case ZhiMa_Circle_Table: {
            tableName = ZhiMaCicle_Talbe_Name;
            break;
        }
        case ZhiMa_Circle_Comment_Table: {
            tableName = ZhiMaCicleComment_Table_Name;
            break;
        }
        case ZhiMa_Circle_Pic_Table: {
            tableName = ZhiMaCirclePic_Table_Name;
            break;
        }
        case ZhiMa_Circle_Like_Table: {
            tableName = ZhiMaCircleLike_Table_Name;
            break;
        }
        case ZhiMa_Chat_ConverseTable: {
            tableName = ZhiMaChatConvence_Table_Name;
            break;
        }
        case ZhiMa_Chat_MessageTable: {
            tableName = ZhiMaChatMessage_Table_Name;
            break;
        }
        default: {
            NSLog(@"无效参数");
            return @"";
            break;
        }
    }
    
    NSString *operationString = [NSString stringWithFormat:@"UPDATE %@ SET %@ WHERE %@;",tableName,option1,option2];
    
    
    return operationString;
}

// 删表
- (NSString *)deletedTableData:(ZhiMaSqliteTableType)type withOption:(NSString *)option {
    NSString *tableName = [NSString string];  //表名
    switch (type) {
        case ZhiMa_Circle_Table: {
            tableName = ZhiMaCicle_Talbe_Name;
            break;
        }
        case ZhiMa_Circle_Comment_Table: {
            tableName = ZhiMaCicleComment_Table_Name;
            break;
        }
        case ZhiMa_Circle_Pic_Table: {
            tableName = ZhiMaCirclePic_Table_Name;
            break;
        }
        case ZhiMa_Circle_Like_Table: {
            tableName = ZhiMaCircleLike_Table_Name;
            break;
        }
        case ZhiMa_Chat_ConverseTable: {
            tableName = ZhiMaChatConvence_Table_Name;
        }
        case ZhiMa_Chat_MessageTable: {
            tableName = ZhiMaChatMessage_Table_Name;
        }
        default: {
            NSLog(@"无效参数");
            return @"";
            break;
        }
    }
    
    NSString *operationString = [NSString stringWithFormat:@"DELETE FROM %@ WHERE %@;",tableName,option];
    
    return operationString;
}


// 拼接参数
- (NSString *)getValuesString:(NSString *)fieldStr {
    
    NSArray *array = [fieldStr componentsSeparatedByString:@","];
    NSString *valueString = @"(";
    for (NSInteger index = 0; index < array.count; index++) {
        
        if (index == 0) {
            valueString = [valueString stringByAppendingString:@"?"];
        } else {
            valueString = [valueString stringByAppendingString:@", ?"];
        }
        
    }
    
    valueString = [valueString stringByAppendingString:@");"];
    
    return valueString;
}


#pragma mark - 动态取出模型的所有属性
- (NSArray *)getPropertyNameArrayWith:(id)model {
    // 动态获取模型的属性名
    NSMutableArray *pArray = [NSMutableArray array];
    unsigned int count = 0;
    
    objc_property_t *properties = class_copyPropertyList([model class], &count);
    
    for (int index = 0; index < count; ++index) {
        // 根据索引获得对应的属性(属性是一个结构体,包含很多其他的信息)
        objc_property_t property = properties[index];
        // 获得属性名字
        const char *cname = property_getName(property);
        // 将c语言字符串转换为oc字符串
        NSString *ocname = [[NSString alloc] initWithCString:cname encoding:NSUTF8StringEncoding];
        
        [pArray addObject:ocname];
    }
    return pArray;
}

// 获取模型属性的值
- (NSArray *)getProperyWith:(id)model andArray:(NSMutableArray *)pArray {
    for (NSInteger index = 0; index < pArray.count; index++) {
        NSMutableString *resultString = [[NSMutableString alloc] init];
        //获取get方法
        SEL getSel = [self creatGetterWithPropertyName:pArray[index]];
        //获得类和方法的签名
        NSMethodSignature *signature = [model methodSignatureForSelector:getSel];
        
        //从签名获得调用对象
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
        
        //设置target
        [invocation setTarget:model];
        
        //设置selector
        [invocation setSelector:getSel];
        
        //接收返回的值
        NSObject *__unsafe_unretained returnValue = nil;
        
        //调用
        [invocation invoke];
        
        //接收返回值
        [invocation getReturnValue:&returnValue];
        
        [resultString appendFormat:@"%@", returnValue];
        [pArray replaceObjectAtIndex:index withObject:resultString];
        
    }
    return pArray;

}

// 设置模型属性的值
- (id)setPropertyWithResule:(FMResultSet *)result WithClass:(Class)modelClass {
    
    //实例化一个model
    id model = [[modelClass alloc] init];
    
    NSArray *pArray = [self getPropertyNameArrayWith:model];

    for (NSInteger index = 0; index < pArray.count; index++ ) {
        //获取set方法
        SEL setSel = [self creatSetterWithPropertyName:pArray[index]];
        
        if ([model respondsToSelector:setSel]) {
            NSString *value = [result stringForColumn:pArray[index]];
            value = [value stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:[[value substringToIndex:1] uppercaseString]];
            [model performSelectorOnMainThread:setSel withObject:value waitUntilDone:[NSThread isMainThread]];
            
        }
        
    }
    return model;
    
}

#pragma mark -- 通过字符串来创建该字符串的Setter方法，并返回
// 获取属性的Get方法
- (SEL)creatGetterWithPropertyName: (NSString *) propertyName{
    //1.返回get方法: oc中的get方法就是属性的本身
    return NSSelectorFromString(propertyName);
}
// 获取属性的set 方法
- (SEL)creatSetterWithPropertyName:(NSString *)propertyName {
    NSString *selName = [NSString stringWithFormat:@"set%@:",propertyName];
    return NSSelectorFromString(selName);
}


#pragma mark 获取数据源方法
#pragma mark - 朋友圈相关
//                              ----------   朋友圈相关
// 存所有朋友圈信息
- (void)saveCircleDataWithDataArray:(NSArray *)dataArray {
    //插入数据
    for (SDTimeLineCellModel *cellModel in dataArray) {
        FMDatabaseQueue *queue = [FMDBShareManager getQueueWithType:ZhiMa_Circle_Table];
        NSLog(@"开始查朋友圈表");
        __block BOOL isExist = NO;
        [queue inDatabase:^(FMDatabase *db) {
            NSString *searchOptionStr = [FMDBShareManager SearchTable:ZhiMa_Circle_Table withOption:[NSString stringWithFormat:@"circle_ID = %@",cellModel.circle_ID]];
            FMResultSet *result = [db executeQuery:searchOptionStr];
            
            while ([result next]) {
                NSLog(@"查表成功");
                isExist = YES;
            }
            
        }];
        NSString *operationStr;
        if (isExist) {
            NSLog(@"存在这条朋友圈数据，更新时间");
            NSString *option1 = [NSString stringWithFormat:@"create_time = '%@'",cellModel.create_time];
            NSString *option2 = [NSString stringWithFormat:@"circle_ID = %@",cellModel.circle_ID];
            operationStr = [FMDBShareManager alterTable:ZhiMa_Circle_Table withOpton1:option1 andOption2:option2];
        } else {
            NSLog(@"不存在这条朋友圈数据，需要插入");
            operationStr = [FMDBShareManager InsertDataInTable:ZhiMa_Circle_Table];
        }
        
        [queue inDatabase:^(FMDatabase *db) {
            BOOL success = [db executeUpdate:operationStr,cellModel.friend_nick,cellModel.circle_ID,cellModel.userId,cellModel.content,cellModel.current_location,cellModel.create_time,cellModel.head_photo];
            if (success) {
                NSLog(@"插入朋友圈成功");
            } else {
                NSLog(@"插入朋友圈失败");
            }
            
        }];
        
        
        
        
        
        //插入评论
        for (SDTimeLineCellCommentItemModel *commentModel in cellModel.commentList) {
            NSLog(@"开始查评论表");
            //查询是否存在评论
            FMDatabaseQueue *queue = [FMDBShareManager getQueueWithType:ZhiMa_Circle_Comment_Table];
            __block BOOL isExist = NO;
            [queue inDatabase:^(FMDatabase *db) {
                NSString *searchOptionStr = [FMDBShareManager SearchTable:ZhiMa_Circle_Comment_Table withOption:[NSString stringWithFormat:@"fcid = %@",commentModel.ID]];
                FMResultSet *result = [db executeQuery:searchOptionStr];
                
                while ([result next]) {
                    NSLog(@"查表成功");
                    isExist = YES;
                }
                
            }];
            
            NSString *operationStr;
            if (isExist) {
                NSLog(@"存在这条评论数据，不做操作");
            } else {
                NSLog(@"不存在这条评论数据，需要插入");
                operationStr = [FMDBShareManager InsertDataInTable:ZhiMa_Circle_Comment_Table];
                
                [queue inDatabase:^(FMDatabase *db) {
                    BOOL success = [db executeUpdate:operationStr,commentModel.friend_nick,commentModel.ID,commentModel.comment,commentModel.reply_friend_nick,commentModel.reply_id,commentModel.head_photo,commentModel.create_time,cellModel.circle_ID,commentModel.userId];
                    if (success) {
                        NSLog(@"插入评论成功");
                    } else {
                        NSLog(@"插入评论失败");
                    }
                    
                }];
            }
        }
        
        //插入图片
        for (SDTimeLineCellPicItemModel *picModel in cellModel.imglist) {
            FMDatabaseQueue *picQueue = [FMDBShareManager getQueueWithType:ZhiMa_Circle_Pic_Table];
            
            NSLog(@"开始查图片表");
            __block BOOL isExist = NO;
            [picQueue inDatabase:^(FMDatabase *db) {
                NSString *searchOptionStr = [FMDBShareManager SearchTable:ZhiMa_Circle_Pic_Table withOption:[NSString stringWithFormat:@"circle_ID = %@",cellModel.circle_ID]];
                FMResultSet *result = [db executeQuery:searchOptionStr];
                while ([result next]) {
                    NSLog(@"查表成功");
                    NSString *imageURL = [result stringForColumn:@"img_url"];
                    if ([imageURL isEqualToString:picModel.img_url]) {
                        isExist = YES;
                    }
                }
            }];
            
            if (isExist) {
                NSLog(@"存在这条图片数据，不做操作");
            } else {
                NSLog(@"不存在这条图片数据，需要插入");
                operationStr = [FMDBShareManager InsertDataInTable:ZhiMa_Circle_Pic_Table];
                [picQueue inDatabase:^(FMDatabase *db) {
                    BOOL success = [db executeUpdate:operationStr,picModel.img_url,picModel.bigimg_url,cellModel.circle_ID];
                    if (success) {
                        NSLog(@"插入图片成功");
                    } else {
                        NSLog(@"插入图片失败");
                    }
                    
                }];
            }
        }
        
        //插入点赞
        for (SDTimeLineCellLikeItemModel *likeModel in cellModel.likeItemsArray) {
            
            FMDatabaseQueue *likeQueue = [FMDBShareManager getQueueWithType:ZhiMa_Circle_Like_Table];
            
            NSLog(@"开始查点赞表");
            __block BOOL isExist = NO;
            [likeQueue inDatabase:^(FMDatabase *db) {
                NSString *searchOptionStr = [FMDBShareManager SearchTable:ZhiMa_Circle_Like_Table withOption:[NSString stringWithFormat:@"circle_ID = %@ and userId = %@",cellModel.circle_ID,likeModel.userId]];
                FMResultSet *result = [db executeQuery:searchOptionStr];
                while ([result next]) {
                    NSLog(@"查表成功");
                    isExist = YES;
                }
            }];
            
            
            if (isExist) {
                NSLog(@"存在这条点赞数据，不做操作");
            } else {
                NSLog(@"不存在这条点赞数据，需要插入");
                operationStr = [FMDBShareManager InsertDataInTable:ZhiMa_Circle_Like_Table];
                [likeQueue inDatabase:^(FMDatabase *db) {
                    BOOL success = [db executeUpdate:operationStr,likeModel.userName,likeModel.userId,@"",cellModel.circle_ID];
                    if (success) {
                        NSLog(@"插入点赞成功");
                    } else {
                        NSLog(@"插入点赞失败");
                    }
                }];
            }
        }
    }
}

// 获取朋友圈所有消息
- (NSArray *)getCirCleDataInArray {
    
    FMDatabaseQueue *queue = [FMDBShareManager getQueueWithType:ZhiMa_Circle_Table];
    NSString *operationStr = [FMDBShareManager SearchTable:ZhiMa_Circle_Table withOption:@"circle_ID > 0 order by circle_ID desc"];
    NSMutableArray *cellModelArray = [NSMutableArray array];
    [queue inDatabase:^(FMDatabase *db) {
        
        FMResultSet *result = [db executeQuery:operationStr];
        while ([result next]) {
            SDTimeLineCellModel *model = [[SDTimeLineCellModel alloc] init];
            model.circle_ID = [result stringForColumn:@"circle_ID"];
            model.friend_nick = [result stringForColumn:@"friend_nick"];
            model.userId = [result stringForColumn:@"userID"];
            model.content = [result stringForColumn:@"content"];
            model.current_location = [result stringForColumn:@"current_location"];
            model.create_time = [result stringForColumn:@"create_time"];
            model.head_photo = [result stringForColumn:@"head_photo"];
            [cellModelArray addObject:model];
        }
    }];
    
    for (SDTimeLineCellModel *cellModel in cellModelArray) {
        FMDatabaseQueue *queue = [FMDBShareManager getQueueWithType:ZhiMa_Circle_Comment_Table];
        
        NSString *operationStr = [FMDBShareManager SearchTable:ZhiMa_Circle_Comment_Table withOption:[NSString stringWithFormat:@"circle_ID = %@",cellModel.circle_ID]];
        
        [queue inDatabase:^(FMDatabase *db) {
            NSMutableArray *commentListArray = [NSMutableArray array];
            FMResultSet *result = [db executeQuery:operationStr];
            while ([result next]) {
                SDTimeLineCellCommentItemModel *model = [[SDTimeLineCellCommentItemModel alloc] init];
                model.friend_nick = [result stringForColumn:@"friend_nick"];
                model.ID = [result stringForColumn:@"circle_ID"];
                model.userId = [result stringForColumn:@"userID"];
                model.reply_friend_nick = [result stringForColumn:@"reply_friend_nick"];
                model.reply_id = [result stringForColumn:@"reply_id"];
                model.comment = [result stringForColumn:@"comment"];
                model.head_photo = [result stringForColumn:@"head_photo"];
                model.create_time = [result stringForColumn:@"create_time"];
                [commentListArray addObject:model];
            }
            cellModel.commentList = commentListArray;
        }];
        
    }
    
    for (SDTimeLineCellModel *cellModel in cellModelArray) {
        FMDatabaseQueue *queue = [FMDBShareManager getQueueWithType:ZhiMa_Circle_Pic_Table];
        NSString *operationStr = [FMDBShareManager SearchTable:ZhiMa_Circle_Pic_Table withOption:[NSString stringWithFormat:@"circle_ID = %@",cellModel.circle_ID]];
        
        [queue inDatabase:^(FMDatabase *db) {
            NSMutableArray *commentListArray = [NSMutableArray array];
            FMResultSet *result = [db executeQuery:operationStr];
            while ([result next]) {
                SDTimeLineCellPicItemModel *model = [[SDTimeLineCellPicItemModel alloc] init];
                model.bigimg_url = [result stringForColumn:@"bigimg_url"];
                model.img_url = [result stringForColumn:@"img_url"];
                [commentListArray addObject:model];
            }
            cellModel.imglist = commentListArray;
        }];
    }
    
    for (SDTimeLineCellModel *cellModel in cellModelArray) {
        FMDatabaseQueue *queue = [FMDBShareManager getQueueWithType:ZhiMa_Circle_Like_Table];
        NSString *operationStr = [FMDBShareManager SearchTable:ZhiMa_Circle_Like_Table withOption:[NSString stringWithFormat:@"circle_ID = %@",cellModel.circle_ID]];
        
        [queue inDatabase:^(FMDatabase *db) {
            NSMutableArray *likeItemArray = [NSMutableArray array];
            FMResultSet *result = [db executeQuery:operationStr];
            while ([result next]) {
                SDTimeLineCellLikeItemModel *model = [[SDTimeLineCellLikeItemModel alloc] init];
                model.userName = [result stringForColumn:@"userName"];
                model.userId = [result stringForColumn:@"userId"];
                [likeItemArray addObject:model];
            }
            cellModel.likeItemsArray = likeItemArray;
        }];
    }
    
    return cellModelArray;
}

// 根据某条朋友圈的id 去删除其对应的数据
- (void)deleteCircleDataWithCircleID:(NSString *)circleID {
    //删除朋友圈数据库该条记录
    FMDatabaseQueue *queue = [FMDBShareManager getQueueWithType:ZhiMa_Circle_Table];
    NSString *operation = [FMDBShareManager deletedTableData:ZhiMa_Circle_Table withOption:[NSString stringWithFormat:@"circle_ID = %@",circleID]];
    [queue inDatabase:^(FMDatabase *db) {
        BOOL success = [db executeUpdate:operation];
        if (success) {
            NSLog(@"删除成功");
        } else {
            NSLog(@"删除失败");
        }
    }];
    
    //删除评论数据库该条记录
    FMDatabaseQueue *commentQueue = [FMDBShareManager getQueueWithType:ZhiMa_Circle_Comment_Table];
    NSString *commentQueueOpeartion = [FMDBShareManager deletedTableData:ZhiMa_Circle_Comment_Table withOption:[NSString stringWithFormat:@"circle_ID = %@",circleID]];
    [commentQueue inDatabase:^(FMDatabase *db) {
        BOOL success = [db executeUpdate:commentQueueOpeartion];
        if (success) {
            NSLog(@"删除成功");
        } else {
            NSLog(@"删除失败");
        }
    }];
    
    //删除图片数据库该条记录
    FMDatabaseQueue *picQueue = [FMDBShareManager getQueueWithType:ZhiMa_Circle_Comment_Table];
    NSString *picOpeartion = [FMDBShareManager deletedTableData:ZhiMa_Circle_Comment_Table withOption:[NSString stringWithFormat:@"circle_ID = %@",circleID]];
    [picQueue inDatabase:^(FMDatabase *db) {
        BOOL success = [db executeUpdate:picOpeartion];
        if (success) {
            NSLog(@"删除成功");
        } else {
            NSLog(@"删除失败");
        }
    }];
}

#pragma mark - 聊天相关
//                    -----------   聊天表  ----------------
// 保存会话列表
- (void)saveConverseListDataWithDataArray:(NSArray *)dataArray {
    for (ConverseModel *converseModel in dataArray) {
        FMDatabaseQueue *queue = [FMDBShareManager getQueueWithType:ZhiMa_Chat_ConverseTable];
        NSLog(@"开始查会话表");
        __block BOOL isExist = NO;
        [queue inDatabase:^(FMDatabase *db) {
            NSString *searchOptionStr = [FMDBShareManager SearchTable:ZhiMa_Chat_ConverseTable withOption:[NSString stringWithFormat:@"converseId = %@",converseModel.converseId]];
            FMResultSet *result = [db executeQuery:searchOptionStr];
            while ([result next]) {
                NSLog(@"查表成功");
                isExist = YES;
            }
        }];
        
        NSString *operationStr;
        if (isExist) {
            NSLog(@"存在这条会话数据，更新数据");
            NSString *option1 = [NSString stringWithFormat:@"time = '%@', converseType = '%@', converseId = '%@', unReadCount = '%@', topChat = '%@', disturb = '%@', converseName = '%@', converseHead_photo = '%@', converseContent = '%@'",converseModel.time,converseModel.converseType,converseModel.converseId,converseModel.unReadCount,@(converseModel.topChat), @(converseModel.disturb), converseModel.converseName,converseModel.converseHead_photo,converseModel.lastConverse];
            NSString *option2 = [NSString stringWithFormat:@"converseId = %@",converseModel.converseId];
            operationStr = [FMDBShareManager alterTable:ZhiMa_Chat_ConverseTable withOpton1:option1 andOption2:option2];
        } else {
            NSLog(@"不存在这条会话数据，需要插入");
            operationStr = [FMDBShareManager InsertDataInTable:ZhiMa_Chat_ConverseTable];
        }
        
        [queue inDatabase:^(FMDatabase *db) {
            BOOL success = [db executeUpdate:operationStr,converseModel.time,converseModel.converseType,converseModel.converseId,converseModel.unReadCount,@(converseModel.topChat), @(converseModel.disturb), converseModel.converseName,converseModel.converseHead_photo,converseModel.lastConverse];
            if (success) {
                NSLog(@"插入会话成功");
            } else {
                NSLog(@"插入会话失败");
            }
        }];
        
        
    }
}

// 获取会话列表
- (NSArray *)getChatConverseDataInArray {
    FMDatabaseQueue *queue = [FMDBShareManager getQueueWithType:ZhiMa_Chat_ConverseTable];
    NSMutableArray *dataArray = [NSMutableArray array];
    NSLog(@"开始查朋友圈表");
    [queue inDatabase:^(FMDatabase *db) {
        
        NSString *searchOptionStr = [FMDBShareManager SearchTable:ZhiMa_Chat_ConverseTable withOption:@"converseId > 0 order by converseId desc"];
        FMResultSet *result = [db executeQuery:searchOptionStr];
        
        while ([result next]) {
            NSLog(@"查表成功");
            ConverseModel *model = [[ConverseModel alloc] init];
            model.unReadCount = [result stringForColumn:@"unReadCount"];
            model.converseName = [result stringForColumn:@"converseName"];
            model.lastConverse = [result stringForColumn:@"lastConverse"];
            model.converseHead_photo = [result stringForColumn:@"converseHead_photo"];
            model.converseId = [result stringForColumn:@"converseId"];
            model.converseType = [result stringForColumn:@"converseType"];
            model.time = [result stringForColumn:@"time"];
            model.topChat = [result intForColumn:@"topChat"];
            model.disturb = [result intForColumn:@"disturb"];
            [dataArray addObject:model];
        }
    }];
    return dataArray;
}


//                    ------------   消息表  ----------------
//  插入消息到 -> 消息表
- (void)saveMessage:(LGMessage *)message toConverseID:(ConverseModel *)converseModel {
    //查询是否有这个会话id
    FMDatabaseQueue *queue = [FMDBShareManager getQueueWithType:ZhiMa_Chat_ConverseTable];
    NSLog(@"开始查会话表");
    __block BOOL isExist = NO;
    [queue inDatabase:^(FMDatabase *db) {
        NSString *searchOptionStr = [FMDBShareManager SearchTable:ZhiMa_Chat_ConverseTable withOption:[NSString stringWithFormat:@"converseId = %@",converseModel.converseId]];
        FMResultSet *result = [db executeQuery:searchOptionStr];
        while ([result next]) {
            NSLog(@"存在这个会话");
            isExist = YES;
        }
    }];
    
    NSString *opeartionStr = [NSString string];
    if (!isExist) {
        //不存在会话列表 ->  创建这个会话
        NSLog(@"会话不存在，需要创建");
        opeartionStr = [FMDBShareManager InsertDataInTable:ZhiMa_Chat_ConverseTable];
        
    } else {
        //更新这个会话
        NSLog(@"会话存在,更新会话");
        NSString *option1 = [NSString stringWithFormat:@"unReadCount = '%@', topChat = '%@',disturb = '%@', converseName = '%@', converseContent = '%@'",converseModel.unReadCount,@(converseModel.topChat),@(converseModel.disturb),converseModel.converseName,converseModel.lastConverse];
        NSString *option2 = [NSString stringWithFormat:@"converseId = %@",converseModel.converseId];
        opeartionStr = [FMDBShareManager alterTable:ZhiMa_Chat_MessageTable withOpton1:option1 andOption2:option2];
    }
    
    [queue inDatabase:^(FMDatabase *db) {
        BOOL success = [db executeUpdate:opeartionStr,converseModel.time,converseModel.converseType,converseModel.converseId,converseModel.unReadCount,@(converseModel.topChat), @(converseModel.disturb), converseModel.converseName,converseModel.converseHead_photo,converseModel.lastConverse];
        if (success) {
            NSLog(@"插入会话成功");
        } else {
            NSLog(@"插入会话失败");
        }
    }];
    
    
    //往消息表 -> 插入 -> 消息
    FMDatabaseQueue *messageQueue = [FMDBShareManager getQueueWithType:ZhiMa_Chat_MessageTable];
    NSString *opeartionStr2 = [FMDBShareManager InsertDataInTable:ZhiMa_Chat_MessageTable];
    [messageQueue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:opeartionStr2,message.msgid,@(message.type),message.fromUid,message.toUidOrGroupId,message.time,message.text,@(message.isGroup),converseModel.converseId];
    }];
}

/**
 *  根据会话id 获取消息列表
 *
 *  @param converseID 会话id
 *
 *  @return 一个消息模型数组 <LGMessage *>
 */
- (NSArray *)getMessageDataWithConverseID:(NSString *)converseID {
    NSMutableArray *dataArray = [NSMutableArray array];
    FMDatabaseQueue *queue = [FMDBShareManager getQueueWithType:ZhiMa_Chat_MessageTable];
    NSString *option = [NSString stringWithFormat:@"converseId = %@",converseID];
    NSString *opeartionStr = [FMDBShareManager SearchTable:ZhiMa_Chat_MessageTable withOption:option];
    [queue inDatabase:^(FMDatabase *db) {
        FMResultSet *result = [db executeQuery:opeartionStr];
        while ([result next]) {
            LGMessage *message = [[LGMessage alloc] init];
            message.msgid = [result stringForColumn:@"msgid"];
            message.type = [result intForColumn:@"type"];
            message.fromUid = [result stringForColumn:@"fromUid"];
            message.isGroup = [result intForColumn:@"isGroup"];
            message.toUidOrGroupId = [result stringForColumn:@"toUidOrGroupId"];
            message.time = [result stringForColumn:@"time"];
            message.text = [result stringForColumn:@"text"];
            [dataArray addObject:message];
        }
    }];
    return dataArray;
}


/**
 *  根据会话ID删除消息
 *
 *  @param converseID 会话id
 */
- (void)deleteMessageFormMessageTableByConverseID:(NSString *)converseID {
    FMDatabaseQueue *messageQueue = [FMDBShareManager getQueueWithType:ZhiMa_Chat_MessageTable];
    NSString *option = [NSString stringWithFormat:@"converseId = %@",converseID];
    NSString *detOpeartionStr = [FMDBShareManager deletedTableData:ZhiMa_Chat_MessageTable withOption:option];
    [messageQueue inDatabase:^(FMDatabase *db) {
        BOOL success = [db executeUpdate:detOpeartionStr];
        if (success) {
            NSLog(@"删除消息成功");
        } else {
            NSLog(@"删除消息失败");
        }
    }];
}

/**
 *  根据消息ID删除消息
 *
 *  @param converseID 消息id
 */
- (void)deleteMessageFormMessageTableByMessageID:(NSString *)messageID {
    FMDatabaseQueue *messageQueue = [FMDBShareManager getQueueWithType:ZhiMa_Chat_MessageTable];
    NSString *option = [NSString stringWithFormat:@"msgid = %@",messageID];
    NSString *detOpeartionStr = [FMDBShareManager deletedTableData:ZhiMa_Chat_MessageTable withOption:option];
    [messageQueue inDatabase:^(FMDatabase *db) {
        BOOL success = [db executeUpdate:detOpeartionStr];
        if (success) {
            NSLog(@"删除消息成功");
        } else {
            NSLog(@"删除消息失败");
        }
    }];
}


@end
