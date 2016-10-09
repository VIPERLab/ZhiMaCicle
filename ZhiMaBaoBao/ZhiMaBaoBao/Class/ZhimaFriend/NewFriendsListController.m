//
//  NewFriendsListController.m
//  ZhiMaBaoBao
//
//  Created by liugang on 16/9/28.
//  Copyright © 2016年 liugang. All rights reserved.
//  新的好友列表

#import "NewFriendsListController.h"
#import "ZhiMaFriendModel.h"
#import "NewFriendsListCell.h"
#import "NewFriendListHeadCell.h"
#import "LGSearchResultController.h"
#import "FriendProfilecontroller.h"

@interface NewFriendsListController ()<UITableViewDelegate,UITableViewDataSource,LGSearchBarDelegate,NewFriendsListCellDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *friendsArr;
@end

static NSString *const reuseIdentifierH = @"NewFriendsListCellH";
static NSString *const reuseIdentifier = @"NewFriendsListCell";
@implementation NewFriendsListController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self addSubViews];
    [self requestNewFriendsList];
}

- (void)addSubViews{
    [self setCustomTitle:@"新的朋友"];
    UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    tableView.delegate = self;
    tableView.dataSource = self;
    [tableView registerNib:[UINib nibWithNibName:@"NewFriendsListCell" bundle:nil] forCellReuseIdentifier:reuseIdentifier];
    [tableView registerClass:[NewFriendListHeadCell class] forCellReuseIdentifier:reuseIdentifierH];
    [self.view addSubview:tableView];
    self.tableView = tableView;
}

//请求新的好友列表数据 - 如果没有从网络加载
- (void)requestNewFriendsList{
    self.friendsArr = [[FMDBShareManager getAllNewFriendsByUserId:USERINFO.userID] mutableCopy];
    [self.tableView reloadData];
    
    if (!self.friendsArr.count) {
        [LGNetWorking getFriendsList:USERINFO.sessionId friendType:FriendTypeNew success:^(ResponseData *responseData) {
            if (responseData.code == 0) {
                self.friendsArr = [ZhiMaFriendModel mj_objectArrayWithKeyValuesArray:responseData.data];
                [self.tableView reloadData];
                [FMDBShareManager saveNewFirendsWithArray:self.friendsArr andUserId:USERINFO.userID];
            }
        } failure:^(ErrorData *error) {
            [LCProgressHUD showFailureText:@"网络好像出错了哦[^_^]"];
        }];
 
    }
}

/**
 *  搜索栏代理方法 -- 搜索新的好友
 */
- (void)searchAction:(NSString *)content{
    if (!content.length) {
        [LCProgressHUD showText:@"搜索内容不能为空！"];
        return;
    }
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
    [LCProgressHUD showLoadingText:@"请稍等..."];
    [LGNetWorking searchFriend:USERINFO.sessionId content:content type:@"new" block:^(ResponseData *responseData) {
            if (responseData.code == 0) {
                [LCProgressHUD hide];
                //搜索成功 -- 跳转到搜索结果展示页面
                LGSearchResultController *vc = [[LGSearchResultController alloc] init];
                vc.dataArr = responseData.data;
                [self.navigationController pushViewController:vc animated:YES];
                
            }else{
                [LCProgressHUD showText:responseData.msg];
                
            }
    }];
}

/**
 *  接受好友请求
 */
- (void)acceptNewFriendRequest:(NSIndexPath *)indexPath{
    ZhiMaFriendModel *friend = self.friendsArr[indexPath.row];
    [LCProgressHUD showLoadingText:@"请稍等..."];
    [LGNetWorking setupFriendFunction:USERINFO.sessionId function:@"friend_type" value:@"2" openfireAccount:friend.user_Id block:^(ResponseData *responseData) {
        if (responseData.code == 0) {
            [LCProgressHUD hide];
            //添加好友成功 -- 更新数据库
            friend.status = YES;
            [FMDBShareManager upDataNewFriendsMessageByFriendModel:friend];
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            
        }else{
            [LCProgressHUD showText:responseData.msg];
        }
    }];
}

#pragma mark - tableView 代理方法
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {     //搜索栏
        return 1;
    }else{      //好友列表
        return self.friendsArr.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {   //搜索栏
        NewFriendListHeadCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifierH];
        cell.searchBar.delegate = self;
        return cell;
    }else{      //好友列表
        NewFriendsListCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
        cell.friendModel = self.friendsArr[indexPath.row];
        cell.delegate = self;
        cell.indexPath = indexPath;
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 1) {
        //跳转到用户详情
        ZhiMaFriendModel *friend = self.friendsArr[indexPath.row];
        FriendProfilecontroller *vc = [[FriendProfilecontroller alloc] init];
        vc.userId = friend.user_Id;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return [UIView new];
    }else{
        UIView *headerView  = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICEWITH, 30)];
        headerView.backgroundColor = self.tableView.backgroundColor;
        
        UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(14, 5, DEVICEWITH - 14, 20)];
        titleLabel.text = @"新的朋友";
        titleLabel.font = [UIFont systemFontOfSize:14.0];
        titleLabel.textColor = RGB(147, 147, 147);
        titleLabel.backgroundColor = [UIColor clearColor];
        [headerView addSubview:titleLabel];
        return headerView;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return 15;
    }else{
        return 30;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.1f;
}

#pragma mark - lazy
- (NSMutableArray *)friendsArr{
    if (!_friendsArr) {
        _friendsArr = [NSMutableArray array];
    }
    return _friendsArr;
}

@end
