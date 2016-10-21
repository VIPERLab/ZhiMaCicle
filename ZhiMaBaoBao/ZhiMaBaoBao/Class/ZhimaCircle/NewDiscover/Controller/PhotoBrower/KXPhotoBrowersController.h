//
//  KXPhotoBrowersController.h
//  ZhiMaBaoBao
//
//  Created by mac on 16/10/18.
//  Copyright © 2016年 liugang. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^BackBlock)(NSMutableArray *imageArray);

@interface KXPhotoBrowersController : UIViewController <UIGestureRecognizerDelegate>

@property (nonatomic, strong) NSMutableArray <UIImage *> *imageArray;

@property (nonatomic, assign) int currentIndex;


@end
