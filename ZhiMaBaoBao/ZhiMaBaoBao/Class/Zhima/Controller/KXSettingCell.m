//
//  KXSettingCell.m
//  ZhiMaBaoBao
//
//  Created by mac on 16/9/19.
//  Copyright © 2016年 liugang. All rights reserved.
//

#import "KXSettingCell.h"

@implementation KXSettingCell {
    UILabel *_titleLabel;
    UISwitch *_zhimaSwitch;
    UIView *_bottomLineView;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setupView];
    }
    return self;
}

- (void)setupView {
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    _titleLabel = [UILabel new];
    _titleLabel.font = [UIFont systemFontOfSize:15];
    _titleLabel.textColor = [UIColor blackColor];
    [self addSubview:_titleLabel];
    
    _zhimaSwitch = [UISwitch new];
    _zhimaSwitch.onTintColor = THEMECOLOR;
    [self addSubview:_zhimaSwitch];
    
    _bottomLineView = [UIView new];
    _bottomLineView.backgroundColor = [UIColor colorFormHexRGB:@"e1e1e1"];
    [self addSubview:_bottomLineView];
    
}

- (void)setTitle:(NSString *)title {
    _title = title;
    _titleLabel.text = title;
}

- (void)layoutSubviews {
    
    CGFloat titleW = [_titleLabel.text sizeWithFont:[UIFont systemFontOfSize:15] maxSize:CGSizeMake(300, 15)].width;
    _titleLabel.frame = CGRectMake(20, 0, titleW, CGRectGetHeight(self.frame));
    
    CGFloat switchW = 51;
    CGFloat switchH = 31;
    CGFloat switchX = CGRectGetWidth(self.frame) - switchW - 10;
    CGFloat switchY =(CGRectGetHeight(self.frame) - switchH) * 0.5;
    _zhimaSwitch.frame = CGRectMake(switchX, switchY, switchW, switchH);
    
    
    _bottomLineView.frame = CGRectMake(20, CGRectGetHeight(self.frame) - 0.5, ScreenWidth - 20, 0.5);
    
}

@end
