//
//  NewDiscoverHeaderCell.m
//  YiIM_iOS
//
//  Created by mac on 16/8/22.
//  Copyright © 2016年 ikantech. All rights reserved.
//

#import "NewDiscoverHeaderView.h"
#import "NewDiscoverPhotoPickerView.h"
#import "SDAutoLayout.h"

#define FontSize 15

@interface NewDiscoverHeaderView () <UITextViewDelegate>

@property (nonatomic, weak) UILabel *contentViewPlaceHolder;

@property (nonatomic, weak) NewDiscoverPhotoPickerView *photoContentView;


@end

@implementation NewDiscoverHeaderView

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}


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
    
    NewDiscoverPhotoPickerView *photoContentView = [[NewDiscoverPhotoPickerView alloc] init];
    self.photoContentView = photoContentView;
    [self addSubview:photoContentView];
    
    
    _textView.sd_layout
    .leftSpaceToView(self,5)
    .rightSpaceToView(self,5)
    .topSpaceToView(self,5)
    .heightIs(130);
    
    
    _contentViewPlaceHolder.sd_layout
    .leftSpaceToView(self,10)
    .rightSpaceToView(self,10)
    .topSpaceToView(self,10)
    .heightIs(20);
    
    _photoContentView.sd_layout
    .topSpaceToView(_textView,10)
    .leftEqualToView(_textView)
    .rightEqualToView(_textView)
    .bottomEqualToView(self);
    
}

#pragma mark - setupView
- (void)setContentWithImageArray:(NSArray *)imageArray {
    
    [self.photoContentView setButtonWithImageArray:imageArray];
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

@end
