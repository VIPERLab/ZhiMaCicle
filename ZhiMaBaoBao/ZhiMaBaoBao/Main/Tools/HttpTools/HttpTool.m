//
//  HttpTool.m
//  WBZhiHuDailyPaper
//
//  Created by caowenbo on 15/12/18.
//  Copyright © 2015年 曹文博. All rights reserved.
//

#import "HttpTool.h"
#import "AFNetworking.h"
#import "MJExtension.h"

@interface HttpTool ()

@end

@implementation HttpTool {
    HttpTool *_httpManager;
}


+ (instancetype)sharedHttpTool {
    return [[self alloc] initWithBaseURL:[NSURL URLWithString:DFAPIURL]];
}


- (instancetype)initWithBaseURL:(NSURL *)url {
    
    if (!_httpManager) {
        static dispatch_once_t onceToken;
        
        dispatch_once(&onceToken, ^{
            
            _httpManager  = [[HttpTool alloc] initWithBaseURL:url];
            // 设置超时时间
            [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
            
            [_httpManager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
            
            _httpManager.requestSerializer.timeoutInterval = 15.0f;
            
            [_httpManager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
            
            _httpManager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html",@"application/json",nil];
            
        });
    }
    return _httpManager;
}


+ (void)POST:(NSString *)url params:(NSDictionary *)params success:(SuccessfulBlock)SuccessfulBlock failure:(FailureBlock)FailureBlock
{
//    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer.timeoutInterval = 30.0f;
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html",@"application/json",nil];
    
    [manager POST:[NSString stringWithFormat:@"%@%@",DFAPIURL,url] parameters:params progress:0 success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        
        
        if (responseObject) {
            ResponseData *data = [ResponseData mj_objectWithKeyValues:responseObject];
            
            //状态码为重新登录
            if (data.code == 14) {
//                [[NSNotificationCenter defaultCenter] postNotificationName:Show_Login object:nil];
//                return ;
            }
            //成功访问
            SuccessfulBlock(data);
        }else{
            //responObject为Nil
            ErrorData *error = [ErrorData mj_objectWithKeyValues:responseObject];
            FailureBlock(error);
            return ;
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//        [LCProgressHUD hide];
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        NSLog(@"请求掉起失败：%@",error.description);
        if (error) {
            ErrorData *errorData = [ErrorData new];
            errorData.code = error.code;
            errorData.msg = @"请检查网络";
            FailureBlock(errorData);
        }
    }];
}


+ (void)getImage:(NSString *)url params:(NSDictionary *)params formData:(NSData *)data success:(void (^)(ResponseData *json))success failure:(void (^)(ErrorData *))error {
    NSString *murl = [NSString stringWithFormat:@"%@%@",DFAPIURL,url];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager POST:murl parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        if (data) {
            [formData appendPartWithFileData:data name:@"imgName" fileName:@"photo.png" mimeType:@"image/jpeg"];
        }
    } progress:0 success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (success) {
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            //封装返回数据
            ResponseData *data = [ResponseData mj_objectWithKeyValues:responseObject];
            NSLog(@"responseData:%@",data.data);
            
            success(data);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (error) {
            
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            FailureBlock(error);
        }
    }];
    
}

+ (void)chatGetImage:(NSString *)url params:(NSDictionary *)params formData:(NSData *)data success:(void (^)(NSDictionary *json))success failure:(void (^)(NSError *))errorblock {


    NSString *murl = [NSString stringWithFormat:@"%@/Api/pic/upfile",CHATPICURL];//@"http://172.16.0.247/Api/pic/upfile";
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];

    [manager POST:murl parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        if (data) {
            [formData appendPartWithFileData:data name:@"file" fileName:@"photo.png" mimeType:@"image/jpeg"];
        }
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        NSLog(@"------%lf",uploadProgress.fractionCompleted);
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (success) {
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            //封装返回数据
            NSDictionary *data = responseObject;
            //            NSLog(@"responseData:%@",data.data);
            
            success(data);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (error) {
            
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            errorblock(error);
        }
    }];
    
}

+ (void)chatGetVideo:(NSString *)url params:(NSDictionary *)params formData:(NSData *)data success:(void (^)(NSDictionary *json))success progress:(void (^)(NSProgress *pro))progress failure:(void (^)(NSError *))errorblock {
    
    
    NSString *murl = [NSString stringWithFormat:@"%@/Api/Vedio/upfile",CHATPICURL];//@"http://172.16.0.247/Api/pic/upfile";
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    [manager POST:murl parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        if (data) {
            [formData appendPartWithFileData:data name:@"file" fileName:@"video.mp4" mimeType:@"mp4"];
        }
    } progress:^(NSProgress * _Nonnull uploadProgress) {
//        NSLog(@"------%lf",uploadProgress.fractionCompleted);
        progress(uploadProgress);
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (success) {
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            //封装返回数据
            NSDictionary *data = responseObject;
            //            NSLog(@"responseData:%@",data.data);
            
            success(data);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (error) {
            
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            errorblock(error);
        }
    }];
    
}

// 聊天界面下载视频
+ (void)chatDownLoadVideo:(NSString *)path urlStr:(NSString*)urlStr success:(void (^)(NSDictionary *json))success progress:(void (^)(NSProgress *pro))progress failure:(void (^)(NSError *))errorblock
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager setResponseSerializer:[AFJSONResponseSerializer serializer]];

    NSString  *fullPath = path;
    NSURL *urll = [NSURL URLWithString:urlStr];
    NSURLRequest *request = [NSURLRequest requestWithURL:urll];
    NSURLSessionDownloadTask *task =[manager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        
//        NSLog(@"------%lf",downloadProgress.fractionCompleted);
        progress(downloadProgress);
        
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        
        return [NSURL fileURLWithPath:fullPath];
        
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        if (error) {
            errorblock(error);
        }else{
            success(@{@"success":@"0"});
        }
    }];
    [task resume];
}

// 上传文件
+ (void)upLoadFileWithURL:(NSString *)url andParams:(NSMutableDictionary *)params andFilePath:(NSString *)filePath success:(void (^)(ResponseData *json))success failure:(void (^)(ErrorData *json))errorBlock {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer.timeoutInterval = 30.0f;
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html",@"application/json",nil];
    
    [manager POST:[NSString stringWithFormat:@"%@%@",DFAPIURL,url] parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
        NSData *imageData = [NSData dataWithContentsOfFile:filePath];//amr 
        [formData appendPartWithFileData:imageData name:@"file" fileName:[NSString stringWithFormat:@"voice.mp3"] mimeType:@"audio/mp3"];
        
    } progress:0 success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        ResponseData *data = [ResponseData mj_objectWithKeyValues:responseObject];
        success(data);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        ErrorData *data = [ErrorData mj_objectWithKeyValues:error];
        errorBlock(data);
        
    }];
}

// 下载文件

+ (void)downloadFileWithURL:(NSString *)url success:(void (^)(ResponseData *json))success failure:(void (^)(ErrorData *json))errorBlock {
    AFHTTPSessionManager *manager =[AFHTTPSessionManager manager];
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",DFAPIURL,url]];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
     NSURLSessionDownloadTask *download = [manager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        
        //监听下载进度
        //completedUnitCount 已经下载的数据大小
        //totalUnitCount     文件数据的中大小
        NSLog(@"%f",1.0 *downloadProgress.completedUnitCount / downloadProgress.totalUnitCount);
        
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        NSString *fullPath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:response.suggestedFilename];
        NSLog(@"targetPath:%@",targetPath);
        NSLog(@"fullPath:%@",fullPath);
        return [NSURL fileURLWithPath:fullPath];
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        
        NSLog(@"%@",filePath);
        ResponseData *data = [[ResponseData alloc] init];
        data.data = filePath;
        success(data);
        
    }];
    [download resume];
}


@end
