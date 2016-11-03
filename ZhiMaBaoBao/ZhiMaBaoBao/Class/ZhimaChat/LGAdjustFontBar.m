//
//  LGAdjustFontBar.m
//  ZhiMaBaoBao
//
//  Created by liugang on 16/11/3.
//  Copyright © 2016年 liugang. All rights reserved.
//

#import "LGAdjustFontBar.h"
@interface LGAdjustFontBar()

@end

@implementation LGAdjustFontBar

static LGAdjustFontBar *fontBar = nil;

+ (instancetype)shareInstance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!fontBar) {
            fontBar = [[LGAdjustFontBar alloc] initWithFrame:CGRectMake(0, DEVICEHIGHT, DEVICEWITH, 140)];
        }
    });
    return fontBar;
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupViews];
    }
    return self;
}

- (void)setupViews{
    
}


@end
