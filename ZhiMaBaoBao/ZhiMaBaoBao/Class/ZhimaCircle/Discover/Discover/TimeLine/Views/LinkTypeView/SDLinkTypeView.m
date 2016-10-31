//
//  SDLinkTypeView.m
//  ZhiMaBaoBao
//
//  Created by mac on 16/10/31.
//  Copyright © 2016年 liugang. All rights reserved.
//

#import "SDLinkTypeView.h"

@implementation SDLinkTypeView {
    UILabel *_titleLabel;
    UILabel *_subTitleLabel;
    UIImageView *_typeImageView;
    UIImageView *_detailImageView;
}


- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupView];
    }
    return self;
}

- (void)setupView {
    
    _titleLabel = [UILabel new];
    [self addSubview:_titleLabel];
    
    _subTitleLabel = [UILabel new];
    [self addSubview:_subTitleLabel];
    
    _typeImageView = [UIImageView new];
    [self addSubview:_typeImageView];
    
    _detailImageView = [UIImageView  new];
    [self addSubview:_detailImageView];
    
}


- (void)layoutSubviews {
    
    CGFloat titleImgX = 6;
    CGFloat titleImgY = 6;
    CGFloat titleImgW = 25;
    CGFloat titleImgH = 35;
    _typeImageView.frame = CGRectMake(titleImgX, titleImgY, titleImgW, titleImgH);
    
    
    CGFloat titleNameX = CGRectGetMaxX(_typeImageView.frame);
    CGFloat titleNameY = CGRectGetMinY(_typeImageView.frame);
    CGFloat titleNameW = CGRectGetWidth(self.frame) - titleNameX;
    CGFloat titleNameH = [_titleLabel.text sizeWithFont:[UIFont systemFontOfSize:17] maxSize:CGSizeMake(titleImgW, 20)].height;
    _titleLabel.frame = CGRectMake(titleNameX, titleNameY, titleNameW, titleNameH);
    
    CGFloat subTitleX = titleNameX;
    CGFloat subTitleY = CGRectGetMaxY(_titleLabel.frame) + 5;
    CGFloat subTitleW = titleNameW;
    CGFloat subTitleH = [_subTitleLabel.text sizeGwWithFont:[UIFont systemFontOfSize:14] Size:CGSizeMake(subTitleW, 30)].height;
    _subTitleLabel.frame = CGRectMake(subTitleX, subTitleY, subTitleW, subTitleH);
    
    
    
}

@end
