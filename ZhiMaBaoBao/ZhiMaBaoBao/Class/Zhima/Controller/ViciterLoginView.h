//
//  ViciterLoginView.h
//  ZhiMaBaoBao
//
//  Created by mac on 16/11/14.
//  Copyright © 2016年 liugang. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^loginBlock)();

@interface ViciterLoginView : UIView

@property (nonatomic, copy) loginBlock block;

- (void)setLoginBlock:(loginBlock)block;

@end
