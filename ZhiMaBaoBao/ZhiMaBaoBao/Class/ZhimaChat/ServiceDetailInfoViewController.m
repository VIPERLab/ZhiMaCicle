//
//  ServiceDetailInfoViewController.m
//  ZhiMaBaoBao
//
//  Created by liugang on 16/11/1.
//  Copyright © 2016年 liugang. All rights reserved.
//

#import "ServiceDetailInfoViewController.h"

@interface ServiceDetailInfoViewController ()

@end

@implementation ServiceDetailInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setCustomTitle:@"麦当劳"];
    [self setupNavRightItem];
}

//已经关注该公众号 设置导航栏右侧按钮
- (void)setupNavRightItem{
    UIButton *rightBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 35, 40)];
    [rightBtn setImage:[UIImage imageNamed:@"nav_more"] forState:UIControlStateNormal];
    [rightBtn addTarget:self action:@selector(setupFriendInfo) forControlEvents:UIControlEventTouchUpInside];
    if (self.isAttention) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
    }
}

@end
