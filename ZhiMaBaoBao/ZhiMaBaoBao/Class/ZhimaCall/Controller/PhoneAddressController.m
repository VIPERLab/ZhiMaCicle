//
//  PhoneAddressController.m
//  YiIM_iOS
//
//  Created by liugang on 16/8/22.
//  Copyright © 2016年 ikantech. All rights reserved.
//

#import "PhoneAddressController.h"
#import "PhoneContact.h"
#import "PhoneContactCell.h"
#import "pinyin.h"
#import "LYVoIP.h"
#import "NSString+MD5.h"
#import "LGCallingController.h"
#import "LGQueryModel.h"
#import "LGQueryCell.h"
#import "LGQueryResModel.h"
#import "LGPhoneContactInfoController.h"
#import <AddressBookUI/ABPeoplePickerNavigationController.h>
#import <AddressBook/ABPerson.h>
#import <AddressBookUI/ABPersonViewController.h>


@interface PhoneAddressController ()<LGQueryCellDelegate>
@property (nonatomic, strong) NSMutableArray *contactsArr;  //筛选结果数组
@property (nonatomic,strong) NSMutableArray *nameAry;   //排序后的联系人数组
@property (nonatomic,strong) NSMutableArray *sectionAry;    //按姓名首字母分组个数
@property (nonatomic,strong) NSMutableArray *numberAry;     //每组联系人个数
@property (nonatomic, strong) NSArray *dataArr;    //所有联系人数据
@property (nonatomic, strong) NSMutableArray *queryArr; //查询数组，用于转json

@property (nonatomic, assign) NSInteger recordId; //通话记录id

@property (nonatomic, strong) PhoneContact *selectContact;

@property (nonatomic, copy) NSString *jsonStr;  //查询json数据
@property (nonatomic, strong) NSMutableArray *queryResArr;  //查询后服务器返回数据数组

//暂时保存数据
@property (nonatomic, strong) NSArray *containArray;

@end

@implementation PhoneAddressController



- (NSMutableArray *)queryResArr{
    if (!_queryResArr) {
        _queryResArr = [NSMutableArray array];
    }
    return _queryResArr;
}

- (NSMutableArray *)queryArr{
    if (!_queryArr) {
        _queryArr = [NSMutableArray array];
    }
    return _queryArr;
}

- (NSMutableArray *)contactsArr{
    if (!_contactsArr) {
        _contactsArr = [NSMutableArray array];
    }
    return _contactsArr;
}

- (NSMutableArray *)nameAry{
    
    if (!_nameAry) {
        _nameAry = [NSMutableArray array];
    }
    return _nameAry;
}

- (NSMutableArray *)sectionAry{
    
    if (!_sectionAry) {
        _sectionAry = [NSMutableArray array];
    }
    return _sectionAry;
}

- (NSMutableArray *)numberAry{
    
    if (!_numberAry) {
        _numberAry = [NSMutableArray array];
    }
    return _numberAry;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.sectionIndexColor = RGB(54, 54, 54);
    self.tableView.sectionIndexBackgroundColor = [UIColor clearColor];
    
//    [self setCustomTitle:@"手机联系人"];

    //获取手机通讯录
    [self getContacts];
    
    if (self.isAddPhoneFriend) {
        
        [self clearAllData];
        
//        [self setCustomTitle:@"添加手机联系人"];
        //获取联系人是否开通芝麻数据
        [self requestData];
    }

    
    //监听textField文本改变
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldDidChanged:) name:UITextFieldTextDidChangeNotification object:nil];
}

- (void)clearAllData{
    if (self.nameAry) {
        [self.nameAry removeAllObjects];
    }
    if (self.sectionAry) {
        [self.sectionAry removeAllObjects];
    }
    if (self.contactsArr) {
        [self.contactsArr removeAllObjects];
    }
    if (self.numberAry) {
        [self.numberAry removeAllObjects];
    }
}

- (void)requestData{
    [LCProgressHUD showLoadingText:@"正在加载..."];
    if (self.contactsArr) {
        [self.contactsArr removeAllObjects];
    }
    
#warning TODO:查询通讯录好友是否开通芝麻
    /*
    [LGNetWorking queryPhoneBook:USERINFO.sessionId openfire:USERINFO.openfireAccount flag:@"check" phonedata:self.jsonStr block:^(ResponseData *responseData) {
        [LCProgressHUD hide];
        if (responseData.code == 0) {
            self.contactsArr = [LGQueryResModel mj_objectArrayWithKeyValuesArray:responseData.data];
            self.containArray = [NSArray arrayWithArray:self.contactsArr];
            [self queryResultCompare];
        }
    }];
     */
 
}

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
        LGQueryModel *queryModel = [[LGQueryModel alloc] init];
        
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
            //如果是座机号码，不去格式化
            if (![phone hasPrefix:@"1"]) {
                continue;
            }
            //去掉手机号码格式化字符
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
        
        queryModel.phonename = name;
        queryModel.phone = strPhone;
        
        [self.contactsArr addObject:contact];
        [self.queryArr addObject:queryModel];
                
    }
    
    //将查询数组转换成json
    NSArray *jsonArr = [LGQueryModel mj_keyValuesArrayWithObjectArray:self.queryArr];
    self.jsonStr = [jsonArr mj_JSONString];
    
    self.dataArr = [NSArray arrayWithArray:self.contactsArr];
    [self setSequenceOfContacts];
}

//查询结果排序
- (void)queryResultCompare{
    
    if (self.nameAry.count) {
        [self.nameAry removeAllObjects];
    }
    
    //排序
    for (int i = 0; i < self.contactsArr.count; i++) {
        
        LGQueryResModel *contact = self.contactsArr[i];
        
        NSString *pinYinResult = [NSString string];
        
        for(int j = 0; j< contact.phonename.length ;j++){
            
            NSString *singlePinyinLetter = [[NSString stringWithFormat:@"%c",pinyinFirstLetter([contact.phonename characterAtIndex:j])] uppercaseString];
            
            pinYinResult = [pinYinResult stringByAppendingString:singlePinyinLetter];
        }
        //将姓名转换成拼音
        contact.pinyin = pinYinResult;
        [self.nameAry addObject:contact];
    }
    
    NSArray *sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"pinyin" ascending:YES]];
    [self.nameAry sortUsingDescriptors:sortDescriptors];
    
    int num = 0;
    
    if (self.sectionAry.count) {
        [self.sectionAry removeAllObjects];
    }
    if (self.numberAry.count) {
        [self.numberAry removeAllObjects];
    }
    
    for(int i=0;i<[self.nameAry count];i++){
        
        LGQueryResModel *contact = self.nameAry[i];
        
        if (i == 0) {
            
            NSString *str = [NSString stringWithFormat:@"%c",pinyinFirstLetter([contact.pinyin characterAtIndex:0])];
            [self.sectionAry addObject:[str uppercaseString]];
        }
        
        if (i < self.nameAry.count - 1) {
            
            LGQueryResModel *contact1 = self.nameAry[i+1];
            
            if (pinyinFirstLetter([contact1.pinyin characterAtIndex:0]) != pinyinFirstLetter([contact.pinyin characterAtIndex:0])) {
                
                NSString *numStr = [NSString stringWithFormat:@"%d",num + 1];
                [self.numberAry addObject:numStr];
                
                NSString *str = [NSString stringWithFormat:@"%c",pinyinFirstLetter([contact1.pinyin characterAtIndex:0])];
                [self.sectionAry addObject:[str uppercaseString]];
                num = 0;
            }
            else{
                
                num ++;
            }
        }
    }
    [self.tableView reloadData];
}


//联系人排序
- (void)setSequenceOfContacts{
    
    if (self.nameAry.count) {
        [self.nameAry removeAllObjects];
    }
    
    //排序
    for (int i = 0; i < self.contactsArr.count; i++) {
        
        PhoneContact *contact = self.contactsArr[i];

        NSString *pinYinResult = [NSString string];
        
        for(int j = 0; j< contact.name.length ;j++){
            
            NSString *singlePinyinLetter = [[NSString stringWithFormat:@"%c",pinyinFirstLetter([contact.name characterAtIndex:j])] uppercaseString];
            
            pinYinResult = [pinYinResult stringByAppendingString:singlePinyinLetter];
        }
        //将姓名转换成拼音
        contact.pinyin = pinYinResult;
        [self.nameAry addObject:contact];
    }
    
    NSArray *sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"pinyin" ascending:YES]];
    [self.nameAry sortUsingDescriptors:sortDescriptors];
    
    int num = 0;
    
    if (self.sectionAry.count) {
        [self.sectionAry removeAllObjects];
    }
    if (self.numberAry.count) {
        [self.numberAry removeAllObjects];
    }
    
    for(int i=0;i<[self.nameAry count];i++){
        
        PhoneContact *contact = self.nameAry[i];

        if (i == 0) {
            
            NSString *str = [NSString stringWithFormat:@"%c",pinyinFirstLetter([contact.pinyin characterAtIndex:0])];
            [self.sectionAry addObject:[str uppercaseString]];
        }
        
        if (i < self.nameAry.count - 1) {
            
            PhoneContact *contact1 = self.nameAry[i+1];
            
            if (pinyinFirstLetter([contact1.pinyin characterAtIndex:0]) != pinyinFirstLetter([contact.pinyin characterAtIndex:0])) {
                
                NSString *numStr = [NSString stringWithFormat:@"%d",num + 1];
                [self.numberAry addObject:numStr];
                
                NSString *str = [NSString stringWithFormat:@"%c",pinyinFirstLetter([contact1.pinyin characterAtIndex:0])];
                [self.sectionAry addObject:[str uppercaseString]];
                num = 0;
            }
            else{
                
                num ++;
            }
        }
    }
    [self.tableView reloadData];
}


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.sectionAry.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    //最后一组
    if (section == self.sectionAry.count - 1) {
        
        int row = 0;
        for (int i = 0; i < self.numberAry.count; i++) {
            row = row + [[self.numberAry objectAtIndex:i] intValue];
        }
        
        return self.nameAry.count - row;
    }
    else{
        return [[self.numberAry objectAtIndex:section] intValue];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSInteger rowNum = 0;
    for (int i = 0; i < indexPath.section; i++) {
        
        rowNum = [[self.numberAry objectAtIndex:i] intValue] + rowNum;
    }

    //添加通讯录好友cell
    if (self.isAddPhoneFriend) {
        LGQueryCell *cell = [tableView dequeueReusableCellWithIdentifier:@"queryCell"];
        if (!cell) {
            cell = [[LGQueryCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"queryCell"];
        }
        cell.delegate = self;
        LGQueryResModel *model = self.nameAry[rowNum + indexPath.row];
        cell.row = rowNum;
        cell.model = model;
        return cell;
    }else{
        PhoneContactCell *cell = [tableView dequeueReusableCellWithIdentifier:@"contactCell"];
        if (!cell) {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"PhoneContactCell" owner:nil options:nil] lastObject];
        }
        
        PhoneContact *contact = self.nameAry[rowNum + indexPath.row];
        
        if (contact.avtar) {
            cell.avtar.image = [UIImage imageWithData:contact.avtar];
        }else{
            cell.avtar.image = [UIImage imageNamed:@"defaultContact@3x"];
        }
        
        cell.name.text = contact.name;
        cell.phoneNumber.text = contact.phoneNumber;
        return cell;

    }
}

#warning TODO:添加聊天好友
/*
- (void)addNewFriend:(NSInteger)row{
    LGQueryResModel *model = self.nameAry[row];
    NSString *jid = [NSString stringWithFormat:@"%@@localhost",model.openfireaccount];
    [LCProgressHUD showText:@"请求发送成功"];
}
 */

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    //如果已添加为好友，跳转到好友详情
    if (self.isAddPhoneFriend) {
        NSInteger rowNum = 0;
        for (int i = 0; i < indexPath.section; i++) {
            
            rowNum = [[self.numberAry objectAtIndex:i] intValue] + rowNum;
        }
        LGQueryResModel *model = self.nameAry[rowNum + indexPath.row];
        
#warning TODO:跳转到好友详情
        /*
        YiUserInfoViewController *vc = [[YiUserInfoViewController alloc] init];
        vc.jid = [NSString stringWithFormat:@"%@@localhost",model.openfireaccount];
        if (model.isadd == 0 || model.isadd == 2) {
            vc.isAddFriend = YES;
        }
        [self.navigationController pushViewController:vc animated:YES];
         */

    }
    //跳转到手机联系人详情页
    else{
        NSInteger rowNum = 0;
        for (int i = 0; i < indexPath.section; i++) {
            
            rowNum = [[self.numberAry objectAtIndex:i] intValue] + rowNum;
        }
        
        PhoneContact *contact = self.nameAry[rowNum + indexPath.row];
        _selectContact = contact;
        
        //

        LGPhoneContactInfoController *vc = [[LGPhoneContactInfoController alloc] init];
        vc.contact = contact;
        [self.navigationController pushViewController:vc animated:YES];
 
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSString *phoneNumber = _selectContact.phoneNumber;
    NSString *name = _selectContact.name;
    if (buttonIndex == 1) {
        //跳转到正在通话页面
        LGCallingController *vc = [[LGCallingController alloc] init];
        vc.phoneNum = phoneNumber;
        vc.name = name;
        [self presentViewController:vc animated:YES completion:nil];

    }
}


//监听搜索结果，改变数据源
- (void)textFieldDidChanged:(NSNotification *)notification{
    UITextField *textField = notification.object;
    NSString *text = textField.text;
    
    if (self.isAddPhoneFriend) {
        
        if (self.contactsArr) {
            [self.contactsArr removeAllObjects];
        }
        
        if (text.length == 0) {
            self.contactsArr = [NSMutableArray arrayWithArray:self.containArray];
        }else{
            for (LGQueryResModel *model in self.containArray) {
                if ([model.phonename containsString:text]) {
                    [self.contactsArr addObject:model];
                }
            }
        }
        
        //排序
        [self queryResultCompare];
        
    }
    else{
        //先清空数据，然后存储筛选数据
        if (self.contactsArr) {
            [self.contactsArr removeAllObjects];
        }
        
        if (text.length == 0) {
            self.contactsArr = [NSMutableArray arrayWithArray:self.dataArr];
        }else{
            for (PhoneContact *contact in self.dataArr) {
                if ([contact.name containsString:text] || [contact.phoneNumber containsString:text]) {
                    [self.contactsArr addObject:contact];
                }
            }
        }
        
        //筛选完毕进行数组排序
        [self setSequenceOfContacts];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 52;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return 70;
    }else{
        return 20;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.1f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        
        //白色背景
        UIView *white = [[UIView alloc] initWithFrame:CGRectMake(0, 0, DEVICEWITH, 70)];
        white.backgroundColor = WHITECOLOR;
        //搜索图片
        UIImageView *seachImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"lsearch"]];
        seachImage.frame = CGRectMake(26, 14, 19, 21);
        [white addSubview:seachImage];
        //输入框
        UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(55, 10, DEVICEWITH - 80, 30)];
        textField.placeholder = @"搜索联系人";
        textField.font = MAINFONT;
        [white addSubview:textField];
        //搜索按钮
//        UIButton *searchBtn = [[UIButton alloc] initWithFrame:CGRectMake(DEVICEWITH - 50 - 12, 10, 50, 30)];
//        [searchBtn setTitle:@"搜索" forState:UIControlStateNormal];
//        [searchBtn setTitleColor:THEMECOLOR forState:UIControlStateNormal];
//        searchBtn.titleLabel.font = MAINFONT;
//        searchBtn.titleLabel.textAlignment = NSTextAlignmentRight;
//        [searchBtn addTarget:searchBtn action:@selector(searchAction) forControlEvents:UIControlEventTouchUpInside];
//        [white addSubview:searchBtn];
        //分割线
        UIView *separtor = [[UIView alloc] initWithFrame:CGRectMake(14, 43, DEVICEWITH - 28, 0.5)];
        separtor.backgroundColor = SEPARTORCOLOR;
        [white addSubview:separtor];
        
        UIView *headerView  = [[UIView alloc]initWithFrame:CGRectMake(0, 50, DEVICEWITH, 20)];
        headerView.backgroundColor = RGB(229, 229, 229);
        [white addSubview:headerView];
        
        UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(14, 0, DEVICEWITH - 14, 20)];
        titleLabel.text = [self.sectionAry objectAtIndex:section];
        titleLabel.font = [UIFont systemFontOfSize:16.0];
        titleLabel.textColor = RGB(147, 147, 147);
        titleLabel.backgroundColor = [UIColor clearColor];
        [headerView addSubview:titleLabel];
        
        return white;
    }else{
        UIView *headerView  = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICEWITH, 20)];
        headerView.backgroundColor = RGB(229, 229, 229);
        
        UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(14, 0, DEVICEWITH - 14, 20)];
        titleLabel.text = [self.sectionAry objectAtIndex:section];
        titleLabel.font = [UIFont systemFontOfSize:16.0];
        titleLabel.textColor = RGB(147, 147, 147);
        titleLabel.backgroundColor = [UIColor clearColor];
        [headerView addSubview:titleLabel];
        return headerView;
    }
}

//添加索引列

- (NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView{
    
    return self.sectionAry;
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

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
}


@end
