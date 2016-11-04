//
//  LGServiceList.h
//  ZhiMaBaoBao
//
//  Created by liugang on 16/11/3.
//  Copyright © 2016年 liugang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LGServiceList : NSObject

/** 服务号消息文章id*/
//@property (nonatomic, copy) NSString *redid;
/** 服务号消息文章id*/

@property (nonatomic, assign) NSInteger redid;
/** 服务号消息文章标题*/
@property (nonatomic, copy) NSString *subject;
/** 服务号消息文章副标题*/
@property (nonatomic, copy) NSString *subsubject;
/** 服务号消息文章图片链接*/
@property (nonatomic, copy) NSString *picurl;
/** 服务号消息文章网页链接*/
@property (nonatomic, copy) NSString *link;


@end
