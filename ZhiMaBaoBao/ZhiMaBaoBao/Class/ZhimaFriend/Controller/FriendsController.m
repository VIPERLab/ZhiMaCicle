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
#import "PhoneAddressController.h"
#import <AudioToolbox/AudioToolbox.h>
#import "ConverseModel.h"
#import "JFMyPlayerSound.h"
#import "RBDMuteSwitch.h"

@interface FriendsController ()<UITableViewDelegate,UITableViewDataSource,RBDMuteSwitchDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *friends;              //好友列表数组
@property (atomic, strong) NSMutableArray *friendsAfterSort;     //排序后的好友列表数组
@property (atomic, strong) NSMutableArray *sectionsArr;             //排序后好友名称首字母
@property (atomic, strong) NSMutableArray *countOfSectionArr;       //每组的好友个数

@property (nonatomic, strong) UILabel *unReadLabel;     //未读好友请求角标
@property (nonatomic, strong) NSMutableArray *nFriends;   //存放新的好友数组

@property(nonatomic,strong)JFMyPlayerSound *myPlaySounde;   //播放系统声音


@end

static NSString * const reuseIdentifier = @"friendListcell";
static NSString * const headerIdentifier = @"headerIdentifier";
@implementation FriendsController {
    dispatch_queue_t _updataQueue; //刷新队列
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setCustomRightItems];
    [self addSubviews];
    [self requestFriendsList];
    
    //创建串行队列
    _updataQueue =  dispatch_queue_create("upDataUserQueue", DISPATCH_QUEUE_SERIAL);
    
    
    
    //监听新的好友请求消息
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recieveFriendRequest:) name:kNewFriendRequest object:nil];
    //我发送的好友请求对方已经同意
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(requestHasAgreed) name:kOtherAgreeMyFrendRequest object:nil];
}


- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self getDataFormSQL];
}

- (void)viewDidAppear:(BOOL)animated {
    
}


- (void)viewDidDisappear:(BOOL)animated{
    [self.nFriends removeAllObjects];
}

- (void)addSubviews{
    UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.sectionIndexColor = RGB(54, 54, 54);
    tableView.sectionIndexBackgroundColor = [UIColor clearColor];
    [tableView registerNib:[UINib nibWithNibName:@"FriendsListCell" bundle:nil] forCellReuseIdentifier:reuseIdentifier];
    [tableView registerNib:[UINib nibWithNibName:@"FriendsListCell" bundle:nil] forCellReuseIdentifier:headerIdentifier];
    [self.view addSubview:tableView];
    self.tableView = tableView;
}

- (void)getDataFormSQL {
    self.friends = [[FMDBShareManager getAllUserMessageInArray] mutableCopy];
    [self.tableView reloadData];
    
    
    [self requestFriendsList];
    
}

//请求好友列表
- (void)requestFriendsList{
//    [self clearAllArray];
    
    
    NSLog(@"--%@",[NSThread currentThread]);
    [LGNetWorking getFriendsList:USERINFO.sessionId friendType:FriendTypeFriends success:^(ResponseData *responseData) {

        self.friends = [ZhiMaFriendModel mj_objectArrayWithKeyValuesArray:responseData.data];
        //刷新tableview
        [self friendsListSort];
        
        if (!self.friends.count) {
            return ;
        }
        
        dispatch_async(_updataQueue, ^{
            [FMDBShareManager deletedAllUserMessage];
            [FMDBShareManager saveUserMessageWithMessageArray:self.friends withComplationBlock:nil andIsUpdata:NO];
                
            NSLog(@"------ chaxun333  %@",[NSThread currentThread]);

            //更新会话表用户头像和昵称
            NSArray *allConversions = [FMDBShareManager getChatConverseDataInArray];
            //1.取出所有单聊的会话
            NSMutableArray *singleConversions = [NSMutableArray array];
            for (ConverseModel *model in allConversions) {
                if (!model.converseType) {
                    [singleConversions addObject:model];
                }
            }
        });
            /*
            //2.更新单聊所有单聊会话的用户头像和昵称
            for (ConverseModel *model in singleConversions) {
                ZhiMaFriendModel *mFriend = nil;
                //遍历好友数组，取出对应id的好友模型
                for (ZhiMaFriendModel *friend in self.friends) {
                    if ([model.converseId isEqualToString:friend.user_Id]) {
                        mFriend = friend;
                        break;
                    }
                }
                
                //如果查到了好友数据，则更新会话列表
                if (mFriend) {
                    NSLog(@"------ 更新  %@",[NSThread currentThread]);

                    //更新数据库会话表
                    FMDatabaseQueue *queue = [FMDBShareManager getQueueWithType:ZhiMa_Chat_Converse_Table];
                    NSString *optionStr1 = [NSString stringWithFormat:@"converseLogo = '%@',converseName = '%@'",mFriend.user_Head_photo,mFriend.displayName];
                    NSString *upDataStr = [FMDBShareManager alterTable:ZhiMa_Chat_Converse_Table withOpton1:optionStr1 andOption2:[NSString stringWithFormat:@"converseId = '%@'",model.converseId]];
                    [queue inDatabase:^(FMDatabase *db) {
                        [db executeUpdate:upDataStr];
                    }];
                }
             
                
            }
             */
        
        
    } failure:^(ErrorData *error) {

    }];
}

- (void)clearAllArray{
    [self.friends removeAllObjects];
    [self.sectionsArr removeAllObjects];
    //拼音相关
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
    
    //记录新的好友请求。 判断如果是重复好友请求 则直接跳过不处理
    ZhiMaFriendModel *neewFriend = notify.userInfo[@"friend"];

    for (NSString *uid in self.nFriends) {
        if ([neewFriend.user_Id isEqualToString:uid]) {
            return;
        }
    }
    
    // 如果已经在好友列表内，则不显示新好友请求
    for (ZhiMaFriendModel *model in self.friends) {
        if ([neewFriend.user_Id isEqualToString:model.user_Id]) {
            //直接系统同意他的好友请求，并且不显示新的好友请求提示
//            [[SocketManager shareInstance] agreeFriendRequest:neewFriend.user_Id];
            return;
        }
    }
    
    
    [self.nFriends addObject:neewFriend.user_Id];
    
    //播放系统声音
    [[RBDMuteSwitch sharedInstance] setDelegate:self];
    [[RBDMuteSwitch sharedInstance] detectMuteSwitch];
    
    //本地存储好友请求数量
    UserInfo *userInfo = [UserInfo read];
    userInfo.unReadCount ++;
    [userInfo save];
    
    //插入数据库，显示未读角标
    self.unReadLabel.hidden = NO;
    self.unReadLabel.text = [NSString stringWithFormat:@"%d",USERINFO.unReadCount];
    if (USERINFO.unReadCount == 0) {
        self.unReadLabel.hidden = YES;
    }
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    
    
    //显示tabbar角标
    //tabbar显示所有未读消息条数
    if (USERINFO.unReadCount > 99) {
        [[self.tabBarController.tabBar.items objectAtIndex:1] setBadgeValue:@"99+"];
        
    }else if(USERINFO.unReadCount > 0){
        [[self.tabBarController.tabBar.items objectAtIndex:1] setBadgeValue:[NSString stringWithFormat:@"%ld", (long)USERINFO.unReadCount]];
    }else {
        [[self.tabBarController.tabBar.items objectAtIndex:1] setBadgeValue:nil];
    }
}

//对方同意我的好友请求。网络加载数据，刷新表
- (void)requestHasAgreed{
    [LGNetWorking getFriendsList:USERINFO.sessionId friendType:FriendTypeFriends success:^(ResponseData *responseData) {
        
        self.friends = [ZhiMaFriendModel mj_objectArrayWithKeyValuesArray:responseData.data];
        
        //更新数据库，然后刷新列表
        [FMDBShareManager saveUserMessageWithMessageArray:self.friends withComplationBlock:nil andIsUpdata:YES];

        [self friendsListSort];

    } failure:^(ErrorData *error) {
        [LCProgressHUD showFailureText:error.msg];
    }];
}

#pragma mark - tableview 代理
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.sectionsArr.count + 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return 3;
    }else{
        //取到是哪一组，返回该数组中的个数
        return [[self.countOfSectionArr objectAtIndex:section - 1] integerValue];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    //组一：新的好友 群组
    if (indexPath.section == 0) {
        FriendsListCell *cell = [tableView dequeueReusableCellWithIdentifier:headerIdentifier];

        if (indexPath.row == 0) {
            cell.name.text = @"手机联系人";
            cell.avtar.image = [UIImage imageNamed:@"phoneFriend"];
            cell.unreadLabel.hidden = YES;
            
        }else if (indexPath.row == 1) {
            cell.name.text = @"新的朋友";
            cell.avtar.image = [UIImage imageNamed:@"new_friend"];
            if (USERINFO.unReadCount > 0) {
                cell.unreadLabel.text = [NSString stringWithFormat:@"%d",USERINFO.unReadCount];
                cell.unreadLabel.hidden = NO;
            }else{
                cell.unreadLabel.hidden = YES;
            }
        }else{
            cell.name.text = @"群聊";
            cell.avtar.image = [UIImage imageNamed:@"group_Icon"];
            cell.unreadLabel.hidden = YES;
        }
        return cell;
    //好友列表
    }else{
        FriendsListCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
        cell.unreadLabel.hidden = YES;
        NSInteger rowNum = 0;
        for (int i = 0; i < indexPath.section - 1; i++) {
            
            rowNum = [[self.countOfSectionArr objectAtIndex:i] intValue] + rowNum;
        }
        rowNum += indexPath.row;
        
        ZhiMaFriendModel *friend = self.friendsAfterSort[rowNum];
        cell.friendModel = friend;
        return cell;
    }
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
        headerView.backgroundColor = self.tableView.backgroundColor;
        
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
        if (indexPath.row == 0) { //手机联系人
            //跳转到添加手机联系人页面
            PhoneAddressController *vc = [[PhoneAddressController alloc] init];
            vc.isAddPhoneFriend = YES;
            vc.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:vc animated:YES];
            
        }else if (indexPath.row == 1){  //新的朋友
            
            NewFriendsListController *vc = [[NewFriendsListController alloc] init];
            vc.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:vc animated:YES];
            
            //清除新朋友请求角标
            UserInfo *userInfo = [UserInfo read];
            userInfo.unReadCount = 0;
            [userInfo save];
            self.unReadLabel.hidden = YES;
            [[self.tabBarController.tabBar.items objectAtIndex:1] setBadgeValue:nil];
            
        }else if (indexPath.row == 2){  //群组
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

//播放系统声音
- (void)isMuted:(BOOL)muted{
    if (muted) {
        //开启静音模式
        self.myPlaySounde = [[JFMyPlayerSound alloc] initSystemShake];
    }else{
        //关闭静音模式
        self.myPlaySounde = [[JFMyPlayerSound alloc] initSystemSoundWithName:@"sms-received1" SoundType:@"caf"];
    }
    
    if (USERINFO.newMessageNotify) {
        if (USERINFO.newMessageVoiceNotify) {
            if (USERINFO.newMessageShakeNotify) {   //声音跟振动
                if (muted) {
                    [self.myPlaySounde play];
                }else{
                    [self.myPlaySounde play];
                    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
                }
            }else{  //只有声音
                [self.myPlaySounde play];
            }
        }else{
            if (USERINFO.newMessageShakeNotify) {   //只有振动提醒
                AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
            }
        }
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

- (NSMutableArray *)nFriends{
    if (!_nFriends) {
        _nFriends = [NSMutableArray array];
    }
    return _nFriends;
}

@end
