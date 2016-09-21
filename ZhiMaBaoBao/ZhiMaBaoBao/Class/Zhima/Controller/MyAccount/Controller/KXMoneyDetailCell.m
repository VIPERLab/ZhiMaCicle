//
//  KXMoneyDetailCell.m
//  YiIM_iOS
//
//  Created by mac on 16/9/17.
//  Copyright © 2016年 ikantech. All rights reserved.
//

#import "KXMoneyDetailCell.h"

@implementation KXMoneyDetailCell {
    UILabel *_titleLabel;
    UILabel *_timeLabel;
    UILabel *_phoneLabel;
    UILabel *_moneyLabel;
    UIView *_bottomLineView;
}


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setupView];
    }
    return self;
}

- (void)setupView {
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.font = [UIFont boldSystemFontOfSize:20];
    _titleLabel.textColor = [UIColor blackColor];
    _titleLabel.textAlignment = NSTextAlignmentLeft;
    [self addSubview:_titleLabel];
    
    _timeLabel = [[UILabel alloc] init];
    _timeLabel.font = [UIFont systemFontOfSize:12];
    _timeLabel.textColor = [UIColor lightGrayColor];
    [self addSubview:_timeLabel];
    
    _phoneLabel = [UILabel new];
    _phoneLabel.font = [UIFont systemFontOfSize:12];
    _phoneLabel.textColor = [UIColor lightGrayColor];
    [self addSubview:_phoneLabel];
    
    _moneyLabel = [UILabel new];
    _moneyLabel.font = [UIFont boldSystemFontOfSize:20];
    _moneyLabel.textColor = THEMECOLOR;
    _moneyLabel.textAlignment = NSTextAlignmentRight;
    [self addSubview:_moneyLabel];
    
    _bottomLineView = [UIView new];
    _bottomLineView.backgroundColor = [UIColor lightGrayColor];
    [self addSubview:_bottomLineView];
    
}


- (void)setModel:(KXMoneyDetailModel *)model {
    _model = model;
    
    _titleLabel.text = model.uphone;
    
    _timeLabel.text = model.createtime;
    
    if ([model.type intValue] == 0) {
        _moneyLabel.text = [NSString stringWithFormat:@"+ %@",model.money];
    } else {
        _moneyLabel.text = [NSString stringWithFormat:@"- %@",model.money];
    }
}


- (void)layoutSubviews {
    CGFloat marge = 5;
    CGFloat nameX = 2 * marge;
    CGFloat nameY = 15;
    CGFloat nameW = 300;
    CGFloat nameH = 20;
    _titleLabel.frame = CGRectMake(nameX, nameY, nameW, nameH);
    
    CGFloat timeX = nameX;
    CGFloat timeY = CGRectGetMaxY(_titleLabel.frame)+3;
    CGFloat timeW = 300;
    CGFloat timeH = 15;
    _timeLabel.frame = CGRectMake(timeX, timeY, timeW, timeH);
    
    CGFloat phoneX = nameX;
    CGFloat phoneY = CGRectGetMaxY(_timeLabel.frame);
    CGFloat phoneW = 300;
    CGFloat phoneH = 15;
    _phoneLabel.frame = CGRectMake(phoneX, phoneY, phoneW, phoneH);
    
    CGFloat moneyX = 0;
    CGFloat moneyY = 0;
    CGFloat moneyW = CGRectGetWidth(self.frame) - 20;
    CGFloat moneyH = CGRectGetHeight(self.frame);
    _moneyLabel.frame = CGRectMake(moneyX, moneyY, moneyW, moneyH);
    
    CGFloat bottomX = 0;
    CGFloat bottomY = CGRectGetHeight(self.frame) - 0.5;
    CGFloat bottomW = CGRectGetWidth(self.frame);
    CGFloat bottomH = 0.5;
    _bottomLineView.frame = CGRectMake(bottomX, bottomY, bottomW, bottomH);
}

@end
