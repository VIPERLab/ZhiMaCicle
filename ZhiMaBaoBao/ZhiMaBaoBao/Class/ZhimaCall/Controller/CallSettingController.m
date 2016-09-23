//
//  CallSettingController.m
//  ZhiMaBaoBao
//
//  Created by liugang on 16/9/20.
//  Copyright © 2016年 liugang. All rights reserved.
//  拨号设置

#import "CallSettingController.h"

@implementation CallSettingController

- (void)viewDidLoad{
    [super viewDidLoad];
    
    [self setCustomTitle:@"拨号设置"];
    [self addSubviews];
}

- (void)addSubviews{
    //振动
    UIView *item1 = [[UIView alloc] initWithFrame:CGRectMake(0, 90, DEVICEWITH, 80)];
    item1.backgroundColor = [UIColor clearColor];
    [self.view addSubview:item1];
    
    UIView *sub1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, DEVICEWITH, 40)];
    sub1.backgroundColor = [UIColor whiteColor];
    [item1 addSubview:sub1];
    
    UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(16, 0, 200, 40)];
    label1.text = @"按键震动";
    label1.font = MAINFONT;
    label1.textAlignment = NSTextAlignmentLeft;
    [item1 addSubview:label1];
    
    UISwitch *switch1 = [[UISwitch alloc] init];
    switch1.right = DEVICEWITH - 16;
    switch1.top = 5;
    switch1.on = USERINFO.isKeyboardShake;
    switch1.onTintColor = THEMECOLOR;
    [switch1 addTarget:self action:@selector(keyboardShakeSwitch:) forControlEvents:UIControlEventValueChanged];
    [item1 addSubview:switch1];
    
    UILabel *subLabel1 = [[UILabel alloc] initWithFrame:CGRectMake(16, 40, DEVICEWITH - 32, 40)];
    subLabel1.text = @"建议开启按键震动，这样有助于您更好操作键盘。";
    subLabel1.font = [UIFont systemFontOfSize:12];
    subLabel1.textColor = GRAYCOLOR;
    [item1 addSubview:subLabel1];
    
    //声音
    UIView *item2 = [[UIView alloc] initWithFrame:CGRectMake(0, 180, DEVICEWITH, 80)];
    item2.backgroundColor = [UIColor clearColor];
    [self.view addSubview:item2];
    
    UIView *sub2 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, DEVICEWITH, 40)];
    sub2.backgroundColor = [UIColor whiteColor];
    [item2 addSubview:sub2];
    
    UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(16, 0, 200, 40)];
    label2.text = @"按键声音";
    label2.font = MAINFONT;
    label2.textAlignment = NSTextAlignmentLeft;
    [item2 addSubview:label2];
    
    UISwitch *switch2 = [[UISwitch alloc] init];
    switch2.right = DEVICEWITH - 16;
    switch2.top = 5;
    switch2.on = USERINFO.isKeyboardVoice;
    switch2.onTintColor = THEMECOLOR;
    [switch2 addTarget:self action:@selector(keyboardVoiceSwitch:) forControlEvents:UIControlEventValueChanged];
    [item2 addSubview:switch2];
    
    UILabel *subLabel2 = [[UILabel alloc] initWithFrame:CGRectMake(16, 40, DEVICEWITH - 32, 40)];
    subLabel2.text = @"开启按键声音，这样有助于您更好操作键盘。";
    subLabel2.font = [UIFont systemFontOfSize:12];
    subLabel2.textColor = GRAYCOLOR;
    [item2 addSubview:subLabel2];
    
}

- (void)keyboardShakeSwitch:(UISwitch *)sender{
    UserInfo *userInfo = [UserInfo read];
    userInfo.keyboardShake = sender.on;
    [userInfo save];
}

- (void)keyboardVoiceSwitch:(UISwitch *)sender{
    UserInfo *userInfo = [UserInfo read];
    userInfo.keyboardVoice = sender.on;
    [userInfo save];
}
@end
