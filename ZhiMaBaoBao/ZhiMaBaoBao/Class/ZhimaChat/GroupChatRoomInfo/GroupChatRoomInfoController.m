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
#import "NSDate+TimeCategory.h"

#import "FriendProfilecontroller.h"  //用户详情
#import "CreateGroupChatController.h"  //创建群聊
#import "GroupChatChangeGroupNameController.h" //修改群名称
#import "GroupChatChangeNoticeController.h"    //修改群公告
#import "GroupChatMessageDetailController.h"   //聊天记录
#import "GroupChatAllMembersController.h"      //全部群成员

#define GroupChatRoomInfoCellReusedID @"GroupChatRoomInfoCellReusedID"
#define GroupChatRoomInfoHeaderCellReusedID @"GroupChatRoomInfoHeaderCellReusedID"
@interface GroupChatRoomInfoController () <UITableViewDelegate,UITableViewDataSource,GroupChatInfoFooterViewDelegate,KXActionSheetDelegate,GroupChatInfoHeaderCellDelegate,UIAlertViewDelegate>

@property (nonatomic, strong) NSArray *titleArray;
@property (nonatomic, strong) NSArray *subTitleArray;
@property (nonatomic, strong) ConverseModel *converseModel;

@property (nonatomic, strong) NSArray <GroupUserModel *>*groupMenberArray;

@property (nonatomic, strong) GroupChatModel *groupModel;   //群聊信息数据模型

@end

@implementation GroupChatRoomInfoController {
    UITableView *_tableView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupView];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)getDataFormSQL {
    // 获取会话模型
    self.converseModel = [FMDBShareManager searchConverseWithConverseID:self.converseId andConverseType:YES];
    self.groupModel = [FMDBShareManager getGroupChatMessageByGroupId:self.converseId];
    
    self.groupModel.create_time = [NSDate dateStrFromCstampTime:self.converseModel.time withDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    self.groupModel.topChat = self.converseModel.topChat;
    self.groupModel.disturb = self.converseModel.disturb;
}

- (void)viewWillAppear:(BOOL)animated {
    [self getDataFormSQL];
     [self setCustomTitle:[NSString stringWithFormat:@"聊天信息(%zd)",self.groupModel.groupUserVos.count]];
    [_tableView reloadData];
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
        if ([subTitleArray[indexPath.row] isEqualToString:@""]) {
            cell.subTitle = @"未设置";
        }
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
    } else if (indexPath.section == 1 && indexPath.row == 2) {
        return [self.groupModel.notice sizeWithFont:[UIFont systemFontOfSize:15] maxSize:CGSizeMake(ScreenWidth - 40, 55)].height;
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && indexPath.row == 1) {
        //全部成员
        NSLog(@"全部群成员");
        GroupChatAllMembersController *members = [[GroupChatAllMembersController alloc] init];
        members.membersArray = self.groupModel.groupUserVos;
        [self.navigationController pushViewController:members animated:YES];
        
    } else if (indexPath.section == 1 && indexPath.row == 0) {
        // 群聊名称
        NSLog(@"修改群名称");
        GroupChatChangeGroupNameController *changeGroupName = [[GroupChatChangeGroupNameController alloc] init];
        changeGroupName.groupModel = self.groupModel;
        changeGroupName.tipsTitle = @"群聊名称";
        changeGroupName.titleName = @"群聊名称";
        changeGroupName.type = 0;
        [self.navigationController pushViewController:changeGroupName animated:YES];
    } else if (indexPath.section == 1 && indexPath.row == 1) {
        // 群公告
        NSLog(@"修改群公告");
        GroupChatChangeNoticeController *changeNotice = [[GroupChatChangeNoticeController alloc] init];
        changeNotice.groupModel = self.groupModel;
        [self.navigationController pushViewController:changeNotice animated:YES];
        
    } else if (indexPath.section == 3 && indexPath.row == 0) {
        // 我在本群的名称
        NSLog(@"修改我在本群的昵称");
        GroupChatChangeGroupNameController *changeGroupName = [[GroupChatChangeGroupNameController alloc] init];
        changeGroupName.groupModel = self.groupModel;
        changeGroupName.tipsTitle = @"我在本群的昵称";
        changeGroupName.titleName = @"我在本群的昵称";
        changeGroupName.type = 1;
        [self.navigationController pushViewController:changeGroupName animated:YES];
        
    } else if (indexPath.section == 4 && indexPath.row == 0) {
        //显示聊天消息
        GroupChatMessageDetailController *detail = [[GroupChatMessageDetailController alloc] init];
        detail.groupId = self.converseId;
        [self.navigationController pushViewController:detail animated:YES];
        
    } else if (indexPath.section == 4 && indexPath.row == 1) {
        //显示聊天消息
        NSLog(@"清空聊天记录");
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"您确定要清除聊天记录吗?" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [alert show];
    }
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

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1) {
        [FMDBShareManager deleteMessageFormMessageTableByConverseID:self.converseId];
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}


- (void)GroupChatInfoHeaderCellDidClickMemberIcon:(NSString *)memberId {
    NSLog(@"点击了用户头像");
    FriendProfilecontroller *friendProfile = [[FriendProfilecontroller alloc] init];
    friendProfile.userId = memberId;
    [self.navigationController pushViewController:friendProfile animated:YES];
}

//邀请好友加入群聊
- (void)GroupChatInfoHeaderCellDelegateDidClickAddMember {
    
    //将已有用户id,存入数组
    NSMutableArray *originUserIds = [NSMutableArray array];
    for (GroupUserModel *model in self.groupMenberArray) {
        [originUserIds addObject:model.userId];
    }
    
    CreateGroupChatController *vc = [[CreateGroupChatController alloc] init];
    vc.fartherVC = self;
    vc.hideFirstSection = self;
    vc.selectedMembers = originUserIds;
    BaseNavigationController *nav = [[BaseNavigationController alloc] initWithRootViewController:vc];
    [self presentViewController:nav animated:YES completion:nil];
}


- (NSArray *)titleArray {
    _titleArray = @[@[@"",[NSString stringWithFormat:@"全部群成员(%zd)",self.groupModel.groupUserVos.count]],@[@"群聊名称",@"群公告"],@[@"新消息提醒",@"置顶聊天",@"保存到通讯录"],@[@"我在本群的昵称",@"显示群成员昵称"],@[@"显示聊天记录",@"清空聊天记录"]];
    return _titleArray;
}

- (NSArray *)subTitleArray {
    _subTitleArray = @[@[@"",@""],@[self.groupModel.groupName,self.groupModel.notice],@[@"",@"",@""],@[self.groupModel.myGroupName,@""],@[@"",@""]];
    return _subTitleArray;
}


- (NSArray<GroupUserModel *> *)groupMenberArray {
    if (!_groupMenberArray) {
        _groupMenberArray = self.groupModel.groupUserVos;
    }
    return _groupMenberArray;
}
@end
