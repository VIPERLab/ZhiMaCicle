//
//  ChatRoomInfoController.m
//  ZhiMaBaoBao
//
//  Created by mac on 16/10/5.
//  Copyright © 2016年 liugang. All rights reserved.
//

#import "ChatRoomInfoController.h"
#import "ChatInfoCell.h"
#import "ChatInfoHeaderCell.h"

#import "ConverseModel.h"

#import "FriendProfilecontroller.h" // 好友详情
#import "CreateGroupChatController.h"
#import "ComplainViewController.h" // 投诉

#import "ChatController.h"
#import "GroupChatModel.h"

#define CharRoomInfoHeaderCellReusedID @"CharRoomInfoHeaderCellReusedID"
#define CharRoomInfoCellReusedID @"CharRoomInfoCellReusedID"

@interface ChatRoomInfoController () <UITableViewDelegate,UITableViewDataSource,UIAlertViewDelegate,ChatInfoHeaderCellDelegate>

@property (nonatomic, strong) NSArray *titleArray;
@property (nonatomic, strong) ConverseModel *converseModel;
@property (nonatomic, strong) ZhiMaFriendModel *friendModel;
@end

@implementation ChatRoomInfoController {
    UITableView *_tableView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setCustomTitle:@"聊天信息"];
    [self setupView];

}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    // 取出该条会话的模型
    self.converseModel = [FMDBShareManager searchConverseWithConverseID:self.userId andConverseType:NO];
    
    //取出好友模型
    self.friendModel = [FMDBShareManager getUserMessageByUserID:self.userId];
    [_tableView reloadData];

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
    
    [_tableView registerClass:[ChatInfoHeaderCell class] forCellReuseIdentifier:CharRoomInfoHeaderCellReusedID];
    [_tableView registerClass:[ChatInfoCell class] forCellReuseIdentifier:CharRoomInfoCellReusedID];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.titleArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *titleArray = self.titleArray[section];
    return titleArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        ChatInfoHeaderCell *cell = [tableView dequeueReusableCellWithIdentifier:CharRoomInfoHeaderCellReusedID forIndexPath:indexPath];
        cell.delegate = self;
        if (self.converseModel.converseId) {
            cell.userName = self.converseModel.converseName;
            cell.iconName = self.converseModel.converseHead_photo;
        }else{
            cell.userName = self.friendModel.displayName;
            cell.iconName = self.friendModel.head_photo;
        }

        return cell;
    }
    NSArray *titleArray = self.titleArray[indexPath.section];
    ChatInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:CharRoomInfoCellReusedID forIndexPath:indexPath];
    cell.userId = self.userId;
    cell.title = titleArray[indexPath.row];
    cell.converseID = self.userId;
    if (indexPath.section == 1) {
        cell.showSwitch = YES;
        cell.indexPath = indexPath;
        if (indexPath.row == 0) {
            cell.statusSwitch.on = self.converseModel.disturb;
        } else {
            cell.statusSwitch.on = self.converseModel.topChat;
        }
        
        
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return 95;
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

#pragma mark - 用户头像点击
- (void)ChatInfoUserIconDidClick:(NSInteger)index {
    if (index == 0) {
        FriendProfilecontroller *vc = [[FriendProfilecontroller alloc] init];
        vc.userId = self.userId;
        [self.navigationController pushViewController:vc animated:YES];
    } else {
        // 新建群聊
        CreateGroupChatController *vc = [[CreateGroupChatController alloc] init];
        vc.selectedMembers = @[self.userId];
        vc.fartherVC = self;
        vc.hideFirstSection = YES;
        BaseNavigationController *nav = [[BaseNavigationController alloc] initWithRootViewController:vc];
        
        __block UINavigationController *navController = [self.tabBarController.viewControllers objectAtIndex:0];
        __block UITabBarController *tabBarController = self.tabBarController;
        vc.block = ^(GroupChatModel *model) {
            
            // 跳转处理
            ChatController *vc = [[ChatController alloc] init];
            vc.conversionId = model.groupId;
            vc.converseLogo = model.groupAvtar;
            vc.conversionName = model.groupName;
            vc.hidesBottomBarWhenPushed = YES;
            vc.converseType = YES;
            vc.hidesBottomBarWhenPushed = YES;
            vc.isPopToRoot = YES;
            
            tabBarController.selectedIndex = 0;
            [navController pushViewController:vc animated:YES];
            
        };
        [self presentViewController:nav animated:YES completion:nil];
    }
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 2 && indexPath.row == 0) {
        //清空聊天记录
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"您确定要清除聊天记录吗?" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [alert show];
    } else if (indexPath.section == 3 && indexPath.row == 0) {
        ComplainViewController *complain = [[ComplainViewController alloc] init];
        complain.userId = self.userId;
        complain.type = 2;
        complain.dataArray = @[@"发布了不适当内容对我造成骚扰",@"存在欺诈骗钱行为",@"此账号可能被盗用了",@"存在侵权行为",@"发布仿冒品信息"];
        [self.navigationController pushViewController:complain animated:YES];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1) {
        [FMDBShareManager deleteMessageFormMessageTableByConverseID:self.userId];
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

#pragma mark - lazyLoad
- (NSArray *)titleArray {
    if (!_titleArray) {
        _titleArray = @[@[@""],@[@"消息免打扰",@"置顶聊天"],@[@"清空聊天记录"],@[@"投诉"]];
    }
    return _titleArray;
}

@end
