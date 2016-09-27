//
//  NSData+Replace.h
//  ZhiMaBaoBao
//
//  Created by liugang on 16/9/27.
//  Copyright © 2016年 liugang. All rights reserved.
//  将包含非utf8编码的data转换成合法data

#import <Foundation/Foundation.h>

@interface NSData (Replace)

/**
 *  将包含非utf8编码的data转换成标准编码data
 *
 *  @return 编码后的data
 */
- (NSData *)replaceNoUtf8;
@end
