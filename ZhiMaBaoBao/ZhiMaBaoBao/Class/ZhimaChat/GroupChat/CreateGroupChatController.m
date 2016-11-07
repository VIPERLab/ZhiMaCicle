//
//  CreateGroupChatController.m
//  ZhiMaBaoBao
//
//  Created by liugang on 16/10/5.
//  Copyright © 2016年 liugang. All rights reserved.
//  发起群聊

#import "CreateGroupChatController.h"
#import "CreateGroupListCell.h"
#import "pinyin.h"
#import "GroupChatModel.h"
#import "SocketManager.h"
#import "ChatController.h"
#import "TransPopView.h"
#import "NSString+MsgId.h"
#import "GroupChatListController.h"

@interface CreateGroupChatController ()<UITableViewDelegate,UITableViewDataSource,GreateGroupListCellDelegate,TransPopViewDelegate>
@property (nonatomic, strong) NSMutableArray *friends;              //好友列表数组
@property (nonatomic, strong) NSMutableArray *friendsAfterSort;     //排序后的好友列表数组
@property (nonatomic, strong) NSMutableArray *sectionsArr;             //排序后好友名称首字母
@property (nonatomic, strong) NSMutableArray *countOfSectionArr;       //每组的好友个数
@property (nonatomic, strong) NSMutableArray *selectedFriends;      //被选择的好友数组
@property (nonatomic, strong) NSMutableArray *searchResultArr;      //搜索结果匹配好友数组

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UITableView *searchTableView;     //搜索好友时展示的tableview
@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) UIScrollView *imagesView;     //展示被选好友头像
@property (nonatomic, strong) UIButton *rightBtn;           //导航栏右侧按钮

@property (nonatomic, strong) GroupChatModel *groupChatModel;

@property (nonatomic, assign) CGFloat lastOffset;   //上一次scrollview偏移量

@property (nonatomic, assign) int j;
@end


static NSString * const headerReuseIdentifier = @"firstSectionCell";
static NSString * const listReuseIdentifier = @"SecondSectionCell";

@implementation CreateGroupChatController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.hideFirstSection) {
        [self setCustomTitle:@"发起群聊"];
    }else{
        [self setCustomTitle:@"选择联系人"];
    }
    [self setNavItem];
    [self addAllSubviews];
    [self requestFriendsList];
    
    //监听输入框
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(searchFriends:) name:UITextFieldTextDidChangeNotification object:nil];
}

//请求好友列表
- (void)requestFriendsList{
    //从数据库拉取好友列表
    self.friends = [[FMDBShareManager getAllUserMessageInArray] mutableCopy];
    [self friendsListSort];
}

- (void)setNavItem{
    
    UIButton *rightBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 80, 40)];
    rightBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [rightBtn setTitle:@"确定" forState:UIControlStateNormal];
    [rightBtn setTitleColor:GRAYCOLOR forState:UIControlStateNormal];
    rightBtn.titleLabel.font = MAINFONT;
    [rightBtn addTarget:self action:@selector(createGroupChatAction) forControlEvents:UIControlEventTouchUpInside];
    self.rightBtn = rightBtn;

    
    UIButton *leftBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    leftBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [leftBtn setTitle:@"取消" forState:UIControlStateNormal];
    [leftBtn setTitleColor:THEMECOLOR forState:UIControlStateNormal];
    leftBtn.titleLabel.font = MAINFONT;
    [leftBtn addTarget:self action:@selector(cancelAction) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftBtn];
    
    if (!self.hideFlagBtn) {     //点击直接转发消息  隐藏右侧确定按钮
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
    }
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
    [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:headerReuseIdentifier];
    [tableView registerNib:[UINib nibWithNibName:@"CreateGroupListCell" bundle:nil] forCellReuseIdentifier:listReuseIdentifier];
    tableView.sectionIndexColor = RGB(54, 54, 54);
    tableView.sectionIndexBackgroundColor = [UIColor clearColor];
    tableView.delegate = self;
    tableView.dataSource = self;
    [self.view addSubview:tableView];
    self.tableView = tableView;
    
    //搜索好友时展示的tableview
    UITableView *searchTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(searchView.frame), DEVICEWITH, DEVICEHIGHT - searchView.height) style:UITableViewStylePlain];
    [searchTableView registerNib:[UINib nibWithNibName:@"CreateGroupListCell" bundle:nil] forCellReuseIdentifier:listReuseIdentifier];
    searchTableView.delegate = self;
    searchTableView.dataSource = self;
    self.searchTableView = searchTableView;
    
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (tableView == self.tableView) {
        if (self.hideFirstSection) {    //不显示选择一个群
            return self.sectionsArr.count;
        }else{
            return self.sectionsArr.count + 1;
        }
    }else{
        return 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (tableView == self.tableView) {
        if (self.hideFirstSection) {    //不显示"选择一个群"
            //取到是哪一组，返回该数组中的个数
            return [[self.countOfSectionArr objectAtIndex:section] integerValue];
        }else{
            if (section == 0) {
                return 1;
            }else{
                //取到是哪一组，返回该数组中的个数
                return [[self.countOfSectionArr objectAtIndex:section - 1] integerValue];
            }
        }
    }else{
        return self.searchResultArr.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView == self.tableView) {
        if (self.hideFirstSection) {    //不显示"选择一个群"
            CreateGroupListCell *cell = [tableView dequeueReusableCellWithIdentifier:listReuseIdentifier];
            NSInteger rowNum = 0;
            for (int i = 0; i < indexPath.section; i++) {
                
                rowNum = [[self.countOfSectionArr objectAtIndex:i] intValue] + rowNum;
            }
            rowNum += indexPath.row;
            
            ZhiMaFriendModel *friend = self.friendsAfterSort[rowNum];
            cell.friendModel = friend;
            cell.delegate = self;
            cell.indexPath = indexPath;
            cell.tableView = tableView;
            
            return cell;

        }else{
            if (indexPath.section == 0) {
                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:headerReuseIdentifier];
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                cell.textLabel.text = @"选择群聊";
                return cell;
            }else{
                CreateGroupListCell *cell = [tableView dequeueReusableCellWithIdentifier:listReuseIdentifier];
                NSInteger rowNum = 0;
                for (int i = 0; i < indexPath.section - 1; i++) {
                    
                    rowNum = [[self.countOfSectionArr objectAtIndex:i] intValue] + rowNum;
                }
                rowNum += indexPath.row;
                
                ZhiMaFriendModel *friend = self.friendsAfterSort[rowNum];
                cell.friendModel = friend;
                cell.delegate = self;
                cell.indexPath = indexPath;
                cell.tableView = tableView;
                cell.selectedMembers = self.selectedMembers;
                
                if (self.hideFlagBtn) {
                    //隐藏选择按钮，头像左移
                    cell.selectFlagBtn.hidden = YES;
                    cell.avtarLeftMargin.constant = -25;
                }
                return cell;
            }
        }

    }else{
        CreateGroupListCell *cell = [tableView dequeueReusableCellWithIdentifier:listReuseIdentifier];
        ZhiMaFriendModel *friend = self.searchResultArr[indexPath.row];
        cell.friendModel = friend;
        cell.delegate = self;
        cell.indexPath = indexPath;
        cell.tableView = tableView;
        
        if (self.hideFlagBtn) {
            //隐藏选择按钮，头像左移
            cell.selectFlagBtn.hidden = YES;
            cell.avtarLeftMargin.constant = -25;
        }
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.textField resignFirstResponder];

    if (tableView == self.tableView) {
        if (self.hideFirstSection) {   //不显示"选择群聊"

            NSInteger rowNum = 0;
            for (int i = 0; i < indexPath.section; i++) {
                
                rowNum = [[self.countOfSectionArr objectAtIndex:i] intValue] + rowNum;
            }
            rowNum += indexPath.row;
            ZhiMaFriendModel *friend = self.friendsAfterSort[rowNum];
            
            //如果是已选成员，直接return
            for (NSString *userId in self.selectedMembers) {
                if ([friend.user_Id isEqualToString:userId]) {
                    return;
                }
            }
            
            friend.selectedGroup = !friend.selectedGroup;
            
            //刷新选中行
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            
            //如果是选中状态，加入数组 如果是非选中状态移出数组
            if (friend.selectedGroup) {
                [self.selectedFriends addObject:friend];
            }else{
                if ([self.selectedFriends containsObject:friend]) {
                    [self.selectedFriends removeObject:friend];
                }
            }
            
            //更新顶栏试图 imagesView 的frame
            [self refreshImagesViewFrame];
        }else{
            if (indexPath.section == 0) {   //选择群聊  ->   跳转到群列表
                GroupChatListController *vc = [[GroupChatListController alloc] init];
                vc.isBigImageTrans = self.isPushFromTrans;  //标记是否为大图转发
                vc.transMsg = self.transMsg;
                [self.navigationController pushViewController:vc animated:YES];
                
            }else{  //添加群成员
                NSInteger rowNum = 0;
                for (int i = 0; i < indexPath.section - 1; i++) {
                    
                    rowNum = [[self.countOfSectionArr objectAtIndex:i] intValue] + rowNum;
                }
                rowNum += indexPath.row;
                
                ZhiMaFriendModel *friend = self.friendsAfterSort[rowNum];
                
                if (self.hideFlagBtn) {     //选择好友 ，转发消息
                    self.transMsg.conversionType = ConversionTypeSingle;
                    TransPopView *popView = [[TransPopView alloc] initWithMessage:self.transMsg toUserId:friend.user_Id isGroup:NO];
                    popView.delegate = self;
                    [popView show];
                }else{      //选择群成员
                    
                    
                    //设置选中属性
                    friend.selectedGroup = !friend.selectedGroup;
                    
                    //刷新选中行
                    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                    
                    //如果是选中状态，加入数组 如果是非选中状态移出数组
                    if (friend.selectedGroup) {
                        [self.selectedFriends addObject:friend];
                    }else{
                        if ([self.selectedFriends containsObject:friend]) {
                            [self.selectedFriends removeObject:friend];
                        }
                    }
                    
                    //更新顶栏试图 imagesView 的frame
                    [self refreshImagesViewFrame];
                }
            }
        }

    }else{
        
        ZhiMaFriendModel *friend = self.searchResultArr[indexPath.row];
        if (self.hideFlagBtn) {     //选择好友 ，转发消息
            self.transMsg.conversionType = ConversionTypeSingle;
            TransPopView *popView = [[TransPopView alloc] initWithMessage:self.transMsg toUserId:friend.user_Id isGroup:NO];
            popView.delegate = self;
            [popView show];
        }else{  //选择好友进群
            //如果是已选成员，直接return
            for (NSString *userId in self.selectedMembers) {
                if ([friend.user_Id isEqualToString:userId]) {
                    return;
                }
            }
            
            //找到在friendsAfterSort数组里面与之对应的模型，设置模型的选中属性
            for (ZhiMaFriendModel *friend1 in self.friendsAfterSort) {
                if ([friend1.user_Id isEqualToString:friend.user_Id]) {
                    friend1.selectedGroup = !friend1.selectedGroup;
                }
            }
            //刷新选中行
            [self.tableView reloadData];
            
            //如果是选中状态，加入数组 如果是非选中状态移出数组
            if (friend.selectedGroup) {
                [self.selectedFriends addObject:friend];
            }else{
                if ([self.selectedFriends containsObject:friend]) {
                    [self.selectedFriends removeObject:friend];
                }
            }
            
            //更新顶栏试图 imagesView 的frame
            [self refreshImagesViewFrame];
            
            //隐藏搜索结果tableview
            self.textField.text = @"";
            [self.searchTableView removeFromSuperview];
        }

    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 53;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (self.hideFirstSection) {
        return 20;
    }else{
        if (section == 0) {
            return 0.1f;
        }else{
            return 20;
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.1f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (self.hideFirstSection) {
        UIView *headerView  = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICEWITH, 20)];
        headerView.backgroundColor = RGB(229, 229, 229);
        
        UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(14, 0, DEVICEWITH - 14, 20)];
        titleLabel.text = [self.sectionsArr objectAtIndex:section];
        titleLabel.font = [UIFont systemFontOfSize:16.0];
        titleLabel.textColor = RGB(147, 147, 147);
        titleLabel.backgroundColor = [UIColor clearColor];
        [headerView addSubview:titleLabel];
        return headerView;
    }else{
        if (section == 0) {
            
            return [UIView new];
        }else{
            UIView *headerView  = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICEWITH, 20)];
            headerView.backgroundColor = RGB(229, 229, 229);
            
            UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(14, 0, DEVICEWITH - 14, 20)];
            titleLabel.text = [self.sectionsArr objectAtIndex:section - 1];
            titleLabel.font = [UIFont systemFontOfSize:16.0];
            titleLabel.textColor = RGB(147, 147, 147);
            titleLabel.backgroundColor = [UIColor clearColor];
            [headerView addSubview:titleLabel];
            return headerView;
        }
    }
}

//添加索引列
- (NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView{
    if (tableView == self.tableView) {
        return self.sectionsArr;
    }else{
        return nil;
    }
}

//索引列点击事件
-(NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    //点击索引，列表跳转到对应索引的行
    
    [tableView
     scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:index]
     atScrollPosition:UITableViewScrollPositionTop animated:YES];
    
    return index;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [self.textField resignFirstResponder];
}

#pragma mark - cell delegate
- (void)selectGroupMember:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath{
    [self tableView:tableView didSelectRowAtIndexPath:indexPath];
}

#pragma mark - 自定义方法
//匹配搜索结果
- (void)searchFriends:(NSNotification *)notify{
    if (self.textField.hasText) {
        [self.view addSubview:self.searchTableView];
        
        [self.searchResultArr removeAllObjects];
        NSString *text = self.textField.text;
        for (ZhiMaFriendModel *friendModel in self.friendsAfterSort) {
            if ([friendModel.displayName containsString:text] || [friendModel.pinyin containsString:[text uppercaseString]]) {
                [self.searchResultArr addObject:friendModel];
            }
        }
        
        [self.searchTableView reloadData];
    }else{
        [self.searchTableView removeFromSuperview];
    }
}


- (void)test{
    _j ++;

    //假数据 - 建一个199人的群聊
    NSMutableArray *uidsArr = [NSMutableArray array];
    for (int i = 10000 + _j*200; i<10199 + _j*200; i++) {
        NSString *userId = [NSString stringWithFormat:@"%d",i];
        [uidsArr addObject:userId];
    }
    NSString *userIds = [uidsArr componentsJoinedByString:@","];
    
    [LGNetWorking addUserToGroup:USERINFO.sessionId userIds:userIds groupId:@"8a9a53d85833725c01583db51fc20032" success:^(ResponseData *responseData) {
        if (responseData.code == 0) {
            [LCProgressHUD hide];
            //生成群聊数据模型
            [GroupChatModel mj_setupObjectClassInArray:^NSDictionary *{
                return @{
                         @"groupUserVos":@"GroupUserModel"
                         };
            }];
            self.groupChatModel = [GroupChatModel mj_objectWithKeyValues:responseData.data];
            self.groupChatModel.myGroupName = USERINFO.username;
            //异步存储群成员信息
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                [FMDBShareManager saveAllGroupMemberWithArray:self.groupChatModel.groupUserVos andGroupChatId:self.groupChatModel.groupId withComplationBlock:^(BOOL success) {
                    if (success) {
                        //群成员信息存储完毕，创建会话
                        //                            dispatch_async(dispatch_get_main_queue(), ^{
                        //
                        //                            });
                        //                            [FMDBShareManager ];
                        [FMDBShareManager saveGroupChatInfo:self.groupChatModel andConverseID:self.groupChatModel.groupId];
                    }
                }];
            });
            
            //通过socket创建群聊
            [uidsArr addObject:USERINFO.userID];
            NSString *socketUids = [uidsArr componentsJoinedByString:@","];
            [[SocketManager shareInstance] createGtoup:self.groupChatModel.groupId uids:socketUids];
        }
    } failure:^(ErrorData *error) {
        [LCProgressHUD showFailureText:error.msg];
    }];
    
    if (_j < 5) {
        [self performSelector:@selector(test) withObject:nil afterDelay:1.5];

    }else{
        [self jumpGroupChat];
        return;
    }

}
//选择完毕，发起群聊
- (void)createGroupChatAction{
    if (self.selectedFriends.count == 0) {
        _j = 0;
        [self performSelector:@selector(test) withObject:nil afterDelay:1.5];
        
        return;
    }
    
    //拼接自己的userId和好友userId
    NSMutableArray *userIdArr = [NSMutableArray array];
//    [userIdArr addObject:USERINFO.userID];
    for (ZhiMaFriendModel *model in self.selectedFriends) {
        [userIdArr addObject:model.user_Id];
    }
    
    //直接拉群
    if (self.selectedMembers.count == 0) {
        
        if (self.selectedFriends.count < 2) {   //群成员少于2个人 ， 不让建群
            [LCProgressHUD showFailureText:@"请至少选择两个好友！"];
            return;
        }
        
        NSString *userIds = [userIdArr componentsJoinedByString:@","];
        
        [LCProgressHUD showLoadingText:@"准备开始群聊..."];
        [LGNetWorking addUserToGroup:USERINFO.sessionId userIds:userIds groupId:@"0" success:^(ResponseData *responseData) {
            if (responseData.code == 0) {
                [LCProgressHUD hide];
                //生成群聊数据模型
                [GroupChatModel mj_setupObjectClassInArray:^NSDictionary *{
                    return @{
                             @"groupUserVos":@"GroupUserModel"
                             };
                }];
                self.groupChatModel = [GroupChatModel mj_objectWithKeyValues:responseData.data];
                self.groupChatModel.myGroupName = USERINFO.username;
                //新建一个群会话，插入数据库
//                [FMDBShareManager saveGroupChatInfo:self.groupChatModel andConverseID:self.groupChatModel.groupId];
                
                //异步存储群成员信息
                dispatch_async(dispatch_get_global_queue(0, 0), ^{
                    [FMDBShareManager saveAllGroupMemberWithArray:self.groupChatModel.groupUserVos andGroupChatId:self.groupChatModel.groupId withComplationBlock:^(BOOL success) {
                        if (success) {
                            //群成员信息存储完毕，创建会话
//                            dispatch_async(dispatch_get_main_queue(), ^{
//                                
//                            });
//                            [FMDBShareManager ];
                        }
                    }];
                });
                
                
                [userIdArr addObject:USERINFO.userID];
                NSString *socketUids = [userIdArr componentsJoinedByString:@","];
                //通过socket创建群聊
                [[SocketManager shareInstance] createGtoup:self.groupChatModel.groupId uids:socketUids];
                
                //跳转到群聊天页面
                [self jumpGroupChat];
            }
        } failure:^(ErrorData *error) {
            [LCProgressHUD showFailureText:error.msg];
        }];

    }else{
        //如果有已选择群成员。 且已选群成员只有一个：代表是单聊发起群聊 -> 新建新群聊   如果有多个已选群成员 -> 拉人进群
        if (self.selectedMembers.count == 1) {
            [userIdArr addObjectsFromArray:self.selectedMembers];
            
            NSString *userIds = [userIdArr componentsJoinedByString:@","];
            
            [LCProgressHUD showLoadingText:@"准备开始群聊..."];
            [LGNetWorking addUserToGroup:USERINFO.sessionId userIds:userIds groupId:@"0" success:^(ResponseData *responseData) {
                if (responseData.code == 0) {
                    [LCProgressHUD hide];
                    //生成群聊数据模型
                    [GroupChatModel mj_setupObjectClassInArray:^NSDictionary *{
                        return @{
                                 @"groupUserVos":@"GroupUserModel"
                                 };
                    }];
                    self.groupChatModel = [GroupChatModel mj_objectWithKeyValues:responseData.data];
                    self.groupChatModel.myGroupName = USERINFO.username;
                    //新建一个群会话，插入数据库
                    [FMDBShareManager saveGroupChatInfo:self.groupChatModel andConverseID:self.groupChatModel.groupId];
                    
                    //通过socket创建群聊
                    [[SocketManager shareInstance] createGtoup:self.groupChatModel.groupId uids:userIds];
                    
                    //跳转到群聊天页面
                    [self jumpGroupChat];
                }
            } failure:^(ErrorData *error) {
                [LCProgressHUD showFailureText:error.msg];
            }];
        }else{      //拉人进群
            //拼接选择好友userId
            NSMutableArray *userIdArray = [NSMutableArray array];
            for (ZhiMaFriendModel *model in self.selectedFriends) {
                [userIdArray addObject:model.user_Id];
            }
            NSString *userIds = [userIdArray componentsJoinedByString:@","];
            
            [LCProgressHUD showLoadingText:@"准备开始群聊..."];
            [LGNetWorking addUserToGroup:USERINFO.sessionId userIds:userIds groupId:self.groupId success:^(ResponseData *responseData) {
                if (responseData.code == 0) {
                    [LCProgressHUD hide];
                    //生成群聊数据模型
                    [GroupChatModel mj_setupObjectClassInArray:^NSDictionary *{
                        return @{
                                 @"groupUserVos":@"GroupUserModel"
                                 };
                    }];
                    self.groupChatModel = [GroupChatModel mj_objectWithKeyValues:responseData.data];
                    self.groupChatModel.myGroupName = USERINFO.username;
                    //保存群会话信息，插入数据库
                    [FMDBShareManager saveGroupChatInfo:self.groupChatModel andConverseID:self.groupChatModel.groupId];

                    //通过socket拉人进群
                    [[SocketManager shareInstance] addUserToGroup:self.groupChatModel.groupId uids:userIds];
                    
                    //跳转到群聊天页面
                    [self jumpGroupChat];
                }
            } failure:^(ErrorData *error) {
                [LCProgressHUD showFailureText:error.msg];
            }];
        }
    }
}

- (void)jumpGroupChat{
    [self dismissViewControllerAnimated:NO completion:nil];
    UserInfo *userinfo = [UserInfo shareInstance];
    [self.fartherVC.navigationController popToRootViewControllerAnimated:NO];
    
    userinfo.mainVC.selectedViewController = userinfo.mainVC.viewControllers[0];
    
    ChatController *vc = [[ChatController alloc] init];
    vc.conversionId = self.groupChatModel.groupId;
    vc.converseType = YES;
    vc.hidesBottomBarWhenPushed = YES;
    ConversationController *conversationVC = userinfo.conversationVC;
    [conversationVC.navigationController pushViewController:vc animated:YES];
}

- (void)cancelAction{
    if (self.isPushFromTrans) {
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        [self dismissViewControllerAnimated:YES completion:nil];
    }
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
        [self.rightBtn setTitle:@"确定" forState:UIControlStateNormal];
        [self.rightBtn setTitleColor:GRAYCOLOR forState:UIControlStateNormal];


    }else{
        self.imagesView.width = width;
        self.imagesView.contentSize = CGSizeMake(width, 40);
        self.textField.x = CGRectGetMaxX(self.imagesView.frame) + margin;
        //更新导航栏右侧按钮显示
        [self.rightBtn setTitle:[NSString stringWithFormat:@"确定(%ld)",(long)count] forState:UIControlStateNormal];
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
        ZhiMaFriendModel *friendModel = self.selectedFriends[i];
        UIImageView *avtar = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, imageS, imageS)];
        avtar.userInteractionEnabled = YES;
        [avtar sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",DFAPIURL,friendModel.user_Head_photo]] placeholderImage:[UIImage imageNamed:@"defaultContact"]];
        avtar.x = (imageS + margin) * (i);
        avtar.tag = i;
        [self.imagesView addSubview:avtar];
        [avtar addTapGestureRecognizer:self forAction:@selector(removeSelectMember:)];
    }
    
}

//单击已选好友头像，移除该群聊成员
- (void)removeSelectMember:(UITapGestureRecognizer *)gesture{
    NSInteger index = gesture.view.tag;
    ZhiMaFriendModel *friend = self.selectedFriends[index];

    //从已选好友中移出，刷新选择栏
    [self.selectedFriends removeObjectAtIndex:index];
    [self refreshImagesViewFrame];

    //从全部好友中移除已选，刷新表
    for (ZhiMaFriendModel *model in self.friends) {
        if ([model.user_Id isEqualToString:friend.user_Id]) {
            model.selectedGroup = !model.selectedGroup;
            break;
        }
    }
    [self.tableView reloadData];
}

//好友列表排序分组
- (void)friendsListSort{
    
    //清空数组
    [self.friendsAfterSort removeAllObjects];
    [self.sectionsArr removeAllObjects];
    [self.countOfSectionArr removeAllObjects];
    
    //遍历好友数组
    for (int i = 0; i < self.friends.count; i++) {
        ZhiMaFriendModel *friend = self.friends[i];
        NSString *pinyin = [NSString string];
        for(int j = 0; j< friend.displayName.length ;j++){
            
            NSString *singlePinyinLetter = [[NSString stringWithFormat:@"%c",pinyinFirstLetter([friend.displayName characterAtIndex:j])] uppercaseString];
            pinyin = [pinyin stringByAppendingString:singlePinyinLetter];
        }
        //将好友显示名称转换成拼音缩写
        friend.pinyin = pinyin;
        [self.friendsAfterSort addObject:friend];
    }
    // 按照模型"pinyin"属性 排序数组
    NSArray *sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"pinyin" ascending:YES]];
    [self.friendsAfterSort sortUsingDescriptors:sortDescriptors];
    
    int num = 0;
    
    //遍历排序后的数组
    for(int i=0; i<[self.friendsAfterSort count]; i++){
        
        ZhiMaFriendModel *friend = self.friendsAfterSort[i];
        if (i == 0) {
            //第一个数据首字母
            NSString *str = [NSString stringWithFormat:@"%c",pinyinFirstLetter([friend.pinyin characterAtIndex:0])];
            [self.sectionsArr addObject:[str uppercaseString]];
            
            //如果只有一个好友
            if (self.friendsAfterSort.count == 1) {
                [self.countOfSectionArr addObject:@(1)];
            }
        }
        
        if (i < self.friendsAfterSort.count - 1) {
            //取到第二条数据，与第一条数据首字母比较
            ZhiMaFriendModel *friend1 = self.friendsAfterSort[i+1];
            
            if (pinyinFirstLetter([friend1.pinyin characterAtIndex:0]) != pinyinFirstLetter([friend.pinyin characterAtIndex:0])) {
                
                NSString *numStr = [NSString stringWithFormat:@"%d",num + 1];
                [self.countOfSectionArr addObject:numStr];
                
                ////最后一条数据 -> 将最后一组数据个数插入
                if (i == self.friendsAfterSort.count - 2) {
                    [self.countOfSectionArr addObject:@(1)];
                }
                
                NSString *str = [NSString stringWithFormat:@"%c",pinyinFirstLetter([friend1.pinyin characterAtIndex:0])];
                [self.sectionsArr addObject:[str uppercaseString]];
                num = 0;
            }
            else{
                num ++;
                //最后一条数据 -> 将最后一组数据个数插入
                if (i == self.friendsAfterSort.count - 2) {
                    [self.countOfSectionArr addObject:@(num+1)];
                }
            }
        }
    }
    [self.tableView reloadData];
    
     //如果有已选群成员， 设置模型属性 originalUser  为 YES
    if (self.selectedMembers.count) {
        for (ZhiMaFriendModel *model in self.friendsAfterSort) {
            for (NSString *userId in self.selectedMembers) {
                if ([model.user_Id isEqualToString:userId]) {
                    model.originalUser = YES;
                }
            }
        }
    }
}

#pragma mark - 转发消息
//转发消息
- (void)transformMessage:(LGMessage *)message toUserId:(NSString *)userId{
    //生成一个新的消息模型
    LGMessage *newMsg = [self generateNewMessage:message to:userId];
    [[SocketManager shareInstance] sendMessage:newMsg];
    
    UserInfo *info = [UserInfo shareInstance];
    if (info.topWindow) {
        [info.topWindow resignKeyWindow];
//        info.topWindow = nil;
        [info.keyWindow makeKeyAndVisible];
        [LCProgressHUD showSuccessText:@"发送成功"];

    }else{
        [self dismissViewControllerAnimated:YES completion:nil];
        [LCProgressHUD showSuccessText:@"发送成功"];
    }
}

//生成一个新的消息模型 -> 用来转发
- (LGMessage *)generateNewMessage:(LGMessage *)message to:(NSString *)userId{
    LGMessage *newMsg = [[LGMessage alloc] init];
    newMsg.type = message.type;
    newMsg.fromUid = USERINFO.userID;
    //如果转发自己的消息，那么touid为旧消息的touid 如果转发的别人的消息，那么to
    newMsg.toUidOrGroupId = userId;
    newMsg.timeStamp = [NSDate currentTimeStamp];
    newMsg.conversionType = message.conversionType;
    newMsg.text = message.text;
    newMsg.msgid = [NSString generateMessageID];
    newMsg.picUrl = message.picUrl;
    return newMsg;
}


#pragma mark - 懒加载
- (NSMutableArray *)friends{
    if (!_friends) {
        _friends = [NSMutableArray array];
    }
    return _friends;
}

- (NSMutableArray *)friendsAfterSort{
    if (!_friendsAfterSort) {
        _friendsAfterSort = [NSMutableArray array];
    }
    return _friendsAfterSort;
}

- (NSMutableArray *)sectionsArr{
    if (!_sectionsArr) {
        _sectionsArr = [NSMutableArray array];
    }
    return _sectionsArr;
}

- (NSMutableArray *)countOfSectionArr{
    if (!_countOfSectionArr) {
        _countOfSectionArr = [NSMutableArray array];
    }
    return _countOfSectionArr;
}

- (NSMutableArray *)selectedFriends{
    if (!_selectedFriends) {
        _selectedFriends = [NSMutableArray array];
    }
    return _selectedFriends;
}

- (NSMutableArray *)searchResultArr{
    if (!_searchResultArr) {
        _searchResultArr = [NSMutableArray array];
    }
    return _searchResultArr;
}
@end
