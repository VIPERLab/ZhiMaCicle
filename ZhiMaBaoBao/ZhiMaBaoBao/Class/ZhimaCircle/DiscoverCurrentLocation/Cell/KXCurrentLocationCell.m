//
//  KXCurrentLocationCell.m
//  YiIM_iOS
//
//  Created by mac on 16/9/6.
//  Copyright © 2016年 ikantech. All rights reserved.
//

#import "KXCurrentLocationCell.h"
#import "UIColor+My.h"


@interface KXCurrentLocationCell ()
@property (nonatomic, weak) UILabel *titleLabel;
@property (nonatomic, weak) UILabel *subTitleLabel;
@property (nonatomic, weak) UIImageView *tickView;
@property (nonatomic, weak) UIView *bottomLineView;

@end

@implementation KXCurrentLocationCell

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
    UILabel *titleLabel = [UILabel new];
    self.titleLabel = titleLabel;
    titleLabel.font = [UIFont systemFontOfSize:16];
    [self addSubview:titleLabel];
    
    UILabel *subTitleLabel = [UILabel new];
    subTitleLabel.font = [UIFont systemFontOfSize:12];
    subTitleLabel.textColor = [UIColor colorFormHexRGB:@"757575"];
    self.subTitleLabel = subTitleLabel;
    [self addSubview:subTitleLabel];
    
    
    UIView *bottomLineView = [UIView new];
    self.bottomLineView = bottomLineView;
    bottomLineView.backgroundColor = [UIColor colorFormHexRGB:@"eaeae9"];
    [self addSubview:bottomLineView];
    
    UIImageView *tickView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Discover_CurrentLocation"]];
    self.tickView = tickView;
    [self addSubview:tickView];
}

- (void)setModel:(KXCurrentLocationModel *)model {
    _model = model;
    
    self.titleLabel.text = model.name;
    self.subTitleLabel.text = [NSString stringWithFormat:@"%@%@",model.city,model.address];
    
    if (model.isShowTick) {
        self.tickView.hidden = NO;
    } else {
        self.tickView.hidden = YES;
    }
}

- (void)layoutSubviews {
    
    CGFloat titleX = 20;
    CGFloat titleY = 10;
    CGFloat titleH = CGRectGetHeight(self.frame) * 0.5;
    
    if ([self.model.address isEqualToString:@""] && [self.model.city isEqualToString:@""]) {
        titleY = 0;
        titleH = CGRectGetHeight(self.frame);
    }
    
    CGFloat titleW = CGRectGetWidth(self.frame) - titleX;
    self.titleLabel.frame = CGRectMake(titleX, titleY, titleW, titleH);
    
    CGFloat subTitleX = titleX;
    CGFloat subTitleY = CGRectGetMaxY(self.titleLabel.frame) - 10;
    CGFloat subTitleW = titleW;
    CGFloat subTitleH = titleH;
    
    if ([self.model.address isEqualToString:@""] && [self.model.city isEqualToString:@""]) {
        subTitleH = 0;
        self.subTitleLabel.hidden = YES;
    }
    
    self.subTitleLabel.frame = CGRectMake(subTitleX, subTitleY, subTitleW, subTitleH);
    
    CGFloat bottomLineX = 0;
    CGFloat bottomLineY = CGRectGetHeight(self.frame) - 0.5;
    CGFloat bottomLineW = CGRectGetWidth(self.frame);
    CGFloat bottomLineH = 0.5;
    self.bottomLineView.frame = CGRectMake(bottomLineX, bottomLineY, bottomLineW, bottomLineH);
    
    CGFloat tickW = 20;
    CGFloat tickH = tickW;
    CGFloat tickX = CGRectGetWidth(self.frame) - tickW - 10;
    CGFloat tickY = (CGRectGetHeight(self.frame) - tickH )* 0.5;
    self.tickView.frame = CGRectMake(tickX, tickY, tickW, tickH);
    
}

@end
