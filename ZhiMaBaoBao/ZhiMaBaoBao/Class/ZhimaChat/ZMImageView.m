//
//  ZMImageView.m
//  ZhiMaBaoBao
//
//  Created by ios开发 on 16/10/18.
//  Copyright © 2016年 liugang. All rights reserved.
//

#import "ZMImageView.h"

@interface ZMImageView()
{
    CALayer      *_contentLayer;
    CAShapeLayer *_maskLayer;
}
@end
@implementation ZMImageView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}


- (void)setup
{
    _maskLayer = [CAShapeLayer layer];
    _maskLayer.fillColor = [UIColor blackColor].CGColor;
    _maskLayer.strokeColor = [UIColor clearColor].CGColor;
    _maskLayer.frame = self.bounds;
    _maskLayer.contentsCenter = CGRectMake(0.5, 0.5, 0.1, 0.1);
    _maskLayer.contentsScale = [UIScreen mainScreen].scale;
    //非常关键设置自动拉伸的效果且不变形
//    _maskLayer.contents = (id)[UIImage imageNamed:@"chat_bg_sender"].CGImage;
    _contentLayer = [CALayer layer];
    _contentLayer.mask = _maskLayer;
    _contentLayer.frame = self.bounds;
    [self.layer addSublayer:_contentLayer];
    
}
- (void)setBackImage:(UIImage *)backImage
{
    _maskLayer.contents = (id)backImage.CGImage;
    
}


- (void)setZmImage:(UIImage *)zmImage
{
//    _contentLayer.contents = (id)zmImage.CGImage;
    
    CGRect frame = [self pictureSizeToImage:zmImage];
    UIImage* newImage = [self ct_imageFromImage:zmImage inRect:frame];
    _contentLayer.contents = (id)newImage.CGImage;
    
//    _contentLayer.borderWidth = 1;
//    _contentLayer.borderColor = [GRAYCOLOR CGColor];
}

// 以图片为中心获取一个最大的正方形
- (CGRect)pictureSizeToImage:(UIImage*)image
{
    CGRect frame = CGRectMake(0, 0, image.size.width, image.size.height);
    CGSize imgSize = image.size;
    if (imgSize.width >= imgSize.height) {
        frame.origin.x = (image.size.width - image.size.height)/2;
        frame.size.width = image.size.height;
    }else{
        frame.origin.y = (image.size.height - image.size.width)/2;
        frame.size.height = image.size.width;
    }
    
    return frame;
}

//根据正方形截取图片得到新图片
- (UIImage *)ct_imageFromImage:(UIImage *)image inRect:(CGRect)rect{

    CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], rect);
    UIImage *thumbScale = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    return thumbScale;
}

@end
