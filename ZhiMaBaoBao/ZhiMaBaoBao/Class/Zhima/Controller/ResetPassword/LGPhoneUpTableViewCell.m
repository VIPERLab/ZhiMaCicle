//
//  LGPhoneUpTableViewCell.m
//  YiIM_iOS
//
//  Created by liugang on 16/8/19.
//  Copyright © 2016年 ikantech. All rights reserved.
//

#import "LGPhoneUpTableViewCell.h"

@implementation LGPhoneUpTableViewCell {
    UIView *_bottomLineView;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setupView];
    }
    return self;
}

- (void)setupView {
    self.titleLabel = [UILabel new];
    self.titleLabel.textColor = [UIColor blackColor];
    self.titleLabel.font = [UIFont systemFontOfSize:15];
    [self addSubview:self.titleLabel];
    
    self.Texf = [[UITextField alloc] init];
    self.Texf.font = [UIFont systemFontOfSize:14];
    self.Texf.secureTextEntry = YES;
    [self addSubview:_Texf];
    
    _bottomLineView = [UIView new];
    _bottomLineView.backgroundColor = [UIColor colorFormHexRGB:@"e1e1e1"];
    [self addSubview:_bottomLineView];
    
}



- (void)layoutSubviews {
    
    CGFloat titleWidth = [self.titleLabel.text sizeWithFont:[UIFont systemFontOfSize:15] maxSize:CGSizeMake(100, 15)].width;
    self.titleLabel.frame = CGRectMake(20, 0, titleWidth, CGRectGetHeight(self.frame));
    
    _Texf.frame = CGRectMake(CGRectGetMaxX(self.titleLabel.frame) + 10, 0, CGRectGetWidth(self.frame) - CGRectGetMaxX(self.titleLabel.frame) - 10, CGRectGetHeight(self.frame));
    
    _bottomLineView.frame = CGRectMake(20, CGRectGetHeight(self.frame) - 0.5, ScreenWidth - 20, 0.5);
}
@end
