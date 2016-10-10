//
//  RemarkController.m
//  ZhiMaBaoBao
//
//  Created by liugang on 16/10/6.
//  Copyright © 2016年 liugang. All rights reserved.
//

#import "RemarkController.h"
#import "ConverseModel.h"

@interface RemarkController ()
@property (nonatomic, strong) UIButton *rightBtn;
@property (nonatomic, strong) UITextField *textField;
@end

@implementation RemarkController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setCustomTitle:@"设置备注"];
    [self setNavRightItem];
    [self addAllSubviews];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeSureBtnState) name:UITextFieldTextDidChangeNotification object:nil];
}

//设置导航栏右侧按钮
- (void)setNavRightItem{
    UIButton *rightBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    rightBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [rightBtn setTitle:@"保存" forState:UIControlStateNormal];
    [rightBtn setTitleColor:GRAYCOLOR forState:UIControlStateNormal];
    rightBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [rightBtn addTarget:self action:@selector(sureAcion) forControlEvents:UIControlEventTouchUpInside];
    self.rightBtn = rightBtn;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
}

- (void)addAllSubviews{
    UITextField *textfield = [[UITextField alloc] initWithFrame:CGRectMake(20, 80, DEVICEWITH - 40, 40)];
    textfield.text = self.nickName;
    textfield.borderStyle = UITextBorderStyleRoundedRect;
    [self.view addSubview:textfield];
    self.textField = textfield;
}

//有文字输入，更改按钮状态
- (void)changeSureBtnState{
    if (self.textField.hasText) {
        [self.rightBtn setTitleColor:THEMECOLOR forState:UIControlStateNormal];
    }else{
        [self.rightBtn setTitleColor:GRAYCOLOR forState:UIControlStateNormal];
    }
}

//修改备注
- (void)sureAcion{
    if (!self.textField.hasText) {
        return;
    }
    
    [LGNetWorking setupFriendFunction:USERINFO.sessionId function:@"friend_nick" value:self.textField.text openfireAccount:self.userId block:^(ResponseData *responseData) {
        if (responseData.code == 0) {
            //修改成功 -> 更新数据库会话表的会话名
            
            //1.先通过id查会话
            ConverseModel *convesion = [FMDBShareManager searchConverseWithConverseID:self.userId];
            //2.修改会话模型的会话名
            convesion.converseName = self.textField.text;
            //3.更新数据库会话表
            [FMDBShareManager saveConverseListDataWithDataArray:@[convesion]];
            //4.更新好友表
            ZhiMaFriendModel *friendModel = [FMDBShareManager getUserMessageByUserID:self.userId];
            friendModel.user_NickName = self.textField.text;
            [FMDBShareManager upDataUserMessage:friendModel];
            
            
            [self.navigationController popViewControllerAnimated:YES];
        }else{
            [LCProgressHUD showFailureText:responseData.msg];
        }
    }];
}

@end
