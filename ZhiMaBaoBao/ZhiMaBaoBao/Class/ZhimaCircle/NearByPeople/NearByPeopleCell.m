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
    UILabel *_contentLabel;
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

- (void)setSignature:(NSString *)signature
{
    _contentLabel.text = signature;
    if (signature.length) {
        _contentLabel.hidden = NO;
    }else{
        _contentLabel.hidden = YES;

    }
}

- (void)setupView {
    
    _iconView = [UIImageView new];
    _iconView.layer.cornerRadius = 4;
    _iconView.layer.masksToBounds = YES;
    _iconView.contentMode =  UIViewContentModeScaleAspectFill;
    _iconView.clipsToBounds  = YES;
    [self addSubview:_iconView];
    
    _nameLabel = [UILabel new];
    _nameLabel.font = [UIFont systemFontOfSize:16];
    _nameLabel.textColor = [UIColor blackColor];
    [self addSubview:_nameLabel];
    
    _distanceLabel = [UILabel new];
    _distanceLabel.font = [UIFont systemFontOfSize:13];
    _distanceLabel.textColor = RGB(159, 159, 159);
    [self addSubview:_distanceLabel];
    
    _bottomLineView = [UIView new];
    _bottomLineView.backgroundColor = [UIColor colorFormHexRGB:@"e1e1e1"];
    [self addSubview:_bottomLineView];
    
    _contentLabel = [[UILabel alloc] init];
    _contentLabel.backgroundColor = RGB(242, 242, 242);
    _contentLabel.font = [UIFont systemFontOfSize:13];
    _contentLabel.textColor = RGB(159, 159, 159);
    _contentLabel.textAlignment = 1;
    _contentLabel.numberOfLines = 2;
    _contentLabel.layer.cornerRadius = 5;
    _contentLabel.layer.masksToBounds = YES;
    [self addSubview:_contentLabel];
    
    hasSubViews = YES;
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
    
    if (hasSubViews) {
        CGFloat iconX = 10;
        CGFloat iconW = 46;
        CGFloat iconH = iconW;
        CGFloat iconY = (CGRectGetHeight(self.frame) - iconH) * 0.5;
        _iconView.frame = CGRectMake(iconX, iconY, iconW, iconH);
        
        CGFloat nameX = CGRectGetMaxX(_iconView.frame) + 10;
        CGFloat nameW = CGRectGetWidth(self.frame) - nameX - 10 - 123;
        CGFloat nameH = 17;
        CGFloat nameY = CGRectGetMinY(_iconView.frame) + 2;
        _nameLabel.frame = CGRectMake(nameX, nameY, nameW, nameH);
        
        CGFloat distanceX = nameX;
        CGFloat distanceW = nameW;
        CGFloat distanceH = 15;
        CGFloat distanceY = CGRectGetMaxY(_nameLabel.frame) + 12;
        _distanceLabel.frame = CGRectMake(distanceX, distanceY, distanceW, distanceH);
        
        _contentLabel.frame = CGRectMake(0, 0, 103, 40);
        [_contentLabel sizeToFit];
        _contentLabel.width += 10;
        _contentLabel.height += 8;
        [_contentLabel centerAlignVerticalForSuperView];
        [_contentLabel setFrameOriginXRightOfView:self.contentView offset:0-_contentLabel.width-10];

        _bottomLineView.frame = CGRectMake(iconX, CGRectGetHeight(self.frame) - 0.5, CGRectGetWidth(self.frame) - 10, 0.5);
        
    }
}



@end
