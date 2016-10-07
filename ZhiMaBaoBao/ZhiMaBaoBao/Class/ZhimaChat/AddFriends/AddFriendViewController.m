//
//  AddFriendViewController.m
//  YiIM_V3
//
//  Created by saint on 14-6-19.
//  Copyright (c) 2014年 ikantech. All rights reserved.
//  添加芝麻朋友

#import "AddFriendViewController.h"
#import "LGAddFriendCell.h"
#import "LGSearchResultController.h"
#import "PhoneAddressController.h"
#import "ScanQRCodeController.h"

@interface AddFriendViewController ()<UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate>
{
    UITableView *_tableView;
}

@property (nonatomic, strong) UITextField *textField;

@end

@implementation AddFriendViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    _tableView  = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 64) style:UITableViewStyleGrouped];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
    [self setCustomTitle:@"添加芝麻朋友"];
    self.view.backgroundColor = BGCOLOR;
    _tableView.backgroundColor = BGCOLOR;
    
}


#pragma mark - Tableview datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
//    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    static NSString *identifier = @"LGItemCell";
    LGAddFriendCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"LGAddFriendCell" owner:nil options:nil] lastObject];
    cell.separtor.hidden = YES;

    if (indexPath.row == 0) {
        cell.iconImg.image = [UIImage imageNamed:@"联系人"];
        cell.desLabel.text = @"添加手机联系人";
    }else{
        cell.iconImg.image = [UIImage imageNamed:@"saoyisao"];
        cell.desLabel.text = @"扫一扫";
    }

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 75;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, DEVICEWITH, 75)];
    header.backgroundColor = BGCOLOR;
    
    //白色背景
    UIView *white = [[UIView alloc] initWithFrame:CGRectMake(0, 15, DEVICEWITH, 50)];
    white.backgroundColor = WHITECOLOR;
    [header addSubview:white];
    //搜索图片
    UIImageView *seachImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"lsearch"]];
    seachImage.frame = CGRectMake(26, 14, 19, 21);
    [white addSubview:seachImage];
    //输入框
    UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(55, 10, 200, 30)];
    textField.placeholder = @"昵称/手机号";
    textField.font = MAINFONT;
    [white addSubview:textField];
    self.textField = textField;
    //搜索按钮
    UIButton *searchBtn = [[UIButton alloc] initWithFrame:CGRectMake(DEVICEWITH - 50 - 12, 10, 50, 30)];
    [searchBtn setTitle:@"搜索" forState:UIControlStateNormal];
    [searchBtn setTitleColor:THEMECOLOR forState:UIControlStateNormal];
    searchBtn.titleLabel.font = MAINFONT;
    searchBtn.titleLabel.textAlignment = NSTextAlignmentRight;
    [searchBtn addTarget:self action:@selector(searchFriendAction) forControlEvents:UIControlEventTouchUpInside];
    [white addSubview:searchBtn];
    //分割线
    UIView *separtor = [[UIView alloc] initWithFrame:CGRectMake(14, 43, DEVICEWITH - 28, 0.5)];
    separtor.backgroundColor = RGB(220, 220, 220);
    [white addSubview:separtor];
    
    return header;
}

//搜索按钮点击方法
- (void)searchFriendAction{
    [self hideKeyboard:nil];
    
    if(!self.textField.hasText) {
        [LCProgressHUD showFailureText:@"搜索内容不能为空"];
        return;
    }
    
    //调用本地接口查询新好友
    [LCProgressHUD showLoadingText:@"正在搜索好友..."];
    [LGNetWorking searchFriend:USERINFO.sessionId content:_textField.text type:@"new" block:^(ResponseData *responseData) {
            if (responseData.code == 0) {
                [LCProgressHUD hide];
                //搜索成功 -- 跳转到搜索结果展示页面
                LGSearchResultController *vc = [[LGSearchResultController alloc] init];
                vc.dataArr = responseData.data;
                vc.isAddFriend = YES;
                [self.navigationController pushViewController:vc animated:YES];
                
            }else{
                [LCProgressHUD showText:responseData.msg];
            }
    }];

}


-(void)hideKeyboard:(id)sender {
    [_textField resignFirstResponder];
}


#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    // 输出点击的view的类名
    //NSLog(@"%@", NSStringFromClass([touch.view class]));
    
    // 若为UITableViewCellContentView（即点击了tableViewCell），则不截获Touch事件
    if ([NSStringFromClass([touch.view class]) isEqualToString:@"UITableViewCellContentView"]) {
        return NO;
    }
    return  YES;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 0) {
        //跳转到添加手机联系人页面
        PhoneAddressController *vc = [[PhoneAddressController alloc] init];
        vc.isAddPhoneFriend = YES;
        [self.navigationController pushViewController:vc animated:YES];
        
    }else{
        //跳转到扫一扫页面
        //扫一扫
        ScanQRCodeController *QRCode = [[ScanQRCodeController alloc] init];
        
        //创建参数对象
        LBXScanViewStyle *style = [[LBXScanViewStyle alloc]init];
        
        //矩形区域中心上移，默认中心点为屏幕中心点
        style.centerUpOffset = 44;
        
        //扫码框周围4个角的类型,设置为外挂式
        style.photoframeAngleStyle = LBXScanViewPhotoframeAngleStyle_Outer;
        
        //扫码框周围4个角绘制的线条宽度
        style.photoframeLineW = 6;
        
        //扫码框周围4个角的宽度
        style.photoframeAngleW = 24;
        
        //扫码框周围4个角的高度
        style.photoframeAngleH = 24;
        
        //扫码框内 动画类型 --线条上下移动
        style.anmiationStyle = LBXScanViewAnimationStyle_LineMove;
        
        //线条上下移动图片
        style.animationImage = [UIImage imageNamed:@"qrcode_scan_light_green"];
        
        //SubLBXScanViewController继承自LBXScanViewController
        //添加一些扫码或相册结果处理
        //    SubLBXScanViewController *vc = [SubLBXScanViewController new];
        QRCode.style = style;
        
        QRCode.isQQSimulator = YES;
        QRCode.isVideoZoom = YES;
        
        QRCode.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:QRCode animated:YES];
    }

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
