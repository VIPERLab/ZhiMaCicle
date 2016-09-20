//
//  HttpTool.m
//  ZhiMaBaoBao
//
//  Created by liugang on 16/9/19.
//  Copyright © 2016年 liugang. All rights reserved.
//

#import "HttpTool.h"

@implementation HttpTool

+ (instancetype)httpTool{
    static HttpTool *singleTon = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        singleTon = [[HttpTool alloc] initWithBaseURL:[NSURL URLWithString:DFAPIURL]];
    });
    return singleTon;
}

- (instancetype)initWithBaseURL:(NSURL *)url{
    self = [super initWithBaseURL:url];
    if (self) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        [self.requestSerializer willChangeValueForKey:@"timeoutInterval"];
        
        self.requestSerializer.timeoutInterval = 15.0f;
        
        [self.requestSerializer didChangeValueForKey:@"timeoutInterval"];
        
        self.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html",@"application/json",nil];

    }
    return self;
}












@end
