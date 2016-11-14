//
//  ViciterLoginView.m
//  ZhiMaBaoBao
//
//  Created by mac on 16/11/14.
//  Copyright © 2016年 liugang. All rights reserved.
//

#import "ViciterLoginView.h"

@implementation ViciterLoginView {
    UIImageView *_imageView;
    UILabel *_tipsLabel;
    UILabel *_tipsLabel1;
    UIButton *_loginButton;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupView];
    }
    return self;
}


- (void)setupView {
    
    _imageView = [[UIImageView alloc] init];
    _imageView.image = [UIImage imageNamed:@"Viciter_Login"];
    [self addSubview:_imageView];
    
    _tipsLabel = [[UILabel alloc] init];
    _tipsLabel.textAlignment = NSTextAlignmentCenter;
    _tipsLabel.textColor = [UIColor colorFormHexRGB:@"888888"];
    _tipsLabel.text = @"您还没有登录";
    [self addSubview:_tipsLabel];
    
    
    _tipsLabel1 = [[UILabel alloc] init];
    _tipsLabel1.textAlignment = NSTextAlignmentCenter;
    _tipsLabel1.textColor = [UIColor colorFormHexRGB:@"888888"];
    _tipsLabel1.text = @"登陆后才能使用此功能哦~";
    [self addSubview:_tipsLabel1];
    
    
    _loginButton = [[UIButton alloc] init];
    [_loginButton setTitle:@"去登录>>" forState:UIControlStateNormal];
    [_loginButton setTitleColor:[UIColor colorFormHexRGB:@"ff6866"] forState:UIControlStateNormal];
    [_loginButton addTarget:self action:@selector(loginButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
    [_loginButton setTitleColor:THEMECOLOR forState:UIControlStateNormal];
    _loginButton.titleLabel.font = [UIFont systemFontOfSize:19];
    [self addSubview:_loginButton];
}


- (void)loginButtonDidClick:(UIButton *)sender {
    if (self.block) {
        self.block();
    }
}

- (void)setLoginBlock:(loginBlock)block {
    _block = block;
}


- (void)layoutSubviews {
    CGFloat imageW = 80;
    CGFloat imageH = imageW;
    _imageView.frame = CGRectMake((CGRectGetWidth(self.frame) - imageW) * 0.5, 170, imageW, imageH);
    
    _tipsLabel.frame = CGRectMake(0, CGRectGetMaxY(_imageView.frame) + 30, CGRectGetWidth(self.frame), 20);
    
    _tipsLabel1.frame = CGRectMake(0, CGRectGetMaxY(_tipsLabel.frame), CGRectGetWidth(self.frame), 20);
    
    _loginButton.frame = CGRectMake(30, CGRectGetMaxY(_tipsLabel1.frame) + 30, CGRectGetWidth(self.frame) - 60, 50);
}


@end
