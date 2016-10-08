//
//  FriendsController.m
//  ZhiMaBaoBao
//
//  Created by liugang on 16/9/18.
//  Copyright © 2016年 liugang. All rights reserved.
//  好友列表

#import "FriendsController.h"
#import "ZhiMaFriendModel.h"
#import "pinyin.h"
#import "FriendsListCell.h"
#import "ChatController.h"
#import "NewFriendsListController.h"
#import "FriendProfilecontroller.h"
#import "ConversationController.h"
#import "GroupChatListController.h"

@interface FriendsController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *friends;              //好友列表数组
@property (nonatomic, strong) NSMutableArray *friendsAfterSort;     //排序后的好友列表数组
@property (nonatomic, strong) NSMutableArray *sectionsArr;             //排序后好友名称首字母
@property (nonatomic, strong) NSMutableArray *countOfSectionArr;       //每组的好友个数

@property (nonatomic, strong) UILabel *unReadLabel;     //未读好友请求角标
@end

static NSString * const reuseIdentifier = @"friendListcell";
@implementation FriendsController

- (instancetype)init{
    self = [super init];
    if (self) {
        [self requestFriendsList];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setCustomRightItems];
    [self addSubviews];
    
    //监听新的好友请求消息
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recieveFriendRequest:) name:kNewFriendRequest object:nil];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self requestFriendsList];
}

- (void)addSubviews{
    UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.sectionIndexColor = RGB(54, 54, 54);
    tableView.sectionIndexBackgroundColor = [UIColor clearColor];
    [tableView registerNib:[UINib nibWithNibName:@"FriendsListCell" bundle:nil] forCellReuseIdentifier:reuseIdentifier];
    [self.view addSubview:tableView];
    self.tableView = tableView;
}

//请求好友列表
- (void)requestFriendsList{
    [self clearAllArray];
    //先从数据库拉取好友列表 从网络请求加载最新数据更新数据库
    self.friends = [[FMDBShareManager getAllUserMessageInArray] mutableCopy];
    [self friendsListSort];
    
    [LGNetWorking getFriendsList:USERINFO.sessionId friendType:FriendTypeFriends success:^(ResponseData *responseData) {

        self.friends = [ZhiMaFriendModel mj_objectArrayWithKeyValuesArray:responseData.data];
        
        //更新数据库，然后刷新列表
        if ([FMDBShareManager saveUserMessageWithMessageArray:self.friends]) {
            NSLog(@"好友列表插入数据库成功");
            [self friendsListSort];
        }else{
            NSLog(@"好友列表插入数据库成功");
        }
        
    } failure:^(ErrorData *error) {
        [LCProgressHUD showFailureText:@"网络好像有点差哦[^_^]"];
    }];
}

- (void)clearAllArray{
    [self.friends removeAllObjects];
    [self.sectionsArr removeAllObjects];
    [self.friendsAfterSort removeAllObjects];
    [self.countOfSectionArr removeAllObjects];
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
//    self.friendsAfterSort = self.friends;
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
//            [self.sectionsArr addObject:friend.headchar];
            //如果只有一个好友
            if (self.friendsAfterSort.count == 1) {
                [self.countOfSectionArr addObject:@(1)];
            }
        }
        
        if (i < self.friendsAfterSort.count - 1) {
            //取到第二条数据，与第一条数据首字母比较
            ZhiMaFriendModel *friend1 = self.friendsAfterSort[i+1];

//            ![friend1.headchar isEqualToString:friend.headchar]
            if (pinyinFirstLetter([friend1.pinyin characterAtIndex:0]) != pinyinFirstLetter([friend.pinyin characterAtIndex:0])) {
                
                NSString *numStr = [NSString stringWithFormat:@"%d",num + 1];
                [self.countOfSectionArr addObject:numStr];
                
                ////最后一条数据 -> 将最后一组数据个数插入
                if (i == self.friendsAfterSort.count - 2) {
                    [self.countOfSectionArr addObject:@(1)];
                }
                
                NSString *str = [NSString stringWithFormat:@"%c",pinyinFirstLetter([friend1.pinyin characterAtIndex:0])];
                [self.sectionsArr addObject:[str uppercaseString]];
//                [self.sectionsArr addObject:friend1.headchar];
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

/**
 *  收到好友请求  -- 显示未读请求消息条数
 *
 *  @param notify 好友信息字典
 */
- (void)recieveFriendRequest:(NSNotification *)notify{
    //本地存储好友请求数量
    UserInfo *userInfo = [UserInfo read];
    userInfo.unReadCount ++;
    [userInfo save];
    
    NSDictionary *userDic = notify.userInfo;
    ZhiMaFriendModel *friend = userDic[@"friend"];
    //插入数据库，显示未读角标
    [FMDBShareManager upDataNewFriendsMessageByFriendModel:friend];
    
    self.unReadLabel.text = [NSString stringWithFormat:@"%d",USERINFO.unReadCount];
    if (USERINFO.unReadCount == 0) {
        self.unReadLabel.hidden = YES;
    }
}

#pragma mark - tableview 代理
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.sectionsArr.count + 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return 2;
    }else{
        //取到是哪一组，返回该数组中的个数
        return [[self.countOfSectionArr objectAtIndex:section - 1] integerValue];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    //组一：新的好友 群组
    FriendsListCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            cell.name.text = @"新的朋友";
            cell.avtar.image = [UIImage imageNamed:@"new_friend"];
            [cell addSubview:self.unReadLabel];
        }else{
            cell.name.text = @"群聊";
            cell.avtar.image = [UIImage imageNamed:@"group_Icon"];
        }
    //好友列表
    }else{
        NSInteger rowNum = 0;
        for (int i = 0; i < indexPath.section - 1; i++) {
            
            rowNum = [[self.countOfSectionArr objectAtIndex:i] intValue] + rowNum;
        }
        rowNum += indexPath.row;
        
        ZhiMaFriendModel *friend = self.friendsAfterSort[rowNum];
        cell.friendModel = friend;
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
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
    return self.sectionsArr;
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

#pragma mark - tableview 点击方法
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {   //新的朋友
            NewFriendsListController *vc = [[NewFriendsListController alloc] init];
            vc.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:vc animated:YES];
            
            //清除新朋友请求角标
            UserInfo *userInfo = [UserInfo read];
            userInfo.unReadCount = 0;
            [userInfo save];
            self.unReadLabel.hidden = YES;
        }else if (indexPath.row == 1){  //群组
            GroupChatListController *vc = [[GroupChatListController alloc] init];
            vc.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:vc animated:YES];
        }
    }else{  //跳转到聊天
        NSInteger rowNum = 0;
        for (int i = 0; i < indexPath.section - 1; i++) {
            
            rowNum = [[self.countOfSectionArr objectAtIndex:i] intValue] + rowNum;
        }
        rowNum += indexPath.row;
        
        ZhiMaFriendModel *friend = self.friendsAfterSort[rowNum];
//        ChatController *chatVC = [[ChatController alloc] init];
//        chatVC.conversionId = friend.user_Id;
//        chatVC.conversionName = friend.displayName;
        
        FriendProfilecontroller *vc = [[FriendProfilecontroller alloc] init];
        vc.userId = friend.user_Id;
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];

    }
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

- (UILabel *)unReadLabel{
    if (!_unReadLabel) {
        _unReadLabel = [[UILabel alloc] initWithFrame:CGRectMake(46, 2, 16, 16)];
        _unReadLabel.textColor = WHITECOLOR;
        _unReadLabel.font = [UIFont systemFontOfSize:14];
        _unReadLabel.textAlignment = NSTextAlignmentCenter;
        _unReadLabel.backgroundColor = THEMECOLOR;
        _unReadLabel.layer.cornerRadius = 8.0f;
        _unReadLabel.clipsToBounds = YES;
        _unReadLabel.hidden = YES;

    }
    return _unReadLabel;
}
@end
