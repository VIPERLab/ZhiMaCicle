//
//  ChooseWhoCanSeeCell.m
//  YiIM_iOS
//
//  Created by mac on 16/8/24.
//  Copyright © 2016年 ikantech. All rights reserved.
//

#import "ChooseWhoCanSeeCell.h"

@interface ChooseWhoCanSeeCell ()

@property (nonatomic, weak) UIView *bottomLineView;
@property (nonatomic, weak) UIButton *selectedButton;
@end

@implementation ChooseWhoCanSeeCell

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
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.font = [UIFont systemFontOfSize:16];
    self.titleLabel = titleLabel;
    [self addSubview:titleLabel];
    
    UILabel *subTitileLabel = [[UILabel alloc] init];
    subTitileLabel.font = [UIFont systemFontOfSize:14];
    subTitileLabel.textColor = [UIColor lightGrayColor];
    self.subTitleLabel = subTitileLabel;
    [self addSubview:subTitileLabel];
    
    UIButton *button = [[UIButton alloc] init];
    [button setImage:[UIImage imageNamed:@"ChooseWhoCanSee_ButtonIcon_normal"] forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:@"ChooseWhoCanSee_ButtonIcon_selected"] forState:UIControlStateSelected];
    [button addTarget:self action:@selector(selectedButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
    self.selectedButton = button;
    [self addSubview:button];
    
    UIView *bottomLineView = [[UIView alloc] init];
    bottomLineView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.bottomLineView = bottomLineView;
    [self addSubview:bottomLineView];
    
}


- (void)layoutSubviews {
    CGFloat titleX = 15;
    CGFloat titleY = 10;
    CGFloat titleW = 100;
    CGFloat titleH = 20;
    self.titleLabel.frame = CGRectMake(titleX, titleY, titleW, titleH);
    
    
    CGFloat subTitleX = 15;
    CGFloat subTitleY = CGRectGetMaxY(self.titleLabel.frame) + 5;
    CGFloat subTitleW = 100;
    CGFloat subTitleH = 20;
    self.subTitleLabel.frame = CGRectMake(subTitleX, subTitleY, subTitleW, subTitleH);
    
    
    CGFloat buttonX = CGRectGetWidth(self.frame) - 70;
    CGFloat buttonW = 50;
    CGFloat buttonH = 50;
    CGFloat buttonY = (CGRectGetHeight(self.frame) - buttonH) * 0.5;
    self.selectedButton.frame = CGRectMake(buttonX, buttonY, buttonW, buttonH);
    
    CGFloat lineX = 10;
    CGFloat lineY = CGRectGetHeight(self.frame)- 1;
    CGFloat lineW = CGRectGetWidth(self.frame) - lineX * 2;
    CGFloat lineH = 1;
    self.bottomLineView.frame = CGRectMake(lineX, lineY, lineW, lineH);
    
}

- (void)setIsPrivate:(BOOL)isPrivate {
    _isPrivate = isPrivate;
    
    if (_isPrivate) {
        self.selectedButton.selected = YES;
    } else {
        self.selectedButton.selected = NO;
    }
}


- (void)selectedButtonDidClick:(UIButton *)sender {
//    sender.selected = !sender.selected;
    self.model.isSelected = !sender.selected;
    self.block();
}

- (void)setModel:(ChooserWhoCanSeeCellModel *)model {
    _model = model;
    
    self.titleLabel.text = model.title;
    self.subTitleLabel.text = model.subTitle;
    
    if (model.isSelected) {
        self.selectedButton.selected = YES;
    } else  self.selectedButton.selected = NO;
}
@end
