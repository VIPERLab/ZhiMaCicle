//
//  ZMAnswerLabel.h
//  ZhiMaBaoBao
//
//  Created by ios开发 on 16/11/3.
//  Copyright © 2016年 liugang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZMAnswerLabel : UIView

@property (nonatomic, copy) NSString *text;   //答案字符串
@property (nonatomic, assign)BOOL isChoice;   //是否被选中状态

@end
