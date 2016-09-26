//
//  ConverseCell.m
//  ZhiMaBaoBao
//
//  Created by mac on 16/9/26.
//  Copyright © 2016年 liugang. All rights reserved.
//

#import "ConverseCell.h"

@implementation ConverseCell {
    UIImageView *_iconView;
    UILabel *_converseLabel;
    UILabel *_lastConverseLabel;
    UILabel *_timeLabel;
    UILabel *_unReadCountLabel;
    UIView *_bottomLineView;
    BOOL hasSubViews;
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
    
    _iconView = [UIImageView new];
    _iconView.layer.cornerRadius = 10;
    [self addSubview:_iconView];
    
    _converseLabel = [UILabel new];
    [self addSubview:_converseLabel];
    
    _lastConverseLabel = [UILabel new];
    _lastConverseLabel.textColor = [UIColor colorFormHexRGB:@"9b9b9b"];
    _lastConverseLabel.font = [UIFont systemFontOfSize:15];
    [self addSubview:_lastConverseLabel];
    
    _timeLabel = [UILabel new];
    _timeLabel.font = [UIFont systemFontOfSize:13];
    _timeLabel.textColor = [UIColor colorFormHexRGB:@"b8b8b8"];
    [self addSubview:_timeLabel];
    
    _unReadCountLabel = [UILabel new];
    _unReadCountLabel.backgroundColor = THEMECOLOR;
    _unReadCountLabel.layer.cornerRadius = 10;
    _unReadCountLabel.textAlignment = NSTextAlignmentCenter;
    _unReadCountLabel.font = [UIFont systemFontOfSize:13];
    _unReadCountLabel.textColor = [UIColor whiteColor];
    _unReadCountLabel.clipsToBounds = YES;
    [self addSubview:_unReadCountLabel];
    
    _bottomLineView = [UIView new];
    _bottomLineView.backgroundColor = [UIColor colorFormHexRGB:@"d9d9d9"];
    [self addSubview:_bottomLineView];
    
    hasSubViews = YES;
}


- (void)setModel:(ConverseModel *)model {
    _model = model;
    _iconView.image = [UIImage imageNamed:model.converseHead_photo];
    
    _converseLabel.text = model.converseName;
    
    _lastConverseLabel.text = model.lastConverse;
    
    _unReadCountLabel.text = model.unReadCount;
    
    _timeLabel.text = model.time;
}

- (void)layoutSubviews {
    if (hasSubViews) {
        
        CGFloat iconX = 10;
        CGFloat iconW = 55;
        CGFloat iconH = iconW;
        CGFloat iconY = (CGRectGetHeight(self.frame) - iconH) * 0.5;
        _iconView.frame = CGRectMake(iconX, iconY, iconW, iconH);
        
        
        CGFloat timeY = CGRectGetMinY(_iconView.frame);
        CGFloat timeW = [_timeLabel.text sizeWithFont:[UIFont systemFontOfSize:13] maxSize:CGSizeMake(MAXFLOAT, 15)].width;
        CGFloat timeX = CGRectGetWidth(self.frame) - timeW - 20;
        CGFloat timeH = 13;
        _timeLabel.frame = CGRectMake(timeX, timeY, timeW, timeH);
        
        CGFloat nameX = CGRectGetMaxX(_iconView.frame) + 10;
        CGFloat nameY = CGRectGetMinY(_iconView.frame);
        CGFloat nameW = CGRectGetWidth(self.frame) - nameX - timeW - 20;
        CGFloat nameH = 30;
        _converseLabel.frame = CGRectMake(nameX, nameY, nameW, nameH);
        
        CGFloat lastX = nameX;
        CGFloat lastY = CGRectGetMaxY(_converseLabel.frame);
        CGFloat lastW = CGRectGetWidth(self.frame) - lastX - 20;
        CGFloat lastH = 20;
        _lastConverseLabel.frame = CGRectMake(lastX, lastY, lastW, lastH);
        
        
        CGFloat countCenterX = CGRectGetMaxX(_iconView.frame) - 10;
        CGFloat countCenterY = CGRectGetMinY(_iconView.frame) - 5;
        _unReadCountLabel.center = CGPointMake(countCenterX, countCenterY);
        if ([_unReadCountLabel.text isEqualToString:@"0"]) {
            _unReadCountLabel.hidden = YES;
        } else {
            _unReadCountLabel.hidden = NO;
            _unReadCountLabel.width = 20;
            _unReadCountLabel.height = _unReadCountLabel.width;
        }
        _bottomLineView.frame = CGRectMake(0, CGRectGetHeight(self.frame) - 0.5, CGRectGetWidth(self.frame), 0.5);
        
    }
}

@end
