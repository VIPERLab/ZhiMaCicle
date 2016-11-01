//
//  GroupChatListController.m
//  ZhiMaBaoBao
//
//  Created by liugang on 16/10/5.
//  Copyright © 2016年 liugang. All rights reserved.
//

#import "GroupChatListController.h"
#import "GroupChatModel.h"
#import "AvtarAndNameCell.h"
#import "CreateGroupChatController.h"
#import "BaseNavigationController.h"
#import "ChatController.h"
#import "TransPopView.h"

@interface GroupChatListController ()<UITableViewDelegate,UITableViewDataSource,TransPopViewDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataArr;
@end

static NSString *const reuseIdentifier = @"groupChatListCell";
@implementation GroupChatListController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setCustomTitle:@"我的群聊"];
    [self getGroupDataFormSQL];
    [self setNavRightItem];
    
    
    UserInfo *userinfo = [UserInfo shareInstance];
    userinfo.groupChatVC = self;
}

//没有数据时的view
- (void)addNodataView{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(30, 300, DEVICEWITH - 60, 50)];
    label.text = @"你可以通过右上角创建群聊，将其保存到这里";
    label.numberOfLines = 0;
    label.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:label];
}

//设置导航栏右侧发起群聊按钮
- (void)setNavRightItem{
    UIButton *rightBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [rightBtn setImage:[UIImage imageNamed:@"nav_add"] forState:UIControlStateNormal];
    [rightBtn addTarget:self action:@selector(createGroupChat) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
}

- (void)addAllSubviews{
    UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    tableView.delegate = self;
    tableView.dataSource = self;
    [tableView registerNib:[UINib nibWithNibName:@"AvtarAndNameCell" bundle:nil] forCellReuseIdentifier:reuseIdentifier];
    [self.view addSubview:tableView];
    tableView.separatorStyle = UITableViewCellSelectionStyleNone;
    self.tableView = tableView;

}

- (void)getGroupDataFormSQL {
    self.dataArr = [[FMDBShareManager getAllGroupChatDataInArray] mutableCopy];
    if (_dataArr.count) {
        if (!self.tableView) {
            [self addAllSubviews];
        }
        [self.tableView reloadData];
        return;
    } else {
        [self.tableView removeFromSuperview];
    }
    [self addNodataView];
}

//获取群聊列表
- (void)requestGroupList{
    [LGNetWorking getGroupList:USERINFO.sessionId block:^(ResponseData *responseData) {
        if (responseData.code == 0) {
            
            self.dataArr = [GroupChatModel mj_objectArrayWithKeyValuesArray:responseData.data];
        }else{
//            [LCProgressHUD showFailureText:responseData.msg];
        }
    } failure:^(ErrorData *error) {
        [LCProgressHUD showFailureText:error.msg];
    }];
}

//发起群聊
- (void)createGroupChat{
    CreateGroupChatController *vc = [[CreateGroupChatController alloc] init];
    vc.hideFirstSection = YES;
    vc.fartherVC = self;
    BaseNavigationController *nav = [[BaseNavigationController alloc] initWithRootViewController:vc];
    [self presentViewController:nav animated:YES completion:nil];
}

#pragma mark - tableView delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    AvtarAndNameCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    ConverseModel *groupModel = self.dataArr[indexPath.row];
    cell.groupModel = groupModel;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 55;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    ConverseModel *groupModel = self.dataArr[indexPath.row];

    if (self.isBigImageTrans) {
        TransPopView *popView = [[TransPopView alloc] initWithMessage:self.transMsg toUserId:groupModel.converseId isGroup:YES];
        popView.delegate = self;
        [popView show];
    }else{
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        ConverseModel *groupModel = self.dataArr[indexPath.row];
        
        UserInfo *userInfo = [UserInfo shareInstance];
        [self.navigationController popToRootViewControllerAnimated:NO];
        userInfo.mainVC.selectedViewController = userInfo.mainVC.viewControllers[0];
        
        ChatController *vc = [[ChatController alloc] init];
        vc.conversionId = groupModel.converseId;
        vc.conversionName = groupModel.converseName;
        vc.converseType = groupModel.converseType;
        vc.hidesBottomBarWhenPushed = YES;
        ConversationController *conversationVC = userInfo.conversationVC;
        [conversationVC.navigationController pushViewController:vc animated:YES];
    }
    
}


#pragma mark - 转发消息
//转发消息
- (void)transformMessage:(LGMessage *)message toUserId:(NSString *)userId{
    //生成一个新的消息模型
    LGMessage *newMsg = [self generateNewMessage:message to:userId];
    [[SocketManager shareInstance] sendMessage:newMsg];
    
    UserInfo *info = [UserInfo shareInstance];
    if (info.topWindow) {
        [info.topWindow resignKeyWindow];
//        info.topWindow = nil;
        [info.keyWindow makeKeyAndVisible];
        [LCProgressHUD showSuccessText:@"发送成功"];
        
    }else{
        [self dismissViewControllerAnimated:YES completion:nil];
        [LCProgressHUD showSuccessText:@"发送成功"];
    }
}

//生成一个新的消息模型 -> 用来转发
- (LGMessage *)generateNewMessage:(LGMessage *)message to:(NSString *)userId{
    LGMessage *newMsg = [[LGMessage alloc] init];
    newMsg.type = message.type;
    newMsg.fromUid = USERINFO.userID;
    //如果转发自己的消息，那么touid为旧消息的touid 如果转发的别人的消息，那么to
    newMsg.toUidOrGroupId = userId;
    newMsg.timeStamp = [NSDate currentTimeStamp];
    newMsg.conversionType = ConversionTypeGroupChat;       //群聊列表，转发的消息是群消息
    newMsg.text = message.text;
    newMsg.msgid = [NSString generateMessageID];
    newMsg.picUrl = message.picUrl;
    return newMsg;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source.
        ConverseModel *model = self.dataArr[indexPath.row];
        //数据库删除该条会话
        [FMDBShareManager deleteConverseWithConverseId:model.converseId];
        
        [self getGroupDataFormSQL];
        
    }
}



#pragma mark - lazy
- (NSMutableArray *)dataArr{
    if (!_dataArr) {
        _dataArr = [NSMutableArray array];
    }
    return _dataArr;
}

@end
