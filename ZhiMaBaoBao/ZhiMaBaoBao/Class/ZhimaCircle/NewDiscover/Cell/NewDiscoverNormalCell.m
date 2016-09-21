//
//  NewDiscoverNormalCell.m
//  YiIM_iOS
//
//  Created by mac on 16/8/22.
//  Copyright © 2016年 ikantech. All rights reserved.
//

#import "NewDiscoverNormalCell.h"

@interface NewDiscoverNormalCell ()

@property (nonatomic, weak) UIButton *iconView;
@property (nonatomic, weak) UILabel *tipsLabel;
@property (nonatomic, weak) UILabel *subTitleLabel;
@property (nonatomic, assign) BOOL isHasSubViews;

@end

@implementation NewDiscoverNormalCell

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
    
    UIButton *iconView = [[UIButton alloc] init];
    iconView.userInteractionEnabled = NO;
    self.iconView = iconView;
    [self addSubview:iconView];
    
    UILabel *tipsLabel = [[UILabel alloc] init];
    self.tipsLabel = tipsLabel;
    self.tipsLabel.textAlignment = NSTextAlignmentLeft;
    self.tipsLabel.font = [UIFont systemFontOfSize:15];
    self.tipsLabel.textColor = [UIColor blackColor];
    [self addSubview:tipsLabel];
    
    
    UILabel *subTitleLabel = [[UILabel alloc] init];
    self.subTitleLabel = subTitleLabel;
    subTitleLabel.textAlignment = NSTextAlignmentRight;
    subTitleLabel.font = [UIFont systemFontOfSize:13];
    subTitleLabel.textColor = [UIColor lightGrayColor];
    [self addSubview:subTitleLabel];
    
    
    self.isHasSubViews = YES;
}



- (void)setTipsName:(NSString *)tipsName {
    _tipsName = tipsName;
    self.tipsLabel.text = tipsName;
}

- (void)setSubTitleName:(NSString *)subTitleName {
    _subTitleName = subTitleName;
    _subTitleLabel.text = subTitleName;
}


- (void)setIconViewWithImageName:(NSString *)imageName Status:(UIControlState)status {
    [self.iconView setImage:[UIImage imageNamed:imageName] forState:status];
}

- (void)setIsSelected:(BOOL)isSelected {
    _isSelected = isSelected;
    self.iconView.selected = isSelected;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (self.isHasSubViews) {
        
        CGFloat imageX = 20;
        CGFloat imageW = 25;
        CGFloat imageH = 25;
        CGFloat imageY = (CGRectGetHeight(self.frame) - imageH) * 0.5;
        self.iconView.frame = CGRectMake(imageX, imageY, imageW, imageH);
        
        CGFloat tipsX = CGRectGetMaxX(self.iconView.frame) + 10;
        CGFloat tipsY = 0;
        CGFloat tipsW = CGRectGetWidth(self.frame) - tipsX - 20;
        CGFloat tipsH = CGRectGetHeight(self.frame);
        self.tipsLabel.frame = CGRectMake(tipsX, tipsY, tipsW, tipsH);
        
        CGFloat subTitleX = CGRectGetWidth(self.frame) - 200;
        CGFloat subTitleY = 0;
        CGFloat subTitleW = 180;
        CGFloat subTitleH = CGRectGetHeight(self.frame);
        self.subTitleLabel.frame = CGRectMake(subTitleX, subTitleY, subTitleW, subTitleH);
        
        
    }
    
}

@end
