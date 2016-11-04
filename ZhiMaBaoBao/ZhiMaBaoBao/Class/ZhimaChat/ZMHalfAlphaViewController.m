//
//  ZMHalfAlphaViewController.m
//  ZhiMaBaoBao
//
//  Created by ios开发 on 16/11/2.
//  Copyright © 2016年 liugang. All rights reserved.
//

#import "ZMHalfAlphaViewController.h"
#import "GetPurseView.h"
#import "NotGetPurseView.h"
#import "NomorePurseView.h"
#import "ZMPasswordView.h"
#import "ZMQuestionView.h"
#import "WrongAnswerView.h"
#import "ChooseAnswerView.h"


@interface ZMHalfAlphaViewController ()

@end

@implementation ZMHalfAlphaViewController


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.modalPresentationStyle= UIModalPresentationOverCurrentContext;
    self.view.backgroundColor = [UIColor clearColor];
    
//    [self showGetPurseView];
//    [self showNotGetPurseView];
//    [self showNomorePurseView];
//    [self showZMPasswordView];
//    [self showZMQuestionView];
//    [self showWrongAnswerView];
    [self showChooseAnswerView];
}

- (void)showGetPurseView
{
    GetPurseView*view = [[GetPurseView alloc]initWithFrame:CGRectMake(0, 0, DEVICEWITH, DEVICEHIGHT)];
    view.money = @"10000";
    view.vc = self;
    [self.view addSubview:view];
}

- (void)showNotGetPurseView
{
    NotGetPurseView*view = [[NotGetPurseView alloc]initWithFrame:CGRectMake(0, 0, DEVICEWITH, DEVICEHIGHT)];
    view.vc = self;
    [self.view addSubview:view];
}

- (void)showNomorePurseView
{
    NomorePurseView*view = [[NomorePurseView alloc]initWithFrame:CGRectMake(0, 0, DEVICEWITH, DEVICEHIGHT)];
    view.vc = self;
    [self.view addSubview:view];
}

- (void)showZMPasswordView
{
    ZMPasswordView*view = [[ZMPasswordView alloc]initWithFrame:CGRectMake(0, 0, DEVICEWITH, DEVICEHIGHT)];
    view.vc = self;
    view.passwordArr = @[@"麦乐送",@"麦乐鸡盒",@"麦乐鸡腿堡"];
    [self.view addSubview:view];
}

- (void)showZMQuestionView
{
    ZMQuestionView*view = [[ZMQuestionView alloc]initWithFrame:CGRectMake(0, 0, DEVICEWITH, DEVICEHIGHT)];
    view.vc = self;
    view.questionStr = @"麦乐送几分钟内必达";
    [self.view addSubview:view];
}

- (void)showWrongAnswerView
{
    WrongAnswerView*view = [[WrongAnswerView alloc]initWithFrame:CGRectMake(0, 0, DEVICEWITH, DEVICEHIGHT)];
    view.vc = self;
    [self.view addSubview:view];
}

- (void)showChooseAnswerView
{
    ChooseAnswerView*view = [[ChooseAnswerView alloc]initWithFrame:CGRectMake(0, 0, DEVICEWITH, DEVICEHIGHT)];
    view.vc = self;
    view.answerArr = @[@"20分钟",@"30分钟分钟分钟",@"40分钟分钟"];
    [self.view addSubview:view];
}

//-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
//{
//    [self dismissViewControllerAnimated:YES completion:nil];
//}

@end
