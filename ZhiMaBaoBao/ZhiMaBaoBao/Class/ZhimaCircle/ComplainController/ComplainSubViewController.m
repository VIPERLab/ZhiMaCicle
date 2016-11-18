//
//  ComplainSubViewController.m
//  YiIM_iOS
//
//  Created by mac on 16/9/9.
//  Copyright © 2016年 ikantech. All rights reserved.
//

#import "ComplainSubViewController.h"
#import "UIColor+My.h"

#import "SDTimeLineTableViewController.h"
#import "ChatController.h"

@interface ComplainSubViewController ()

@end

@implementation ComplainSubViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setCustomTitle:@"投诉"];
    
    [self setupView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)setupView {
    self.view.backgroundColor = [UIColor whiteColor];
    
    CGFloat imageW = 100;
    CGFloat imageH = imageW;
    CGFloat imageY = 30 + 64;
    CGFloat imageX = ([UIScreen mainScreen].bounds.size.width - imageW) * 0.5;
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(imageX, imageY, imageW, imageH)];
    imageView.image = [UIImage imageNamed:@"ComplainSuccess_TickIcon"];
    [self.view addSubview:imageView];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(imageView.frame) + 30, [UIScreen mainScreen].bounds.size.width, 30)];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.text = @"投诉已提交";
    titleLabel.font = [UIFont systemFontOfSize:18];
    [self.view addSubview:titleLabel];
    
    UILabel * subTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(titleLabel.frame), [UIScreen mainScreen].bounds.size.width, 40)];
    subTitle.textAlignment = NSTextAlignmentCenter;
    subTitle.text = @"芝麻客服会尽快对的投诉内容进行核实，感谢你的支持。";
    subTitle.textColor = [UIColor lightGrayColor];
    subTitle.font = [UIFont systemFontOfSize:12];
    subTitle.numberOfLines = 0;
    [self.view addSubview:subTitle];
    
    
    UIButton *closeButton = [[UIButton alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(subTitle.frame) + 20, [UIScreen mainScreen].bounds.size.width - 20, 40)];
    closeButton.layer.cornerRadius = 10;
    [closeButton setTitle:@"关闭" forState:UIControlStateNormal];
    [closeButton addTarget:self action:@selector(closeButtonDidClick) forControlEvents:UIControlEventTouchUpInside];
    closeButton.backgroundColor = [UIColor colorFormHexRGB:@"09bb07"];
    [self.view addSubview:closeButton];
    
    
    
}

- (void)closeButtonDidClick {
    if (self.type == 1) { //投诉朋友圈
        for (UIViewController *controller in self.navigationController.viewControllers) {
            if ([controller isKindOfClass:[SDTimeLineTableViewController class]]) {
                [self.navigationController popToViewController:controller animated:YES];
            }
        }
    } else if (self.type == 2 || self.type == 3) {  // 单聊
        for (UIViewController *controller in self.navigationController.viewControllers) {
            if ([controller isKindOfClass:[ChatController class]]) {
                [self.navigationController popToViewController:controller animated:YES];
            }
        }
    }
    
}

- (void)backAction {
    for (UIViewController *viewController in self.navigationController.viewControllers) {
        if ([viewController isKindOfClass:[SDTimeLineTableViewController class]]) {
            [self.navigationController popToViewController:viewController animated:YES];
        }
    }
}


@end
