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
#import "LGCallingController.h"
#import "PhoneContact.h"
#import "LGPhoneContactInfoController.h"
#import "CallSettingController.h"
#import "CallKeyboardController.h"
#import <AddressBookUI/ABPeoplePickerNavigationController.h>
#import <AddressBook/ABPerson.h>
#import <AddressBookUI/ABPersonViewController.h>
#import "POP.h"

@interface CallViewController ()<UITableViewDelegate,UITableViewDataSource,YiKeyBoardViewDelegate,CallBarDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) YiKeyBoardView *keyboardView; //拨号键盘
@property (nonatomic, strong) NSMutableArray *dataArr;      //数据源数组
@property (nonatomic, strong) NSMutableArray *matchArr;     //通话记录
@property (nonatomic, strong) NSMutableArray *contactsArr;  //筛选结果数组

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
    //获取通讯录联系人
    [self getContacts];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //请求通话记录
    [self requestCallRecords];

}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    //清空输入号码，移除拨号底栏
    self.keyboardView.numberTextField.text = @"";
    [self.callBar dismiss];
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
    

    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, DEVICEWITH, DEVICEHIGHT - KeyboardHeight*SCLACEW - TabbarHeight - 64) style:UITableViewStylePlain];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerNib:[UINib nibWithNibName:@"LGCallRecordCell" bundle:nil] forCellReuseIdentifier:reuseIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:@"PhoneContactCell" bundle:nil] forCellReuseIdentifier:phoneContactIdenty];
    [self.view addSubview:self.tableView];
    self.tableView.backgroundColor = BGCOLOR;
    
    //拨号键盘
    YiKeyBoardView *keyboardView = [YiKeyBoardView keyBoardView];
    keyboardView.frame = CGRectMake(0, DEVICEHIGHT - KeyboardHeight*SCLACEW - TabbarHeight, DEVICEWITH, KeyboardHeight*SCLACEW);
    keyboardView.delegate = self;
    [self.view addSubview:keyboardView];
    self.keyboardView = keyboardView;
    
    //初始化拨号底栏
    self.callBar = [CallBottombar shareinstance];
    self.callBar.delegate = self;
    
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
            //拷贝一份通话记录数据
            self.matchArr = [NSMutableArray arrayWithArray:self.dataArr];
            [self.tableView reloadData];
        }else{
            [LCProgressHUD showText:responseData.msg];
        }
    }];

}

//获取通讯录联系人
- (void)getContacts{
    //这个变量用于记录授权是否成功，即用户是否允许我们访问通讯录
    int __block tip=0;
    //声明一个通讯簿的引用
    ABAddressBookRef addBook =nil;
    //因为在IOS6.0之后和之前的权限申请方式有所差别，这里做个判断
    if ([[UIDevice currentDevice].systemVersion floatValue]>=6.0) {
        //创建通讯簿的引用
        addBook=ABAddressBookCreateWithOptions(NULL, NULL);
        //创建一个出事信号量为0的信号
        dispatch_semaphore_t sema=dispatch_semaphore_create(0);
        //申请访问权限
        ABAddressBookRequestAccessWithCompletion(addBook, ^(bool greanted, CFErrorRef error)        {
            //greanted为YES是表示用户允许，否则为不允许
            if (!greanted) {
                tip=1;
            }
            //发送一次信号
            dispatch_semaphore_signal(sema);
        });
        //等待信号触发
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    }else{
        //IOS6之前
        addBook =ABAddressBookCreate();
    }
    if (tip) {
        //做一个友好的提示
        UIAlertView * alart = [[UIAlertView alloc]initWithTitle:@"温馨提示" message:@"请您设置允许APP访问您的通讯录\nSettings>General>Privacy" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alart show];
        return;
    }
    
    //获取所有联系人的数组
    CFArrayRef allLinkPeople = ABAddressBookCopyArrayOfAllPeople(addBook);
    //获取联系人总数
    CFIndex number = ABAddressBookGetPersonCount(addBook);
    
    //进行遍历
    for (NSInteger i=0; i<number; i++) {
        //联系人数据模型
        PhoneContact *contact = [[PhoneContact alloc] init];
        
        //获取联系人对象的引用
        ABRecordRef  people = CFArrayGetValueAtIndex(allLinkPeople, i);
        //获取当前联系人名字
        NSString *firstName=(__bridge NSString *)(ABRecordCopyValue(people, kABPersonFirstNameProperty));
        //获取当前联系人姓氏
        NSString *lastName=(__bridge NSString *)(ABRecordCopyValue(people, kABPersonLastNameProperty));
        //获取当前联系人中间名
        NSString *middleName=(__bridge NSString*)(ABRecordCopyValue(people, kABPersonMiddleNameProperty));
        //获取当前联系人的姓氏拼音
        NSString *lastNamePhoneic=(__bridge NSString*)(ABRecordCopyValue(people, kABPersonLastNamePhoneticProperty));
        //获取当前联系人的电话 数组 默认取第一个
        ABMultiValueRef phones = ABRecordCopyValue(people, kABPersonPhoneProperty);
        NSString *phoneNumber = (__bridge NSString *)(ABMultiValueCopyValueAtIndex(phones, 0));
        
        NSMutableArray * phoneArr = [[NSMutableArray alloc]init];
        for (NSInteger j=0; j<ABMultiValueGetCount(phones); j++) {
            NSString *phone = (__bridge NSString *)(ABMultiValueCopyValueAtIndex(phones, j));
            //去掉电话号码格式化字符
            //去除数字以外的所有字符
            NSCharacterSet *setToRemove = [[ NSCharacterSet characterSetWithCharactersInString:@"0123456789"]
                                           invertedSet ];
            NSString *strPhone = [[phone componentsSeparatedByCharactersInSet:setToRemove] componentsJoinedByString:@""];
            if ([strPhone hasPrefix:@"86"]) {
                strPhone = [strPhone substringWithRange:NSMakeRange(2, strPhone.length - 2)];
            }
            
            [phoneArr addObject:strPhone];
        }
        //获取当前联系人头像图片
        NSData *userImage=(__bridge NSData*)(ABPersonCopyImageData(people));
        
        //拼接姓名
        NSString *name = @"";
        if (lastName.length) {
            name = lastName;
            if (middleName.length) {
                name = [NSString stringWithFormat:@"%@%@",name,middleName];
            }
            if (firstName.length) {
                name = [NSString stringWithFormat:@"%@%@",name,firstName];
            }
        }else{
            if (middleName.length) {
                name = middleName;
                if (firstName.length) {
                    name = [NSString stringWithFormat:@"%@%@",name,firstName];
                }
            }else{
                if (firstName.length) {
                    name = firstName;
                }else{
                    name = @"未命名";
                }
            }
            
        }
        
        //去除数字以外的所有字符
        NSCharacterSet *setToRemove = [[ NSCharacterSet characterSetWithCharactersInString:@"0123456789"]
                                       invertedSet ];
        NSString *strPhone = [[phoneNumber componentsSeparatedByCharactersInSet:setToRemove] componentsJoinedByString:@""];
        if ([strPhone hasPrefix:@"86"]) {
            strPhone = [strPhone substringWithRange:NSMakeRange(2, strPhone.length - 2)];
        }
        
        contact.name = name;
        contact.phoneNumber = strPhone;
        contact.pinyin = lastNamePhoneic;
        contact.avtar = userImage;
        contact.allPhones = [NSArray arrayWithArray:phoneArr];
        
        [self.contactsArr addObject:contact];
        
    }
    
}


#pragma mark - tableview代理方法
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    //搜索栏输入，联系人展示匹配联系人单元格
    if (self.matchTable) {
        PhoneContactCell *cell = [tableView dequeueReusableCellWithIdentifier:phoneContactIdenty];
        PhoneContact *contact = self.dataArr[indexPath.row];
        
        cell.backgroundColor = RGB(245, 245, 245);
        cell.name.text = contact.name;
        cell.phoneNumber.text = contact.phoneNumber;
        if (contact.avtar) {
            cell.avtar.image = [UIImage imageWithData:contact.avtar];
        }else{
            cell.avtar.image = [UIImage imageNamed:@"defaultContact"];
        }
        return cell;
    }
    else{
        LGCallRecordCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
        if (indexPath.row < self.dataArr.count) {
            cell.model = self.dataArr[indexPath.row];
        }
        return cell;
    }

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    self.selectRow = indexPath.row;
    
    //搜索匹配tableview --> 跳转到联系人详情页
    if (self.matchTable) {
        LGPhoneContactInfoController *vc = [[LGPhoneContactInfoController alloc] init];
        PhoneContact *contact = self.dataArr[self.selectRow];
        vc.contact = contact;
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
    }
    //通话记录tableview --> 拨打电话
    else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"是否拨打电话？" message:@"" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"拨打", nil];
        [alert show];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.matchTable) {
        return 52;
    }else{
        return 64;
    }
}

//拨号输入监听
- (void)inputTextFieldValueChanged:(NSNotification *)notis {
    
    NSString * phoneText = self.keyboardView.numberTextField.text;
    //有输入，弹出拨号工具条，
    if (phoneText.length >0) {
        
        [self.callBar show];
        self.titleLabel.text = phoneText;
        
    }else if (phoneText.length<1) {
        
        [self.callBar dismiss];
        self.titleLabel.text = @"拨打";
    }

    //匹配联系人
    if (self.dataArr) {
        [self.dataArr removeAllObjects];
    }
    NSString *phoneNumber = self.keyboardView.numberTextField.text;
    if (!phoneNumber.length) {
        self.dataArr = [NSMutableArray arrayWithArray:self.matchArr];
        self.matchTable = NO;
    }else{
        for (PhoneContact *contact in self.contactsArr) {
            if ([contact.phoneNumber containsString:phoneNumber]) {
                [self.dataArr addObject:contact];
            }
        }
        self.matchTable = YES;
    }
    [self.tableView reloadData];
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1) {
        
        //跳转到正在通话页面
        LGCallRecordModel *model = self.dataArr[self.selectRow];
        LGCallingController *vc = [[LGCallingController alloc] init];
        vc.phoneNum = model.to_phone;
        vc.name = model.to_weuser;
        
        if (model.call_type == 2) {
            vc.phoneNum = model.from_phone;
            vc.name = model.from_weuser;
        }
        
        [self presentViewController:vc animated:YES completion:nil];
    }
}


#pragma mark - 拨号栏代理方法
//取消
- (void)cancelCallPhone{
    //清空输入号码，移除拨号底栏
    self.keyboardView.numberTextField.text = @"";
    [self.callBar dismiss];
}
//拨打电话
- (void)callPhone{
    LGCallingController *vc = [[LGCallingController alloc] init];
    vc.phoneNum = self.keyboardView.numberTextField.text;
    [self presentViewController:vc animated:YES completion:nil];
}



//跳转到通讯录
- (void)jumpToAddress{
    PhoneAddressController *vc = [[PhoneAddressController alloc] init];
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
//    CallKeyboardController *vc = [[CallKeyboardController alloc] init];
//    
//    [self presentViewController:vc animated:YES completion:nil];

    
    
}

//跳转到拨号设置
- (void)KeyBoardView:(YiKeyBoardView *)keyboardView settingBtn:(UIButton *)settingBtn{
    CallSettingController *vc = [[CallSettingController alloc] init];
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
