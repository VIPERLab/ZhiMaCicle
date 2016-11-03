//
//  ZhiMaCollectionVoiceTypeView.m
//  ZhiMaBaoBao
//
//  Created by mac on 16/11/1.
//  Copyright © 2016年 liugang. All rights reserved.
//

#import "ZhiMaCollectionVoiceTypeView.h"

@implementation ZhiMaCollectionVoiceTypeView {
    UIImageView *_imageView;
    UILabel *_typeLabel;
    UILabel *_voiceLongLabel;
    
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupView];
    }
    return self;
}


- (void)setupView {
    _imageView = [UIImageView new];
    _imageView.image = [UIImage imageNamed:@"CollectionVoice"];
    [self addSubview:_imageView];
    
    _typeLabel = [UILabel new];
    _typeLabel.font = [UIFont systemFontOfSize:16];
    _typeLabel.text = @"语音";
    [self addSubview:_typeLabel];
    
    _voiceLongLabel = [UILabel new];
    _voiceLongLabel.font = [UIFont systemFontOfSize:12];
    _voiceLongLabel.textColor = [UIColor lightGrayColor];
    _voiceLongLabel.text = @"60秒";
//    [self addSubview:_voiceLongLabel];
}

- (void)setTimeLong:(NSString *)timeLong {
    _timeLong = timeLong;
    _voiceLongLabel.text = timeLong;
}


- (void)layoutSubviews {
    CGFloat imageW = 20;
    CGFloat imageH = 29;
    CGFloat imageX = 30;
    CGFloat imageY = (CGRectGetHeight(self.frame) - imageH) * 0.5;
    _imageView.frame = CGRectMake(imageX, imageY, imageW, imageH);
    
    CGFloat tpyeX = CGRectGetMaxX(_imageView.frame) + 30;
    CGFloat typeY = 0;
    CGFloat typeW = 100;
    CGFloat typeH = CGRectGetHeight(self.frame);
    _typeLabel.frame = CGRectMake(tpyeX, typeY, typeW, typeH);
    
    CGFloat timeX = tpyeX;
    CGFloat timeY = CGRectGetMaxY(_typeLabel.frame) + 3;
    CGFloat timeW = 100;
    CGFloat timeH = 15;
    _voiceLongLabel.frame = CGRectMake(timeX, timeY, timeW, timeH);
}

@end
