//
//  NewDiscoverHeaderCell.h
//  YiIM_iOS
//
//  Created by mac on 16/8/22.
//  Copyright © 2016年 ikantech. All rights reserved.
//

#import <UIKit/UIKit.h>
@class NewDiscoverPhotoPickerView;


@interface NewDiscoverHeaderView : UIView
@property (nonatomic, weak) UITextView *textView;


- (void)setContentWithImageArray:(NSArray *)imageArray;
@end
