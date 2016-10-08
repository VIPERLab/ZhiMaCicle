//
//  GroupChatInfoFooterView.m
//  ZhiMaBaoBao
//
//  Created by mac on 16/10/5.
//  Copyright © 2016年 liugang. All rights reserved.
//

#import "GroupChatInfoFooterView.h"

@implementation GroupChatInfoFooterView {
    UIButton *_quitButton;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupView];
    }
    return self;
}

- (void)setupView {
    _quitButton = [UIButton new];
    [_quitButton setTitle:@"删除并退出" forState:UIControlStateNormal];
    [_quitButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _quitButton.layer.cornerRadius = 5;
    _quitButton.backgroundColor = THEMECOLOR;
    [_quitButton addTarget:self action:@selector(quitButtonDidClick) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_quitButton];
}

- (void)quitButtonDidClick {
    if ([self.delegate respondsToSelector:@selector(GroupChatInfoFooterViewDidClick)]) {
        [self.delegate GroupChatInfoFooterViewDidClick];
    }
}

- (void)layoutSubviews {
    CGFloat buttonX = 20;
    CGFloat buttonY =20;
    CGFloat buttonW = CGRectGetWidth(self.frame) - buttonX * 2;
    CGFloat buttonH = 45;
    _quitButton.frame = CGRectMake(buttonX, buttonY, buttonW, buttonH);
}


@end
