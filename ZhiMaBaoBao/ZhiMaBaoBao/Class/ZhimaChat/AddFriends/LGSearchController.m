//
//  LGSearchController.m
//  YiIM_iOS
//
//  Created by liugang on 16/8/11.
//  Copyright © 2016年 ikantech. All rights reserved.
//  搜索好友

#import "LGSearchController.h"
#import "LGSearchResultController.h"
#import "LGSearchResultCell.h"
#import "pinyin.h"
#import "ZhiMaFriendModel.h"
#import "AvtarAndNameCell.h"
#import "ChatController.h"

@interface LGSearchController ()<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate>

@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) NSMutableArray *containArray;     //拷贝一份数据源，用作搜索匹配
@end

static NSString *const reuseIdentifier = @"searchResultCell";
@implementation LGSearchController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.hidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated{
    self.navigationController.navigationBar.hidden = NO;

}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = WHITECOLOR;
    [self setUI];
    [self getDataFormSqlist];
    [self.view becomeFirstResponder];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChanged) name:UITextFieldTextDidChangeNotification object:nil];
}

//设置UI
- (void)setUI{
    UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0, 20, DEVICEWITH, 50)];
    topView.backgroundColor = BGCOLOR;
    [self.view addSubview:topView];
    
    UIView *whiteView = [[UIView alloc] initWithFrame:CGRectMake(14, 10, DEVICEWITH - 70, 30)];
    whiteView.backgroundColor = WHITECOLOR;
    whiteView.layer.cornerRadius = 5;
    [topView addSubview:whiteView];
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    [btn setImage:[UIImage imageNamed:@"lsearch"] forState:UIControlStateNormal];
    [whiteView addSubview:btn];
    [btn addTarget:self action:@selector(searchAction) forControlEvents:UIControlEventTouchUpInside];
    
    UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(41, 0, DEVICEWITH - 80, 30)];
    textField.borderStyle = UITextBorderStyleNone;
    textField.font = MAINFONT;
    [whiteView addSubview:textField];
    textField.delegate = self;
    self.textField = textField;
    
    //取消按钮
    UIButton *cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(DEVICEWITH - 55, 5, 50, 40)];
    [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    [cancelBtn setTitleColor:THEMECOLOR forState:UIControlStateNormal];
    [topView addSubview:cancelBtn];
    [cancelBtn addTarget:self action:@selector(cancelAction) forControlEvents:UIControlEventTouchUpInside];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 70, DEVICEWITH, DEVICEHIGHT - 70) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.tableView.backgroundColor = WHITECOLOR;
    [self.tableView registerNib:[UINib nibWithNibName:@"AvtarAndNameCell" bundle:nil] forCellReuseIdentifier:reuseIdentifier];
    [self.view addSubview:self.tableView];
}

//从数据库获取好友列表
- (void)getDataFormSqlist {
    
    self.containArray = [[FMDBShareManager getAllUserMessageInArray] mutableCopy];
}


#pragma mark - tableView delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return self.dataArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    AvtarAndNameCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    ZhiMaFriendModel *friendModel = self.dataArray[indexPath.row];
    cell.friendModel = friendModel;
    cell.bottomLineView.hidden = YES;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    ZhiMaFriendModel *friendModel = self.dataArray[indexPath.row];

    //跳转到聊天
    [self dismissViewControllerAnimated:NO completion:nil];
    UserInfo *userinfo = [UserInfo shareInstance];
    userinfo.mainVC.selectedViewController = userinfo.mainVC.viewControllers[0];
    
    ChatController *vc = [[ChatController alloc] init];
    vc.conversionId = friendModel.user_Id;
    vc.conversionName = friendModel.displayName;
    vc.converseLogo = friendModel.head_photo;
    vc.hidesBottomBarWhenPushed = YES;
    ConversationController *conversationVC = userinfo.conversationVC;
    [conversationVC.navigationController pushViewController:vc animated:YES];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 53;
}

#pragma mark - 功能实现方法
//搜索框匹配
- (void)textChanged{
    [self.dataArray removeAllObjects];
    if (!self.textField.hasText) {
        [self.dataArray removeAllObjects];
    }else{
        for (ZhiMaFriendModel *friendModel in self.containArray) {
            if ([friendModel.displayName containsString:self.textField.text] || [friendModel.pinyin containsString:[self.textField.text uppercaseString]]) {
                [self.dataArray addObject:friendModel];
            }
        }
    }
    [self.tableView reloadData];
}

//搜索好友
- (void)searchAction{
    
}

//好友排序
- (void)setSequenceOfAgentName{
    
    
}

- (void)cancelAction{
    [self dismissViewControllerAnimated:NO completion:nil];
}


#pragma mark - lazy
- (NSMutableArray *)dataArray{
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

- (NSMutableArray *)containArray{
    if (!_containArray) {
        _containArray = [NSMutableArray array];
    }
    return _containArray;
}
@end
