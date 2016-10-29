//
//  GroupChatChangeGroupNameController.m
//  ZhiMaBaoBao
//
//  Created by mac on 16/10/9.
//  Copyright © 2016年 liugang. All rights reserved.
//

#import "GroupChatChangeGroupNameController.h"
#import "GroupChatModel.h"

@interface GroupChatChangeGroupNameController ()

@property (nonatomic, weak) UITextField *textField;

@end

@implementation GroupChatChangeGroupNameController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupNav];
    [self setupView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.textField becomeFirstResponder];
}

- (void)setupNav {
    [self setCustomTitle:self.titleName];
    
    UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(saveGroupName)];
    self.navigationItem.rightBarButtonItem = rightBarButton;
}

- (void)setupView {
    
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    UILabel *tipsLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 64 + 20, 100, 14)];
    [self.view addSubview:tipsLabel];
    tipsLabel.textColor = [UIColor colorFormHexRGB:@"888888"];
    tipsLabel.text = self.tipsTitle;
    tipsLabel.font = [UIFont systemFontOfSize:13];
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(tipsLabel.frame) + 5, ScreenWidth, 40)];
    view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:view];
    
    UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(20, 0, ScreenWidth - 40 , 40)];
    self.textField = textField;
    textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    textField.textAlignment = NSTextAlignmentLeft;
    textField.font = [UIFont systemFontOfSize:17];
    
    if (self.type) {
        textField.text = self.groupModel.myGroupName;
    } else {
        textField.text = self.groupModel.groupName;
    }
    
    [view addSubview:textField];
    
}

- (void)saveGroupName {
    if ([self.textField.text isEqualToString:@""]) {
        NSLog(@"不能为空");
        return;
    }
    
    // 更新数据库
    if (self.type) {
        self.groupModel.myGroupName = self.textField.text;
    } else {
        self.groupModel.groupName = self.textField.text;
    }
    
    [LGNetWorking setupGroup:USERINFO.sessionId groupId:self.groupModel.groupId functionName:@"group_name" value:self.groupModel.groupName success:^(ResponseData *responseData) {
        
        if (responseData.code == 0) {
            [FMDBShareManager saveGroupChatInfo:self.groupModel andConverseID:self.groupModel.groupId];
            
            //socket发送"修改群名"消息,通知群用户修改群名称  -> 插入一条系统消息到数据库
            [[SocketManager shareInstance] renameGroup:self.groupModel.groupId name:self.groupModel.groupName];
            
            LGMessage *systemMsg = [[LGMessage alloc] init];
            systemMsg.actType = ActTypeRenamegroup;
            systemMsg.text = [NSString stringWithFormat:@"你修改群名为\"%@\"",self.groupModel.groupName];
            systemMsg.fromUid = USERINFO.userID;
            systemMsg.toUidOrGroupId = self.groupModel.groupId;
            systemMsg.type = MessageTypeSystem;
            systemMsg.msgid = [NSString generateMessageID];
            systemMsg.isGroup = YES;
            systemMsg.timeStamp = [NSDate currentTimeStamp];
            [FMDBShareManager saveGroupChatMessage:systemMsg andConverseId:self.groupModel.groupId];
            
            //发送通知，即时更新相应的页面
            NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
            userInfo[@"message"] = systemMsg;
            [[NSNotificationCenter defaultCenter] postNotificationName:kRecieveNewMessage object:nil userInfo:userInfo];
            
            [self.navigationController popViewControllerAnimated:YES];

        }else{
            [LCProgressHUD showFailureText:responseData.msg];
        }
        
    } failure:^(ErrorData *error) {
        [LCProgressHUD showFailureText:error.msg];

    }];
}

@end
