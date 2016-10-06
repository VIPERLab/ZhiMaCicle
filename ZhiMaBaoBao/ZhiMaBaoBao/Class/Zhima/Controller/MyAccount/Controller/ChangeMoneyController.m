//
//  ChangeMoneyController.m
//  YiIM_iOS
//
//  Created by mac on 16/8/27.
//  Copyright © 2016年 ikantech. All rights reserved.
//

#import "ChangeMoneyController.h"

#import "ChangeMoenySubController.h"
#import "KXMoneyDetailController.h"

//临时用
#import "KXMoneyDetailModel.h"

@interface ChangeMoneyController ()

@end

@implementation ChangeMoneyController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setCustomTitle:@"零钱"];
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    [self setupNav];
    [self setupView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupNav {
    UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc] initWithTitle:@"明细" style:UIBarButtonItemStylePlain target:self action:@selector(rightBarButtonAction)];
    self.navigationItem.rightBarButtonItem = rightBarButton;
}

- (void)setupView {
    UIImageView *iconView = [[UIImageView alloc] init];
    iconView.image = [UIImage imageNamed:@"loginAndRes"];
    
    CGFloat iconW = 100;
    CGFloat iconH = 100;
    CGFloat iconX = ([UIScreen mainScreen].bounds.size.width - iconW )* 0.5;
    CGFloat iconY = 30 + 64;
    iconView.frame = CGRectMake(iconX, iconY, iconW, iconH);
    [self.view addSubview:iconView];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(iconView.frame) + 10, [UIScreen mainScreen].bounds.size.width, 20)];
    titleLabel.text = @"我的零钱";
    titleLabel.font = [UIFont systemFontOfSize:14];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:titleLabel];
    
    
    UILabel *moneyLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(titleLabel.frame) +  5, [UIScreen mainScreen].bounds.size.width, 30)];
    moneyLabel.textAlignment = NSTextAlignmentCenter;
    moneyLabel.text = [NSString stringWithFormat:@"￥%@",self.model.amount];
    moneyLabel.font = [UIFont systemFontOfSize:16];
    [self.view addSubview:moneyLabel];
    
    CGFloat buttonX = 20;
    CGFloat buttonW = [UIScreen mainScreen].bounds.size.width - buttonX * 2;
    CGFloat buttonH = 40;
    CGFloat buttonY = CGRectGetMaxY(moneyLabel.frame) + 10;
    UIButton *chargeButton = [[UIButton alloc] initWithFrame:CGRectMake(buttonX, buttonY, buttonW, buttonH)];
    [chargeButton setTitle:@"提现" forState:UIControlStateNormal];
    [chargeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    chargeButton.backgroundColor = THEMECOLOR;
    chargeButton.layer.cornerRadius = 5;
    [chargeButton addTarget:self action:@selector(chargeButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:chargeButton];
    
}


- (void)chargeButtonDidClick:(UIButton *)sender {
    ChangeMoenySubController *vc = [[ChangeMoenySubController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
    
}

- (void)rightBarButtonAction {
    //零钱明细
    KXMoneyDetailController *detail = [[KXMoneyDetailController alloc] init];
    detail.model = self.model;
    [self.navigationController pushViewController:detail animated:YES];
    
}

@end
