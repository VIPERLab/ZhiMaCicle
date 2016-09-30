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
#import "ZhiMaFriendModel.h"
#import "GroupChatModel.h"
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
    
    //用户相关的表
    FMDatabaseQueue *user_message_DB;
    FMDatabaseQueue *newFriend_message_DB;
    
    //群聊相关的表
    FMDatabaseQueue *group_userMenber_DB;
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
            
        case ZhiMa_Chat_Converse_Table:
            return chat_Converse_DB;
            
        case ZhiMa_Chat_Message_Table:
            return chat_message_DB;
            
        case ZhiMa_User_Message_Table:
            return user_message_DB;
            
        case ZhiMa_NewFriend_Message_Table:
            return newFriend_message_DB;
        
        case ZhiMa_GroupChat_GroupMenber_Table:
            return group_userMenber_DB;
        default:
            NSLog(@"无效参数");
            return nil;
            break;
    }
}

#pragma mark - 建表
- (void)creatTableWithTableType:(ZhiMaSqliteTableType)type {
    
    // 1.通过路径创建数据库
    NSString *path = ZhiMa_SqlitePath;
    [NSString stringWithFormat:@""];
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
                case ZhiMa_Chat_Converse_Table: {    //会话表
                    tableName = ZhiMaChatConvence_Table_Name;
                    tableField = Chat_ConverseField;
                    chat_Converse_DB = db_Queue;
                    break;
                }
                case ZhiMa_Chat_Message_Table: {     //消息表
                    tableName = ZhiMaChatMessage_Table_Name;
                    tableField = Chat_MessageField;
                    chat_message_DB = db_Queue;
                    break;
                }
                case ZhiMa_User_Message_Table: {     //用户信息表
                    tableName = ZhiMaUserMessage_Table_Name;
                    tableField = User_MessageField;
                    user_message_DB = db_Queue;
                    break;
                }
                
                case ZhiMa_NewFriend_Message_Table: {  //新好友表
                    tableName = ZhiMaNewFriend_Table_Name;
                    tableField = NewFrend_MessageField;
                    newFriend_message_DB = db_Queue;
                    break;
                }
                case ZhiMa_GroupChat_GroupMenber_Table: { //群聊成员信息表
                    tableName = ZhiMaGroupChatMember_Table_Name;
                    tableField = GroupChat_MemberField;
                    group_userMenber_DB = db_Queue;
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
        case ZhiMa_Chat_Converse_Table: {
            tableName = ZhiMaChatConvence_Table_Name;
            fieldName = Chat_ConverseFields_Name;
            break;
        }
        case ZhiMa_Chat_Message_Table: {
            tableName = ZhiMaChatMessage_Table_Name;
            fieldName = Chat_MessageFields_name;
            break;
        }
        case ZhiMa_User_Message_Table: {
            tableName = ZhiMaUserMessage_Table_Name;
            fieldName = User_MessageFields_name;
            break;
        }
        case ZhiMa_NewFriend_Message_Table: {
            tableName = ZhiMaNewFriend_Table_Name;
            fieldName = NewFriend_MessageFields_Name;
            break;
        }
        case ZhiMa_GroupChat_GroupMenber_Table: {
            tableName = ZhiMaGroupChatMember_Table_Name;
            fieldName = GroupChat_MemberFields_Name;
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
        case ZhiMa_Chat_Converse_Table: {
            tableName = ZhiMaChatConvence_Table_Name;
            fieldName = Chat_ConverseFields_Name;
            break;
        }
        case ZhiMa_Chat_Message_Table: {
            tableName = ZhiMaChatMessage_Table_Name;
            fieldName = Chat_MessageFields_name;
            break;
        }
        case ZhiMa_User_Message_Table: {
            tableName = ZhiMaUserMessage_Table_Name;
            fieldName = User_MessageFields_name;
            break;
        }
        case ZhiMa_NewFriend_Message_Table: {
            tableName = ZhiMaNewFriend_Table_Name;
            fieldName = NewFriend_MessageFields_Name;
            break;
        }
        case ZhiMa_GroupChat_GroupMenber_Table: {
            tableName = ZhiMaGroupChatMember_Table_Name;
            fieldName = GroupChat_MemberFields_Name;
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
        case ZhiMa_Chat_Converse_Table: {
            tableName = ZhiMaChatConvence_Table_Name;
            break;
        }
        case ZhiMa_Chat_Message_Table: {
            tableName = ZhiMaChatMessage_Table_Name;
            break;
        }
        case ZhiMa_User_Message_Table: {
            tableName = ZhiMaUserMessage_Table_Name;
            break;
        }
        case ZhiMa_NewFriend_Message_Table: {
            tableName = ZhiMaNewFriend_Table_Name;
            break;
        }
        case ZhiMa_GroupChat_GroupMenber_Table: {
            tableName = ZhiMaGroupChatMember_Table_Name;
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
        case ZhiMa_Chat_Converse_Table: {
            tableName = ZhiMaChatConvence_Table_Name;
            break;
        }
        case ZhiMa_Chat_Message_Table: {
            tableName = ZhiMaChatMessage_Table_Name;
            break;
        }
        case ZhiMa_User_Message_Table: {
            tableName = ZhiMaUserMessage_Table_Name;
            break;
        }
        case ZhiMa_NewFriend_Message_Table: {
            tableName = ZhiMaNewFriend_Table_Name;
            break;
        }
        case ZhiMa_GroupChat_GroupMenber_Table: {
            tableName = ZhiMaGroupChatMember_Table_Name;
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


#pragma mark 获取数据源方法
#pragma mark - 朋友圈相关
//                              ----------   朋友圈相关
// 存所有朋友圈信息
- (BOOL)saveCircleDataWithDataArray:(NSArray *)dataArray {
    __block BOOL successFul = YES;
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
                successFul = NO;
            }
            
        }];
        
        if (!successFul) {
            return NO;
        }
        
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
                        successFul = NO;
                    }
                    
                }];
            }
        }
        
        if (!successFul) {
            return NO;
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
                        successFul = NO;
                    }
                    
                }];
            }
        }
        
        if (!successFul) {
            return NO;
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
                        successFul = NO;
                    }
                }];
            }
        }
        
        if (!successFul) {
            return NO;
        }
    }
    return YES;
}

/**
 *  获取所有朋友圈消息
 */
- (NSArray *)getCirCleDataInArrayWithPage:(int)pageNumber {
    
    FMDatabaseQueue *queue = [FMDBShareManager getQueueWithType:ZhiMa_Circle_Table];
    NSString *operationStr = [FMDBShareManager SearchTable:ZhiMa_Circle_Table withOption:[NSString stringWithFormat:@"circle_ID > 0 order by circle_ID desc LIMIT (%zd-1)*30,30",pageNumber]];
    
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
- (BOOL)deleteCircleDataWithCircleID:(NSString *)circleID {
    __block BOOL successFul = YES;
    //删除朋友圈数据库该条记录
    FMDatabaseQueue *queue = [FMDBShareManager getQueueWithType:ZhiMa_Circle_Table];
    NSString *operation = [FMDBShareManager deletedTableData:ZhiMa_Circle_Table withOption:[NSString stringWithFormat:@"circle_ID = %@",circleID]];
    [queue inDatabase:^(FMDatabase *db) {
        BOOL success = [db executeUpdate:operation];
        if (success) {
            NSLog(@"删除成功");
        } else {
            NSLog(@"删除失败");
            successFul = NO;
        }
    }];
    
    if (!successFul) {
        return NO;
    }
    
    //删除评论数据库该条记录
    FMDatabaseQueue *commentQueue = [FMDBShareManager getQueueWithType:ZhiMa_Circle_Comment_Table];
    NSString *commentQueueOpeartion = [FMDBShareManager deletedTableData:ZhiMa_Circle_Comment_Table withOption:[NSString stringWithFormat:@"circle_ID = %@",circleID]];
    [commentQueue inDatabase:^(FMDatabase *db) {
        BOOL success = [db executeUpdate:commentQueueOpeartion];
        if (success) {
            NSLog(@"删除成功");
        } else {
            NSLog(@"删除失败");
            successFul = NO;
        }
    }];
    
    if (!successFul) {
        return NO;
    }
    
    //删除图片数据库该条记录
    FMDatabaseQueue *picQueue = [FMDBShareManager getQueueWithType:ZhiMa_Circle_Comment_Table];
    NSString *picOpeartion = [FMDBShareManager deletedTableData:ZhiMa_Circle_Comment_Table withOption:[NSString stringWithFormat:@"circle_ID = %@",circleID]];
    [picQueue inDatabase:^(FMDatabase *db) {
        BOOL success = [db executeUpdate:picOpeartion];
        if (success) {
            NSLog(@"删除成功");
        } else {
            NSLog(@"删除失败");
            successFul = NO;
        }
    }];
    
    if (!successFul) {
        return NO;
    }
    
    return YES;
}

#pragma mark - 用户相关
//                    -----------   用户表  ----------------
/**
 *  向用户表插入用户数据
 *
 *  @param userMessageArray 用户数据模型数组
 *
 *  @return 是否插入成功
 */
- (BOOL)saveUserMessageWithMessageArray:(NSArray <ZhiMaFriendModel *> *)userMessageArray {
    __block BOOL isSuccess = YES;
    for (ZhiMaFriendModel *model in userMessageArray) {
        __block BOOL isExist = NO;
        FMDatabaseQueue *queue = [FMDBShareManager getQueueWithType:ZhiMa_User_Message_Table];
        NSString *searchOpeartionStr = [FMDBShareManager SearchTable:ZhiMa_User_Message_Table withOption:[NSString stringWithFormat:@"user_Id = %@",model.user_Id]];
        [queue inDatabase:^(FMDatabase *db) {
            FMResultSet *result =[db executeQuery:searchOpeartionStr];
            while ([result next]) {
                isExist = YES;
            }
        }];
        
        NSString *opeartionStr = [NSString string];
        if (isExist) {
            NSLog(@"存在用户,需要更新");
            NSString *option1 = [NSString stringWithFormat:@"user_Name = '%@', user_Head_photo = '%@', user_NickName = '%@'",model.user_Name,model.user_Head_photo,model.user_NickName];
            NSString *option2 = [NSString stringWithFormat:@"user_Id = %@",model.user_Id];
            opeartionStr = [FMDBShareManager alterTable:ZhiMa_User_Message_Table withOpton1:option1 andOption2:option2];
        } else {
            NSLog(@"不存在用户，需要插入");
            opeartionStr = [FMDBShareManager InsertDataInTable:ZhiMa_User_Message_Table];
        }
        
        [queue inDatabase:^(FMDatabase *db) {
            BOOL success = [db executeUpdate:opeartionStr,model.user_Name,model.user_Id,model.user_Head_photo,model.user_NickName];
            if (success) {
                NSLog(@"插入用户成功");
            } else {
                NSLog(@"插入用户失败");
                isSuccess = NO;
            }
        }];
    }
    return isSuccess;
}

/**
 *  查询所有的消息
 *
 *  @return 返回一个ZhiMaFriendModel 的数组
 */
- (NSArray <ZhiMaFriendModel *>*)getAllUserMessageInArray {
    NSMutableArray *dataArray = [NSMutableArray array];
    FMDatabaseQueue *queue = [FMDBShareManager getQueueWithType:ZhiMa_User_Message_Table];
    NSString *option = [FMDBShareManager SearchTable:ZhiMa_User_Message_Table withOption:[NSString stringWithFormat:@"user_Id > 0 order by user_Id desc"]];
    [queue inDatabase:^(FMDatabase *db) {
        FMResultSet *result = [db executeQuery:option];
        while ([result next]) {
            ZhiMaFriendModel *model = [[ZhiMaFriendModel alloc] init];
            model.user_NickName = [result stringForColumn:@"user_NickName"];
            model.user_Name = [result stringForColumn:@"user_Name"];
            model.user_Id = [result stringForColumn:@"user_Id"];
            model.user_Head_photo = [result stringForColumn:@"user_Head_photo"];
            [dataArray addObject:model];
        }
    }];
    
    return [dataArray copy];
}

/**
 *  根据用户id更新用户信息
 *
 *  @param userMessage 用户数据模型
 *
 *  @return 是否成功
 */
- (BOOL)upDataUserMessage:(ZhiMaFriendModel *)userMessage {
    __block BOOL isSuccess = YES;
    NSString *option1 = [NSString stringWithFormat:@"user_Name = '%@', user_Head_photo = '%@', user_NickName = '%@'",userMessage.user_Name,userMessage.user_Head_photo,userMessage.user_NickName];
    NSString *option2 = [NSString stringWithFormat:@"user_Id = %@",userMessage.user_Id];
    NSString *opeartionStr = [FMDBShareManager alterTable:ZhiMa_User_Message_Table withOpton1:option1 andOption2:option2];
    
    FMDatabaseQueue *queue = [FMDBShareManager getQueueWithType:ZhiMa_User_Message_Table];
    [queue inDatabase:^(FMDatabase *db) {
        BOOL success = [db executeUpdate:opeartionStr,userMessage.user_Name,userMessage.user_Head_photo,userMessage.user_NickName];
        if (success) {
            NSLog(@"插入朋友圈成功");
        } else {
            NSLog(@"插入朋友圈失败");
            isSuccess = NO;
        }
        
    }];
    return isSuccess;
}

/**
 *  根据用户id 来删除数据库中的用户信息
 *
 *  @param userID 用户id
 *
 *  @return 是否操作成功
 */
- (BOOL)deleteUserMessageByUserID:(NSString *)userID {
    __block BOOL isSuccess = YES;
    
    FMDatabaseQueue *queue = [FMDBShareManager getQueueWithType:ZhiMa_User_Message_Table];
    NSString *operation = [FMDBShareManager deletedTableData:ZhiMa_User_Message_Table withOption:[NSString stringWithFormat:@"user_Id = %@",userID]];
    [queue inDatabase:^(FMDatabase *db) {
        BOOL success = [db executeUpdate:operation];
        if (success) {
            NSLog(@"删除成功");
        } else {
            NSLog(@"删除失败");
            isSuccess = NO;
        }
    }];
    
    return isSuccess;
}


/**
 *  根据用户的id查询用户信息
 *
 *  @param userID 要查询的用户id
 *
 *  @return 用户信息模型
 */
- (ZhiMaFriendModel *)getUserMessageByUserID:(NSString *)userID {
    ZhiMaFriendModel *model = [[ZhiMaFriendModel alloc] init];
    FMDatabaseQueue *queue = [FMDBShareManager getQueueWithType:ZhiMa_User_Message_Table];
    NSString *option = [FMDBShareManager SearchTable:ZhiMa_User_Message_Table withOption:[NSString stringWithFormat:@"user_Id = %@",userID]];
    [queue inDatabase:^(FMDatabase *db) {
        FMResultSet *result = [db executeQuery:option];
        while ([result next]) {
            model.user_NickName = [result stringForColumn:@"user_NickName"];
            model.user_Name = [result stringForColumn:@"user_Name"];
            model.user_Id = [result stringForColumn:@"user_Id"];
            model.user_Head_photo = [result stringForColumn:@"user_Head_photo"];
        }
    }];
    return model;
}


#pragma mark - 新的好友相关
//                    ------------   新好友表  ----------------
/**
 *  根据用户id 取出当前用户所有的新好友列表
 *
 *  @param userID 当前用户id
 *
 *  @return 新的好友模型数组
 */
- (NSArray <ZhiMaFriendModel *> *)getAllNewFriendsByUserId:(NSString *)userID {
    NSMutableArray *dataArray = [NSMutableArray array];
    FMDatabaseQueue *queue = [FMDBShareManager getQueueWithType:ZhiMa_NewFriend_Message_Table];
    NSString *optionStr = [FMDBShareManager SearchTable:ZhiMa_NewFriend_Message_Table withOption:[NSString stringWithFormat:@"userId = %@ order by id desc",userID]];
    [queue inDatabase:^(FMDatabase *db) {
        FMResultSet *result = [db executeQuery:optionStr];
        while ([result next]) {
            ZhiMaFriendModel *model = [[ZhiMaFriendModel alloc] init];
            model.user_Name = [result stringForColumn:@"user_Name"];
            model.user_Id = [result stringForColumn:@"user_Id"];
            model.user_Head_photo = [result stringForColumn:@"user_Head_photo"];
            model.status = [result intForColumn:@"status"];
            [dataArray addObject:model];
        }
        
    }];
    return [dataArray copy];
}

/**
 *  保存新的好友信息
 *
 *  @param dataArray 新的好友信息数组
 *  @param userId    当前用户id
 */
- (void)saveNewFirendsWithArray:(NSArray <ZhiMaFriendModel *>*)dataArray andUserId:(NSString *)userId {
    for (ZhiMaFriendModel *model in dataArray) {
        FMDatabaseQueue *queue = [FMDBShareManager getQueueWithType:ZhiMa_NewFriend_Message_Table];
        NSString *optionStr = [FMDBShareManager InsertDataInTable:ZhiMa_NewFriend_Message_Table];
        [queue inDatabase:^(FMDatabase *db) {
            BOOL success = [db executeUpdate:optionStr,model.user_Name,model.user_Id,model.user_Head_photo,@(model.status),userId];
            if (success) {
                NSLog(@"插入新好友成功");
            } else {
                NSLog(@"插入新好友失败");
            }
        }];
    }
}

/**
 *  更新新的好友模型
 *
 *  @param model 新的好友模型
 *
 *  @return 是否更新成功
 */
- (BOOL)upDataNewFriendsMessageByFriendModel:(ZhiMaFriendModel *)model {
    __block BOOL successFul = NO;
    FMDatabaseQueue *queue = [FMDBShareManager getQueueWithType:ZhiMa_NewFriend_Message_Table];
    NSString *option1 = [NSString stringWithFormat:@"user_Name = '%@', user_Head_photo = '%@', status = '%@'",model.user_Name,model.user_Head_photo,@(model.status)];
    NSString *option2 = [NSString stringWithFormat:@"user_Id = %@",model.user_Id];
    NSString *optionStr = [FMDBShareManager alterTable:ZhiMa_NewFriend_Message_Table withOpton1:option1 andOption2:option2];
    [queue inDatabase:^(FMDatabase *db) {
        BOOL success = [db executeUpdate:optionStr,model.user_Name,model.user_Head_photo,@(model.status)];
        if (success) {
            NSLog(@"更新新的好友成功");
            successFul = YES;
        } else {
            NSLog(@"更新新的好友失败");
        }
    }];
    
    return successFul;
}

#pragma mark - 会话相关
//                    -----------   会话表  ----------------
/**
 *  保存会话列表数据
 *
 *  @param dataArray 数据数组 <ConverseModel *>
 */
- (void)saveConverseListDataWithDataArray:(NSArray *)dataArray {
    for (ConverseModel *converseModel in dataArray) {
        FMDatabaseQueue *queue = [FMDBShareManager getQueueWithType:ZhiMa_Chat_Converse_Table];
        NSLog(@"开始查会话表");
        __block BOOL isExist = NO;
        [queue inDatabase:^(FMDatabase *db) {
            NSString *searchOptionStr = [FMDBShareManager SearchTable:ZhiMa_Chat_Converse_Table withOption:[NSString stringWithFormat:@"converseId = %@",converseModel.converseId]];
            FMResultSet *result = [db executeQuery:searchOptionStr];
            while ([result next]) {
                NSLog(@"查表成功");
                isExist = YES;
            }
        }];
        
        NSString *operationStr;
        if (isExist) {
            NSLog(@"存在这条会话数据，更新数据");
            converseModel.unReadCount ++;
            NSString *option1 = [NSString stringWithFormat:@"time = '%@', converseType = '%@', converseId = '%@', unReadCount = '%@', topChat = '%@', disturb = '%@', converseName = '%@', converseHead_photo = '%@', converseContent = '%@'",@(converseModel.time),@(converseModel.converseType),converseModel.converseId,@(converseModel.unReadCount),@(converseModel.topChat), @(converseModel.disturb), converseModel.converseName,converseModel.converseHead_photo,converseModel.lastConverse];
            NSString *option2 = [NSString stringWithFormat:@"converseId = %@",converseModel.converseId];
            operationStr = [FMDBShareManager alterTable:ZhiMa_Chat_Converse_Table withOpton1:option1 andOption2:option2];
        } else {
            NSLog(@"不存在这条会话数据，需要插入");
            operationStr = [FMDBShareManager InsertDataInTable:ZhiMa_Chat_Converse_Table];
        }
        
        [queue inDatabase:^(FMDatabase *db) {
            BOOL success = [db executeUpdate:operationStr,converseModel.time,@(converseModel.converseType),converseModel.converseId,converseModel.unReadCount,@(converseModel.topChat), @(converseModel.disturb), converseModel.converseName,converseModel.converseHead_photo,converseModel.lastConverse];
            if (success) {
                NSLog(@"插入会话成功");
            } else {
                NSLog(@"插入会话失败");
            }
        }];
        
        
    }
}

/**
 *  获取会话列表
 *
 *  @return 返回一个ConverseModel数组
 */
- (NSArray *)getChatConverseDataInArray {
    FMDatabaseQueue *queue = [FMDBShareManager getQueueWithType:ZhiMa_Chat_Converse_Table];
    NSMutableArray *dataArray = [NSMutableArray array];
    NSLog(@"开始查会话表");
    [queue inDatabase:^(FMDatabase *db) {
        
        NSString *searchOptionStr = [FMDBShareManager SearchTable:ZhiMa_Chat_Converse_Table withOption:@"time > 0 order by time desc"];
        FMResultSet *result = [db executeQuery:searchOptionStr];
        
        while ([result next]) {
            NSLog(@"查表成功");
            ConverseModel *model = [[ConverseModel alloc] init];
            model.unReadCount = [result intForColumn:@"unReadCount"];
            model.converseName = [result stringForColumn:@"converseName"];
            model.lastConverse = [result stringForColumn:@"converseContent"];
            model.converseHead_photo = [result stringForColumn:@"converseHead_photo"];
            model.converseId = [result stringForColumn:@"converseId"];
            model.converseType = [result intForColumn:@"converseType"];
            model.time = [result intForColumn:@"time"];
            model.topChat = [result intForColumn:@"topChat"];
            model.disturb = [result intForColumn:@"disturb"];
            [dataArray addObject:model];
        }
    }];
    return dataArray;
}

/**
 *  根据会话id查询会话模型
 *
 *  @param converseID 会话id
 *
 *  @return 会话模型
 */
- (ConverseModel *)searchConverseWithConverseID:(NSString *)converseID {
    FMDatabaseQueue *queue = [FMDBShareManager getQueueWithType:ZhiMa_Chat_Converse_Table];
    ConverseModel *model = [[ConverseModel alloc] init];
    [queue inDatabase:^(FMDatabase *db) {
        
        NSString *searchOptionStr = [FMDBShareManager SearchTable:ZhiMa_Chat_Converse_Table withOption:[NSString stringWithFormat:@"converseId = %@",converseID]];
        FMResultSet *result = [db executeQuery:searchOptionStr];
        
        while ([result next]) {
            NSLog(@"查表成功");
            model.unReadCount = [result intForColumn:@"unReadCount"];
            model.converseName = [result stringForColumn:@"converseName"];
            model.lastConverse = [result stringForColumn:@"converseContent"];
            model.converseHead_photo = [result stringForColumn:@"converseHead_photo"];
            model.converseId = [result stringForColumn:@"converseId"];
            model.converseType = [result intForColumn:@"converseType"];
            model.time = [result intForColumn:@"time"];
            model.topChat = [result intForColumn:@"topChat"];
            model.disturb = [result intForColumn:@"disturb"];
        }
    }];
    return model;
}



#pragma mark - 消息相关   罅隙（TM这两个字谁能打出来）
//                    ------------   消息表  ----------------
//  插入消息到 -> 消息表
- (BOOL)saveMessage:(LGMessage *)message toConverseID:(NSString *)converseID {
    
    __block BOOL success = YES;   //消息是否插入成功
    
    //先把消息插入到消息表
    FMDatabaseQueue *messageQueue = [FMDBShareManager getQueueWithType:ZhiMa_Chat_Message_Table];
    NSString *opeartionStr2 = [FMDBShareManager InsertDataInTable:ZhiMa_Chat_Message_Table];
    [messageQueue inDatabase:^(FMDatabase *db) {
        BOOL successFul = [db executeUpdate:opeartionStr2,message.msgid,@(message.type),message.fromUid,message.toUidOrGroupId,@(message.timeStamp),message.text,@(message.isGroup),converseID];
        if (successFul) {
            NSLog(@"插入消息成功");
        } else {
            NSLog(@"插入消息失败");
            success = NO;
        }
    }];
    
    
    if (!success) {
        return success;
    }
    
    //查询这个消息对应的会话是否存在
    // converseID = userID 根据这个id 取出用户表对应的用户数据
    ZhiMaFriendModel *userModel = [FMDBShareManager getUserMessageByUserID:converseID];
    
    FMDatabaseQueue *queue = [FMDBShareManager getQueueWithType:ZhiMa_Chat_Converse_Table];
    NSLog(@"开始查会话表");
    __block BOOL isExist = NO;
    [queue inDatabase:^(FMDatabase *db) {
        NSString *searchOptionStr = [FMDBShareManager SearchTable:ZhiMa_Chat_Converse_Table withOption:[NSString stringWithFormat:@"converseId = %@",converseID]];
        FMResultSet *result = [db executeQuery:searchOptionStr];
        while ([result next]) {
            NSLog(@"存在这个会话");
            isExist = YES;
        }
    }];
    
    //更新会话模型
    ConverseModel *converseModel = [[ConverseModel alloc] init];
    converseModel.time = message.timeStamp;
    converseModel.converseHead_photo = userModel.user_Head_photo;
    converseModel.converseName = userModel.displayName;
    if (message.type == MessageTypeText) {
        converseModel.lastConverse = message.text;
    }else if (message.type == MessageTypeImage){
        converseModel.lastConverse = @"[图片]";
    }else if (message.type == MessageTypeAudio){
        converseModel.lastConverse = @"[语音]";
    }
    
    
    NSString *opeartionStr = [NSString string];
    if (!isExist) {
        //不存在会话列表 ->  创建这个会话
        NSLog(@"会话不存在，需要创建");
        
        converseModel.converseId = converseID;
        converseModel.disturb = NO;
        converseModel.topChat = NO;
        converseModel.unReadCount = 1;
        converseModel.converseType = message.isGroup;
        
        opeartionStr = [FMDBShareManager InsertDataInTable:ZhiMa_Chat_Converse_Table];
        
    } else {
        //更新这个会话
        NSLog(@"会话存在,更新会话");
        //取出这个会话
        converseModel = [FMDBShareManager searchConverseWithConverseID:converseID];
        //设置更新内容
        converseModel.unReadCount ++;
        converseModel.time = message.timeStamp;
        converseModel.lastConverse = message.text;
        
        if (message.type == MessageTypeText) {
            converseModel.lastConverse = message.text;
        }else if (message.type == MessageTypeImage){
            converseModel.lastConverse = @"[图片]";
        }else if (message.type == MessageTypeAudio){
            converseModel.lastConverse = @"[语音]";
        }
        
        NSString *option1 = [NSString stringWithFormat:@"unReadCount = '%@', converseName = '%@', converseContent = '%@', time = '%@'",@(converseModel.unReadCount),converseModel.converseName,converseModel.lastConverse, @(converseModel.time)];
        NSString *option2 = [NSString stringWithFormat:@"converseId = %@",converseModel.converseId];
        
        opeartionStr = [FMDBShareManager alterTable:ZhiMa_Chat_Converse_Table withOpton1:option1 andOption2:option2];
    }
    
    [queue inDatabase:^(FMDatabase *db) {
        BOOL successFul = [db executeUpdate:opeartionStr,@(converseModel.time),@(converseModel.converseType),converseModel.converseId,@(converseModel.unReadCount),@(converseModel.topChat), @(converseModel.disturb), converseModel.converseName,converseModel.converseHead_photo,converseModel.lastConverse];
        if (successFul) {
            NSLog(@"插入会话成功");
        } else {
            NSLog(@"插入会话失败");
            success = NO;
        }
    }];
    
    return success;
}

/**
 *  根据会话id 获取消息列表
 *
 *  @param converseID 会话id
 *
 *  @return 一个消息模型数组 <LGMessage *>
 */
- (NSArray <LGMessage *> *)getMessageDataWithConverseID:(NSString *)converseID andPageNumber:(int)pageNumber {
    NSMutableArray *dataArray = [NSMutableArray array];
    FMDatabaseQueue *queue = [FMDBShareManager getQueueWithType:ZhiMa_Chat_Message_Table];
    NSString *option = [NSString stringWithFormat:@"converseId = %@ order by time asc LIMIT (%zd-1)*20,20",converseID,pageNumber];
    NSString *opeartionStr = [FMDBShareManager SearchTable:ZhiMa_Chat_Message_Table withOption:option];
    [queue inDatabase:^(FMDatabase *db) {
        FMResultSet *result = [db executeQuery:opeartionStr];
        while ([result next]) {
            LGMessage *message = [[LGMessage alloc] init];
            message.msgid = [result stringForColumn:@"msgid"];
            message.type = [result intForColumn:@"type"];
            message.fromUid = [result stringForColumn:@"fromUid"];
            message.isGroup = [result intForColumn:@"isGroup"];
            message.toUidOrGroupId = [result stringForColumn:@"toUidOrGroupId"];
            message.timeStamp = [result intForColumn:@"time"];
            message.text = [result stringForColumn:@"text"];
            [dataArray addObject:message];
        }
    }];
    return dataArray;
}

/**
 *  设置消息的未读数量为0
 *
 *  @param converseId 会话id
 */
- (void)setConverseUnReadCountZero:(NSString *)converseId {
    FMDatabaseQueue *queue = [FMDBShareManager getQueueWithType:ZhiMa_Chat_Converse_Table];
    NSLog(@"开始查会话表");
    [queue inDatabase:^(FMDatabase *db) {
        NSString *option1 = [NSString stringWithFormat:@"unReadCount = '0'"];
        NSString *searchOptionStr = [FMDBShareManager alterTable:ZhiMa_Chat_Converse_Table withOpton1:option1 andOption2:[NSString stringWithFormat:@"converseId = %@",converseId]];
        FMResultSet *result = [db executeQuery:searchOptionStr];
        while ([result next]) {
            NSLog(@"消息置0成功");
        }
    }];
}

/**
 *  根据会话id删除会话
 *
 *  @param converseId 会话模型
 */
- (void)deleteConverseWithConverseId:(NSString *)converseId {
    //先删除消息表
    [self deleteMessageFormMessageTableByConverseID:converseId];
    
    //再删除会话表
    FMDatabaseQueue *queue = [FMDBShareManager getQueueWithType:ZhiMa_Chat_Converse_Table];
    NSString *optionStr = [FMDBShareManager deletedTableData:ZhiMa_Chat_Converse_Table withOption:[NSString stringWithFormat:@"converseId = %@",converseId]];
    [queue inDatabase:^(FMDatabase *db) {
        BOOL success = [db executeUpdate:optionStr];
        if (success) {
            NSLog(@"删除会话成功");
        } else {
            NSLog(@"删除会话失败");
        }
    }];
}

/**
 *  根据会话ID删除消息
 *
 *  @param converseID 会话id
 */
- (void)deleteMessageFormMessageTableByConverseID:(NSString *)converseID {
    FMDatabaseQueue *messageQueue = [FMDBShareManager getQueueWithType:ZhiMa_Chat_Message_Table];
    NSString *option = [NSString stringWithFormat:@"converseId = %@",converseID];
    NSString *detOpeartionStr = [FMDBShareManager deletedTableData:ZhiMa_Chat_Message_Table withOption:option];
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
    FMDatabaseQueue *messageQueue = [FMDBShareManager getQueueWithType:ZhiMa_Chat_Message_Table];
    NSString *option = [NSString stringWithFormat:@"msgid = %@",messageID];
    NSString *detOpeartionStr = [FMDBShareManager deletedTableData:ZhiMa_Chat_Message_Table withOption:option];
    [messageQueue inDatabase:^(FMDatabase *db) {
        BOOL success = [db executeUpdate:detOpeartionStr];
        if (success) {
            NSLog(@"删除消息成功");
        } else {
            NSLog(@"删除消息失败");
        }
    }];
}


#pragma mark - 群聊信息表
//                    ------------   群聊信息表  ----------------
//- (BOOL)saveGroupChatMessage:(GroupChatModel *)model andConverseID:(NSString *)converseID {
//    
//    FMDatabaseQueue *queue = [FMDBShareManager getQueueWithType:ZhiMa_GroupChat_GroupMessage_Table];
//    NSString *opeartionStr = [FMDBShareManager InsertDataInTable:ZhiMa_GroupChat_GroupMessage_Table];
//    
//    return YES;
//}


#pragma mark - 群成员信息表
//                    ------------   群成员信息表  ----------------
/**
 *  保存群成员信息，如果成员存在，则更新成员名称和头像
 *
 *  @param array   群成员数组
 *  @param groupId 群聊id
 *
 */
- (void)saveAllGroupMemberWithArray:(NSArray <ZhiMaFriendModel *> *)array andGroupChatId:(NSString *)groupChatId {
    FMDatabaseQueue *queuq = [FMDBShareManager getQueueWithType:ZhiMa_GroupChat_GroupMenber_Table];
    for (ZhiMaFriendModel *model in array) {
        //查询是否存在该条群成员信息
        BOOL isExist = [FMDBShareManager isGroupMemberWithGroupChatId:groupChatId andMemberId:model.user_Id];
        
        NSString *opeartionStr;
        if (isExist) {
            NSLog(@"存在成员信息");
            NSString *option1 = [NSString stringWithFormat:@"memberNameInGroup = '%@', memberHeader_Photo = '%@'",model.user_NickName,model.user_Head_photo];
            NSString *option2 = [NSString stringWithFormat:@"converseId = %@ and userId = %@",groupChatId, model.user_Id];
            opeartionStr = [FMDBShareManager alterTable:ZhiMa_GroupChat_GroupMenber_Table withOpton1:option1 andOption2:option2];
        } else {
            NSLog(@"不存在成员信息");
            opeartionStr = [FMDBShareManager InsertDataInTable:ZhiMa_GroupChat_GroupMenber_Table];
        }
        
        [queuq inDatabase:^(FMDatabase *db) {
            BOOL success = [db executeUpdate:opeartionStr,model.groupId,model.user_Id,model.user_Name,model.user_NickName,model.user_Head_photo];
            if (success) {
                NSLog(@"插入群成员成功");
            } else {
                NSLog(@"插入群成员失败");
            }
            
        }];
    }
}


/**
 *  根据群id 和用户id 查询群成员表是否有这个人
 *
 *  @param groupId  群聊id
 *  @param memberId 用户id
 *
 *  @return 是否存在
 */
- (BOOL)isGroupMemberWithGroupChatId:(NSString *)groupId andMemberId:(NSString *)memberId {
    __block BOOL successFul = NO;
    FMDatabaseQueue *queue = [FMDBShareManager getQueueWithType:ZhiMa_GroupChat_GroupMenber_Table];
    NSString *optionStr = [FMDBShareManager SearchTable:ZhiMa_GroupChat_GroupMenber_Table withOption:[NSString stringWithFormat:@"converseId = %@ and userId = %@",groupId, memberId]];
    [queue inDatabase:^(FMDatabase *db) {
        FMResultSet *result = [db executeQuery:optionStr];
        while ([result next]) {
            NSLog(@"查询群聊成员成功");
            successFul = YES;
        }
    }];
    
    return successFul;
}

/**
 *  取出该群聊所有群成员
 *
 *  @param groupId 群Id
 *
 *  @return 群成员数组
 */
- (NSArray <ZhiMaFriendModel *> *)getAllGroupMenberWithGroupId:(NSString *)groupId {
    NSMutableArray *dataArray = [NSMutableArray array];
    FMDatabaseQueue *queue = [FMDBShareManager getQueueWithType:ZhiMa_GroupChat_GroupMenber_Table];
    NSString *optionStr = [FMDBShareManager SearchTable:ZhiMa_GroupChat_GroupMenber_Table withOption:[NSString stringWithFormat:@"converseId = %@",groupId]];
    [queue inDatabase:^(FMDatabase *db) {
        FMResultSet *result = [db executeQuery:optionStr];
        while ([result next]) {
            NSLog(@"查询群聊成员成功");
            ZhiMaFriendModel *model = [[ZhiMaFriendModel alloc] init];
            model.user_Id = [result stringForColumn:@"memberId"];
            model.user_Name = [result stringForColumn:@"memberName"];
            model.user_NickName = [result stringForColumn:@"memberNameInGroup"];
            model.user_Head_photo = [result stringForColumn:@"memberHeader_Photo"];
            model.groupId = [result stringForColumn:@"converseId"];
            [dataArray addObject:model];
        }
    }];
    return dataArray;
}

@end
