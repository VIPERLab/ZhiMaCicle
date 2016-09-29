//
//  LGPhotosView.m
//  YiIM_iOS
//
//  Created by liugang on 16/8/26.
//  Copyright © 2016年 ikantech. All rights reserved.
//

#import "LGPhotosView.h"

@implementation LGPhotosView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
//        self.photosArr = [NSMutableArray array];
//        [self configerSubviews];
    }
    return self;
}

- (void)setPhotosArr:(NSMutableArray *)photosArr{
    _photosArr = photosArr;
    
    CGFloat imageWH = 60;
    CGFloat padding = 10;
    for (int i = 0; i<self.photosArr.count; i++) {
        CGFloat x = (imageWH + padding) * i;
        NSString *imageUrl = [NSString stringWithFormat:@"%@%@",DFAPIURL,[self.photosArr objectAtIndex:i]];
        UIImageView *imageview = [[UIImageView alloc] initWithFrame:CGRectMake(x, 0, imageWH, imageWH)];
        [imageview sd_setImageWithURL:[NSURL URLWithString:imageUrl]];
        [self addSubview:imageview];
    }

}

////配置所有子试图
//- (void)configerSubviews{
//    CGFloat imageWH = 50;
//    CGFloat padding = 5;
//    for (int i = 0; i<self.photosArr.count; i++) {
//        CGFloat x = (imageWH + padding) * i;
//        NSString *imageUrl = [NSString stringWithFormat:@"%@%@",DFAPIURL,[self.photosArr objectAtIndex:i]];
//        UIImageView *imageview = [[UIImageView alloc] initWithFrame:CGRectMake(x, 0, imageWH, imageWH)];
//        [imageview sd_setImageWithURL:[NSURL URLWithString:imageUrl]];
//        [self addSubview:imageview];
//    }
//}

@end
