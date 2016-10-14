//
//  ZMCallBoardViewController.m
//  ZhiMaBaoBao
//
//  Created by ios开发 on 16/10/13.
//  Copyright © 2016年 liugang. All rights reserved.
//

#import "ZMCallBoardViewController.h"
#import "LGCallingController.h"
#import "PhoneContactCell.h"
#import "LGPhoneNumberCell.h"

#import "YiKeyBoardView.h"
#import "CallInfoMarkView.h"

#import "PhoneContact.h"


@interface ZMCallBoardViewController ()<YiKeyBoardViewDelegate,CallInfoMarkViewDelegate,LGPhoneNumberCellDelegate,UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) YiKeyBoardView   *keyboardView; //拨号键盘
@property (nonatomic, strong) CallInfoMarkView *callInfoView; //搜索出的用户信息view
@property (nonatomic, strong) UILabel          *showNumLabel; //已波数字展示label
@property (nonatomic, strong) UIButton         *deleteBtn;    //数字删除按钮
@property (nonatomic, strong) UIButton         *callBtn;      //拨号按钮
@property (nonatomic, strong) UITableView *tableView;


@property (nonatomic, strong) NSMutableArray *dataArr;      //数据源数组
@property (nonatomic, assign) NSInteger selectRow;          //点击行


@end

#define KeyboardHeight 247  //拨号键盘高度
static NSString * const phoneContactIdenty = @"LGPhoneNumberCell";

@implementation ZMCallBoardViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"TextFieldValueChanged" object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initOthers];
    [self initKeyBoard];
    [self initShowView];
    [self initcallInfoView];
    [self initTableview];

}

#pragma mark - init

- (void)initOthers
{
    self.dataArr     = [NSMutableArray array];
    
    self.view.backgroundColor = WHITECOLOR;
    UIButton*closeBtn = [[UIButton alloc]initWithFrame:CGRectMake(10, 25, 50, 50)];
    [closeBtn setImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
    [closeBtn addTarget:self action:@selector(dissBackAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:closeBtn];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(inputTextFieldValueChanged:) name:@"TextFieldValueChanged" object:nil];
}

- (void)initKeyBoard
{
    CGFloat sss = 624.0/750.0; //键盘的款高比
    //拨号键盘
    YiKeyBoardView *keyboardView = [YiKeyBoardView keyBoardView];
    keyboardView.frame = CGRectMake(0, DEVICEHIGHT - DEVICEWITH*sss - (12+58+30), DEVICEWITH, DEVICEWITH*sss);
    keyboardView.delegate = self;
    keyboardView.setBtn.hidden = YES;
    keyboardView.deleteBtn.hidden = YES;
    [self.view addSubview:keyboardView];
    self.keyboardView = keyboardView;
    
    UIButton*callBtn = [[UIButton alloc]initWithFrame:CGRectMake(DEVICEWITH/2 - 29, keyboardView.frameMaxY+12, 58, 58)];
    [callBtn setImage:[UIImage imageNamed:@"phoneGreen"] forState:UIControlStateNormal];
    [callBtn addTarget:self action:@selector(callAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:callBtn];
    self.callBtn = callBtn;
}

- (void)initShowView
{
    self.showNumLabel = [[UILabel alloc]initWithFrame:CGRectMake(50, 75, DEVICEWITH-100, 60)];
    self.showNumLabel.textAlignment = 1;
    self.showNumLabel.font = [UIFont systemFontOfSize:17];
    self.showNumLabel.textColor = GRAYCOLOR;
    self.showNumLabel.text = @"请拨号或搜索姓名";
    self.showNumLabel.adjustsFontSizeToFitWidth = YES;
    [self.view addSubview:self.showNumLabel];
    
    self.deleteBtn = [[UIButton alloc]initWithFrame:CGRectMake(DEVICEWITH-50, 90, 40, 30)];
    [self.deleteBtn setImage:[UIImage imageNamed:@"deleteNum"] forState:UIControlStateNormal];
    [self.deleteBtn addTarget:self action:@selector(deleteNum) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.deleteBtn];
}

- (void)initcallInfoView
{
    // 活动区域剩下的高度
    CGFloat height = self.keyboardView.frameOriginY - self.showNumLabel.frameMaxY;
    CGFloat frameY = self.showNumLabel.frameMaxY + height/2 - 25;
    
    self.callInfoView = [[CallInfoMarkView alloc]initWithFrame:CGRectMake(0, frameY, DEVICEWITH, 50)];
    self.callInfoView.delegate = self;
    self.callInfoView.hidden =YES;
    [self.view addSubview:self.callInfoView];
}

- (void)initTableview
{
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, self.keyboardView.frameOriginY, DEVICEWITH,0) style:UITableViewStylePlain];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
//    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerNib:[UINib nibWithNibName:@"LGPhoneNumberCell" bundle:nil] forCellReuseIdentifier:phoneContactIdenty];
    [self.view addSubview:self.tableView];
    self.tableView.backgroundColor = WHITECOLOR;
    
    self.tableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
}

#pragma mark -  get data



#pragma mark - action

- (void)dissBackAction
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)callAction
{
    LGCallingController *vc = [[LGCallingController alloc] init];
    vc.phoneNum = self.keyboardView.numberTextField.text;
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)deleteNum
{
    [self.keyboardView deleteClick:nil];
}

#pragma mark - notifaction

//拨号输入监听
- (void)inputTextFieldValueChanged:(NSNotification *)notis {
    
    NSString * phoneText = self.keyboardView.numberTextField.text;
    //有输入，弹出拨号工具条，
    if (phoneText.length >0) {
        
        self.showNumLabel.font = [UIFont systemFontOfSize:40];
        self.showNumLabel.textColor = BLACKCOLOR;
        self.showNumLabel.text = phoneText;
        
    }else if (phoneText.length<1) {
        
        self.showNumLabel.font = [UIFont systemFontOfSize:17];
        self.showNumLabel.textColor = GRAYCOLOR;
        self.showNumLabel.text = @"请拨号或搜索姓名";
        
        if (self.tableView.frameSize.height != 0) {
            [self.callInfoView changeBtnState];
        }
    }
    
    //匹配联系人
    if (self.dataArr) {
        [self.dataArr removeAllObjects];
    }
    NSString *phoneNumber = self.keyboardView.numberTextField.text;
    if (!phoneNumber.length) {
        self.dataArr = [self.contactsArr mutableCopy];
         [self.callInfoView changeStateWithContact:nil];
    }else{
        for (PhoneContact *contact in self.contactsArr) {
            if ([contact.phoneNumber containsString:phoneNumber]) {
                [self.dataArr addObject:contact];
            }
        }
        if (self.dataArr.count) {
            [self.callInfoView changeStateWithContact:self.dataArr[0]];
            [self.callInfoView setColorWithString:self.keyboardView.numberTextField.text];

        }else{
            [self.callInfoView changeStateWithContact:nil];
        }
    }
    [self.tableView reloadData];
    
}

#pragma mark - callInfoMarkViewDelegate

- (void)stateChange:(BOOL)isSelected
{
    if (isSelected) {

        CGRect frame = self.tableView.frame;
        frame.size.height =  DEVICEHIGHT -self.keyboardView.frameOriginY;
        [UIView animateWithDuration:0.2 animations:^{
            self.tableView.frame = frame;
        }];
    }else{

        CGRect frame = self.tableView.frame;
        frame.size.height =  0;
        [UIView animateWithDuration:0.2 animations:^{
            self.tableView.frame = frame;
        }];
    }
}

- (void)call
{
    if (self.callInfoView.phoneLabel.hidden) {
        return;
    }
    PhoneContact*conteact = self.dataArr[0];
    self.selectRow = 0;
    NSString*message = [NSString stringWithFormat:@"\n%@  %@",conteact.name,conteact.phoneNumber];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"是否拨打电话？" message:message delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"拨打", nil];
    [alert show];

}

#pragma mark - LGPhoneNumberCellDelegate

- (void)makeCall:(NSInteger)row
{
    self.selectRow = row;
    PhoneContact*conteact = self.dataArr[row];
    NSString*message = [NSString stringWithFormat:@"\n%@  %@",conteact.name,conteact.phoneNumber];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"是否拨打电话？" message:message delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"拨打", nil];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1) {
        //跳转到正在通话页面
        PhoneContact *model = self.dataArr[self.selectRow];
        LGCallingController *vc = [[LGCallingController alloc] init];
        vc.phoneNum = model.phoneNumber;
        vc.name = model.name;
        [self presentViewController:vc animated:YES completion:nil];
    }
}

#pragma mark - tableviewDelegate & dataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    LGPhoneNumberCell *cell = [tableView dequeueReusableCellWithIdentifier:phoneContactIdenty];
    PhoneContact *contact = self.dataArr[indexPath.row];
    cell.titleLabel.text = contact.name;
    cell.phoneNumber.text = contact.phoneNumber;
    cell.delegate = self;
    cell.row = indexPath.row;
    
    [cell setColorWithString:self.keyboardView.numberTextField.text];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    self.selectRow = indexPath.row;
    PhoneContact*conteact = self.dataArr[indexPath.row];
    NSString*message = [NSString stringWithFormat:@"\n%@  %@",conteact.name,conteact.phoneNumber];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"是否拨打电话？" message:message delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"拨打", nil];
    [alert show];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    return 25;
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, DEVICEWITH, 25)];
    lab.backgroundColor = RGB(240, 240, 240);
    lab.text = @"    手机联系人";
    lab.textColor = RGB(134, 134, 134);
    lab.font = [UIFont systemFontOfSize:15];
    return lab;
    
}

@end
