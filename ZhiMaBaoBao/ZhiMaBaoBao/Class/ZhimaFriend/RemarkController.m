//
//  RemarkController.m
//  ZhiMaBaoBao
//
//  Created by liugang on 16/10/6.
//  Copyright © 2016年 liugang. All rights reserved.
//

#import "RemarkController.h"
#import "ConverseModel.h"

@interface RemarkController () <UITextFieldDelegate>
@property (nonatomic, strong) UIButton *rightBtn;
@property (nonatomic, strong) UITextField *textField;
@end

@implementation RemarkController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setCustomTitle:@"设置备注"];
    [self setNavRightItem];
    [self addAllSubviews];
}

- (void)viewWillAppear:(BOOL)animated {
    [self.textField becomeFirstResponder];
}

//设置导航栏右侧按钮
- (void)setNavRightItem{
    UIButton *rightBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    rightBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [rightBtn setTitle:@"保存" forState:UIControlStateNormal];
    [rightBtn setTitleColor:THEMECOLOR forState:UIControlStateNormal];
    rightBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [rightBtn addTarget:self action:@selector(sureAcion) forControlEvents:UIControlEventTouchUpInside];
    self.rightBtn = rightBtn;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
}

- (void)addAllSubviews{
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake( 0 , 64 + 20, ScreenWidth, 40)];
    view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:view];
    
    
    UITextField *textField = [[UITextField alloc] init];
    textField.frame = CGRectMake( 10 , 0, ScreenWidth - 20 , 40);
    textField.text = self.nickName;
    textField.delegate = self;
    textField.backgroundColor = [UIColor whiteColor];
    textField.clearButtonMode = UITextFieldViewModeAlways;
    [view addSubview:textField];
    self.textField = textField;
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    [self.rightBtn setTitleColor:THEMECOLOR forState:UIControlStateNormal];
    return YES;
}

//有文字输入，更改按钮状态
- (void)changeSureBtnState{
//    if (self.textField.hasText) {
//        [self.rightBtn setTitleColor:THEMECOLOR forState:UIControlStateNormal];
//    }else{
//        [self.rightBtn setTitleColor:GRAYCOLOR forState:UIControlStateNormal];
//    }
    
//    [self.rightBtn setTitleColor:THEMECOLOR forState:UIControlStateNormal];

}

//修改备注
- (void)sureAcion{
    
    NSString *nickName = self.textField.text;
    if (!self.textField.hasText) {
        nickName = @"";
    }

    [LGNetWorking setupFriendFunction:USERINFO.sessionId function:@"friend_nick" value:nickName openfireAccount:self.userId block:^(ResponseData *responseData) {
        if (responseData.code == 0) {
            //修改成功 -> 更新数据库会话表的会话名
            
            //1.更新好友表
            ZhiMaFriendModel *friendModel = [FMDBShareManager getUserMessageByUserID:self.userId];
            friendModel.user_NickName = self.textField.text;
            [FMDBShareManager upDataUserMessage:friendModel];
            
            //2.先通过id查会话
            ConverseModel *convesion = [FMDBShareManager searchConverseWithConverseID:self.userId andConverseType:NO];
            //3.修改会话模型的会话名
            convesion.converseName = self.textField.text;
            if (!self.textField.hasText) {
                convesion.converseName = friendModel.user_Name;
            }
            
            //4.更新数据库会话表 （会话名）
//            [FMDBShareManager saveConverseListDataWithDataArray:@[convesion]];
            FMDatabaseQueue *queue = [FMDBShareManager getQueueWithType:ZhiMa_Chat_Converse_Table];
            NSString *option1 = [NSString stringWithFormat:@"converseName = '%@'",convesion.converseName];
            NSString *option2 = [NSString stringWithFormat:@"converseId = '%@'",self.userId];
            NSString *optionStr = [FMDBShareManager alterTable:ZhiMa_Chat_Converse_Table withOpton1:option1 andOption2:option2];
            [queue inDatabase:^(FMDatabase *db) {
                [db executeQuery:optionStr];
            }];
            
            [self.navigationController popViewControllerAnimated:YES];
        }else{
            [LCProgressHUD showFailureText:responseData.msg];
        }
    }];
}

@end
