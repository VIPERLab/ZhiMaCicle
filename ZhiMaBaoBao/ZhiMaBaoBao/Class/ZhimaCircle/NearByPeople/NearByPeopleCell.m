//
//  NearByPeopleCell.m
//  ZhiMaBaoBao
//
//  Created by mac on 16/9/23.
//  Copyright © 2016年 liugang. All rights reserved.
//

#import "NearByPeopleCell.h"


@implementation NearByPeopleCell {
    UIImageView *_iconView;
    UILabel *_nameLabel;
    UILabel *_distanceLabel;
    UIView *_bottomLineView;
    BOOL hasSubViews;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setupView];
    }
    return self;
}

- (void)setIconName:(NSString *)iconName {
    [_iconView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",DFAPIURL,iconName]] placeholderImage:[UIImage imageNamed:@"Image_placeHolder"]];
}

- (void)setName:(NSString *)name {
    _nameLabel.text = name;
}


- (void)setDistance:(NSString *)distance {
    _distanceLabel.text = distance;
}

- (void)setupView {
    
    _iconView = [UIImageView new];
    [self addSubview:_iconView];
    
    _nameLabel = [UILabel new];
    _nameLabel.font = [UIFont systemFontOfSize:17];
    _nameLabel.textColor = [UIColor blackColor];
    [self addSubview:_nameLabel];
    
    _distanceLabel = [UILabel new];
    _distanceLabel.font = [UIFont systemFontOfSize:15];
    _distanceLabel.textColor = [UIColor lightGrayColor];
    [self addSubview:_distanceLabel];
    
    _bottomLineView = [UIView new];
    _bottomLineView.backgroundColor = [UIColor colorFormHexRGB:@"e1e1e1"];
    [self addSubview:_bottomLineView];
    
    hasSubViews = YES;
}

- (void)layoutSubviews {
    if (hasSubViews) {
        CGFloat iconX = 10;
        CGFloat iconW = 45;
        CGFloat iconH = iconW;
        CGFloat iconY = (CGRectGetHeight(self.frame) - iconH) * 0.5;
        _iconView.frame = CGRectMake(iconX, iconY, iconW, iconH);
        
        CGFloat nameX = CGRectGetMaxX(_iconView.frame) + 10;
        CGFloat nameW = CGRectGetWidth(self.frame) - nameX;
        CGFloat nameH = 17;
        CGFloat nameY = CGRectGetMinY(_iconView.frame) + 5;
        _nameLabel.frame = CGRectMake(nameX, nameY, nameW, nameH);
        
        CGFloat distanceX = nameX;
        CGFloat distanceW = nameW;
        CGFloat distanceH = 15;
        CGFloat distanceY = CGRectGetMaxY(_nameLabel.frame) + 5;
        _distanceLabel.frame = CGRectMake(distanceX, distanceY, distanceW, distanceH);
        
        _bottomLineView.frame = CGRectMake(iconX, CGRectGetHeight(self.frame) - 0.5, CGRectGetWidth(self.frame) - 10, 0.5);
        
    }
}



@end
