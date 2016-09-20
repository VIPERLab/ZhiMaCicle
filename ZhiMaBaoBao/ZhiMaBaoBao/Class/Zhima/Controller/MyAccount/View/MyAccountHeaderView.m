//
//  MyAccountHeaderView.m
//  YiIM_iOS
//
//  Created by mac on 16/8/25.
//  Copyright © 2016年 ikantech. All rights reserved.
//

#import "MyAccountHeaderView.h"

@interface MyAccountHeaderView ()

@property (nonatomic, strong) NSMutableArray *buttonViewArray;



@end

@implementation MyAccountHeaderView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupView];
    }
    return self;
}

- (void)setupView {
    
    for (NSInteger index = 0; index < 3; index++) {
        UIButton *buttonView = [[UIButton alloc] init];
        [self addSubview:buttonView];
    
        buttonView.tag = index;
        [buttonView addTarget:self action:@selector(buttonViewDidClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.buttonViewArray addObject:buttonView];
        buttonView.tag = index;
        
    }
    
}

- (void)buttonDidClick:(UIButton *)sender {
    
}

//设置图片
- (void)setButtonWithArray:(NSArray *)imageArray andSubTitleArray:(NSArray *)subTitleArray andSubTitleColor:(UIColor *)titleColor {
    CGFloat viewW = [UIScreen mainScreen].bounds.size.width / 3;
    CGFloat viewH = 120;
    for (NSInteger index = 0; index < self.buttonViewArray.count; index++) {
        
        UIButton *buttonView = self.buttonViewArray[index];
        
        buttonView.frame = CGRectMake(index * viewW, 0, viewW, viewH);
        
        if (index != 1) {
            [self setupButtonView:buttonView WithImageName:imageArray[index] andTitle:subTitleArray[index] andSubTitle:@"" andTitleColor:titleColor];
        } else {
            [self setupButtonView:buttonView WithImageName:imageArray[index] andTitle:subTitleArray[index] andSubTitle:@"0" andTitleColor:titleColor];
        }
        
        
    }
}

- (void)setupButtonView:(UIView *)buttonView WithImageName:(NSString *)imageName andTitle:(NSString *)title andSubTitle:(NSString *)subTitle andTitleColor:(UIColor *)titleColor {
    
    CGFloat buttonW = 35;
    CGFloat buttonH = 30;
    CGFloat buttonX = (CGRectGetWidth(buttonView.frame) - buttonW )* 0.5;
    CGFloat buttonY = 30 + 20;
    
    
    UIImageView *button = [[UIImageView alloc] initWithFrame:CGRectMake(buttonX, buttonY, buttonW, buttonH)];
    button.image = [UIImage imageNamed:imageName];
    [buttonView addSubview:button];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(button.frame) + 10, CGRectGetWidth(buttonView.frame), 20)];
    titleLabel.text = title;
    titleLabel.textColor = titleColor;
    titleLabel.font = [UIFont systemFontOfSize:15];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [buttonView addSubview:titleLabel];
    
    if (![subTitle isEqualToString:@""]) { //零钱
        UILabel *subLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(titleLabel.frame) + 3, CGRectGetWidth(titleLabel.frame), 20)];
        self.moneyLabel = subLabel;
        subLabel.text = [NSString stringWithFormat:@"￥%@",subTitle];
        subLabel.alpha = 0.35;
        subLabel.textAlignment = NSTextAlignmentCenter;
        subLabel.textColor = [UIColor whiteColor];
        subLabel.font = [UIFont systemFontOfSize:13];
        [buttonView addSubview:subLabel];
    }

}


- (void)buttonViewDidClick:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(MyAccountHeaderView:DidClickButton:)]) {
        [self.delegate MyAccountHeaderView:self DidClickButton:sender];
    }
}



#pragma mark - lazyLoad
- (NSMutableArray *)buttonViewArray {
    if (!_buttonViewArray) {
        _buttonViewArray = [NSMutableArray array];
    }
    return _buttonViewArray;
}



@end
