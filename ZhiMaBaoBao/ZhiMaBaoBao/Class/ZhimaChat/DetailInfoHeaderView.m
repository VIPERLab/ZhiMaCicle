//
//  DetailInfoHeaderView.m
//  ZhiMaBaoBao
//
//  Created by liugang on 16/11/2.
//  Copyright © 2016年 liugang. All rights reserved.
//

#import "DetailInfoHeaderView.h"
#import "SDPhotoBrowser.h"

@interface DetailInfoHeaderView()<SDPhotoBrowserDelegate>{
    UIView *_imgContainer;      //头像容器，用作点击放大收回效果
    UIImageView *_avtar;
    UILabel *_name;
}

@end

@implementation DetailInfoHeaderView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupViews];
    }
    return self;
}

- (void)setupViews{
    _imgContainer = [[UIView alloc] initWithFrame:CGRectMake(14, 35, 65, 65)];
    _imgContainer.backgroundColor = [UIColor clearColor];
    [self addSubview:_imgContainer];
    
    _avtar = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 65, 65)];
    _avtar.userInteractionEnabled = YES;
    _avtar.clipsToBounds = YES;
    _avtar.layer.cornerRadius = 33;
    [_avtar addTapGestureRecognizer:self forAction:@selector(tapAvtar:)];
    [_imgContainer addSubview:_avtar];
    
    _name = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_avtar.frame) + 12, 35, DEVICEWITH - 105, 30)];
    _name.font = [UIFont systemFontOfSize:17];
    [self addSubview:_name];
}

- (void)setNameText:(NSString *)nameText{
    _name.text = nameText;
}

- (void)setAvtarUrl:(NSString *)avtarUrl{
    [_avtar sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",DFAPIURL,self.avtarUrl]] placeholderImage:[UIImage imageNamed:@"defaultContact"]];
}

//单击头像
- (void)tapAvtar:(UITapGestureRecognizer *)tap{
    SDPhotoBrowser *browser = [[SDPhotoBrowser alloc] init];
    browser.sourceImagesContainerView = _imgContainer;
    browser.delegate = self;
    browser.currentImageIndex = 0;
    browser.imageCount = 1;
    [browser show];
}

#pragma mark -- SDPhotoBrowser代理方法
- (UIImage *)photoBrowser:(SDPhotoBrowser *)browser placeholderImageForIndex:(NSInteger)index{
    return _avtar.image;
}

- (NSURL *)photoBrowser:(SDPhotoBrowser *)browser highQualityImageURLForIndex:(NSInteger)index{
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",DFAPIURL,self.avtarUrl]];
}

@end
