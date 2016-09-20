//
//  LGPhoneNumberCell.h
//  YiIM_iOS
//
//  Created by liugang on 16/9/7.
//  Copyright © 2016年 ikantech. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LGPhoneNumberCellDelegate <NSObject>

- (void)makeCall:(NSInteger)row;
@end

@interface LGPhoneNumberCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *phoneNumber;
@property (nonatomic, assign) NSInteger row;
@property (nonatomic, assign) id<LGPhoneNumberCellDelegate> delegate;

@end
