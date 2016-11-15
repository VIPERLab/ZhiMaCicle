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
#import "KXKeyBoardView.h"
#import "CallInfoMarkView.h"

#import "KXCopyView.h"

#import "PhoneContact.h"

#import "CallDismissAnimation.h"


@interface ZMCallBoardViewController ()<CallInfoMarkViewDelegate,LGPhoneNumberCellDelegate,KXKeyBoardViewDelegate,UITableViewDelegate,UITableViewDataSource,KXCopyViewDelegate,UIViewControllerTransitioningDelegate>

@property (nonatomic, strong) KXKeyBoardView   *keyboardView; //拨号键盘
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

@implementation ZMCallBoardViewController {
    BOOL _isKeyBoardShow;
    NSString *_currentNum;
    KXCopyView *_copyView;
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

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    if (!_isKeyBoardShow) {
        _isKeyBoardShow = YES;
        [self.keyboardView showAnimation];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [self creatCopyViewWithSubTitle:@""];
}


- (void)viewWillDisappear:(BOOL)animated {
    [self.keyboardView hideAnimation];
}


#pragma mark - init

- (void)initOthers
{
    self.dataArr = [NSMutableArray array];
    
    self.view.backgroundColor = [UIColor whiteColor];
    UIButton*closeBtn = [[UIButton alloc]initWithFrame:CGRectMake(10, 25, 50, 50)];
    [closeBtn setImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
    [closeBtn addTarget:self action:@selector(dissBackAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:closeBtn];
}

- (void)initKeyBoard
{
    CGFloat sss = 624.0/750.0; //键盘的款高比
    //拨号键盘
    KXKeyBoardView *keyboardView = [[KXKeyBoardView alloc] init];
    keyboardView.frame = CGRectMake(0, DEVICEHIGHT - DEVICEWITH*sss - (12+58+30), DEVICEWITH, DEVICEWITH*sss);
    keyboardView.delegate = self;
    
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
    self.showNumLabel.userInteractionEnabled = YES;
    [self.view addSubview:self.showNumLabel];
    
    //添加长按手势
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(creatCopyView:)];
    [self.showNumLabel addGestureRecognizer:longPress];

    
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
    self.callInfoView.hidden = YES;
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

#pragma mark - copyView
- (void)creatCopyViewWithSubTitle:(NSString *)subTitle {
    UIPasteboard *pboard = [UIPasteboard generalPasteboard];
    NSString *copyStr = pboard.string;
    if (pboard.string.length && [self isMobile:pboard.string]) {
        _copyView = [[KXCopyView alloc] initWithFrame:CGRectMake(self.showNumLabel.center.x - 25, CGRectGetMinY(self.showNumLabel.frame) - 40, 50, 40)];
        _copyView.delegate = self;
        
        if (subTitle.length) {
            _copyView.titleArray = @[@"粘贴",subTitle];
        } else {
             _copyView.titleArray = @[@"粘贴"];
        }
        
        [_copyView setImage:[UIImage imageNamed:@"Discovre_Copy"] andInsets:UIEdgeInsetsMake(30, 40, 30, 40)];
        [self.view addSubview:_copyView];
        [_copyView showAnimation];
    }
}

//正则表达式筛选电话号码
- (BOOL)isMobile:(NSString *)mobileNumbel{
    /**
     * 手机号码
     * 移动：134[0-8],135,136,137,138,139,150,151,157,158,159,182,187,188
     * 联通：130,131,132,152,155,156,185,186
     * 电信：133,1349,153,180,189,181(增加)
     */
    NSString * MOBIL = @"^1(3[0-9]|5[0-35-9]|8[025-9])\\d{8}$";
    /**
     10         * 中国移动：China Mobile
     11         * 134[0-8],135,136,137,138,139,150,151,157,158,159,182,187,188
     12         */
    NSString * CM = @"^1(34[0-8]|(3[5-9]|5[017-9]|8[2378])\\d)\\d{7}$";
    /**
     15         * 中国联通：China Unicom
     16         * 130,131,132,152,155,156,185,186
     17         */
    NSString * CU = @"^1(3[0-2]|5[256]|8[56])\\d{8}$";
    /**
     20         * 中国电信：China Telecom
     21         * 133,1349,153,180,189,181(增加)
     22         */
    NSString * CT = @"^1((33|53|8[019])[0-9]|349)\\d{7}$";
    
    NSPredicate *regextestmobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", MOBIL];
    NSPredicate *regextestcm = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CM];
    NSPredicate *regextestcu = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CU];
    NSPredicate *regextestct = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CT];
    
    if (([regextestmobile evaluateWithObject:mobileNumbel]
         || [regextestcm evaluateWithObject:mobileNumbel]
         || [regextestct evaluateWithObject:mobileNumbel]
         || [regextestcu evaluateWithObject:mobileNumbel])) {
        return YES;
    }
    
    return NO;
}


#pragma mark - kxCopyViewDelegate 
- (void)KXCopyViewDidClickWithIndex:(NSInteger)index {
    if (index == 0) { // 粘贴
        [_copyView removeFromSuperview];
        _copyView = nil;
        UIPasteboard *pboard = [UIPasteboard generalPasteboard];
        self.showNumLabel.text = pboard.string;
        [self inputTextFieldValueChanged:nil];
    } else {        //复制
        UIPasteboard *pboard = [UIPasteboard generalPasteboard];
        pboard.string = self.showNumLabel.text;
        
        [_copyView removeFromSuperview];
        _copyView = nil;
    }
    
}

#pragma mark - keyBoardDelegate
- (void)KXKeyBoardViewDidClickNum:(NSString *)number {
    if (_copyView) {
        [_copyView removeFromSuperview];
    }
    
    if (self.showNumLabel.text.length >= 13) {
        return;
    }
    
    if ([self.showNumLabel.text isEqualToString:@"请拨号或搜索姓名"]) {
        self.showNumLabel.text = @"";
    }
    _currentNum = number;
    self.showNumLabel.text = [self.showNumLabel.text stringByAppendingString:number];
    [self inputTextFieldValueChanged:nil];
}



#pragma mark - action

// 长按手势
- (void)creatCopyView:(UIGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateBegan) {
        if (_copyView) {
            return;
        }
        if ([self.showNumLabel.text isEqualToString:@"请拨号或搜索姓名"]) {
            [self creatCopyViewWithSubTitle:@""];
        } else {
            [self creatCopyViewWithSubTitle:@"复制"];
        }
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (_copyView) {
        [_copyView removeFromSuperview];
        _copyView = nil;
    }
}


- (void)dissBackAction {
    if (_copyView) {
        [_copyView removeFromSuperview];
        _copyView = nil;

    }
    self.transitioningDelegate = self;
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    return [[CallDismissAnimation alloc] init];
}

- (void)callAction {
    if (_copyView) {
        [_copyView removeFromSuperview];
        _copyView = nil;

    }
    LGCallingController *vc = [[LGCallingController alloc] init];
    vc.phoneNum = self.showNumLabel.text;
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)deleteNum {
    if (_copyView) {
        [_copyView removeFromSuperview];
        _copyView = nil;
    }
    
    if ([self.showNumLabel.text isEqualToString:@"请拨号或搜索姓名"]) {
        return;
    }
    
    if (self.showNumLabel.text.length <= 11  ) {
        self.showNumLabel.text = [self.showNumLabel.text stringByReplacingOccurrencesOfString:@"-" withString:@""];;
    }
    
    if ( self.showNumLabel.text.length > 0 ) {
        self.showNumLabel.text = [self.showNumLabel.text substringToIndex:self.showNumLabel.text.length-1];
    }
    
    [self inputTextFieldValueChanged:nil];
}

#pragma mark - notifaction
//拨号输入监听
- (void)inputTextFieldValueChanged:(NSNotification *)notis {
    
    NSString * phoneText = self.showNumLabel.text;
    //有输入，弹出拨号工具条，
    if (phoneText.length >0) {
        
        self.showNumLabel.font = [UIFont systemFontOfSize:40];
        self.showNumLabel.textColor = [UIColor blackColor];
        self.showNumLabel.text = phoneText;
        
    }else if (phoneText.length < 1) {
        
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
    NSString *phoneNumber = self.showNumLabel.text;
    if (!phoneNumber.length) {
        self.dataArr = [self.contactsArr mutableCopy];
         [self.callInfoView changeStateWithContact:nil];
    }else{
        for (PhoneContact *contact in self.contactsArr) {
            
            //匹配电话
            if ([contact.phoneNumber containsString:phoneNumber]) {
                [self.dataArr addObject:contact];
            }
            
        }
        if (self.dataArr.count) {
            [self.callInfoView changeStateWithContact:self.dataArr[0]];
            [self.callInfoView setColorWithString:self.showNumLabel.text];

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
        [UIView animateWithDuration:0.15 animations:^{
            self.tableView.frame = frame;
        }];
    }else{

        CGRect frame = self.tableView.frame;
        frame.size.height =  0;
        [UIView animateWithDuration:0.15 animations:^{
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
    
    [cell setColorWithString:self.self.showNumLabel.text];
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
