//
//  NewDiscoverRedBagView.m
//  ZhiMaBaoBao
//
//  Created by mac on 16/10/28.
//  Copyright © 2016年 liugang. All rights reserved.
//

#import "NewDiscoverLinkTypeView.h"

#import "SDLinkTypeView.h"

#define FontSize 15

@interface NewDiscoverLinkTypeView () <UITextViewDelegate>

@property (nonatomic, weak) UILabel *contentViewPlaceHolder;

@property (nonatomic, weak) UIView *linkView;

@end

@implementation NewDiscoverLinkTypeView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupView];
    }
    return self;
}


- (void)setupView {
    UITextView *textView = [[UITextView alloc] init];
    textView.font = [UIFont systemFontOfSize:FontSize];
    textView.delegate = self;
    self.textView = textView;
    [self addSubview:textView];
    
    UILabel *contentViewPlaceHolder = [[UILabel alloc] init];
    self.contentViewPlaceHolder = contentViewPlaceHolder;
    self.contentViewPlaceHolder.textColor = [UIColor lightGrayColor];
    self.contentViewPlaceHolder.font = [UIFont systemFontOfSize:FontSize];
    self.contentViewPlaceHolder.text = @"这一刻你的想法...";
    [self addSubview:contentViewPlaceHolder];
    
    SDLinkTypeView *linkView = [[SDLinkTypeView alloc] init];
    linkView.tapEnable = NO;
    self.linkView = linkView;
    [self addSubview:linkView];
}


#pragma mark - textViewDelegate
- (void)textViewDidBeginEditing:(UITextView *)textView {
    self.contentViewPlaceHolder.hidden = YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    if ([textView.text isEqualToString:@""] || textView.text == nil) {
        self.contentViewPlaceHolder.hidden = NO;
    } else self.contentViewPlaceHolder.hidden = YES;
}



- (void)layoutSubviews {
    self.textView.frame = CGRectMake(5, 5, CGRectGetWidth(self.frame) - 10, 100);

    self.contentViewPlaceHolder.frame = CGRectMake(10, 10, CGRectGetWidth(self.frame) - 20, 20);
    
    self.linkView.frame = CGRectMake(20, CGRectGetMaxY(self.textView.frame) + 10, CGRectGetWidth(self.frame) - 40, 50);
}



@end
