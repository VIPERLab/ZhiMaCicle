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

@interface GroupChatListController ()<UITableViewDelegate,UITableViewDataSource>
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
    label.text = @"你可以通过群聊中的\"保存通讯录\"选项，将其保存到这里";
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
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
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


#pragma mark - lazy
- (NSMutableArray *)dataArr{
    if (!_dataArr) {
        _dataArr = [NSMutableArray array];
    }
    return _dataArr;
}

@end
