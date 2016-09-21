//
//  KXLocationCell.m
//  YiIM_iOS
//
//  Created by mac on 16/8/29.
//  Copyright © 2016年 ikantech. All rights reserved.
//

#import "KXLocationCell.h"

@implementation KXLocationCell {
    UILabel *_titleLabel;
    UILabel *_subTitleLabel;
    UIView *_bottomLineView;
}

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
        [self seupView];
    }
    return self;
}


- (void)seupView {
    _titleLabel = [[UILabel alloc] init];
    [self addSubview:_titleLabel];
    
    _bottomLineView = [[UIView alloc] init];
    _bottomLineView.backgroundColor = [UIColor lightGrayColor];
    [self addSubview:_bottomLineView];
    
    
    _subTitleLabel = [[UILabel alloc] init];
    _subTitleLabel.textColor = [UIColor lightGrayColor];
    _subTitleLabel.font = [UIFont systemFontOfSize:13];
    _subTitleLabel.textAlignment = NSTextAlignmentRight;
    _subTitleLabel.text = @"已选地区";
    _subTitleLabel.hidden = YES;
    [self addSubview:_subTitleLabel];
    
}

- (void)setIsShowLocation:(BOOL)isShowLocation {
    _isShowLocation = isShowLocation;
    
    _subTitleLabel.hidden = !isShowLocation;
}

- (void)setModel:(KXLocationModel *)model {
    _model = model;
    _titleLabel.text = model.region_name;
}


- (void)layoutSubviews {
    _titleLabel.frame = CGRectMake(30, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
    _subTitleLabel.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame) - 30, CGRectGetHeight(self.frame));
    _bottomLineView.frame = CGRectMake(0, CGRectGetHeight(self.frame) - 0.5, CGRectGetWidth(self.frame), 0.5);
}

@end
