//
//  ConverseWithouNetworkCell.m
//  ZhiMaBaoBao
//
//  Created by mac on 16/9/30.
//  Copyright © 2016年 liugang. All rights reserved.
//

#import "ConverseWithouNetworkCell.h"

@implementation ConverseWithouNetworkCell {
    UILabel *_titleLabel;
    UIView *_bottomLineView;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setupView];
    }
    return self;
}

- (void)setupView {
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.text = @"当前网络不可用，请检查你的网络设置";
    _titleLabel.textColor = [UIColor colorFormHexRGB:@"6b5d5d"];
    _titleLabel.backgroundColor = [UIColor colorFormHexRGB:@"ffdfdf"];
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.font = [UIFont systemFontOfSize:15];
    [self addSubview:_titleLabel];
    
    _bottomLineView = [UIView new];
    _bottomLineView.backgroundColor = [UIColor colorFormHexRGB:@"dedede"];
    [self addSubview:_bottomLineView];
}

- (void)layoutSubviews {
    _titleLabel.frame = self.bounds;
    _bottomLineView.frame = CGRectMake(0, CGRectGetHeight(self.frame) - 1, CGRectGetWidth(self.frame), 1);
}


@end
