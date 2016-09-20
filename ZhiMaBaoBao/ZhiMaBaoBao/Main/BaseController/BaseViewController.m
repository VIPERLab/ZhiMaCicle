//
//  BaseViewController.m
//  ZhiMaBaoBao
//
//  Created by mac on 16/9/19.
//  Copyright © 2016年 liugang. All rights reserved.
//

#import "BaseViewController.h"

@interface BaseViewController ()

@end

@implementation BaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupBackNav];
}

- (void)setupBackNav {

    self.navigationController.navigationBar.tintColor = THEMECOLOR;
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
}


- (void)setCustomTitle:(NSString *)title {
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 120, 40)];
    titleLabel.text = title;
    titleLabel.textColor = THEMECOLOR;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont systemFontOfSize:17];
    self.navigationItem.titleView = titleLabel;
    
}


- (void)backAction {
    [self.navigationController popViewControllerAnimated:YES];
}



// 清除子类未消除的通知
- (void)dealloc {
    NSLog(@"%@销毁了",NSStringFromClass(self.class));
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}



@end
