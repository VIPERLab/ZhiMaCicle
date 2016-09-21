//
//  TelephoneBillCell.h
//  YiIM_iOS
//
//  Created by mac on 16/8/26.
//  Copyright © 2016年 ikantech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TelephoneBillCell : UITableViewCell

@property (nonatomic, weak) UITextField *inputView;

@property (nonatomic, copy) NSString *title;

@property (nonatomic, assign) NSTextAlignment inputViewTextAlignment;

@property (nonatomic, copy) NSString *inputPlaceHolder;
@end
