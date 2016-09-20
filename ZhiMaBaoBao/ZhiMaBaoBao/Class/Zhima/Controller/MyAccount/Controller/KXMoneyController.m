//
//  KXMoneyController.m
//  YiIM_iOS
//
//  Created by mac on 16/9/17.
//  Copyright © 2016年 ikantech. All rights reserved.
//

#import "KXMoneyController.h"

@interface KXMoneyController ()

@property (nonatomic, weak) UIView *firstView;
@property (nonatomic, weak) UIView *secondView;

@end

@implementation KXMoneyController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setCustomTitle:@"零钱明细"];
    [self setupView];
}

- (void)setupView {
    
    UIView *firstView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 85)];
    firstView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:firstView];
    self.firstView = firstView;
    
    
    UIView *secondView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(firstView.frame), [UIScreen mainScreen].bounds.size.width, 140)];
    secondView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:secondView];
    self.secondView = secondView;
    [self setFirstView];
    [self setSecondView];
    
}


- (void)setFirstView {
    CGFloat titleX = 20;
    CGFloat titleW = 100;
    CGFloat titleH = 30;
    CGFloat titleY = (CGRectGetHeight(self.firstView.frame) - titleH )* 0.5;
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(titleX, titleY, titleW, titleH)];
    titleLabel.font = [UIFont systemFontOfSize:17];
    titleLabel.textColor = [UIColor lightGrayColor];
    titleLabel.text = @"入账金额";
    [self.firstView addSubview:titleLabel];
    
    CGFloat moneyX = 0;
    CGFloat moneyY = 0;
    CGFloat moneyW = CGRectGetWidth(self.firstView.frame) - 20;
    CGFloat moneyH = CGRectGetHeight(self.firstView.frame);
    UILabel *moneyLabel = [[UILabel alloc] initWithFrame:CGRectMake(moneyX, moneyY, moneyW, moneyH)];
    moneyLabel.font = [UIFont boldSystemFontOfSize:20];
    moneyLabel.textColor = [UIColor greenColor];
    moneyLabel.textAlignment = NSTextAlignmentRight;
    moneyLabel.text = self.model.money;
    [self.firstView addSubview:moneyLabel];
    
    UIView *bottomLineView =[[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.firstView.frame) - 0.5, CGRectGetWidth(self.firstView.frame), 0.5)];
    bottomLineView.backgroundColor = [UIColor lightGrayColor];
    [self.firstView addSubview:bottomLineView];
    
}


- (void)setSecondView {
    
    UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(20, 10, 100, 30)];
    label1.text = @"类    型";
    label1.textColor = [UIColor lightGrayColor];
    label1.font = [UIFont systemFontOfSize:15];
    [self.secondView addSubview:label1];
    
    UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(label1.frame), 100, 30)];
    label2.text = @"时    间";
    label2.textColor = [UIColor lightGrayColor];
    label2.font = [UIFont systemFontOfSize:15];
    [self.secondView addSubview:label2];
    
    UILabel *label3 = [[UILabel alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(label2.frame), 100, 30)];
    label3.text = @"交易单号";
    label3.textColor = [UIColor lightGrayColor];
    label3.font = [UIFont systemFontOfSize:15];
    [self.secondView addSubview:label3];
    
    UILabel *label4 = [[UILabel alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(label3.frame), 100, 30)];
    label4.text = @"剩余零钱";
    label4.textColor = [UIColor lightGrayColor];
    label4.font = [UIFont systemFontOfSize:15];
    [self.secondView addSubview:label4];
    
    
    UIView *bottomLineView =[[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.secondView.frame) - 0.5, CGRectGetWidth(self.firstView.frame), 0.5)];
    bottomLineView.backgroundColor = [UIColor lightGrayColor];
    [self.secondView addSubview:bottomLineView];
    
    
    UILabel *typeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, CGRectGetWidth(self.secondView.frame) - 20, 30)];
    typeLabel.textAlignment = NSTextAlignmentRight;
    typeLabel.font = [UIFont systemFontOfSize:15];
    typeLabel.text = @"收入";
    [self.secondView addSubview:typeLabel];
    
    UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMinY(label2.frame), CGRectGetWidth(self.secondView.frame) - 20, 30)];
    timeLabel.textAlignment = NSTextAlignmentRight;
    timeLabel.font = [UIFont systemFontOfSize:15];
    [self.secondView addSubview:timeLabel];
    
    
    UILabel *orderLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMinY(label3.frame), CGRectGetWidth(timeLabel.frame), 30)];
    orderLabel.textAlignment = NSTextAlignmentRight;
    orderLabel.font = [UIFont systemFontOfSize:12];
    [self.secondView addSubview:orderLabel];
    
    UILabel *moneyLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMinY(label4.frame), CGRectGetWidth(orderLabel.frame), 30)];
    moneyLabel.textAlignment = NSTextAlignmentRight;
    moneyLabel.font = [UIFont systemFontOfSize:15];
    [self.secondView addSubview:moneyLabel];
    
    
    
    
}
@end
