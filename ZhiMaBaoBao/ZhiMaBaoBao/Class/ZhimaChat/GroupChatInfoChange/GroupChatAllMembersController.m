//
//  GroupChatAllMembersController.m
//  ZhiMaBaoBao
//
//  Created by mac on 16/10/10.
//  Copyright © 2016年 liugang. All rights reserved.
//

#import "GroupChatAllMembersController.h"
#import "GroupAllMemberCell.h"


#import "FriendProfilecontroller.h"
#import "CreateGroupChatController.h"

#define GroupChatMembersCellReusedID @"GroupChatMembersCellReusedID"
@interface GroupChatAllMembersController () <UITableViewDelegate,UITableViewDataSource,GroupAllMemberCellDelegate,UIAlertViewDelegate>

@property (nonatomic, weak) UIButton *rightBtn;

@property (nonatomic, weak) GroupUserModel *currentModel;
@property (nonatomic, weak) GroupAllMemberCell *currentCell;
@end

@implementation GroupChatAllMembersController {
    UITableView *_tableView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setCustomTitle:@""];
    
    if (self.isDeletedMembers) {
        for (GroupUserModel *model in self.membersArray) {
            if ([model.userId isEqualToString:USERINFO.userID]) {
                [self.membersArray removeObject:model];
                break;
            }
        }
    }
    
    [self setupNav];
    [self setupView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupNav {
    
    UIButton *rightBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 80, 40)];
    rightBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    
    rightBtn.titleLabel.font = MAINFONT;
    self.rightBtn = rightBtn;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
    
    if (self.isDeletedMembers) {
        [self setCustomTitle:@"删除成员"];
//        [rightBtn setTitle:@"删除" forState:UIControlStateNormal];
//        [rightBtn setTitleColor:GRAYCOLOR forState:UIControlStateNormal];
//        [rightBtn addTarget:self action:@selector(delGroupMembers) forControlEvents:UIControlEventTouchUpInside];
        
    } else {
        [self setCustomTitle:[NSString stringWithFormat:@"群成员(%zd)",self.membersArray.count]];
        [rightBtn setTitle:@"添加" forState:UIControlStateNormal];
        [rightBtn setTitleColor:THEMECOLOR forState:UIControlStateNormal];
        [rightBtn addTarget:self action:@selector(addGroupMembers) forControlEvents:UIControlEventTouchUpInside];
    }
    
}

- (void)setupView {
    
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    [self.view addSubview:_tableView];
    
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [_tableView registerClass:[GroupAllMemberCell class] forCellReuseIdentifier:GroupChatMembersCellReusedID];
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.membersArray.count;
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


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GroupUserModel *model = self.membersArray[indexPath.row];
    GroupAllMemberCell *cell = [tableView dequeueReusableCellWithIdentifier:GroupChatMembersCellReusedID forIndexPath:indexPath];
    cell.model = model;
    cell.delegate = self;
    cell.isDeletedMembers = self.isDeletedMembers;
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (self.isDeletedMembers) {
        return;
    }
    GroupUserModel *model = self.membersArray[indexPath.row];
    FriendProfilecontroller *friendProfile = [[FriendProfilecontroller alloc] init];
    friendProfile.userId = model.userId;
    [self.navigationController pushViewController:friendProfile animated:YES];
}


// 新增群成员
- (void)addGroupMembers {
    CreateGroupChatController *vc = [[CreateGroupChatController alloc] init];
    
    //取出所有群成员id
    NSMutableArray *membersUids = [NSMutableArray array];
    for (GroupUserModel *model in self.membersArray) {
        [membersUids addObject:model.userId];
    }
    
    vc.fartherVC = self;
    vc.hideFirstSection = self;
    vc.selectedMembers = membersUids;
    vc.groupId = self.groupId;
    BaseNavigationController *nav = [[BaseNavigationController alloc] initWithRootViewController:vc];
    [self presentViewController:nav animated:YES completion:nil];
}


// 删除群成员
- (void)GroupAllMemberCellDelegateDeletedButtonDidClick:(GroupUserModel *)model andCell:(GroupAllMemberCell *)cell {
    self.currentModel = model;
    self.currentCell = cell;
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"确定删除群成员%@",model.friend_nick] message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alertView show];
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSLog(@"%zd",buttonIndex);
    if (buttonIndex == 1) {
        //删除好友
        GroupActModel *actModel = [[GroupActModel alloc] init];
//        [[SocketManager shareInstance] delUserFromGroup:self.groupId uids:self.currentCell.model.userId];
        NSIndexPath *indexPath = [_tableView indexPathForCell:self.currentCell];
        
        
        [self.membersArray removeObject:self.currentCell.model];
        [_tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationTop];
        
        // 更新群用户表里 群成员的状态 memberState = 1
        GroupUserModel *model = self.currentCell.model;
        model.memberGroupState = 1;
        [FMDBShareManager saveAllGroupMemberWithArray:@[model] andGroupChatId:self.groupId withComplationBlock:nil];
    }
}

@end
