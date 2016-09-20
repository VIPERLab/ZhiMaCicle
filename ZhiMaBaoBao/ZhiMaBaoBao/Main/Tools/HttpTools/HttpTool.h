//
//  HttpTool.h
//  WBZhiHuDailyPaper
//
//  Created by caowenbo on 15/12/18.
//  Copyright © 2015年 曹文博. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"
#import "ResponseData.h"

typedef void(^SuccessfulBlock)(ResponseData *responseData);
typedef void(^FailureBlock)(ErrorData *error);


@interface HttpTool : AFHTTPSessionManager
// 单例
+ (instancetype)sharedHttpTool;
- (instancetype)initWithBaseURL:(NSURL *)url;

//请求方式
+ (void)POST:(NSString *)url params:(NSDictionary *)params success:(SuccessfulBlock)SuccessfulBlock failure:(FailureBlock)FailureBlock;



+ (void)getImage:(NSString *)url params:(NSDictionary *)params formData:(NSData *)data success:(void (^)(ResponseData *json))success failure:(void (^)(ErrorData *json))error;
@end
