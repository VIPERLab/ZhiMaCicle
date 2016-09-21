//
//  CicleCell.m
//  DemoDiscover
//
//  Created by kit on 16/8/20.
//  Copyright © 2016年 kit. All rights reserved.
//

#import "CicleCell.h"

@implementation CicleCell {
    UIImageView *_icon;
    UILabel *_titleLabel;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self  setupView];
    }
    return self;
}

- (void)setupView {
    UIImageView *icon = [[UIImageView alloc] init];
    _icon = icon;
    [self addSubview:icon];
    
    UILabel *title = [[UILabel alloc] init];
    title.font = [UIFont systemFontOfSize:17];
    _titleLabel = title;
    [self addSubview:title];
}

- (void)layoutSubviews {
    CGFloat iconWidth = 45;
    CGFloat iconHeight = iconWidth;
    CGFloat iconY = (CGRectGetHeight(self.frame) - iconHeight )* 0.5;
    _icon.frame = CGRectMake(30, iconY, iconWidth, iconHeight);
    
    
    _titleLabel.frame = CGRectMake(CGRectGetMaxX(_icon.frame) + 10, 0, 100, CGRectGetHeight(self.frame));
}

- (void)setTitleName:(NSString *)titleName {
    _titleName = titleName;
    _titleLabel.text = titleName;
}


@end
