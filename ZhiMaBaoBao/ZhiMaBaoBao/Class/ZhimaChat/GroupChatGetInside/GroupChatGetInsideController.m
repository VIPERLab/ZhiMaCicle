//
//  GroupChatGetInsideController.m
//  ZhiMaBaoBao
//
//  Created by mac on 16/10/11.
//  Copyright © 2016年 liugang. All rights reserved.
//

#import "GroupChatGetInsideController.h"

#import "ChatController.h"
#import "GroupChatModel.h"
#import "ConverseModel.h"


@interface GroupChatGetInsideController ()
@property (nonatomic, weak) GroupChatModel *groupChatModel;
@property (nonatomic, copy) NSString *userName; //扫码人的用户名

@end

@implementation GroupChatGetInsideController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.userName = @"";
    [self setGroupModel];
    [self setCustomTitle:@""];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setGroupModel {
    //根据id 查询群信息  查询userId 用户名
    [LGNetWorking getGroupInfo:USERINFO.sessionId groupId:self.groupId userId:self.qrCodeUserId success:^(ResponseData *responseData) {
        
        if (responseData.code != 0) {
            [LCProgressHUD showFailureText:responseData.msg];
        }
        
        //生成群聊数据模型
        [GroupChatModel mj_setupObjectClassInArray:^NSDictionary *{
            return @{
                     @"groupUserVos":@"GroupUserModel"
                     };
        }];
        GroupChatModel *groupChatModel = [GroupChatModel mj_objectWithKeyValues:responseData.data];
        self.userName = responseData.data[@"swept_name"];
        self.groupChatModel = groupChatModel;
        
        [self setupView];
    } failure:^(ErrorData *error) {
        
    }];

}


- (void)setupView {
    
    UIView *firstView = [[UIView alloc] initWithFrame:CGRectMake(0, 64, ScreenWidth, 180)];
    firstView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:firstView];
    
    CGFloat imageW = 65;
    CGFloat imageH = imageW;
    CGFloat imageX = (ScreenWidth - imageW) * 0.5;
    CGFloat imageY = (CGRectGetHeight(firstView.frame) - imageH) * 0.5 - 20;
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(imageX, imageY, imageW, imageH)];
    [imageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",DFAPIURL,self.groupChatModel.groupAvtar]] placeholderImage:[UIImage imageNamed:@"Image_placeHolder"]];
    [firstView addSubview:imageView];
    
    UILabel *groupNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(imageView.frame) + 10, ScreenWidth, 20)];
    groupNameLabel.textAlignment = NSTextAlignmentCenter;
    groupNameLabel.font = [UIFont systemFontOfSize:17];
    groupNameLabel.text = self.groupChatModel.groupName;
    [firstView addSubview:groupNameLabel];
    
    UILabel *groupCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(groupNameLabel.frame)+10, ScreenWidth, 15)];
    [firstView addSubview:groupCountLabel];
    groupCountLabel.textColor = [UIColor colorFormHexRGB:@"888888"];
    groupCountLabel.textAlignment = NSTextAlignmentCenter;
    groupCountLabel.font = [UIFont systemFontOfSize:12];
    groupCountLabel.text = [NSString stringWithFormat:@"(共%zd人)",self.groupChatModel.groupUserVos.count];
    
    
    UILabel *tipsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(firstView.frame) + 30, ScreenWidth, 50)];
    tipsLabel.text = @"确认加入群聊";
    tipsLabel.font = [UIFont systemFontOfSize:20];
    tipsLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:tipsLabel];
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake((ScreenWidth - 200) * 0.5, CGRectGetMaxY(tipsLabel.frame) + 10, 200, 40)];
    [button setTitle:@"加入该群聊" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(addToGroup) forControlEvents:UIControlEventTouchUpInside];
    button.backgroundColor = THEMECOLOR;
    button.layer.cornerRadius = 5;
    [self.view addSubview:button];
}

- (void)addToGroup {
    [LCProgressHUD showLoadingText:@"准备开始群聊..."];
    [LGNetWorking addUserToGroup:USERINFO.sessionId userIds:USERINFO.userID groupId:self.groupId success:^(ResponseData *responseData) {
        if (responseData.code == 0) {
            [LCProgressHUD hide];
            //生成群聊数据模型
            [LCProgressHUD hide];
            [GroupChatModel mj_setupObjectClassInArray:^NSDictionary *{
                return @{
                         @"groupUserVos":@"GroupUserModel"
                         };
            }];
            GroupChatModel *model  = [GroupChatModel mj_objectWithKeyValues:responseData.data];
            self.groupChatModel = model;
            
            //添加系统消息
            LGMessage *systemMsg = [[LGMessage alloc] init];
            systemMsg.text = [NSString stringWithFormat:@"你通过扫描\"%@\"分享的二维码加入了群聊",self.userName];
            systemMsg.fromUid = USERINFO.userID;
            systemMsg.toUidOrGroupId = self.groupId;
            systemMsg.converseId = self.groupId;
            systemMsg.type = MessageTypeSystem;
            systemMsg.msgid = [NSString generateMessageID];
            systemMsg.conversionType = ConversionTypeSingle;
            systemMsg.timeStamp = [NSDate currentTimeStamp];
            systemMsg.actType = ActTypeUpdategroupnum;
            systemMsg.converseName = self.groupChatModel.groupName;
            [FMDBShareManager saveMessage:systemMsg toConverseID:self.groupId];
            [[NSNotificationCenter defaultCenter] postNotificationName:kRecieveNewMessage object:nil userInfo:@{@"message":systemMsg}];
            
            //保存群会话信息，插入数据库
            [FMDBShareManager saveGroupChatInfo:self.groupChatModel andConverseID:self.groupId];
            
            //创建会话
            ConverseModel *converseModel  = [[ConverseModel alloc] init];
            converseModel.time = [NSDate cTimestampFromString:self.groupChatModel.create_time format:@"yyyy-MM-dd HH:mm:ss"];
            converseModel.converseType = 1;
            converseModel.converseId = self.groupChatModel.groupId;
            converseModel.converseName = self.groupChatModel.groupName;
            converseModel.converseHead_photo = self.groupChatModel.groupAvtar;
            converseModel.lastConverse = [NSString stringWithFormat:@"你通过扫描\"%@\"分享的二维码加入了群聊",self.userName];
            [FMDBShareManager saveConverseListDataWithModel:converseModel withComplationBlock:nil];
            
            //通过socket扫码进群
            GroupActModel *actModel = [[GroupActModel alloc] init];
            actModel.uids = self.qrCodeUserId;
            actModel.usernames = self.userName;
            actModel.groupId = self.groupChatModel.groupId;
            actModel.groupLogo = self.groupChatModel.groupAvtar;
            actModel.groupName = self.groupChatModel.groupName;
            [[SocketManager shareInstance] scanCodeToGroup:actModel];
            
            
            //跳转到群聊天页面
            [self jumpGroupChat];
        } else if (responseData.code == 78) {
            //跳转到会话列表
            [LCProgressHUD hide];
            
            
            GroupChatModel *model = [FMDBShareManager getGroupChatMessageByGroupId:self.groupId];
            
            // 创建/ 更新会话
            [FMDBShareManager saveGroupChatInfo:model andConverseID:self.groupId];
            
            UserInfo *userInfo = [UserInfo shareInstance];
            [self.navigationController popToRootViewControllerAnimated:NO];
            userInfo.mainVC.selectedViewController = userInfo.mainVC.viewControllers[0];
            
            ChatController *vc = [[ChatController alloc] init];
            vc.conversionId = model.groupId;
            vc.conversionName = model.groupName;
            vc.converseLogo = model.groupAvtar;
            vc.converseType = YES;
            vc.hidesBottomBarWhenPushed = YES;
            ConversationController *conversationVC = userInfo.conversationVC;
            [conversationVC.navigationController pushViewController:vc animated:YES];
            
            
        }
    } failure:^(ErrorData *error) {
        [LCProgressHUD showFailureText:error.msg];
    }];
}


- (void)jumpGroupChat {
    
    ConverseModel *groupModel = [FMDBShareManager searchConverseWithConverseID:self.groupId andConverseType:YES];
    
    UserInfo *userInfo = [UserInfo shareInstance];
    [self.navigationController popToRootViewControllerAnimated:NO];
    userInfo.mainVC.selectedViewController = userInfo.mainVC.viewControllers[0];
    
    ChatController *vc = [[ChatController alloc] init];
    vc.conversionId = groupModel.converseId;
    vc.conversionName = groupModel.converseName;
    vc.converseLogo = groupModel.converseHead_photo;
    vc.converseType = groupModel.converseType;
    vc.hidesBottomBarWhenPushed = YES;
    
    ConversationController *conversationVC = userInfo.conversationVC;
    [conversationVC.navigationController pushViewController:vc animated:YES];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
