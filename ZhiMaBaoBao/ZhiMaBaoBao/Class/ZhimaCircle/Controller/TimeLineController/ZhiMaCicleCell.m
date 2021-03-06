//
//  ZhiMaCicleCell.m
//  ZhiMaBaoBao
//
//  Created by mac on 16/9/21.
//  Copyright © 2016年 liugang. All rights reserved.
//

#import "ZhiMaCicleCell.h"

@implementation ZhiMaCicleCell {
    UILabel *_titleLabel;
    UIImageView *_titleImage;
    UIImageView *_unReadCircleImage;
    UIView *_redView;
    UILabel *_unReadCountLabel;
    UIView *_bottomLineView;
    BOOL hasSubViews;
}


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setupView];
    }
    return self;
}

- (void)setupView {
    _titleLabel = [UILabel new];
    _titleLabel.font = [UIFont systemFontOfSize:16];
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_titleLabel];
    
    _titleImage = [UIImageView new];
    [self addSubview:_titleImage];
    
    _unReadCircleImage = [UIImageView new];
    _unReadCircleImage.hidden = YES;
    [self addSubview:_unReadCircleImage];
    
    _redView = [UIView new];
    _redView.backgroundColor = THEMECOLOR;
    [self addSubview:_redView];
    
    _unReadCountLabel = [UILabel new];
    _unReadCountLabel.hidden = YES;
    _unReadCountLabel.backgroundColor = THEMECOLOR;
    _unReadCountLabel.layer.cornerRadius = 10;
    _unReadCountLabel.textAlignment = NSTextAlignmentCenter;
    _unReadCountLabel.clipsToBounds = YES;
    _unReadCountLabel.textColor = [UIColor whiteColor];
    _unReadCountLabel.font = [UIFont systemFontOfSize:13];
    [self addSubview:_unReadCountLabel];
    
    _bottomLineView = [UIView new];
    _bottomLineView.backgroundColor = [UIColor colorFormHexRGB:@"dedede"];
    [self addSubview:_bottomLineView];
    
    hasSubViews = YES;
    
}

- (void)setTitle:(NSString *)title {
    _titleLabel.text = title;
}

- (void)setImageName:(NSString *)imageName {
    _titleImage.image = [UIImage imageNamed:imageName];
}

- (void)setUnReadImage:(NSString *)unReadImage {
    if ([unReadImage isEqualToString:@""] || unReadImage == nil) {
        _unReadCircleImage.hidden = YES;
        _redView.hidden = YES;
        return;
    }
    _redView.hidden = NO;
    _unReadCircleImage.hidden = NO;
    [_unReadCircleImage sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",DFAPIURL,unReadImage]] placeholderImage:[UIImage imageNamed:@"Image_placeHolder"]];
}


- (void)setUnReadCount:(int)unReadCount {
    if (unReadCount == 0) {
        _unReadCountLabel.hidden = YES;
        return;
    }
    _unReadCountLabel.hidden = NO;
    _unReadCountLabel.text = [NSString stringWithFormat:@"%zd",unReadCount];
}

- (void)layoutSubviews {
    if (hasSubViews) {
        CGFloat imageW = 28;
        CGFloat imageH = imageW;
        CGFloat imageX = 20;
        CGFloat imageY =(CGRectGetHeight(self.frame) - imageW )* 0.5;
        _titleImage.frame = CGRectMake(imageX, imageY, imageW, imageH);
        
        CGFloat titleX = CGRectGetMaxX(_titleImage.frame) + 10;
        CGFloat titleY = 0;
        CGFloat titleW = [_titleLabel.text sizeWithFont:[UIFont systemFontOfSize:16] maxSize:CGSizeMake(MAXFLOAT, 20)].width;
        CGFloat titleH = CGRectGetHeight(self.frame);
        _titleLabel.frame = CGRectMake(titleX, titleY, titleW, titleH);
        
        CGFloat countX = CGRectGetMaxX(_titleLabel.frame) + 10;
        CGFloat countW = 20;
        CGFloat countH = 20;
        CGFloat countY = (CGRectGetHeight(_titleLabel.frame) - countH) * 0.5;
        _unReadCountLabel.frame = CGRectMake(countX, countY, countW, countH);
        
        CGFloat circleW = 35;
        CGFloat circleH = circleW;
        CGFloat circelX = CGRectGetWidth(self.frame) - circleW - 20;
        CGFloat circleY = (CGRectGetHeight(self.frame) - circleH) * 0.5;
        _unReadCircleImage.frame = CGRectMake(circelX, circleY, circleW, circleH);
        
        CGFloat redW = 10;
        CGFloat redH = redW;
        CGFloat redX = CGRectGetMaxX(_unReadCircleImage.frame) - redW * 0.5;
        CGFloat redY = CGRectGetMinY(_unReadCircleImage.frame) - redH * 0.5;
        _redView.layer.cornerRadius = redW * 0.5;
        _redView.clipsToBounds = YES;
        _redView.frame = CGRectMake(redX, redY, redW, redH);
        
        
        _bottomLineView.frame = CGRectMake(20, CGRectGetHeight(self.frame) - 0.5, CGRectGetWidth(self.frame) - 0.5, 0.5);
    }
}

@end
