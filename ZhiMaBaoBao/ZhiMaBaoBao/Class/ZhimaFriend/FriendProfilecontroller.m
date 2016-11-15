//
//  FriendProfilecontroller.m
//  ZhiMaBaoBao
//
//  Created by liugang on 16/9/29.
//  Copyright © 2016年 liugang. All rights reserved.
//  好友详情资料

#import "FriendProfilecontroller.h"
#import "ZhiMaFriendModel.h"
#import "InfoHeaderCell.h"
#import "InfoContentCell.h"
#import "LGPhotosView.h"
#import "SetupFriendInfoController.h"   //设置好友资料
#import "ChatController.h"
#import "SocketManager.h"
#import "LGCallingController.h"
#import "PesonalDiscoverController.h"
#import "NSString+MsgId.h"
#import "ConverseModel.h"

@interface FriendProfilecontroller ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) ZhiMaFriendModel *friend;
@property (nonatomic, strong) NSMutableArray *photosUrl;    //存放个人相册图片url
@property (nonatomic, assign) FriendType friendType;        //好友类型
@property (nonatomic, assign) BOOL hasRequestData;          //标记已经请求数据

@property (nonatomic, strong) NSArray *titlesArr;    //标题数组
@property (nonatomic, strong) NSArray *subTitlesArr; //副标题数组
@property (nonatomic, assign) NSInteger totalSections;    //tableview 总组数 （是好友4组，不是好友3组）

@end
static NSString *const headerIdentifier = @"headerIdentifier";
static NSString *const textIdentifier = @"textIdentifier";
static NSString *const photoIdentifier = @"photoIdentifier";
static NSString *const btnIdentifier = @"btnIdentifier";


@implementation FriendProfilecontroller

- (void)viewDidLoad{
    [super viewDidLoad];
    [self addAllSubviews];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillDisappear:YES];
    [self requestFriendProfile:NO];
}

- (void)addAllSubviews{
    [self setCustomTitle:@"详细资料"];
    UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [tableView registerNib:[UINib nibWithNibName:@"InfoHeaderCell" bundle:nil] forCellReuseIdentifier:headerIdentifier];
    [tableView registerNib:[UINib nibWithNibName:@"InfoContentCell" bundle:nil] forCellReuseIdentifier:textIdentifier];
    [tableView registerNib:[UINib nibWithNibName:@"InfoContentCell" bundle:nil] forCellReuseIdentifier:photoIdentifier];

    [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:btnIdentifier];
    [self.view addSubview:tableView];
    self.tableView = tableView;
}

//如果是好友设置导航栏右侧按钮
- (void)setupNavRightItem{
    UIButton *rightBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 35, 40)];
    [rightBtn setImage:[UIImage imageNamed:@"nav_more"] forState:UIControlStateNormal];
    [rightBtn addTarget:self action:@selector(setupFriendInfo) forControlEvents:UIControlEventTouchUpInside];
    if (self.friendType == FriendTypeFriends) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
    }
}

//设置好友资料
- (void)setupFriendInfo{
    SetupFriendInfoController *vc = [[SetupFriendInfoController alloc] init];
    vc.userId = self.userId;
    [self.navigationController pushViewController:vc animated:YES];
}

//请求好友详细资料
- (void)requestFriendProfile:(BOOL)addSqlit{
    
    [LGNetWorking getFriendInfo:USERINFO.sessionId userId:self.userId block:^(ResponseData *responseData) {
        if (responseData.code == 0) {
            self.hasRequestData = YES;
            self.friend = [ZhiMaFriendModel mj_objectWithKeyValues:responseData.data];
            self.friendType = self.friend.friend_type;

            if ([self.friend.user_Id isEqualToString:USERINFO.userID]) {
                self.friendType = FriendTypeSelf;
            }
            //生成好友相册
            [self generateAlbums];
            [self setupNavRightItem];

            self.totalSections = self.friendType ? 4 : 3;
            [self.tableView reloadData];
            
            //更新好友表
            [FMDBShareManager upDataUserMessage:self.friend];
            
            //更新会话表 （头像）
            FMDatabaseQueue *queue = [FMDBShareManager getQueueWithType:ZhiMa_Chat_Converse_Table];
            NSString *option1 = [NSString stringWithFormat:@"converseLogo = '%@'",self.friend.head_photo];
            NSString *option2 = [NSString stringWithFormat:@"converseId = '%@'",self.userId];
            NSString *optionStr = [FMDBShareManager alterTable:ZhiMa_Chat_Converse_Table withOpton1:option1 andOption2:option2];
            [queue inDatabase:^(FMDatabase *db) {
                [db executeUpdate:optionStr];
            }];
            
            if (addSqlit) {
                //插入好友到数据库
                //添加好友成功 -- 更新数据库 新的好友表  和好友表
                self.friend.status = YES;
                [FMDBShareManager saveNewFirendsWithArray:@[self.friend] withComplationBlock:nil];
                [FMDBShareManager saveUserMessageWithMessageArray:@[self.friend] withComplationBlock:nil andIsUpdata:YES];
            }

        }else{
            [LCProgressHUD showFailureText:responseData.msg];
        }
    } failure:^(ErrorData *error) {
        [LCProgressHUD showFailureText:error.msg];
    }];
}

#pragma mark - tableview 代理方法
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.totalSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{

    if (section == (self.titlesArr.count - 2)) {    //倒数第二组
        return 3;
    }else {
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

        if (indexPath.section == 0) {       //头像，用户名
            InfoHeaderCell *cell = [tableView dequeueReusableCellWithIdentifier:headerIdentifier];
            cell.friendModel = self.friend;
            return cell;
        }
        else if (indexPath.section == self.totalSections - 2 && indexPath.row == 0){     //地区
            InfoContentCell *cell = [tableView dequeueReusableCellWithIdentifier:textIdentifier];
            cell.cellTitle.text = @"地区";
            cell.cellContent.text = self.friend.area;
            return cell;
        }
        else if (indexPath.section == self.totalSections - 2 && indexPath.row == 1){     //个性签名
            InfoContentCell *cell = [tableView dequeueReusableCellWithIdentifier:textIdentifier];
            cell.cellTitle.text = @"个性签名";
            cell.cellContent.text = self.friend.signature;
            return cell;
        }
        else if (indexPath.section == self.totalSections - 2 && indexPath.row == 2){     //个人相册
            InfoContentCell *cell = [tableView dequeueReusableCellWithIdentifier:photoIdentifier];
            cell.separtor.hidden = YES;
            cell.cellTitle.text = @"个人相册";
            LGPhotosView *photosView = [[LGPhotosView alloc] initWithFrame:CGRectMake(104, 10, 250, 60)];
            photosView.photosArr = [NSMutableArray arrayWithArray:self.photosUrl];
            [cell addSubview:photosView];
            return cell;
        }
        //底部按钮 ：用户本身不显示。 好友："发消息"，"拨号"，  不是好友："添加通讯录"  黑名单："移除黑名单"
        else if (indexPath.section == self.totalSections - 1){
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:btnIdentifier];
            //添加footerView
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            UIView *footerView = [self setupLastSectionView];
            [cell.contentView addSubview:footerView];
            return cell;
        }
        else{
            InfoContentCell *cell = [tableView dequeueReusableCellWithIdentifier:textIdentifier];
            cell.cellTitle.text = @"手机号";
            if (self.friendType) { //不是好友，不显示手机号码
                cell.cellContent.text = self.friend.uphone;
            }
            cell.separtor.hidden = YES;
            return cell;
        }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //点击跳转到朋友圈
    if (indexPath.section == self.totalSections - 2 && indexPath.row == 2) {
        PesonalDiscoverController *vc = [[PesonalDiscoverController alloc] init];
        vc.sessionID = USERINFO.sessionId;
        vc.userID = self.friend.user_Id;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        return 90;
    }
    else if (indexPath.section == self.totalSections - 2 && indexPath.row == 2){ //个人相册
        return 79;
    }
    else if (indexPath.section == self.totalSections - 1){   //打电话、发消息按钮
        return 120;
    }
    else{
        return 48;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 20;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.1;
}

#pragma mark - 自定义方法

//设置最后一组的按钮
- (UIView *)setupLastSectionView{
    
    UIView *footerView  = [[UIView alloc] initWithFrame:CGRectMake(0, 0, DEVICEWITH, 135)];
    footerView.backgroundColor = self.tableView.backgroundColor;
    
    UIButton *sendMsg = [[UIButton alloc] initWithFrame:CGRectMake(14, 0, DEVICEWITH - 28, 48)];
    sendMsg.backgroundColor = THEMECOLOR;
    sendMsg.layer.cornerRadius = 5;
    sendMsg.titleLabel.font = MAINFONT;
    [sendMsg setTitleColor:WHITECOLOR forState:UIControlStateNormal];
    [sendMsg addTarget:self action:@selector(sendMsgAction) forControlEvents:UIControlEventTouchUpInside];
    [footerView addSubview:sendMsg];
    sendMsg.hidden = YES;
    
    UIButton *callBtn = [[UIButton alloc] initWithFrame:CGRectMake(14, 63, DEVICEWITH - 28, 48)];
    callBtn.backgroundColor = WHITECOLOR;
    callBtn.layer.cornerRadius = 5;
    callBtn.layer.borderColor = RGB(212, 212, 212).CGColor;
    callBtn.layer.borderWidth = 1;
    callBtn.titleLabel.font = MAINFONT;
    [callBtn setTitleColor:BLACKCOLOR forState:UIControlStateNormal];
    [callBtn addTarget:self action:@selector(callBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [footerView addSubview:callBtn];
    callBtn.hidden = YES;
    
    if (self.friendType == FriendTypeBlack) {   //黑名单
        sendMsg.hidden = NO;
        [sendMsg setTitle:@"移出黑名单" forState:UIControlStateNormal];
    }
    else if (self.friendType == FriendTypeNotFriend && self.hasRequestData){   //不是好友
        sendMsg.hidden = NO;
        [sendMsg setTitle:@"添加到通讯录" forState:UIControlStateNormal];
    }
    else if (self.friendType == FriendTypeFriends){     //好友
        sendMsg.hidden = NO;
        callBtn.hidden = NO;
        [sendMsg setTitle:@"发消息" forState:UIControlStateNormal];
        [callBtn setTitle:@"拨号" forState:UIControlStateNormal];
    }
    else if (self.friendType == FriendTypeNew){    //新的好友
        sendMsg.hidden = NO;
        [sendMsg setTitle:@"通过验证" forState:UIControlStateNormal];
    }
    
    return footerView;
}

/**
 *  底部第一个按钮点击方法 根据好友类型判断
 */
- (void)sendMsgAction{
    if (self.friendType == FriendTypeBlack) {   //黑名单 -> 移出黑名单
        [LGNetWorking setupFriendFunction:USERINFO.sessionId function:@"friend_type" value:@"2" openfireAccount:self.friend.user_Id block:^(ResponseData *responseData) {
            if (responseData.code == 0) {
                //重新加载数据 -> 刷新
                [self requestFriendProfile:YES];
            }else{
                [LCProgressHUD showFailureText:responseData.msg];
            }
        }];
    }
    else if (self.friendType == FriendTypeNotFriend){   //不是好友 -> 添加到通讯录
        SocketManager *manager = [SocketManager shareInstance];
        [manager addFriend:self.friend];
        [LCProgressHUD showSuccessText:@"请求发送成功"];
    }
    else if (self.friendType == FriendTypeFriends){     //好友 -> 发消息
        //先pop到跟控制器。然后切换到会话控制器。然后push到聊天
        UserInfo *userInfo = [UserInfo shareInstance];
        [self.navigationController popToRootViewControllerAnimated:NO];
        userInfo.mainVC.selectedViewController = userInfo.mainVC.viewControllers[0];
        
        ChatController *vc = [[ChatController alloc] init];
        vc.conversionId = self.friend.user_Id;
        vc.conversionName = self.friend.displayName;
        vc.converseLogo = self.friend.head_photo;
        vc.hidesBottomBarWhenPushed = YES;
//        [self.navigationController pushViewController:vc animated:YES];
        ConversationController *conversationVC = userInfo.conversationVC;
        [conversationVC.navigationController pushViewController:vc animated:YES];
        
    }
    else if (self.friendType == FriendTypeNew){     //同意好友请求
        [LGNetWorking setupFriendFunction:USERINFO.sessionId function:@"friend_type" value:@"2" openfireAccount:self.friend.user_Id block:^(ResponseData *responseData) {
            if (responseData.code == 0) {
                //将好友加入数据库好友列表
                [FMDBShareManager saveUserMessageWithMessageArray:@[self.friend] withComplationBlock:nil andIsUpdata:NO];
//                //转换成芝麻友数据模型
//                ZhiMaFriendModel *friend = [[ZhiMaFriendModel alloc] init];
//                friend.user_Id = self.friend.user_Id;
//                friend.head_photo = self.friend.head_photo;
//                friend.user_Name = self.friend.user_Name;
//                friend.friend_type = FriendTypeFriends;
                self.friend.friend_type = FriendTypeFriends;
                [[SocketManager shareInstance] agreeFriendRequest:self.friend];
                [self addSystemMsgToSqlite:self.friend];
                //重新加载数据 -> 刷新
                [self requestFriendProfile:YES];
            }else{
                [LCProgressHUD showFailureText:responseData.msg];
            }
        }];
    }

}

//添加系统消息"你已添加了xx,现在可以开始聊天了"
- (void)addSystemMsgToSqlite:(ZhiMaFriendModel *)friend{
    LGMessage *systemMsg = [[LGMessage alloc] init];
    systemMsg.text = [NSString stringWithFormat:@"你已添加了%@,现在可以开始聊天了",friend.user_Name];
    systemMsg.fromUid = USERINFO.userID;
    systemMsg.toUidOrGroupId = friend.user_Id;
    systemMsg.type = MessageTypeSystem;
    systemMsg.msgid = [NSString generateMessageID];
    systemMsg.conversionType = ConversionTypeSingle;
    systemMsg.timeStamp = [NSDate currentTimeStamp];
    systemMsg.actType = ActTypeDofriend;
    [FMDBShareManager saveMessage:systemMsg toConverseID:friend.user_Id];
    
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    userInfo[@"message"] = systemMsg;
    [[NSNotificationCenter defaultCenter] postNotificationName:kRecieveNewMessage object:nil userInfo:userInfo];
}

/**
 *  拨号
 */
- (void)callBtnAction{
    LGCallingController *vc = [[LGCallingController alloc] init];
    vc.name = self.friend.displayName;
    vc.phoneNum = self.friend.uphone;
    vc.avtarUrl = self.friend.head_photo;
    [self presentViewController:vc animated:YES completion:nil];
}


/**
 *  生成相册
 */
- (void)generateAlbums{
    if (self.photosUrl) {
        [self.photosUrl removeAllObjects];
    }
    //添加图片url进相册数组
    if (self.friend.album1.length) {
        [self.photosUrl addObject:self.friend.album1];
    }
    if (self.friend.album2.length) {
        [self.photosUrl addObject:self.friend.album2];
    }
    if (self.friend.album3.length) {
        [self.photosUrl addObject:self.friend.album3];
    }
}

#pragma mark - lazy
- (NSMutableArray *)photosUrl{
    if (!_photosUrl) {
        _photosUrl = [NSMutableArray array];
    }
    return _photosUrl;
}

- (NSArray *)titlesArr{
    if (self.friendType) {
        _titlesArr = @[@"手机号",@"地区",@"个性签名",@"个人相册"];
    }else{
        _titlesArr = @[@"地区",@"个性签名",@"个人相册"];
    }
    return _titlesArr;
}

- (NSArray *)subTitlesArr{
    if (self.friendType) {
        _subTitlesArr = @[self.friend.uphone,self.friend.area,self.friend.signature];
    }else{
        _subTitlesArr = @[self.friend.uphone,self.friend.area,self.friend.signature];
    }
    return _subTitlesArr;
}
@end
