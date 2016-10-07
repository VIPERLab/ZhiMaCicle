//
//  ZhiMaCollectionHeaderView.m
//  ZhiMaBaoBao
//
//  Created by mac on 16/10/7.
//  Copyright © 2016年 liugang. All rights reserved.
//

#import "ZhiMaCollectionHeaderView.h"

@implementation ZhiMaCollectionHeaderView {
    UIView *_searchView;
    UIButton *_tipsButton;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupView];
    }
    return self;
}


- (void)setupView {
    _searchView = [[UIView alloc] init];
    _searchView.layer.borderColor = [UIColor colorFormHexRGB:@"dedede"].CGColor;
    _searchView.backgroundColor = [UIColor whiteColor];
    _searchView.layer.borderWidth = 0.5;
    _searchView.layer.cornerRadius = 10;
    [self addSubview:_searchView];
    
    _tipsButton = [[UIButton alloc] init];
    [_tipsButton setImage:[UIImage imageNamed:@"nav_search"] forState:UIControlStateNormal];
    [_tipsButton setTitle:@"搜索" forState:UIControlStateNormal];
    [_tipsButton setTitleColor:[UIColor colorFormHexRGB:@"888888"] forState:UIControlStateNormal];
    [_searchView addSubview:_tipsButton];
    
    
}

- (void)layoutSubviews {
    CGFloat searchX = 20;
    CGFloat searchW = CGRectGetWidth(self.frame) - searchX * 2;
    CGFloat searchH = 33;
    CGFloat searchY = (CGRectGetHeight(self.frame) - searchH) * 0.5;
    _searchView.frame = CGRectMake(searchX, searchY, searchW, searchH);
    
    CGFloat tipsW = 100;
    CGFloat tipsH = 20;
    CGFloat tipsX = (CGRectGetWidth(_searchView.frame) - tipsW) * 0.5;
    CGFloat tipsY = (CGRectGetHeight(_searchView.frame) - tipsH) * 0.5;
    _tipsButton.frame = CGRectMake(tipsX, tipsY, tipsW, tipsH);
}


@end
