//
//  LGPickerView.h
//  ZhiMaBaoBao
//
//  Created by liugang on 16/10/21.
//  Copyright © 2016年 liugang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MoreInfoModel.h"

@protocol LGPickerViewDelegate <NSObject>

//选择了某一行，输出结果
- (void)selectedRow:(NSInteger)row andModel:(MoreInfoModel *)model;

@end

@interface LGPickerView : UIView

//初始化方法，默认高度为160  3行
+ (instancetype)pickerView;

//显示
- (void)show;

- (void)dismiss;

@property (nonatomic, copy) NSString *title;            //pickerView标题
@property (nonatomic, assign) CGFloat rowHeight;        //行高  默认为40
@property (nonatomic, assign) CGFloat componentWidth;   //列宽  默认为屏幕宽度
@property (nonatomic, strong) NSArray *dataArr;         //数据源数组 (存放模型数组)

@property (nonatomic, assign) id<LGPickerViewDelegate> delegate;

@end
