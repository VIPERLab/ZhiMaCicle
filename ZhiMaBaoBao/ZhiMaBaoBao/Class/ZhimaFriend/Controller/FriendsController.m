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

@interface FriendsController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *friends;              //好友列表数组
@property (nonatomic, strong) NSMutableArray *friendsAfterSort;     //排序后的好友列表数组
@property (nonatomic, strong) NSMutableArray *sectionsArr;             //排序后好友名称首字母
@property (nonatomic, strong) NSMutableArray *countOfSectionArr;       //每组的好友个数
@end

@implementation FriendsController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setCustomRightItems];

    [self requestFriendsList];
    [self addSubviews];
}
//请求好友列表
- (void)requestFriendsList{
    //先从数据库拉取好友列表，没有数据则从网络请求
    self.friends = [[FMDBShareManager getAllUserMessageInArray] mutableCopy];
    [self friendsListSort];
    if (!self.friends.count) {
        [LGNetWorking getFriendsList:USERINFO.sessionId friendType:FriendTypeFriends success:^(ResponseData *responseData) {
            self.friends = [ZhiMaFriendModel mj_objectArrayWithKeyValuesArray:responseData.data];
            [self friendsAfterSort];
            //将拉取的好友列表插入数据库
            if ([FMDBShareManager saveUserMessageWithMessageArray:self.friends]) {
                NSLog(@"好友列表插入数据库成功");
            }else{
                NSLog(@"好友列表插入数据库成功");
            }
            
        } failure:^(ErrorData *error) {
            [LCProgressHUD showFailureText:@"网络好像有点差哦[^_^]"];
        }];
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
        }
        
        if (i < self.friendsAfterSort.count - 1) {
            //取到第二条数据，与第一条数据首字母比较
            ZhiMaFriendModel *friend1 = self.friendsAfterSort[i+1];

            if (pinyinFirstLetter([friend1.pinyin characterAtIndex:0]) != pinyinFirstLetter([friend.pinyin characterAtIndex:0])) {
                
                NSString *numStr = [NSString stringWithFormat:@"%d",num + 1];
                [self.countOfSectionArr addObject:numStr];
                
                NSString *str = [NSString stringWithFormat:@"%c",pinyinFirstLetter([friend1.pinyin characterAtIndex:0])];
                [self.sectionsArr addObject:[str uppercaseString]];
                num = 0;
            }
            else{
                
                num ++;
            }
        }
    }

}

#pragma mark - tableview delegate


- (void)addSubviews{
    UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
//    tableView.delegate = self;
//    tableView.dataSource = self;
    [self.view addSubview:tableView];
    self.tableView = tableView;
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
@end
