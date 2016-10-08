//
//  SDTimeLineCellModel.m
//  GSD_WeiXin(wechat)
//
//  Created by gsd on 16/2/25.
//  Copyright © 2016年 GSD. All rights reserved.
//


#import "SDTimeLineCellModel.h"
#import "MJExtension.h"
#import <UIKit/UIKit.h>

extern const CGFloat contentLabelFontSize;
extern CGFloat maxContentLabelHeight;

@implementation SDTimeLineCellModel
{
    CGFloat _lastContentWidth;
}

@synthesize content = _content;



+ (NSDictionary *)mj_replacedKeyFromPropertyName {
    return @{
              @"circle_ID":@"id",
             };
}


+ (NSArray <SDTimeLineCellModel *>*)getModelArrayWithJsonData:(ResponseData *)responseData andIsUpdata:(BOOL)isUpdata {
    NSMutableArray *modelArray = [SDTimeLineCellModel mj_objectArrayWithKeyValuesArray:responseData.data];
    UserInfo *info = [UserInfo read];
    for (SDTimeLineCellModel *cellModel in modelArray) {
        
        //保存第一条（最新一条的朋友圈ID）
        if (!USERINFO.lastFcID.length || isUpdata) {
            info.lastFcID = cellModel.circle_ID;
            [info save];
            isUpdata = NO;
            [[NSNotificationCenter defaultCenter] postNotificationName:K_UpdataUnReadNotification object:nil];
        }
        
        //转换数组类型
        if (cellModel.imglist.count != 0) {
            NSArray *picArray = [SDTimeLineCellPicItemModel mj_objectArrayWithKeyValuesArray:cellModel.imglist];
            cellModel.imglist = picArray;
        }
        
        
        //如果有评论，则转换评论数据类型
        if (cellModel.commentList.count !=0) {
            NSMutableArray *commentListArray = [SDTimeLineCellCommentItemModel mj_objectArrayWithKeyValuesArray:cellModel.commentList];
            
            NSMutableArray *likeItemsArray = [NSMutableArray array];
            
            //需要循环的次数
            NSInteger count = commentListArray.count -1;
            
            //拷贝一份评论数组
            NSMutableArray *copyArray = [commentListArray mutableCopy];
            
            //循环开始
            for (NSInteger index = count; index >= 0; index--) {
                
                //获取原始数据Model
                SDTimeLineCellCommentItemModel *model = commentListArray[index];
                
                
                if (model.type) {
                    //如果是点赞，则把MODEL移出拷贝数组，放到like数组
                    [copyArray removeObjectAtIndex:index];
                    
                    SDTimeLineCellLikeItemModel *likeModel = [[SDTimeLineCellLikeItemModel alloc] init];
                    if (!model.friend_nick) {
                        model.friend_nick = @"未命名";
                    }
                    
                    likeModel.userName = model.friend_nick;
                    likeModel.userId = model.userId;
                    [likeItemsArray addObject:likeModel];
                    
                    //判断是否点赞了
                    if (!cellModel.liked) {
                        if ([likeModel.userId isEqualToString:USERINFO.userID]) {
                            cellModel.liked = YES;
                        } else {
                            cellModel.liked = NO;
                        }
                    }
                }
            }
            
            //循环结束之后，把筛选剩下的评论数赋值回去
            commentListArray = [copyArray mutableCopy];
            
            
            for (SDTimeLineCellCommentItemModel *model in commentListArray) {
                if (!model.friend_nick) {
                    model.friend_nick = @"未命名";
                }
            }
            
            cellModel.likeItemsArray = [likeItemsArray mutableCopy];
            cellModel.commentList = [commentListArray mutableCopy];
        }
        
    }
    
    return [modelArray copy];

}


- (void)setMsgContent:(NSString *)msgContent
{
    _content = msgContent;
}

- (NSString *)msgContent
{
    CGFloat contentW = [UIScreen mainScreen].bounds.size.width - 70;
    if (contentW != _lastContentWidth) {
        _lastContentWidth = contentW;
        CGRect textRect = [_content boundingRectWithSize:CGSizeMake(contentW, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:contentLabelFontSize]} context:nil];
        if (textRect.size.height > maxContentLabelHeight) {
            _shouldShowMoreButton = YES;
        } else {
            _shouldShowMoreButton = NO;
        }
    }
    
    return _content;
}

- (void)setIsOpening:(BOOL)isOpening
{
    if (!_shouldShowMoreButton) {
        _isOpening = NO;
    } else {
        _isOpening = isOpening;
    }
}


@end


@implementation SDTimeLineCellLikeItemModel


@end

@implementation SDTimeLineCellCommentItemModel

+ (NSDictionary *)mj_replacedKeyFromPropertyName {
    return @{
             @"ID" : @"id"
             };
}


@end

@implementation SDTimeLineCellPicItemModel


@end
