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

#import "LGCallRecordCell.h"
#import "PhoneContactCell.h"
#import "ZMCallViewCell.h"

#import "PhoneContact.h"


@interface ZMCallViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataArr;      //数据源数组
@property (nonatomic, strong) NSMutableArray *matchArr;     //通话记录
@property (nonatomic, assign) BOOL matchTable;              //标记是否在匹配通讯录 （切换cell）
@property (nonatomic, assign) NSInteger selectRow;          //点击行


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
}

#pragma mark - init

- (void)initOthers
{
    self.navigationItem.title = @"拨打";
    self.dataArr  = [NSMutableArray array];
    self.matchArr = [NSMutableArray array];
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
    CGFloat height = DEVICEWITH/2.9;
    UIView*headView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICEWITH, height)];
    headView.backgroundColor = BGCOLOR;
    for (int i=0; i<2; i++) {
        UIButton*btn  = [[UIButton alloc]initWithFrame:CGRectMake((i+1)*DEVICEWITH/3 - 64/2, (height-82)/2, 64, 64)];
        UILabel*label = [[UILabel alloc]initWithFrame:CGRectMake(btn.frameOriginX, btn.frameMaxY+5, 64, 15)];
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
    
    UIImageView*lineview = [[UIImageView alloc]initWithFrame:CGRectMake(0, height-1, DEVICEWITH, 1)];
    lineview.backgroundColor = htmlColor(@"d6d7dc");
    [headView addSubview:lineview];
    
    self.tableView.tableHeaderView = headView;
}

#pragma mark - get data

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
            //            [LCProgressHUD showText:responseData.msg];
        }
    }];
    
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
    [self presentViewController:callBoardVC animated:YES completion:nil];
//    callBoardVC.hidesBottomBarWhenPushed = YES;
//    [self.navigationController pushViewController:callBoardVC animated:YES];
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

#pragma mark - tableviewDelegate & dataSource

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
        ZMCallViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
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

@end
