//
//  BaseViewController.m
//  ZhiMaBaoBao
//
//  Created by mac on 16/9/19.
//  Copyright © 2016年 liugang. All rights reserved.
//

#import "BaseViewController.h"
#import "LGSearchController.h"
#import "AddFriendViewController.h"

@interface BaseViewController ()

@end

@implementation BaseViewController {
    BOOL isEneryForeground;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = BGCOLOR;
    self.navigationController.navigationBar.tintColor = THEMECOLOR;
    
    // 进去前台通知
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enteryForground) name:KEnteryForeground_Notification object:nil];
}


//自定义标题
- (void)setCustomTitle:(NSString *)title {
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 120, 40)];
    titleLabel.text = title;
    titleLabel.textColor = THEMECOLOR;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont systemFontOfSize:17];
    self.navigationItem.titleView = titleLabel;
    
    //自定义返回按钮
    UIButton *backBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    backBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [backBtn setImage:[UIImage imageNamed:@"nav_back"] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    self.navigationItem.leftBarButtonItem = backItem;
}

//添加右侧items
- (void)setCustomRightItems{
    UIView *rightView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 85, 40)];
    UIButton *searchBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [searchBtn setImage:[UIImage imageNamed:@"nav_search"] forState:UIControlStateNormal];
    [searchBtn addTarget:self action:@selector(searchFriendAction) forControlEvents:UIControlEventTouchUpInside];
    UIButton *addBtn = [[UIButton alloc] initWithFrame:CGRectMake(45, 0, 40, 40)];
    [addBtn setImage:[UIImage imageNamed:@"nav_add"] forState:UIControlStateNormal];
    [addBtn addTarget:self action:@selector(addFriendAction) forControlEvents:UIControlEventTouchUpInside];
    [rightView addSubview:searchBtn];
    [rightView addSubview:addBtn];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightView];
}

//返回方法
- (void)backAction {
    [self.navigationController popViewControllerAnimated:YES];
}

//搜索匹配好友
- (void)searchFriendAction{
    LGSearchController *searchVC = [[LGSearchController alloc] init];
    searchVC.fatherVC = self;
    [self presentViewController:searchVC animated:NO completion:nil];
}

//添加新好友
- (void)addFriendAction{
    AddFriendViewController *vc = [[AddFriendViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}


// 进入前台通知
- (void)enteryForground {
//    ForegroundManager *manager = [ForegroundManager shareManager];
//    if (manager.is_Entry_Foreground) {
//        NSLog(@"进入前台通知 !!!!");
//        manager.entry_Foreground = NO;
//    }
}

// 清除子类未消除的通知
- (void)dealloc {
    NSLog(@"%@销毁了",NSStringFromClass(self.class));
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}
@end
