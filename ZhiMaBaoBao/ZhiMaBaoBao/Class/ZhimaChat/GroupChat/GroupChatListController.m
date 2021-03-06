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

//测试用 - 后续删除
#import "GroupUserModel.h"

@interface GroupChatListController ()<UITableViewDelegate,UITableViewDataSource,TransPopViewDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataArr;
@property (nonatomic, strong) ConverseModel *selectedConverse;      //点击选中的会话模型
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

//测试数据库耗时时间
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    NSMutableArray *models = [NSMutableArray array];
    for (int i = 0; i < 1000; i++) {
        GroupUserModel *model = [[GroupUserModel alloc] init];
        model.userId = [NSString stringWithFormat:@"%d",i];
        model.friend_nick = [NSString stringWithFormat:@"我是昵称%d",i];
        model.head_photo = @"hhhhhhh";
        [models addObject:model];
    }
    
    //converseId TEXT NOT NULL, memberId TEXT NOT NULL, memberName TEXT NOT NULL, memberHeader_Photo TEXT NOT NULL, memberGroupState INTEGER
//    [FMDBShareManager saveAllGroupMemberWithArray:models andGroupChatId:<#(NSString *)#>];
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
    self.selectedConverse = groupModel;
    if (self.isBigImageTrans) {
        TransPopView *popView = [[TransPopView alloc] initWithMessage:self.transMsg toUserId:groupModel.converseId isGroup:YES];
        popView.delegate = self;
        [popView show];
    }else{
        ConverseModel *groupModel = self.dataArr[indexPath.row];
        
        
        ChatController *vc = [[ChatController alloc] init];
        vc.conversionId = groupModel.converseId;
        vc.conversionName = groupModel.converseName;
        vc.converseLogo = groupModel.converseHead_photo;
        vc.converseType = groupModel.converseType;
        vc.hidesBottomBarWhenPushed = YES;
        
        
        // 跳转处理
        self.tabBarController.selectedIndex = 0;
        UINavigationController *nav = [self.tabBarController.viewControllers objectAtIndex:0];
        [nav pushViewController:vc animated:YES];
        
        [self.navigationController popToRootViewControllerAnimated:YES];
        
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
    newMsg.holderImage = message.holderImage;
    newMsg.videoDownloadUrl = message.videoDownloadUrl;
    newMsg.holderImageUrlString = message.holderImageUrlString;
    newMsg.isDownLoad = message.isDownLoad;
    newMsg.fromUserPhoto = USERINFO.head_photo;
    newMsg.fromUserName = USERINFO.username;
    newMsg.converseName = self.selectedConverse.converseName;
    newMsg.converseLogo = self.selectedConverse.converseHead_photo;
    //如果是群聊消息 -- 发送群聊的"名称"、"头像"
    if (self.selectedConverse.converseType == ConversionTypeGroupChat) {
        newMsg.converseName = self.selectedConverse.converseName;
        newMsg.converseLogo = self.selectedConverse.converseHead_photo;
    }
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
