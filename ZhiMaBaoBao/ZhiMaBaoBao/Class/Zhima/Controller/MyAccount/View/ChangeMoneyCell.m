//
//  ChangeMoneyCell.m
//  YiIM_iOS
//
//  Created by mac on 16/8/27.
//  Copyright © 2016年 ikantech. All rights reserved.
//

#import "ChangeMoneyCell.h"

@interface ChangeMoneyCell ()




@end

@implementation ChangeMoneyCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setupView];
    }
    return self;
}

- (void)setupView {
    
    UILabel *titleLabel = [[UILabel alloc] init];
    self.titleLabel = titleLabel;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont systemFontOfSize:15];
    
    UITextField *textFild = [[UITextField alloc] init];
    self.textFild = textFild;
    textFild.textAlignment = NSTextAlignmentCenter;
    textFild.font = [UIFont systemFontOfSize:15];
    
}

- (void)layoutSubviews {
    self.titleLabel.frame = CGRectMake(0, 0, 100, CGRectGetHeight(self.frame));
    
    self.textFild.frame = CGRectMake(CGRectGetMaxX(_titleLabel.frame), 0, CGRectGetWidth(self.frame) - 100, CGRectGetHeight(self.frame));
    
    
}

@end
