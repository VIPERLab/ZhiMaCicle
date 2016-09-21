//
//  NewDIscoverPhotoPickerView.h
//  YiIM_iOS
//
//  Created by mac on 16/8/22.
//  Copyright © 2016年 ikantech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NewDiscoverPhotoPickerView : UIView

@property (nonatomic, strong) NSMutableArray *buttonArray;

@property (nonatomic, strong) NSMutableArray *imagsArray;

- (void)addAnotherButton;

- (void)setButtonWithImageArray:(NSArray *)imageArray;
@end
