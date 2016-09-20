//
//  LYVoIP.h
//  LYVoIP
//
//  Created by lijia on 16/8/5.
//  Copyright © 2016年 lzy. All rights reserved.
//

#import <Foundation/Foundation.h>

@class LYResponseModel;
@protocol LYVoIPDelegate <NSObject>

@end

/**
 *  SDK运行模式
 */
typedef NS_ENUM(NSUInteger,LYVoIPModel) {
    /**
     *  当app正在上架审核时建议改为此模式
     */
    LYVoIPModelAPPReView,
    /**
     *  默认模式
     */
    LYVoIPModelNone
 
};

typedef void (^LYSuccessBlock)(LYResponseModel *responseModel);
typedef void (^LYFailureBlock)(NSError *error);


@interface LYVoIP : NSObject
@property(nonatomic,assign)id<LYVoIPDelegate> voIPDelegate;

+(instancetype)shareInstance;

/**
 *  SDK配置、初始化
 *  @param voipID 申请到id
 *  @param key    申请到key
 *  @param model  SDK运行模式
 */
-(void)voipConfigWithID:(NSString *)voipID Key:(NSString *)key model:(LYVoIPModel)model;

/**
 *  回拨方法
 *  @param caller 主叫号码
 *  @param called 被叫号码
 */
-(void)voipCallBackWithCaller:(NSString *)caller  Called:(NSString *)called success:(LYSuccessBlock)successBlock failure:(LYFailureBlock)failureBlock;
/**
 *  查询余额方法
 *  @param mobile 手机号码
 */
-(void)voipQueryWithMobile:(NSString *)mobile success:(LYSuccessBlock)successBlock failure:(LYFailureBlock)failureBlock;
/**
 *  充值方法
 *  @param mobile 目标手机号码
 *  @param num 卡号
 *  @param pwd 卡密
 */
-(void)voipRechargeWithMobile:(NSString *)mobile CardNumber:(NSString *)num CardPassword:(NSString *)pwd success:(LYSuccessBlock)successBlock failure:(LYFailureBlock)failureBlock;
@end
