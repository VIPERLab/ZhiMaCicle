//
//  CallBottombar.h
//  ZhiMaBaoBao
//
//  Created by liugang on 16/9/19.
//  Copyright © 2016年 liugang. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CallBarDelegate <NSObject>

//取消拨打电话
- (void)cancelCallPhone;
//拨打电话
- (void)callPhone;

@end

@interface CallBottombar : UIWindow

@property (nonatomic, assign) id<CallBarDelegate> delegate;

+ (instancetype)shareinstance;
- (void)show;
- (void)dismiss;
@end
