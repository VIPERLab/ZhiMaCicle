//
//  SDTimeLineTableHeaderView.m
//  GSD_WeiXin(wechat)
//
//  Created by gsd on 16/2/25.
//  Copyright © 2016年 GSD. All rights reserved.
//

#import "SDTimeLineTableHeaderView.h"

#import "UIView+SDAutoLayout.h"
#import "UIButton+WebCache.h"

@implementation SDTimeLineTableHeaderView

{
    UIButton *_iconView;
    UILabel *_nameLabel;
    UILabel *_signLabel;
    UIView *_newMessage;

}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    return self;
}

- (void)setup {
    _backgroundImageView = [UIButton new];
    _backgroundImageView.highlighted = NO;
    _backgroundImageView.imageView.contentMode = UIViewContentModeScaleToFill;
    [_backgroundImageView addTarget:self action:@selector(backGroundImageViewDidClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_backgroundImageView];
    
    _iconView = [UIButton new];
    _iconView.layer.borderColor = [UIColor whiteColor].CGColor;
    _iconView.layer.borderWidth = 1.5;
    [_iconView addTarget:self action:@selector(UserIconDidClick) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_iconView];
    
    _nameLabel = [UILabel new];
    _nameLabel.textColor = [UIColor whiteColor];
    _nameLabel.textAlignment = NSTextAlignmentRight;
    _nameLabel.font = [UIFont boldSystemFontOfSize:15];
    [self addSubview:_nameLabel];
    
    
    _signLabel = [UILabel new];
    _signLabel.textColor = [UIColor colorFormHexRGB:@"6e6c66"];
    _signLabel.textAlignment = NSTextAlignmentRight;
    _signLabel.font = [UIFont systemFontOfSize:14];
    [self addSubview:_signLabel];
    
    _newMessage = [UIView new];
    _newMessage.backgroundColor = [UIColor clearColor];
    [self addSubview:_newMessage];
    
    
    _backgroundImageView
    .sd_layout.spaceToSuperView(UIEdgeInsetsMake(-60, 0, 50, 0));
    
    _iconView.sd_layout
    .widthIs(70)
    .heightIs(70)
    .rightSpaceToView(self, 15)
    .bottomSpaceToView(self, 30);
    
    
    _nameLabel.tag = 1000;
    [_nameLabel setSingleLineAutoResizeWithMaxWidth:200];
    _nameLabel.sd_layout
    .rightSpaceToView(_iconView, 20)
    .bottomSpaceToView(_iconView, -35)
    .heightIs(20);
    
    
    _signLabel.sd_layout
    .topSpaceToView(_iconView,0)
    .leftEqualToView(self)
    .rightSpaceToView(self,15)
    .heightIs(15);
    
}


- (void)setUserName:(NSString *)userName {
    _userName = userName;
    if ([userName isEqualToString:@""] || userName == nil) {
        return;
    }
    _nameLabel.text = userName;
}

- (void)setBJImage:(NSString *)BJImage {
    _BJImage = BJImage;
    [_backgroundImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",DFAPIURL,BJImage]] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@""]];
}

- (void)backGroundImageViewDidClick:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(SDTimeLineTableHeaderViewBackGroundViewDidClick:andBackGround:)]) {
        [self.delegate SDTimeLineTableHeaderViewBackGroundViewDidClick:self andBackGround:sender];
    }
}

- (void)setUserImage:(NSString *)userImage {
    _userImage = userImage;
    [_iconView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",DFAPIURL,userImage]] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"Image_placeHolder"]];
}

- (void)setSignName:(NSString *)signName {
    _signName = signName;
    _signLabel.text = signName;
}






#pragma mark - 头像的点击事件
- (void)UserIconDidClick {
    if ([self.delegate respondsToSelector:@selector(SDTimeLineTableHeaderViewHeaderViewDidClick:)]) {
        [self.delegate SDTimeLineTableHeaderViewHeaderViewDidClick:self];
    }
}

@end
