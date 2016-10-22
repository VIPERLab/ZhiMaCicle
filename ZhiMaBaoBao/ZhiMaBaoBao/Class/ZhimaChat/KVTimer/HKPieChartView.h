//
//  HKPieChartView.h
//  PieChart
//
//  Created by hukaiyin on 16/6/20.
//  Copyright © 2016年 HKY. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HKPieChartView : UIView

- (void)updatePercent:(CGFloat)percent  lastProgress:(CGFloat)lastProgress animation:(BOOL)animationed ;

@end
