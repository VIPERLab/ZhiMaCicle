//
//  GroupChatRoomInfoController.m
//  ZhiMaBaoBao
//
//  Created by mac on 16/10/5.
//  Copyright © 2016年 liugang. All rights reserved.
//

#import "GroupChatRoomInfoController.h"
#import "GroupChatInfoFooterView.h"

#import "GroupChatInfoCell.h"
#import "GroupChatInfoHeaderCell.h"

#import "ConverseModel.h"
#import "ZhiMaFriendModel.h"

#import "KXActionSheet.h"
#import "SocketManager.h"

#define GroupChatRoomInfoCellReusedID @"GroupChatRoomInfoCellReusedID"
#define GroupChatRoomInfoHeaderCellReusedID @"GroupChatRoomInfoHeaderCellReusedID"
@interface GroupChatRoomInfoController () <UITableViewDelegate,UITableViewDataSource,GroupChatInfoFooterViewDelegate,KXActionSheetDelegate,GroupChatInfoHeaderCellDelegate>

@property (nonatomic, strong) NSArray *titleArray;
@property (nonatomic, strong) NSArray *subTitleArray;
@property (nonatomic, strong) ConverseModel *converseModel;

@property (nonatomic, strong) NSArray <GroupUserModel *>*groupMenberArray;

@end

@implementation GroupChatRoomInfoController {
    UITableView *_tableView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // 获取会话模型
    self.converseModel = [FMDBShareManager searchConverseWithConverseID:self.converseId];
    self.groupModel = [FMDBShareManager getGroupChatMessageByGroupId:self.converseId];
    
    [self setCustomTitle:[NSString stringWithFormat:@"聊天信息(%zd)",self.groupModel.groupUserVos.count]];
    
    [self setupView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupView {
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    [self.view addSubview:_tableView];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    // 设置尾部
    GroupChatInfoFooterView *footer = [[GroupChatInfoFooterView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 85)];
    footer.delegate = self;
    _tableView.tableFooterView = footer;
    
    // 注册cell
    [_tableView registerClass:[GroupChatInfoCell class] forCellReuseIdentifier:GroupChatRoomInfoCellReusedID];
    [_tableView registerClass:[GroupChatInfoHeaderCell class] forCellReuseIdentifier:GroupChatRoomInfoHeaderCellReusedID];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.titleArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *titleArray = self.titleArray[section];
    return titleArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // 第一个cell 特殊处理
    if (indexPath.section == 0 && indexPath.row == 0) {
        GroupChatInfoHeaderCell *cell = [tableView dequeueReusableCellWithIdentifier:GroupChatRoomInfoHeaderCellReusedID forIndexPath:indexPath];
        cell.modelArray = self.groupMenberArray;
        cell.delegate = self;
        return cell;
    }
    
    // 第二种样式cell
    NSArray *titleArray = self.titleArray[indexPath.section];
    NSArray *subTitleArray = self.subTitleArray[indexPath.section];
    GroupChatInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:GroupChatRoomInfoCellReusedID forIndexPath:indexPath];
    cell.title = titleArray[indexPath.row];
    cell.indexPath = indexPath;
    cell.subTitle = subTitleArray[indexPath.row];
    cell.converseId = self.converseId;
    if (indexPath.section == 1 && indexPath.row == 1) {
        cell.imageName = subTitleArray[indexPath.row];
    }
    
    if (indexPath.section == 2 || (indexPath.section == 3 && indexPath.row == 1)) {
        if (indexPath.section == 2 && indexPath.row == 0) {
            // 是否消息免打扰
            cell.statusSwitch.on = !self.converseModel.disturb;
        } else if (indexPath.section == 2 && indexPath.row == 1) {
            // 是否置顶
            cell.statusSwitch.on = self.converseModel.topChat;
        } else if (indexPath.section == 2 && indexPath.row == 2) {
            // 保存到通讯录
            cell.statusSwitch.on = self.groupModel.saveToMailList;
        } else if (indexPath.section == 3 && indexPath.row == 1) {
            // 显示群成员名称
            cell.statusSwitch.on = self.groupModel.showMemberName;
        }
        cell.showStatuSwitch = YES;
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && indexPath.row == 0) {
        CGFloat iconW = (ScreenWidth - 20 * 5) / 4;
        CGFloat line = (self.groupMenberArray.count + 1) / 4.0;
        int temp = (int)line;
        if (temp < line) {
            temp++;
        }
        return ((iconW + 45) * temp + 15);
    }
    return 45;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 0.1;
    }
    return 20;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.1;
}


// 退出的点击事件
- (void)GroupChatInfoFooterViewDidClick {
    KXActionSheet *sheet = [[KXActionSheet alloc] initWithTitle:@"退出后不会通知群聊中其他成员，且不会再接收此群聊消息" cancellTitle:@"取消" andOtherButtonTitles:@[@"确定"]];
    sheet.delegate = self;
    [sheet show];
}

- (void)KXActionSheet:(KXActionSheet *)sheet andIndex:(NSInteger)index {
    if (index == 0) {
        [[SocketManager shareInstance] delGroup:self.groupModel.groupId uid:USERINFO.userID];
        [FMDBShareManager deleteMessageFormMessageTableByConverseID:self.groupModel.groupId];
        [FMDBShareManager deleteConverseWithConverseId:self.groupModel.groupId];
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}


- (void)GroupChatInfoHeaderCellDidClickMemberIcon:(NSString *)memberId {
    NSLog(@"点击了用户头像");
}

- (void)GroupChatInfoHeaderCellDelegateDidClickAddMember {
    NSLog(@"点击了添加好友");
}





- (NSArray *)titleArray {
    if (!_titleArray) {
        _titleArray = @[@[@"",[NSString stringWithFormat:@"全部群成员(%zd)",self.groupModel.groupUserVos.count]],@[@"群聊名称",@"群二维码",@"群公告"],@[@"消息免打扰",@"置顶聊天",@"保存到通讯录"],@[@"我在本群的昵称",@"显示群成员昵称"],@[@"清空聊天记录"]];
    }
    return _titleArray;
}

- (NSArray *)subTitleArray {
    if (!_subTitleArray) {
        _subTitleArray = @[@[@"",@""],@[self.groupModel.groupName,@"QRCode",self.groupModel.notice],@[@"",@"",@""],@[self.groupModel.myGroupName,@""],@[@""]];
    }
    return _subTitleArray;
}


- (NSArray<GroupChatModel *> *)groupMenberArray {
    if (!_groupMenberArray) {
        _groupMenberArray = self.groupModel.groupUserVos;
    }
    return _groupMenberArray;
}
@end
