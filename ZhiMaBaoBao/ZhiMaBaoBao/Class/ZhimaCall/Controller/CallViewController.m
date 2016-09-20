//
//  CallViewController.m
//  ZhiMaBaoBao
//
//  Created by liugang on 16/9/18.
//  Copyright © 2016年 liugang. All rights reserved.
//  芝麻通


#define KeyboardHeight 247  //拨号键盘高度
#define TabbarHeight 49     //系统Tabbar高度

#import "CallViewController.h"
#import "PhoneAddressController.h"
#import "YiKeyBoardView.h"
#import "LGCallRecordCell.h"
#import "PhoneContactCell.h"
#import "CallBottombar.h"

@interface CallViewController ()<UITableViewDelegate,UITableViewDataSource,YiKeyBoardViewDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) YiKeyBoardView *keyboardView; //拨号键盘
@property (nonatomic, strong) NSMutableArray *dataArr;      //数据源数组
@property (nonatomic, strong) NSMutableArray *matchArr;     //联系人匹配结果数组
@property (nonatomic, strong) NSMutableArray *contactsArr;  //筛选结果数组

@property (nonatomic, strong) UITextField *saveField;       //保存titleview
@property (nonatomic, strong) UILabel *titleLabel;          //导航栏titleView
@property (nonatomic, assign) NSInteger selectRow;          //点击行
@property (nonatomic, assign) BOOL matchTable;              //标记是否在匹配通讯录 （切换cell）
@property (nonatomic, assign) BOOL hasAmount;               //有余额

@property (nonatomic, strong) CallBottombar *callBar;       //拨号低栏
@end

@implementation CallViewController
static NSString * const reuseIdentifier = @"LGCallRecordCell";
static NSString * const phoneContactIdenty = @"PhoneContactCell";


- (void)viewDidLoad {
    [super viewDidLoad];
    [self addSubViews];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //请求通话记录
    if (!self.matchTable) {
        [self requestCallRecords];
    }
}

- (void)addSubViews{
    self.view.backgroundColor = BGCOLOR;
    self.navigationItem.titleView = self.titleLabel;
    //通讯录按钮
    UIButton *addressBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0 , 60, 30)];
    [addressBtn setTitle:@"通讯录" forState:UIControlStateNormal];
    [addressBtn setTitleColor:THEMECOLOR forState:UIControlStateNormal];
    addressBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [addressBtn addTarget:self action:@selector(jumpToAddress) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:addressBtn];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, DEVICEWITH, DEVICEHIGHT - KeyboardHeight*SCLACEW - TabbarHeight) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerNib:[UINib nibWithNibName:@"LGCallRecordCell" bundle:nil] forCellReuseIdentifier:reuseIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:@"PhoneContactCell" bundle:nil] forCellReuseIdentifier:phoneContactIdenty];
    [self.view addSubview:self.tableView];
    self.tableView.backgroundColor = [UIColor redColor];
    
    //拨号键盘
    YiKeyBoardView *keyboardView = [YiKeyBoardView keyBoardView];
    keyboardView.frame = CGRectMake(0, DEVICEHIGHT - KeyboardHeight*SCLACEW - TabbarHeight, DEVICEWITH, KeyboardHeight*SCLACEW);
    keyboardView.delegate = self;
    [self.view addSubview:keyboardView];
    self.keyboardView = keyboardView;
    
    //初始化拨号底栏
    self.callBar = [CallBottombar shareinstance];
    
    //拨号输入监听
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(inputTextFieldValueChanged:) name:@"TextFieldValueChanged" object:nil];

}

//请求通话记录
- (void)requestCallRecords{
    if (self.dataArr) {
        [self.dataArr removeAllObjects];
    }
    
    [LGNetWorking getAllCallRecords:USERINFO.sessionId block:^(ResponseData *responseData) {
        if (responseData.code == 0) {
            self.dataArr = [LGCallRecordModel mj_objectArrayWithKeyValuesArray:responseData.data];
            [self.tableView reloadData];
        }else{
            [LCProgressHUD showText:responseData.msg];
        }
    }];

}

#pragma mark - tableview代理方法
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    LGCallRecordCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (indexPath.row < self.dataArr.count) {
        cell.model = self.dataArr[indexPath.row];
    }
    return cell;
}

//拨号输入监听
- (void)inputTextFieldValueChanged:(NSNotification *)notis {
    
    NSString * phoneText = self.keyboardView.numberTextField.text;
    //有输入，弹出拨号工具条，
    if (phoneText.length >0) {
        
        [self.callBar show];
        self.titleLabel.text = phoneText;
        //            self.navigationItem.titleView = self.titleLabel;
        
    }else if (phoneText.length<1) {
        
        [self.callBar dismiss];
        self.titleLabel.text = @"拨打";
        //            self.navigationItem.titleView = self.titleLabel;
    }

#warning TODO: 匹配联系人
    /*
    if (self.dataArr) {
        [self.dataArr removeAllObjects];
    }
    
    if (!self.tempField.hasText) {
        self.dataArr = [NSMutableArray arrayWithArray:self.matchArr];
        self.matchTable = NO;
    }else{
        for (PhoneContact *contact in self.contactsArr) {
            if ([contact.phoneNumber containsString:self.tempField.text]) {
                [self.dataArr addObject:contact];
            }
        }
        self.matchTable = YES;
    }
    [self.tableView reloadData];
     */
    
}


//跳转到通讯录
- (void)jumpToAddress{
    PhoneAddressController *vc = [[PhoneAddressController alloc] init];
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - lazy
- (NSMutableArray *)contactsArr{
    if (!_contactsArr) {
        _contactsArr = [NSMutableArray array];
    }
    return _contactsArr;
}

- (NSMutableArray *)matchArr{
    if (!_matchArr) {
        _matchArr = [NSMutableArray array];
    }
    return _matchArr;
}

- (NSMutableArray *)dataArr{
    if (!_dataArr) {
        _dataArr = [NSMutableArray array];
    }
    return _dataArr;
}

- (UILabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 150, 40)];
        _titleLabel.text = @"拨打";
        _titleLabel.textColor = THEMECOLOR;
        _titleLabel.font = [UIFont systemFontOfSize:17];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _titleLabel;
}

@end
