//
//  GroupDeleteMembersController.m
//  ZhiMaBaoBao
//
//  Created by liugang on 16/10/25.
//  Copyright © 2016年 liugang. All rights reserved.
//

#import "GroupDeleteMembersController.h"
#import "CreateGroupListCell.h"
#import "GroupChatModel.h"


@interface GroupDeleteMembersController ()<UITableViewDelegate,UITableViewDataSource,GreateGroupListCellDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UITableView *searchTableView;     //搜索好友时展示的tableview
@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) UIScrollView *imagesView;     //展示被选好友头像
@property (nonatomic, strong) UIButton *rightBtn;           //导航栏右侧按钮

@property (nonatomic, strong) NSMutableArray *searchResultArr;      //搜索结果匹配好友数组
@property (nonatomic, strong) NSMutableArray *selectedFriends;      //被选择的好友数组

@property (nonatomic, assign) CGFloat lastOffset;   //上一次scrollview偏移量
@property (nonatomic, assign)NSInteger currentPage; //当前页



@end
static NSString * const headerReuseIdentifier = @"firstSectionCell";
static NSString * const listReuseIdentifier = @"SecondSectionCell";
@implementation GroupDeleteMembersController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setCustomTitle:@"删除成员"];
    [self setNavItem];
    
    self.currentPage = 1;
    
//    NSArray *allUser = [FMDBShareManager getAllGroupMenberWithGroupId:self.groupId];
//    self.membersArr = [allUser mutableCopy];
    NSArray *allUser = [self.membersArr copy];
    //移除自己
    for (GroupUserModel *user in allUser) {
        if ([user.userId isEqualToString:USERINFO.userID]) {
            [self.membersArr removeObject:user];
        }
    }
    [self addAllSubviews];

    //监听输入框
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(searchFriends:) name:UITextFieldTextDidChangeNotification object:nil];
}

- (void)setNavItem{
    
    UIButton *rightBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 80, 40)];
    rightBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [rightBtn setTitle:@"删除" forState:UIControlStateNormal];
    [rightBtn setTitleColor:GRAYCOLOR forState:UIControlStateNormal];
    rightBtn.titleLabel.font = MAINFONT;
    [rightBtn addTarget:self action:@selector(deleteMemberAction) forControlEvents:UIControlEventTouchUpInside];
    self.rightBtn = rightBtn;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];

    
    
    UIButton *leftBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    leftBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [leftBtn setTitle:@"取消" forState:UIControlStateNormal];
    [leftBtn setTitleColor:THEMECOLOR forState:UIControlStateNormal];
    leftBtn.titleLabel.font = MAINFONT;
    [leftBtn addTarget:self action:@selector(cancelAction) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftBtn];
    
}

- (void)addAllSubviews{
    //顶部搜索栏
    UIView *searchView = [[UIView alloc] initWithFrame:CGRectMake(0, 64, DEVICEWITH, 50)];
    searchView.backgroundColor = WHITECOLOR;
    [self.view addSubview:searchView];
    
    //搜索图片
    UIImageView *seachImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"lsearch"]];
    seachImage.frame = CGRectMake(14, 15, 19, 21);
    [searchView addSubview:seachImage];
    
    //相册试图
    UIScrollView *imagesView = [[UIScrollView alloc] initWithFrame:CGRectMake(14, 5, 0, 40)];
    [searchView addSubview:imagesView];
    self.imagesView = imagesView;
    
    //输入框
    UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(40, 10, 200, 30)];
    textField.font = MAINFONT;
    textField.placeholder = @"搜索";
    self.textField = textField;
    [searchView addSubview:textField];
    
    //分割线
    UIView *separtor = [[UIView alloc] initWithFrame:CGRectMake(0, 49, DEVICEWITH, 1)];
    separtor.backgroundColor = SEPARTORCOLOR;
    [searchView addSubview:separtor];
    
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(searchView.frame), DEVICEWITH, DEVICEHIGHT - CGRectGetMaxY(searchView.frame)) style:UITableViewStylePlain];
    [tableView registerNib:[UINib nibWithNibName:@"CreateGroupListCell" bundle:nil] forCellReuseIdentifier:listReuseIdentifier];
    tableView.sectionIndexColor = RGB(54, 54, 54);
    tableView.sectionIndexBackgroundColor = [UIColor clearColor];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.tableFooterView = [[UIView alloc] init];
    [self.view addSubview:tableView];
    self.tableView = tableView;
    
    //搜索好友时展示的tableview
    UITableView *searchTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(searchView.frame), DEVICEWITH, DEVICEHIGHT - searchView.height) style:UITableViewStylePlain];
    [searchTableView registerNib:[UINib nibWithNibName:@"CreateGroupListCell" bundle:nil] forCellReuseIdentifier:listReuseIdentifier];
    searchTableView.delegate = self;
    searchTableView.dataSource = self;
    searchTableView.tableFooterView = [[UIView alloc] init];
    self.searchTableView = searchTableView;
    
    MJRefreshAutoNormalFooter*footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreRefreshOrderList)];
    [footer setTitle:@"已全部加载完" forState:MJRefreshStateNoMoreData];
    self.tableView.mj_footer = footer;
}

- (void)loadMoreRefreshOrderList
{
    self.currentPage ++;
    [self dataRequstMembers];
    
}

- (void)dataRequstMembers
{
    
    [LGNetWorking getGroupInfo:USERINFO.sessionId groupId:self.groupId page:self.currentPage success:^(ResponseData *responseData) {
        
        if (responseData.code != 0) {
            if (responseData.code == 29) {
                [_tableView.mj_footer endRefreshingWithNoMoreData];
                return ;
            }
            
            [LCProgressHUD showFailureText:responseData.msg];
            return ;
        }
        
        if (responseData.code == 81) {
            [LCProgressHUD showFailureText:responseData.msg];
            [self.navigationController popViewControllerAnimated:YES];
            return;
        }
        
        [GroupChatModel mj_setupObjectClassInArray:^NSDictionary *{
            return @{
                     @"groupUserVos":@"GroupUserModel"
                     };
        }];
        GroupChatModel *groupModel = [GroupChatModel mj_objectWithKeyValues:responseData.data];
        NSArray*arr = groupModel.groupUserVos;
        
        //        if (arr.count<40  || !arr) {
        //            [_tableView.mj_footer endRefreshingWithNoMoreData];
        //
        //        }
        
        for (int i=0; i<arr.count; i++) {
            GroupUserModel*model = arr[i];
            [self.membersArr addObject:model];
        }
        
        [_tableView.mj_footer endRefreshing];
        
        
        [_tableView reloadData];
        
    } failure:^(ErrorData *error) {
        
        [_tableView.mj_footer endRefreshing];
        
    }];
}


#pragma mark - cell delegate
- (void)selectGroupMember:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath{
    [self tableView:tableView didSelectRowAtIndexPath:indexPath];
}


//删除群成员
- (void)deleteMemberAction{
    NSMutableArray *names = [NSMutableArray array];
    for (GroupUserModel *model in self.selectedFriends) {
        [names addObject:model.friend_nick];
    }
    NSString *userNames = [names componentsJoinedByString:@","];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"确定删除群成员%@?",userNames] message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alertView show];
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSLog(@"%zd",buttonIndex);
    if (buttonIndex == 1) {
        
        [LCProgressHUD showLoadingText:@"请稍等..."];
        
        //删除好友
        NSMutableArray *uidsArr = [NSMutableArray array];
        NSMutableArray *namesArr = [NSMutableArray array];
        for (GroupUserModel *model in self.selectedFriends) {
            [uidsArr addObject:model.userId];
            [namesArr addObject:model.friend_nick];
        }
        NSString *userIds = [uidsArr componentsJoinedByString:@","];
        NSString *names = [namesArr componentsJoinedByString:@","];
        
        //添加系统消息
        LGMessage *systemMsg = [[LGMessage alloc] init];
        systemMsg.text = [NSString stringWithFormat:@"你将\"%@\"移除了群聊",names];
        systemMsg.converseId = self.groupId;
        systemMsg.type = MessageTypeSystem;
        systemMsg.msgid = [NSString generateMessageID];
        systemMsg.conversionType = ConversionTypeSingle;
        systemMsg.timeStamp = [NSDate currentTimeStamp];
        systemMsg.actType = ActTypeDeluserfromgroup;
        systemMsg.converseName = self.groupName;
        systemMsg.converseLogo = self.groupLogo;
        [FMDBShareManager saveMessage:systemMsg toConverseID:self.groupId];
        [[NSNotificationCenter defaultCenter] postNotificationName:kRecieveNewMessage object:nil userInfo:@{@"message":systemMsg}];
        
        //通过socket删除群成员群聊
        GroupActModel *actModel = [[GroupActModel alloc] init];
        actModel.uids = userIds;
        actModel.usernames = names;
        actModel.groupId = self.groupId;
        actModel.groupLogo = self.groupLogo;
        actModel.groupName = self.groupName;
        [[SocketManager shareInstance] delUserFromGroup:actModel];
        
        [self.membersArr removeObjectsInArray:self.selectedFriends];
        [_tableView reloadData];
        
        
        //从群成员表里面删除数据
        [FMDBShareManager deletedGroupMembersInArray:uidsArr fromGroupId:self.groupId];
        
        //调用http接口，获取最新群头像
        [LGNetWorking getGroupHeadGroupId:self.groupId success:^(ResponseData *responseData) {
            if (responseData.code == 0) {
                NSLog(@"-----删除成员更新头像成功");
            }
        } failure:^(ErrorData *error) {
        }];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [LCProgressHUD showSuccessText:@"删除成功"];
        });
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self dismissViewControllerAnimated:YES completion:nil];
        });
    }
}

- (void)cancelAction{
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - tableview datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (tableView == self.tableView) {
        return self.membersArr.count;
    }else{
        return self.searchResultArr.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView == self.tableView) {
        CreateGroupListCell *cell = [tableView dequeueReusableCellWithIdentifier:listReuseIdentifier];
        
        GroupUserModel *model = self.membersArr[indexPath.row];
        cell.model = model;
        cell.delegate = self;
        cell.indexPath = indexPath;
        cell.tableView = tableView;
        
        return cell;
        
    }else{
        CreateGroupListCell *cell = [tableView dequeueReusableCellWithIdentifier:listReuseIdentifier];
        GroupUserModel *model = self.searchResultArr[indexPath.row];
        cell.model = model;
        cell.delegate = self;
        cell.indexPath = indexPath;
        cell.tableView = tableView;
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (tableView == self.tableView) {
        
        GroupUserModel *model = self.membersArr[indexPath.row];
        
            model.selectedGroup = !model.selectedGroup;
            
            //刷新选中行
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            
            //如果是选中状态，加入数组 如果是非选中状态移出数组
            if (model.selectedGroup) {
                [self.selectedFriends addObject:model];
            }else{
                if ([self.selectedFriends containsObject:model]) {
                    [self.selectedFriends removeObject:model];
                }
            }
            
            //更新顶栏试图 imagesView 的frame
            [self refreshImagesViewFrame];
        
    }else{
        [self.textField resignFirstResponder];
        
        GroupUserModel *model = self.searchResultArr[indexPath.row];
        
        //找到在friendsAfterSort数组里面与之对应的模型，设置模型的选中属性
        for (GroupUserModel *model1 in self.membersArr) {
            if ([model1.userId isEqualToString:model.userId]) {
                model1.selectedGroup = !model1.selectedGroup;
            }
        }
        //刷新选中行
        [self.tableView reloadData];
        
        //如果是选中状态，加入数组 如果是非选中状态移出数组
        if (model.selectedGroup) {
            [self.selectedFriends addObject:model];
        }else{
            if ([self.selectedFriends containsObject:model]) {
                [self.selectedFriends removeObject:model];
            }
        }
        
        //更新顶栏试图 imagesView 的frame
        [self refreshImagesViewFrame];
        
        //隐藏搜索结果tableview
        self.textField.text = @"";
        [self.searchTableView removeFromSuperview];
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 53;
}

//刷新imagesView 的frame
- (void)refreshImagesViewFrame{
    
    CGFloat margin = 7;
    CGFloat imageS = 40;
    NSInteger count = self.selectedFriends.count;
    CGFloat width = imageS * count + margin * (count - 1);
    CGFloat maxWidth = DEVICEWITH - 100;
    
    
    if (count == 0) {
        self.imagesView.width = 0;
        self.textField.x = 40;
        //更新导航栏右侧按钮显示
        [self.rightBtn setTitle:@"删除" forState:UIControlStateNormal];
        [self.rightBtn setTitleColor:GRAYCOLOR forState:UIControlStateNormal];
        
        
    }else{
        self.imagesView.width = width;
        self.imagesView.contentSize = CGSizeMake(width, 40);
        self.textField.x = CGRectGetMaxX(self.imagesView.frame) + margin;
        //更新导航栏右侧按钮显示
        [self.rightBtn setTitle:[NSString stringWithFormat:@"删除(%ld)",(long)count] forState:UIControlStateNormal];
        [self.rightBtn setTitleColor:THEMECOLOR forState:UIControlStateNormal];
    }
    
    //设置滑动试图最大宽度，
    if (width >= maxWidth) {
        self.imagesView.width = maxWidth;
        self.textField.x = CGRectGetMaxX(self.imagesView.frame) + margin;
        
        //先滑倒上次偏移的位置
        
        [self.imagesView setContentOffset:CGPointMake(self.lastOffset, 0) animated:NO];
        
        //滑动到最右边
        [self.imagesView setContentOffset:CGPointMake(width - maxWidth, 0) animated:YES];
        self.lastOffset = width - maxWidth;
    }else{
        [self.imagesView setContentOffset:CGPointMake(0, 0) animated:YES];
    }
    
    
    //先移除所有子试图 添加好友头像
    [self.imagesView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    for (int i = 0; i < count; i ++) {
        GroupUserModel *friendModel = self.selectedFriends[i];
        UIImageView *avtar = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, imageS, imageS)];
        avtar.userInteractionEnabled = YES;
        [avtar sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",DFAPIURL,friendModel.head_photo]] placeholderImage:[UIImage imageNamed:@"defaultContact"]];
        avtar.x = (imageS + margin) * (i);
        avtar.tag = i;
        [self.imagesView addSubview:avtar];
        [avtar addTapGestureRecognizer:self forAction:@selector(removeSelectMember:)];
    }
    
}

//单击已选好友头像，移除该群聊成员
- (void)removeSelectMember:(UITapGestureRecognizer *)gesture{
    NSInteger index = gesture.view.tag;
    GroupUserModel *friend = self.selectedFriends[index];
    
    //从已选好友中移出，刷新选择栏
    [self.selectedFriends removeObjectAtIndex:index];
    [self refreshImagesViewFrame];
    
    //从全部好友中移除已选，刷新表
    for (GroupUserModel *model in self.membersArr) {
        if ([model.userId isEqualToString:friend.userId]) {
            model.selectedGroup = !model.selectedGroup;
            break;
        }
    }
    [self.tableView reloadData];
}

//匹配搜索结果
- (void)searchFriends:(NSNotification *)notify{
    if (self.textField.hasText) {
        [self.view addSubview:self.searchTableView];
        
        [self.searchResultArr removeAllObjects];
        NSString *text = self.textField.text;
        for (GroupUserModel *friendModel in self.membersArr) {
            if ([friendModel.friend_nick containsString:text]) {
                [self.searchResultArr addObject:friendModel];
            }
        }
        [self.searchTableView reloadData];
    }else{
        [self.searchTableView removeFromSuperview];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [self.textField resignFirstResponder];
}


#pragma mark - lazy
- (NSMutableArray *)searchResultArr{
    if (!_searchResultArr) {
        _searchResultArr = [NSMutableArray array];
    }
    return _searchResultArr;
}

- (NSMutableArray *)selectedFriends{
    if (!_selectedFriends) {
        _selectedFriends = [NSMutableArray array];
    }
    return _selectedFriends;
}
@end
