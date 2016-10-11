//
//  TelephoneBillCell.m
//  YiIM_iOS
//
//  Created by mac on 16/8/26.
//  Copyright © 2016年 ikantech. All rights reserved.
//

#import "TelephoneBillCell.h"

@interface TelephoneBillCell ()

@property (nonatomic, weak) UILabel *titleLabel;
@property (nonatomic, weak) UIView *bottomLineView;

@end

@implementation TelephoneBillCell

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
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.font = [UIFont systemFontOfSize:15];
    titleLabel.textAlignment = NSTextAlignmentLeft;
    self.titleLabel = titleLabel;
    [self addSubview:titleLabel];
    
    UITextField *inputView = [[UITextField alloc] init];
    inputView.textColor = [UIColor lightGrayColor];
    inputView.font = [UIFont systemFontOfSize:14];
    self.inputView = inputView;
    [self addSubview:inputView];
    inputView.textAlignment = NSTextAlignmentRight;
    inputView.userInteractionEnabled = NO;
    
    UIView *bottomLineView = [[UIView alloc] init];
    bottomLineView.backgroundColor = [UIColor colorFormHexRGB:@"dedede"];
    self.bottomLineView = bottomLineView;
    [self addSubview:bottomLineView];
    
    
    
    
    
}

- (void)setTitle:(NSString *)title {
    _title = title;
    self.titleLabel.text = title;
}


- (void)setInputViewTextAlignment:(NSTextAlignment)inputViewTextAlignment {
    _inputViewTextAlignment = inputViewTextAlignment;
    self.inputView.textAlignment = inputViewTextAlignment;
    
}

- (void)setInputPlaceHolder:(NSString *)inputPlaceHolder {
    _inputPlaceHolder = inputPlaceHolder;
    
    self.inputView.placeholder = inputPlaceHolder;
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.inputView resignFirstResponder];
}


- (void)layoutSubviews {
    
    CGFloat titleX = 10;
    CGFloat titleY = 0;
    CGFloat titleW = [self.titleLabel.text sizeWithFont:[UIFont systemFontOfSize:15] maxSize:CGSizeMake(ScreenWidth * 0.5, 15)].width;
    CGFloat titleH = CGRectGetHeight(self.frame);
    self.titleLabel.frame = CGRectMake(titleX, titleY, titleW, titleH);
    
    CGFloat inputX = CGRectGetMaxX(self.titleLabel.frame) + 30;
    CGFloat inputY = 0;
    CGFloat inputW = CGRectGetWidth(self.frame) - inputX - 15;
    CGFloat inputH = CGRectGetHeight(self.frame);
    self.inputView.frame = CGRectMake(inputX, inputY, inputW, inputH);
    
    CGFloat bottomX = 10;
    CGFloat bottomY = CGRectGetHeight(self.frame) - 0.5;
    CGFloat bottomW = CGRectGetWidth(self.frame) - 20;
    CGFloat bottomH = 0.5;
    self.bottomLineView.frame = CGRectMake(bottomX, bottomY, bottomW, bottomH);
}
@end
