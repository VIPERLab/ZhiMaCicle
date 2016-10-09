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

@interface CreateGroupChatController ()<UITableViewDelegate,UITableViewDataSource,GreateGroupListCellDelegate>
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
@end


static NSString * const headerReuseIdentifier = @"firstSectionCell";
static NSString * const listReuseIdentifier = @"SecondSectionCell";

@implementation CreateGroupChatController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setCustomTitle:@"选择联系人"];
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
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
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
        return self.sectionsArr.count + 1;
    }else{
        return 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (tableView == self.tableView) {
        if (section == 0) {
            return 1;
        }else{
            //取到是哪一组，返回该数组中的个数
            return [[self.countOfSectionArr objectAtIndex:section - 1] integerValue];
        }
    }else{
        return self.searchResultArr.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView == self.tableView) {
        if (indexPath.section == 0) {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:headerReuseIdentifier];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.textLabel.text = @"选择一个群";
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
            return cell;
        }
    }else{
        CreateGroupListCell *cell = [tableView dequeueReusableCellWithIdentifier:listReuseIdentifier];
        ZhiMaFriendModel *friend = self.searchResultArr[indexPath.row];
        cell.friendModel = friend;
        cell.delegate = self;
        cell.indexPath = indexPath;
        cell.tableView = tableView;
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (tableView == self.tableView) {
        if (indexPath.section == 0) {   //选择一个群
            
        }else{  //添加群成员
            NSInteger rowNum = 0;
            for (int i = 0; i < indexPath.section - 1; i++) {
                
                rowNum = [[self.countOfSectionArr objectAtIndex:i] intValue] + rowNum;
            }
            rowNum += indexPath.row;
            
            ZhiMaFriendModel *friend = self.friendsAfterSort[rowNum];
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
 
    }else{
        ZhiMaFriendModel *friend = self.searchResultArr[indexPath.row];
        
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 53;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return 0.1f;
    }else{
        return 20;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.1f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
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

//选择完毕，发起群聊
- (void)createGroupChatAction{
    if (self.selectedFriends.count == 0) {
        return;
    }
    //拼接自己的userId和好友userId
    NSMutableArray *userIdArr = [NSMutableArray array];
    [userIdArr addObject:USERINFO.userID];
    for (ZhiMaFriendModel *model in self.selectedFriends) {
        [userIdArr addObject:model.user_Id];
    }
    NSString *userIds = [userIdArr componentsJoinedByString:@","];

    [LCProgressHUD showLoadingText:@"准备开始群聊..."];
    [LGNetWorking addUserToGroup:USERINFO.sessionId userIds:userIds success:^(ResponseData *responseData) {
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
            [FMDBShareManager saveGroupChatMessage:self.groupChatModel andConverseID:self.groupChatModel.groupId];
            
            //通过socket创建群聊
            [[SocketManager shareInstance] createGtoup:self.groupChatModel.groupId uids:userIds];
            
            //跳转到群聊天页面
            [self jumpGroupChat];
        }
    } failure:^(ErrorData *error) {
        [LCProgressHUD showFailureText:error.msg];
    }];
    
}

- (void)jumpGroupChat{
    [self dismissViewControllerAnimated:NO completion:nil];
    UserInfo *userinfo = [UserInfo shareInstance];
    [userinfo.groupChatVC.navigationController popToRootViewControllerAnimated:NO];
    
    userinfo.mainVC.selectedViewController = userinfo.mainVC.viewControllers[0];
    
    ChatController *vc = [[ChatController alloc] init];
    vc.conversionId = self.groupChatModel.groupId;
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
        self.textField.x = CGRectGetMaxX(self.imagesView.frame) + margin;
        //更新导航栏右侧按钮显示
        [self.rightBtn setTitle:[NSString stringWithFormat:@"确定(%d)",count] forState:UIControlStateNormal];
        [self.rightBtn setTitleColor:THEMECOLOR forState:UIControlStateNormal];
    }
    
    //设置滑动试图最大宽度，
    if (width > maxWidth) {
        self.imagesView.width = maxWidth;
        self.imagesView.contentSize = CGSizeMake(width, 40);
        self.textField.x = CGRectGetMaxX(self.imagesView.frame) + margin;
        
        //滑动到最右边
        [self.imagesView setContentOffset:CGPointMake(width - maxWidth, 0) animated:YES];
    }
    
    
    //先移除所有子试图 添加好友头像
//    [self.imagesView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    for (int i = 0; i < count; i ++) {
        ZhiMaFriendModel *friendModel = self.selectedFriends[i];
        UIImageView *avtar = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, imageS, imageS)];
        [avtar sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",friendModel.user_Head_photo]] placeholderImage:[UIImage imageNamed:@"defaultContact"]];
        avtar.x = (imageS + margin) * (count - 1);
        [self.imagesView addSubview:avtar];
    }
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
