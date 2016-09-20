//
//  UIImage+YiExtension.m
//  YiIM_iOS
//
//  Created by admin on 16/6/1.
//  Copyright © 2016年 ikantech. All rights reserved.
//

#import "UIImage+YiExtension.h"

@implementation UIImage (YiExtension)

- (UIImage *)circle
{
    UIGraphicsBeginImageContextWithOptions(self.size, NO, 0.0);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextAddEllipseInRect(ctx, CGRectMake(0, 0, self.size.width, self.size.height));
    CGContextClip(ctx);
    [self drawInRect:CGRectMake(0, 0, self.size.width, self.size.height)];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return image;
}

+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size
{
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context,color.CGColor);
    CGContextFillRect(context, rect);
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return img;
}

+(instancetype)imageWithName:(NSString *)imgName{
    // 如果系统大于ios7,使用带有ios7的图片
    if([[UIDevice currentDevice].systemVersion doubleValue] >= 7.0){
        NSString *ios7ImgName = [imgName stringByAppendingString:@"_ios7"];
        return [UIImage imageNamed:ios7ImgName];
    }
    
    return [UIImage imageNamed:imgName];
}

+(instancetype)resizeImgWithName:(NSString *)imgName{
    UIImage *img = [UIImage imageNamed:imgName];
    return [img stretchableImageWithLeftCapWidth:img.size.width * 0.5 topCapHeight:img.size.height * 0.5];
}

// 二维码中间画图片
- (UIImage *)iconImageWithIcon:(UIImage *)icon
{
    // 开启上下文
    UIGraphicsBeginImageContext(self.size);
    
    // 1. 将画原图片
    [self drawInRect:CGRectMake(0, 0, self.size.width, self.size.height)];
    
    // 2.在中间画头像 (20%)
    CGFloat iconWH = MIN(self.size.width, self.size.height) * 0.2;
    [icon drawInRect:CGRectMake((self.size.width - iconWH) / 2, (self.size.height - iconWH) / 2, iconWH, iconWH)];
    
    // 3.获取上下文的图片
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // 关闭上下文
    UIGraphicsEndImageContext();
    
    return newImage;
}

@end








