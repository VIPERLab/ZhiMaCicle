//
//  KXActionSheet.m
//  ZhiMaBaoBao
//
//  Created by mac on 16/9/29.
//  Copyright © 2016年 liugang. All rights reserved.
//

#import "KXActionSheet.h"

#define ButtonHeight 50

@implementation KXActionSheet {
    UIButton *_bjView;
    UIView *_buttonView;
}

- (instancetype)initWithTitle:(NSString *)titleName cancellTitle:(NSString *)cancelTitle andOtherButtonTitles:(NSArray *)titles {
    if (self = [super initWithFrame:[UIScreen mainScreen].bounds]) {
        [self setupView];
        [self setupButtonWithTitleName:titleName andCancellTitle:cancelTitle andOtherButton:titles];
        [[UIApplication sharedApplication].keyWindow addSubview:self];
    }
    return self;
}

- (void)setupView {
    _bjView = [UIButton new];
    _bjView.backgroundColor = [UIColor blackColor];
    _bjView.alpha = 0.0;
    [self addSubview:_bjView];
    [_bjView addTarget:self action:@selector(bjViewDidClick) forControlEvents:UIControlEventTouchUpInside];
}


- (void)setupButtonWithTitleName:(NSString *)titleName andCancellTitle:(NSString *)cancellTitle andOtherButton:(NSArray *)titles {
    NSInteger buttonCount = titles.count + 1;
    UIView *buttonView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight([UIScreen mainScreen].bounds), ScreenWidth, ButtonHeight * buttonCount + 5)];
    [self addSubview:buttonView];
    _buttonView = buttonView;
    _buttonView.backgroundColor = [UIColor lightGrayColor];
    //标题
    UIView *lastView;
    if (![titleName isEqualToString:@""]) {
        UILabel *titleLable = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(buttonView.frame), ButtonHeight)];
        titleLable.text = titleName;
        lastView = titleLable;
        [buttonView addSubview:titleLable];
    }
    
    
    for (NSInteger index = 0; index < titles.count; index++ ) {
        NSString *buttonTitle = titles[index];
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(lastView.frame), ScreenWidth, ButtonHeight)];
        [buttonView addSubview:button];
        
        [button setTitle:buttonTitle forState:UIControlStateNormal];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        button.backgroundColor = [UIColor whiteColor];
        button.tag = index;
        [button addTarget:self action:@selector(titleButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
        
        if (index != titles.count - 1) {
            UIView *bottomLineView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(button.frame) - 1, CGRectGetWidth(buttonView.frame), 1)];
            bottomLineView.backgroundColor = [UIColor colorFormHexRGB:@"dedede"];
            [buttonView addSubview:bottomLineView];
        }
        
        lastView = button;
    }
    
    if (![cancellTitle isEqualToString:@""]) {
        UIButton *cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(lastView.frame) + 5 , ScreenWidth, ButtonHeight)];
        [cancelButton setTitle:cancellTitle forState:UIControlStateNormal];
        cancelButton.backgroundColor = [UIColor whiteColor];
        [cancelButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        cancelButton.tag = titles.count;
        [cancelButton addTarget:self action:@selector(titleButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
        [buttonView addSubview:cancelButton];
    }
    
}

- (void)show {
    [UIView animateWithDuration:0.3 animations:^{
        _bjView.alpha = 0.3;
        CGFloat height = _buttonView.height;
        _buttonView.frame = CGRectMake(0, _buttonView.y - height, ScreenWidth, height);
    } completion:^(BOOL finished) {
        
    }];
}


- (void)titleButtonDidClick:(UIButton *)sender {
    [self bjViewDidClick];
    if ([self.delegate respondsToSelector:@selector(KXActionSheet:andIndex:)]) {
        [self.delegate KXActionSheet:self andIndex:sender.tag];
    }
}


- (void)bjViewDidClick {
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 0.0f;
        _buttonView.frame = CGRectMake(0, CGRectGetHeight([UIScreen mainScreen].bounds), ScreenWidth, _buttonView.height);
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}


- (void)layoutSubviews {
    _bjView.frame = self.bounds;
}

@end
