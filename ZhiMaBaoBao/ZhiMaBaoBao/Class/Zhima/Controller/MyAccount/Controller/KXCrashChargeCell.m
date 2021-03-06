//
//  KXCrashChargeCell.m
//  YiIM_iOS
//
//  Created by mac on 16/9/17.
//  Copyright © 2016年 ikantech. All rights reserved.
//

#import "KXCrashChargeCell.h"
#import "UIColor+My.h"

@implementation KXCrashChargeCell {
    UIImageView *_imageView;
    UILabel *_titleLabel;
    UIButton *_tickButton;
    UIView *_bottomLineView;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
    self.model.isSelected = selected;
    _tickButton.selected = selected;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setupView];
    }
    return self;
}

- (void)setupView {
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    _imageView = [[UIImageView alloc] init];
    [self addSubview:_imageView];
    
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.textColor = [UIColor blackColor];
    _titleLabel.font = [UIFont systemFontOfSize:15];
    [self addSubview:_titleLabel];
    
    _tickButton = [UIButton new];
    _tickButton.userInteractionEnabled = NO;
    [self addSubview:_tickButton];
    [_tickButton setImage:[UIImage imageNamed:@"MyPayWay_tickButton"] forState:UIControlStateNormal];
    [_tickButton setImage:[UIImage imageNamed:@"MyPayWay_tickButton_selected"] forState:UIControlStateSelected];
    
    _bottomLineView = [[UIView alloc] init];
    _bottomLineView.backgroundColor = [UIColor colorFormHexRGB:@"d6d7dc"];
    [self addSubview:_bottomLineView];
}


- (void)setModel:(chargeMomeyMdoel *)model {
    _model = model;
    _titleLabel.text = model.titleName;
    _imageView.image = [UIImage imageNamed:model.iconName];
    [_tickButton setSelected:model.isSelected];
}


- (void)layoutSubviews {
    _imageView.frame = CGRectMake(20, 15, 35, 30);
    _titleLabel.frame = CGRectMake(CGRectGetMaxX(_imageView.frame) + 12, 0, 100, CGRectGetHeight(self.frame));
    
    CGFloat tickX = CGRectGetWidth(self.frame) - 30 - 30;
    _tickButton.frame = CGRectMake(tickX,( CGRectGetHeight(self.frame) -30) * 0.5, 30, 30);
    
    _bottomLineView.frame = CGRectMake(CGRectGetMinX(_imageView.frame), CGRectGetHeight(self.frame) - 0.5, CGRectGetWidth(self.frame), 0.5);
}



@end
