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

typedef void(^ChatSuccessfulBlock)(NSDictionary *responseData);
typedef void(^ChatFailureBlock)(NSError *error);
typedef void(^ChatProgressBlock)(NSProgress *progress);


@interface HttpTool : AFHTTPSessionManager
// 单例
+ (instancetype)sharedHttpTool;
- (instancetype)initWithBaseURL:(NSURL *)url;

//请求方式
+ (void)POST:(NSString *)url params:(NSDictionary *)params success:(SuccessfulBlock)SuccessfulBlock failure:(FailureBlock)FailureBlock;



+ (void)getImage:(NSString *)url params:(NSDictionary *)params formData:(NSData *)data success:(void (^)(ResponseData *json))success failure:(void (^)(ErrorData *json))error;

// 聊天界面上传图片
+ (void)chatGetImage:(NSString *)url params:(NSDictionary *)params formData:(NSData *)data success:(void (^)(NSDictionary *json))success failure:(void (^)(NSError *))errorblock;
// 聊天界面上传视频
+ (void)chatGetVideo:(NSString *)url params:(NSDictionary *)params formData:(NSData *)data success:(void (^)(NSDictionary *json))success progress:(void (^)(NSProgress *pro))progress failure:(void (^)(NSError *))errorblock;

// 聊天界面下载视频
+ (void)chatDownLoadVideo:(NSString *)path urlStr:(NSString*)urlStr success:(void (^)(NSDictionary *json))success progress:(void (^)(NSProgress *pro))progress failure:(void (^)(NSError *))errorblock;

+ (void)upLoadFileWithURL:(NSString *)url andParams:(NSMutableDictionary *)params andFilePath:(NSString *)filePath success:(void (^)(ResponseData *json))success failure:(void (^)(ErrorData *json))error;
+ (void)downloadFileWithURL:(NSString *)url success:(void (^)(ResponseData *json))success failure:(void (^)(ErrorData *json))errorBlock;

@end
