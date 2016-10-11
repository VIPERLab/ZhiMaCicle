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
@interface GroupChatAllMembersController () <UITableViewDelegate,UITableViewDataSource>

@end

@implementation GroupChatAllMembersController {
    UITableView *_tableView;
}

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

- (void)setupNav {
    [self setCustomTitle:[NSString stringWithFormat:@"群成员(%zd)",self.membersArray.count]];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"添加" style:UIBarButtonItemStylePlain target:self action:@selector(addGroupMembers)];
}

- (void)setupView {
    
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    [self.view addSubview:_tableView];
    
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
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
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    GroupUserModel *model = self.membersArray[indexPath.row];
    FriendProfilecontroller *friendProfile = [[FriendProfilecontroller alloc] init];
    friendProfile.userId = model.userId;
    [self.navigationController pushViewController:friendProfile animated:YES];
}


// 新增群成员
- (void)addGroupMembers {
    CreateGroupChatController *vc = [[CreateGroupChatController alloc] init];
    BaseNavigationController *nav = [[BaseNavigationController alloc] initWithRootViewController:vc];
    [self presentViewController:nav animated:YES completion:nil];
}

@end