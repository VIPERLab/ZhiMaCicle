//
//  PersonalSettingCell.m
//  ZhiMaBaoBao
//
//  Created by mac on 16/9/20.
//  Copyright © 2016年 liugang. All rights reserved.
//

#import "PersonalSettingCell.h"

@implementation PersonalSettingCell {
    UIImageView *_iconView;
    UILabel *_titleLabel;
    UILabel *_subTitleLabel;
    UIView *_bottomLineView;
    UIImageView *_QRCodeImage;
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


- (void)setupView {
    hasSubViews = YES;
    _iconView = [UIImageView new];
    _iconView.layer.cornerRadius = 5;
    _iconView.clipsToBounds = YES;
    [self addSubview:_iconView];
    
    _titleLabel = [UILabel new];
    _titleLabel.textColor = [UIColor blackColor];
    _titleLabel.font = [UIFont systemFontOfSize:15];
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_titleLabel];
    
    _subTitleLabel = [UILabel new];
    _subTitleLabel.font = [UIFont systemFontOfSize:13];
    _subTitleLabel.textColor = [UIColor colorFormHexRGB:@"888888"];
    _subTitleLabel.numberOfLines = 2;
    _subTitleLabel.textAlignment = NSTextAlignmentRight;
    [self addSubview:_subTitleLabel];
    
    
    _bottomLineView = [UIView new];
    _bottomLineView.backgroundColor = [UIColor colorFormHexRGB:@"d9d9d9"];
    [self addSubview:_bottomLineView];
    
    
    _QRCodeImage = [UIImageView new];
    _QRCodeImage.image = [UIImage imageNamed:@"QRCode"];
    _QRCodeImage.hidden = YES;
    [self addSubview:_QRCodeImage];
    
}

- (void)setShowImage:(BOOL)showImage {
    _showImage = showImage;
    _titleLabel.hidden = YES;
    _iconView.hidden = NO;
}


- (void)setImageName:(NSString *)imageName {
    _imageName = imageName;
    self.showImage = YES;
    [_iconView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",DFAPIURL,imageName]] placeholderImage:[UIImage imageNamed:@"Image_placeHolder"]];
}


- (void)setTitleName:(NSString *)titleName {
    _titleName = titleName;
    if ([titleName isEqualToString:@""]) {
        _titleLabel.hidden = YES;
    } else _titleLabel.hidden = NO;
    
    _titleLabel.text = titleName;
}

- (void)setSubTitle:(NSString *)subTitle {
    _subTitle = subTitle;
    _subTitleLabel.text = subTitle;
}

- (void)setShowQRCode:(BOOL)showQRCode {
    _showQRCode = showQRCode;
    _QRCodeImage.hidden = NO;
}

- (void)layoutSubviews {
    if (hasSubViews) {
        UIView *fistView;
        if (_showImage) {
            //要展示图片
            CGFloat iconX = 10;
            CGFloat iconW = 70;
            CGFloat iconH = iconW;
            CGFloat iconY = (CGRectGetHeight(self.frame) - iconH) * 0.5;
            _iconView.frame = CGRectMake(iconX, iconY, iconW, iconH);
            fistView = _iconView;
        } else {
            //要展示文字
            CGFloat titleX = 10;
            CGFloat titleY = 0;
            CGFloat titleW = [_titleLabel.text sizeWithFont:[UIFont systemFontOfSize:15] maxSize:CGSizeMake(MAXFLOAT, 15)].width;
            CGFloat titleH = CGRectGetHeight(self.frame);
            _titleLabel.frame = CGRectMake(titleX, titleY, titleW, titleH);
            fistView = _titleLabel;
            
        }
        
        CGFloat subX = CGRectGetMaxX(fistView.frame) + 10;
        CGFloat subY = 0;
        CGFloat subW = CGRectGetWidth(self.frame) - subX - 20;
        CGFloat subH = CGRectGetHeight(self.frame);
        if ([_subTitleLabel.text sizeWithFont:[UIFont systemFontOfSize:13] maxSize:CGSizeMake(MAXFLOAT, 15)].width > subW) {
            _subTitleLabel.textAlignment = NSTextAlignmentLeft;
        }
        _subTitleLabel.frame = CGRectMake(subX, subY, subW, subH);
        
        CGFloat codeW = 20;
        CGFloat codeH = codeW;
        CGFloat codeX = CGRectGetWidth(self.frame) - codeW - 20;
        CGFloat codeY = (CGRectGetHeight(self.frame) - codeH )* 0.5;
        _QRCodeImage.frame = CGRectMake(codeX, codeY, codeW, codeH);
        
        _bottomLineView.frame = CGRectMake(10, CGRectGetHeight(self.frame) - 0.5, CGRectGetMaxX(_subTitleLabel.frame), 0.5);
        
    }
}

@end
