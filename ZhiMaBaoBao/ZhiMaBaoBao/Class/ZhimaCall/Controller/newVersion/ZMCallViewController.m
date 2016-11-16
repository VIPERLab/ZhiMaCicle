//
//  ZMCallViewController.m
//  ZhiMaBaoBao
//
//  Created by ios开发 on 16/10/13.
//  Copyright © 2016年 liugang. All rights reserved.
//


#import "ZMCallViewController.h"
#import "PhoneAddressController.h"
#import "LGPhoneContactInfoController.h"
#import "LGCallingController.h"
#import "ZMCallBoardViewController.h"
#import "LGPhoneContactInfoController.h"

#import "LGCallRecordCell.h"
#import "PhoneContactCell.h"
#import "ZMCallViewCell.h"

#import "PhoneContact.h"
#import "PinYin4Objc.h"

#import <AddressBookUI/ABPeoplePickerNavigationController.h>
#import <AddressBook/ABPerson.h>
#import <AddressBookUI/ABPersonViewController.h>

#import "CallPresendAnimation.h"


@interface ZMCallViewController ()<UITableViewDelegate,UITableViewDataSource,ZMCallCellDelegate,UIViewControllerTransitioningDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataArr;      //数据源数组
@property (nonatomic, strong) NSMutableArray *matchArr;     //通话记录
@property (nonatomic, assign) BOOL matchTable;              //标记是否在匹配通讯录 （切换cell）
@property (nonatomic, assign) NSInteger selectRow;          //点击行

@property (nonatomic, strong) NSMutableArray *contactsArr;  //所有通讯录联系人信息


@end

#define TabbarHeight 49     //系统Tabbar高度

@implementation ZMCallViewController

static NSString * const reuseIdentifier = @"ZMCallViewCell";
static NSString * const phoneContactIdenty = @"PhoneContactCell";

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //请求通话记录
    [self requestCallRecords];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initOthers];
    [self initTableview];
    [self initTableviewHead];
    //获取通讯录联系人
    [self getContacts];
}

#pragma mark - init

- (void)initOthers
{
    [self setNaviTitle:@"拨打"];
    self.dataArr  = [NSMutableArray array];
    self.matchArr = [NSMutableArray array];
    self.contactsArr = [NSMutableArray array];
}

- (void)initTableview
{
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, DEVICEWITH, DEVICEHIGHT-TabbarHeight-64) style:UITableViewStylePlain];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerNib:[UINib nibWithNibName:@"ZMCallViewCell" bundle:nil] forCellReuseIdentifier:reuseIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:@"PhoneContactCell" bundle:nil] forCellReuseIdentifier:phoneContactIdenty];
    [self.view addSubview:self.tableView];
    self.tableView.backgroundColor = WHITECOLOR;
}

- (void)initTableviewHead
{
    CGFloat height = 118;
    UIView*headView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICEWITH, height)];
    headView.backgroundColor = BGCOLOR;//RGB(240, 240, 240);
    for (int i=0; i<2; i++) {
        UIButton*btn  = [[UIButton alloc]initWithFrame:CGRectMake((i+1)*DEVICEWITH/3 - 58/2, (height-78)/2, 58, 58)];
        UILabel*label = [[UILabel alloc]initWithFrame:CGRectMake(btn.frameOriginX-3, btn.frameMaxY+5, 64, 15)];
        label.textColor = htmlColor(@"888888");
        label.textAlignment = 1;
        label.font = [UIFont systemFontOfSize:12];
        switch (i) {
            case 0:
                label.text = @"呼叫联系人";
                [btn setImage:[UIImage imageNamed:@"callAddress"] forState:UIControlStateNormal];
                [btn addTarget:self action:@selector(jumpToAddress) forControlEvents:UIControlEventTouchUpInside];
                break;
            case 1:
                label.text = @"拨号";
                [btn setImage:[UIImage imageNamed:@"jumpToCall"] forState:UIControlStateNormal];
                [btn addTarget:self action:@selector(jumpToCallView) forControlEvents:UIControlEventTouchUpInside];
                break;
            default:
                break;
        }
        [headView addSubview:btn];
        [headView addSubview:label];
    }
    
    UIImageView*lineview = [[UIImageView alloc]initWithFrame:CGRectMake(0, height-0.5, DEVICEWITH, 0.5)];
    lineview.backgroundColor = htmlColor(@"d6d7dc");
    [headView addSubview:lineview];
    
    self.tableView.tableHeaderView = headView;
    
}

#pragma mark - get data

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
        UIAlertView * alart = [[UIAlertView alloc]initWithTitle:@"温馨提示" message:@"请您设置允许APP访问您的通讯录\n设置>芝麻宝宝>通讯录" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
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
        
        
        
        //将姓名转换成拼音
        HanyuPinyinOutputFormat *outputFormat=[[HanyuPinyinOutputFormat alloc] init];
        [outputFormat setToneType:ToneTypeWithoutTone];
        [outputFormat setVCharType:VCharTypeWithV];
        [outputFormat setCaseType:CaseTypeLowercase];
        
        [PinyinHelper toHanyuPinyinStringWithNSString:name withHanyuPinyinOutputFormat:outputFormat withNSString:@"" outputBlock:^(NSString *pinYin) {
            
            contact.pinyin = pinYin;
            [self.contactsArr addObject:contact];
        }];
        
        
        
//        [self.contactsArr addObject:contact];
        
    }
    
}

//请求通话记录
- (void)requestCallRecords{
    if (self.dataArr) {
        [self.dataArr removeAllObjects];
    }

    [LGNetWorking getAllCallRecords:USERINFO.sessionId block:^(ResponseData *responseData) {
        if (responseData.code == 0) {
            self.dataArr = [LGCallRecordModel mj_objectArrayWithKeyValuesArray:responseData.data];
            
            [self fixName];
            
            //拷贝一份通话记录数据
            self.matchArr = [self.dataArr mutableCopy];
            [self.tableView reloadData];
        }else{
            //            [LCProgressHUD showText:responseData.msg];
        }
    }];
    
}

// 获取完列表数据后 去通讯录数组里面匹配，修改对应的名字
- (void)fixName
{
    if (self.contactsArr.count == 0) {
        return;
    }
    
    for (int i=0; i<self.dataArr.count; i++) {
        LGCallRecordModel*model = self.dataArr[i];
        for (PhoneContact *contact in self.contactsArr) {
            //来电
            if (model.call_type == 2) {
                if ([model.from_phone isEqualToString:contact.phoneNumber]) {
                    model.from_weuser = contact.name;
                    break;

                }
            }else if (model.call_type == 1){
                if ([model.to_phone isEqualToString:contact.phoneNumber]) {
                    model.to_weuser = contact.name;
                    break;

                }
            }
        }
    }
}

#pragma mark - action

// 联系人列表
- (void)jumpToAddress
{
    PhoneAddressController *vc = [[PhoneAddressController alloc] init];
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

//拨号界面
- (void)jumpToCallView
{
    ZMCallBoardViewController*callBoardVC = [[ZMCallBoardViewController alloc]init];
    callBoardVC.contactsArr = self.contactsArr;
    
    callBoardVC.transitioningDelegate = self;
    [self presentViewController:callBoardVC animated:YES completion:nil];

}


- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    return [[CallPresendAnimation alloc] init];
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1) {
        
        //跳转到正在通话页面
        LGCallRecordModel *model = self.dataArr[self.selectRow];
        LGCallingController *vc = [[LGCallingController alloc] init];
        vc.phoneNum = model.to_phone;
        vc.name = model.to_weuser;
        
        if (model.call_type == 2 || model.call_type == 3) {
            vc.phoneNum = model.from_phone;
            vc.name = model.from_weuser;
        }
        
        [self presentViewController:vc animated:YES completion:nil];
    }
}
#pragma mark - ZMCallCellDelegate

// 联系人详情
- (void)checkDetailInfoWithModel:(LGCallRecordModel *)model
{
    LGPhoneContactInfoController* vc = [[LGPhoneContactInfoController alloc]init];
    PhoneContact *contact = [[PhoneContact alloc]init];
    //来电
    if (model.call_type == 2) {
        contact.phoneNumber = model.from_phone;
        contact.name = model.from_weuser;
    }else if (model.call_type == 1) {
        contact.phoneNumber = model.to_phone;
        contact.name = model.to_weuser;
    }
    if (!contact.name || !contact.name.length) {
        contact.name = contact.phoneNumber;
    }
    vc.contact = contact;
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - tableviewDelegate & dataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    ZMCallViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (indexPath.row < self.dataArr.count) {
        cell.model = self.dataArr[indexPath.row];
        cell.delegate = self;
    }
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    self.selectRow = indexPath.row;

        LGCallRecordModel*model = self.dataArr[indexPath.row];
        NSString*phone;
        NSString*name;
        if (model.call_type == 2 || model.call_type == 3) {
            phone = model.from_phone;
            if (model.from_weuser) {
                name = model.from_weuser;
            }else{
                name = @"";
            }
        }
        else if (model.call_type == 1){
            phone = model.to_phone;
            if (model.to_weuser) {
                name = model.to_weuser;
            }else{
                name = @"";
            }
        }

        NSString*message = [NSString stringWithFormat:@"\n%@  %@",name,phone];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"是否拨打电话？" message:message delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"拨打", nil];
        [alert show];

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{

    return 70;
}

@end
