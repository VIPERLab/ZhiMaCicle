//
//  UIImage+YiExtension.h
//  YiIM_iOS
//
//  Created by admin on 16/6/1.
//  Copyright © 2016年 ikantech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (YiExtension)

// 图片转圆角
- (UIImage *)circle;

// 颜色转图片
+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size;


+(instancetype)imageWithName:(NSString *)imgName;

/**
 *  自动从中间拉伸图片
 *
 *  @param imgName 图片名称
 */
+(instancetype)resizeImgWithName:(NSString *)imgName;

// 二维码中间画图片
- (UIImage *)iconImageWithIcon:(UIImage *)icon;

@end
