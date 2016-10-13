//
//  ZMCallBoardViewController.m
//  ZhiMaBaoBao
//
//  Created by ios开发 on 16/10/13.
//  Copyright © 2016年 liugang. All rights reserved.
//

#import "ZMCallBoardViewController.h"
#import "YiKeyBoardView.h"


@interface ZMCallBoardViewController ()<YiKeyBoardViewDelegate>

@property (nonatomic, strong) YiKeyBoardView *keyboardView; //拨号键盘
@property (nonatomic, strong) UILabel        *showNumLabel; //已波数字展示label
@property (nonatomic, strong) UIButton       *deleteBtn;    //数字删除按钮

@end

#define KeyboardHeight 247  //拨号键盘高度

@implementation ZMCallBoardViewController

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initOthers];
    [self initKeyBoard];
    [self initShowView];
}

#pragma mark - init

- (void)initOthers
{
    self.view.backgroundColor = WHITECOLOR;
    UIButton*closeBtn = [[UIButton alloc]initWithFrame:CGRectMake(10, 25, 50, 50)];
    [closeBtn setImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
    [closeBtn addTarget:self action:@selector(dissBackAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:closeBtn];
}

- (void)initKeyBoard
{
    //拨号键盘
    YiKeyBoardView *keyboardView = [YiKeyBoardView keyBoardView];
    keyboardView.frame = CGRectMake(0, DEVICEHIGHT - KeyboardHeight*SCLACEW - (27+58+30), DEVICEWITH, KeyboardHeight*SCLACEW);
    keyboardView.delegate = self;
    [self.view addSubview:keyboardView];
    self.keyboardView = keyboardView;
    
    UIButton*callBtn = [[UIButton alloc]initWithFrame:CGRectMake(DEVICEWITH/2 - 29, keyboardView.frameMaxY+27, 58, 58)];
    [callBtn setImage:[UIImage imageNamed:@"phoneGreen"] forState:UIControlStateNormal];
    [callBtn addTarget:self action:@selector(callAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:callBtn];
}

- (void)initShowView
{
    self.showNumLabel = [[UILabel alloc]initWithFrame:CGRectMake(50, 75, DEVICEWITH-100, 60)];
    self.showNumLabel.backgroundColor = GRAYCOLOR;
    self.showNumLabel.textAlignment = 1;
    self.showNumLabel.font = [UIFont systemFontOfSize:17];
    self.showNumLabel.textColor = BLACKCOLOR;
    self.showNumLabel.text = @"请拨号或搜索姓名";
    [self.view addSubview:self.showNumLabel];
    
    self.deleteBtn = [[UIButton alloc]initWithFrame:CGRectMake(DEVICEWITH-50, 90, 40, 30)];
//    self.deleteBtn.backgroundColor = GRAYCOLOR;
    [self.deleteBtn setImage:[UIImage imageNamed:@"deleteNum"] forState:UIControlStateNormal];
    [self.view addSubview:self.deleteBtn];
}

#pragma mark - action

- (void)dissBackAction
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)callAction
{
}

@end
