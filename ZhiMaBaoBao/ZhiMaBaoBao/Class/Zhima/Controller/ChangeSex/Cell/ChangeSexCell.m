//
//  ChangeSexCell.m
//  ZhiMaBaoBao
//
//  Created by mac on 16/10/14.
//  Copyright © 2016年 liugang. All rights reserved.
//

#import "ChangeSexCell.h"

@implementation ChangeSexCell {
    UILabel *_titleLabel;
    UIImageView *_tickImage;
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
        [self setupView];
    }
    return self;
}

- (void)setupView {
    _titleLabel = [UILabel new];
    [self addSubview:_titleLabel];
    
    _tickImage = [UIImageView new];
    _tickImage.image = [UIImage imageNamed:@"Sex_Tick"];
    _tickImage.hidden = YES;
    [self addSubview:_tickImage];
    
    _bottomLineView = [UIView new];
    _bottomLineView.backgroundColor = [UIColor colorFormHexRGB:@"dedede"];
    [self addSubview:_bottomLineView];
}

- (void)setTitleName:(NSString *)titleName {
    _titleName = titleName;
    _titleLabel.text = titleName;
}

- (void)setIsSelected:(BOOL)isSelected {
    _isSelected = isSelected;
    _tickImage.hidden = !isSelected;
}

- (void)layoutSubviews {
    _titleLabel.frame = CGRectMake(20, 0, 50, CGRectGetHeight(self.frame));
    _tickImage.frame = CGRectMake(CGRectGetWidth(self.frame) - 15 - 20, (CGRectGetHeight(self.frame) - 15) * 0.5, 15, 15);
    _bottomLineView.frame = CGRectMake(20, CGRectGetHeight(self.frame) - 0.5, ScreenWidth - 20, 0.5);
}

@end
