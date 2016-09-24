//
//  FMDBManager.m
//  FMDBTestDemo
//
//  Created by mac on 16/9/22.
//  Copyright © 2016年 mac. All rights reserved.
//

#import "FMDBManager.h"
#import "SDTimeLineCellModel.h"
#import <objc/runtime.h>
#import "FMDBManagerHeader.h"


@implementation FMDBManager {
    FMDatabaseQueue *circle_DB;
    FMDatabaseQueue *circle_Comment_DB;
    FMDatabaseQueue *circle_Pic_DB;
    FMDatabaseQueue *circle_Like_Db;
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
        default:
            NSLog(@"无效参数");
            return nil;
            break;
    }
}

#pragma mark - 建表
- (void)creatTableWithTableType:(ZhiMaSqliteTableType)type {
    
    // 1.通过路径创建数据库
    NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject;
    switch (type) {
        case ZhiMa_Circle_Table:
            path = [path stringByAppendingPathComponent:@"ZhiMa_Circle.sqlite"];
            break;
        case ZhiMa_Circle_Comment_Table:
            path = [path stringByAppendingPathComponent:@"ZhiMa_Circle_Comment.sqlite"];
            break;
        case ZhiMa_Circle_Pic_Table:
            path = [path stringByAppendingPathComponent:@"ZhiMa_Circle_Pic.sqlite"];
            break;
        case ZhiMa_Circle_Like_Table:
            path = [path stringByAppendingPathComponent:@"ZhiMa_Circle_Like.sqlite"];
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


#pragma mark - 获取数据源方法
// 存所有朋友圈信息
- (void)saveCircleDataWithDataArray:(NSArray *)dataArray {
    //插入数据
    for (SDTimeLineCellModel *cellModel in dataArray) {
        FMDatabaseQueue *queue = [FMDBShareManager getQueueWithType:ZhiMa_Circle_Table];
        NSLog(@"开始查朋友圈表");
        __block BOOL isExist = NO;
        [queue inDatabase:^(FMDatabase *db) {
            NSString *searchOptionStr = [FMDBShareManager SearchTable:ZhiMa_Circle_Table withOption:[NSString stringWithFormat:@"fcid = %@",cellModel.ID]];
            FMResultSet *result = [db executeQuery:searchOptionStr];
            
            while ([result next]) {
                NSLog(@"查表成功");
                isExist = YES;
            }
            
        }];
        NSString *operationStr;
        if (isExist) {
            NSLog(@"存在这条朋友圈数据，更新是时间");
            NSString *option1 = [NSString stringWithFormat:@"create_time = '%@'",cellModel.create_time];
            NSString *option2 = [NSString stringWithFormat:@"fcid = %@",cellModel.ID];
            operationStr = [FMDBShareManager alterTable:ZhiMa_Circle_Table withOpton1:option1 andOption2:option2];
        } else {
            NSLog(@"不存在这条朋友圈数据，需要插入");
            operationStr = [FMDBShareManager InsertDataInTable:ZhiMa_Circle_Table];
        }
        
        [queue inDatabase:^(FMDatabase *db) {
            BOOL success = [db executeUpdate:operationStr,cellModel.friend_nick,cellModel.ID,cellModel.openfireaccount,cellModel.content,cellModel.current_location,cellModel.create_time,cellModel.head_photo];
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
                    BOOL success = [db executeUpdate:operationStr,commentModel.friend_nick,commentModel.ID,commentModel.comment,commentModel.reply_friend_nick,commentModel.reply_openfireaccount,commentModel.head_photo,commentModel.create_time,cellModel.ID,commentModel.openfireaccount];
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
                NSString *searchOptionStr = [FMDBShareManager SearchTable:ZhiMa_Circle_Pic_Table withOption:[NSString stringWithFormat:@"circle_ID = %@",cellModel.ID]];
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
                    BOOL success = [db executeUpdate:operationStr,picModel.img_url,picModel.bigimg_url,cellModel.ID];
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
                NSString *searchOptionStr = [FMDBShareManager SearchTable:ZhiMa_Circle_Like_Table withOption:[NSString stringWithFormat:@"circle_ID = %@ and userId = %@",cellModel.ID,likeModel.userId]];
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
                    BOOL success = [db executeUpdate:operationStr,likeModel.userName,likeModel.userId,@"",cellModel.ID];
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
    NSString *operationStr = [FMDBShareManager SearchTable:ZhiMa_Circle_Table withOption:@"fcid > 0 order by fcid desc"];
    NSMutableArray *cellModelArray = [NSMutableArray array];
    [queue inDatabase:^(FMDatabase *db) {
        
        FMResultSet *result = [db executeQuery:operationStr];
        while ([result next]) {
            SDTimeLineCellModel *model = [[SDTimeLineCellModel alloc] init];
            model.ID = [result stringForColumn:@"fcid"];
            model.friend_nick = [result stringForColumn:@"friend_nick"];
            model.openfireaccount = [result stringForColumn:@"openfireaccount"];
            model.content = [result stringForColumn:@"content"];
            model.current_location = [result stringForColumn:@"current_location"];
            model.create_time = [result stringForColumn:@"create_time"];
            model.head_photo = [result stringForColumn:@"head_photo"];
            [cellModelArray addObject:model];
        }
    }];
    
    for (SDTimeLineCellModel *cellModel in cellModelArray) {
        FMDatabaseQueue *queue = [FMDBShareManager getQueueWithType:ZhiMa_Circle_Comment_Table];
        NSString *operationStr = [FMDBShareManager SearchTable:ZhiMa_Circle_Comment_Table withOption:[NSString stringWithFormat:@"circle_ID = %@",cellModel.ID]];
        
        [queue inDatabase:^(FMDatabase *db) {
            NSMutableArray *commentListArray = [NSMutableArray array];
            FMResultSet *result = [db executeQuery:operationStr];
            while ([result next]) {
                SDTimeLineCellCommentItemModel *model = [[SDTimeLineCellCommentItemModel alloc] init];
                model.friend_nick = [result stringForColumn:@"friend_nick"];
                model.ID = [result stringForColumn:@"fcid"];
                model.openfireaccount = [result stringForColumn:@"openfireaccount"];
                model.reply_friend_nick = [result stringForColumn:@"reply_friend_nick"];
                model.reply_openfireaccount = [result stringForColumn:@"reply_openfireaccount"];
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
        NSString *operationStr = [FMDBShareManager SearchTable:ZhiMa_Circle_Pic_Table withOption:[NSString stringWithFormat:@"circle_ID = %@",cellModel.ID]];
        
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
        NSString *operationStr = [FMDBShareManager SearchTable:ZhiMa_Circle_Like_Table withOption:[NSString stringWithFormat:@"circle_ID = %@",cellModel.ID]];
        
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
    NSString *operation = [FMDBShareManager deletedTableData:ZhiMa_Circle_Table withOption:[NSString stringWithFormat:@"fcid = %@",circleID]];
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



@end
