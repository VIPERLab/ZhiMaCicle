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

@interface FriendProfilecontroller ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) ZhiMaFriendModel *friend;
@property (nonatomic, strong) NSMutableArray *photosUrl;    //存放个人相册图片url

@end
static NSString *const headerIdentifier = @"headerIdentifier";
static NSString *const textIdentifier = @"textIdentifier";
static NSString *const photoIdentifier = @"photoIdentifier";
static NSString *const btnIdentifier = @"btnIdentifier";


@implementation FriendProfilecontroller

- (void)viewDidLoad{
    [super viewDidLoad];
    
    [self requestFriendProfile];
    [self addAllSubviews];
}

- (void)addAllSubviews{
    [self setCustomTitle:@"详细资料"];
    UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [tableView registerNib:[UINib nibWithNibName:@"InfoHeaderCell" bundle:nil] forCellReuseIdentifier:headerIdentifier];
    [tableView registerNib:[UINib nibWithNibName:@"InfoContentCell" bundle:nil] forCellReuseIdentifier:textIdentifier];
    [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:btnIdentifier];
    [self.view addSubview:tableView];
}

//请求好友详细资料
- (void)requestFriendProfile{
    [LGNetWorking getFriendInfo:USERINFO.sessionId userId:self.userId block:^(ResponseData *responseData) {
        if (responseData.code == 0) {
            self.friend = [ZhiMaFriendModel mj_objectWithKeyValues:responseData.data];
            //生成好友相册
            [self generateAlbums];
            self.friendType = self.friend.friend_type;
            [self.tableView reloadData];
        }else{
            [LCProgressHUD showText:responseData.msg];
        }
    } failure:^(ErrorData *error) {
        [LCProgressHUD showText:error.msg];
    }];
}

#pragma mark - tableview 代理方法

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 2) {
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
    else if (indexPath.section == 1){   //手机号
        InfoContentCell *cell = [tableView dequeueReusableCellWithIdentifier:textIdentifier];
        cell.cellTitle.text = @"手机号";
        cell.cellContent.text = self.friend.uphone;
        cell.separtor.hidden = YES;
        return cell;
    }
    else if (indexPath.section == 2 && indexPath.row == 0){     //地区
        InfoContentCell *cell = [tableView dequeueReusableCellWithIdentifier:textIdentifier];
        cell.cellTitle.text = @"地区";
        cell.cellContent.text = self.friend.area;
        return cell;
    }
    else if (indexPath.section == 2 && indexPath.row == 1){     //个性签名
        InfoContentCell *cell = [tableView dequeueReusableCellWithIdentifier:textIdentifier];
        cell.cellTitle.text = @"个性签名";
        cell.cellContent.text = self.friend.signature;
        return cell;
    }
    else if (indexPath.section == 2 && indexPath.row == 2){     //个人相册
        InfoContentCell *cell = [tableView dequeueReusableCellWithIdentifier:textIdentifier];
        cell.separtor.hidden = YES;
        cell.cellTitle.text = @"个人相册";
        LGPhotosView *photosView = [[LGPhotosView alloc] initWithFrame:CGRectMake(104, 10, 250, 60)];
        photosView.photosArr = [NSMutableArray arrayWithArray:self.photosUrl];
        [cell addSubview:photosView];
        return cell;
    }
    else{       //底部按钮 ：用户本身不显示。 好友："发消息"，"拨号"，  不是好友："添加通讯录"  黑名单："移除黑名单"
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:btnIdentifier];
        //添加footerView
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        UIView *footerView = [self setupLastSectionView];
        [cell.contentView addSubview:footerView];
        return cell;
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        return 90;
    }
    else if (indexPath.section == 2 && indexPath.row == 2){ //个人相册
        return 79;
    }
    else if (indexPath.section == 3){   //打电话、发消息按钮
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
    footerView.backgroundColor = BGCOLOR;
    
    UIButton *sendMsg = [[UIButton alloc] initWithFrame:CGRectMake(14, 0, DEVICEWITH - 28, 48)];
    sendMsg.backgroundColor = THEMECOLOR;
    sendMsg.layer.cornerRadius = 5;
    sendMsg.titleLabel.font = MAINFONT;
    [sendMsg setTitleColor:WHITECOLOR forState:UIControlStateNormal];
    [sendMsg addTarget:self action:@selector(sendMsgAction) forControlEvents:UIControlEventTouchUpInside];
    [footerView addSubview:sendMsg];
    
    UIButton *callBtn = [[UIButton alloc] initWithFrame:CGRectMake(14, 63, DEVICEWITH - 28, 48)];
    callBtn.backgroundColor = WHITECOLOR;
    callBtn.layer.cornerRadius = 5;
    callBtn.layer.borderColor = RGB(212, 212, 212).CGColor;
    callBtn.layer.borderWidth = 1;
    callBtn.titleLabel.font = MAINFONT;
    [callBtn setTitleColor:BLACKCOLOR forState:UIControlStateNormal];
    [callBtn addTarget:self action:@selector(callBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [footerView addSubview:callBtn];
    
    if (self.friendType == FriendTypeBlack) {   //黑名单
        callBtn.hidden = YES;
        [sendMsg setTitle:@"移出黑名单" forState:UIControlStateNormal];
    }
    else if (self.friendType == FriendTypeNotFriend){   //不是好友
        callBtn.hidden = YES;
        [sendMsg setTitle:@"添加到通讯录" forState:UIControlStateNormal];
    }
    else if (self.friendType == FriendTypeFriends){     //好友
        [sendMsg setTitle:@"发消息" forState:UIControlStateNormal];
        [callBtn setTitle:@"拨号" forState:UIControlStateNormal];
    }
    else if (self.friendType == FriendTypeSelf){    //用户自己
        callBtn.hidden = YES;
        sendMsg.hidden = YES;
    }
    
    return footerView;
}

/**
 *  底部第一个按钮点击方法 根据好友类型判断
 */
- (void)sendMsgAction{
    
}

/**
 *  拨号
 */
- (void)callBtnAction{
    
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
@end
