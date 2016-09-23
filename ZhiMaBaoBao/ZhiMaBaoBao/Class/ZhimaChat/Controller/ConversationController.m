//
//  ConversationController.m
//  ZhiMaBaoBao
//
//  Created by liugang on 16/9/18.
//  Copyright © 2016年 liugang. All rights reserved.
//  会话列表

#import "ConversationController.h"
#import "ChatController.h"

@interface ConversationController ()

@end

@implementation ConversationController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setCustomRightItems];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    ChatController *vc = [[ChatController alloc] init];
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}


@end
