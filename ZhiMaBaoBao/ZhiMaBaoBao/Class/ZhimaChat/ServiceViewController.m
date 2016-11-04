//
//  ServiceViewController.m
//  ZhiMaBaoBao
//
//  Created by ios开发 on 16/10/31.
//  Copyright © 2016年 liugang. All rights reserved.
//

#import "ServiceViewController.h"
#import "ServicePurseCell.h"
#import "ServiceSingleMsgCell.h"
#import "ZMServiceMessage.h"
#import "ServiceMoreThanOneMsgCell.h"
#import "WebViewController.h"
#import "ZMHalfAlphaViewController.h"
#import "ServiceDetailInfoViewController.h"

@interface ServiceViewController ()<UITableViewDelegate,UITableViewDataSource,MoreThanOneCellDelegate>

@property (nonatomic, strong) UITableView *tableView; // 列表
@property (nonatomic, strong) NSMutableArray *messages; //消息数组

@end

@implementation ServiceViewController

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initTableview];
    [self setupNavRightItem];
    [self requestMessages];

}


#pragma mark - init

- (void)initTableview
{
    [self setCustomTitle:@"麦当劳"];
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, DEVICEWITH, DEVICEHIGHT) style:UITableViewStylePlain];
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.dataSource = self;
    tableView.delegate = self;
    [self.view addSubview:tableView];
    self.tableView = tableView;
}

//设置导航栏右侧按钮
- (void)setupNavRightItem{
    UIButton *rightBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 35, 40)];
    [rightBtn setImage:[UIImage imageNamed:@"redContant"] forState:UIControlStateNormal];
    [rightBtn addTarget:self action:@selector(lookConversionInfo) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
}

#pragma mark - action

- (void)lookConversionInfo
{
    ServiceDetailInfoViewController *vc = [[ServiceDetailInfoViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - get data

- (void)requestMessages
{
    NSMutableArray*marr = [[FMDBShareManager getAllServiceMessageByServiceId:self.conversionModel.converseId andPageNumber:1] mutableCopy];
    for (int i=0; i<marr.count; i++) {
        
        ZMServiceMessage*msg = marr[0];
        NSArray*dicArr = [msg.listJson jsonObject];
        msg.list = [LGServiceList mj_objectArrayWithKeyValuesArray:dicArr];
        
        [self.messages addObject:msg];
        
    }
    
    [self.tableView reloadData];
    
}

#pragma mark - tableviewDelegate DataSource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ZMServiceMessage*msg = self.messages[indexPath.row];
    switch (msg.type) {
        case ServiceMessageTypePurse:
            return 55+(DEVICEWITH-36)*690/682;
            break;
        case ServiceMessageTypeSingle:
            return 55+(DEVICEWITH-36)*700/676;
            break;
        case ServiceMessageTypeMoreThanOne:
            return 55+205+(msg.list.count-1)*50;
            break;
        default:
            break;
    }

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.messages.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    ZMServiceMessage*msg = self.messages[indexPath.row];
    
    NSLog(@"msg.type = %ld",msg.type);
    switch (msg.type) {
            
            
        case ServiceMessageTypePurse:
        {
            ServicePurseCell *servicePurseCell = [tableView dequeueReusableCellWithIdentifier:@"ServicePurseCell"];
            if(!servicePurseCell) {
                servicePurseCell = [[ServicePurseCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ServicePurseCell"];
            }
            servicePurseCell.message = msg;
            return servicePurseCell;
        }
            break;
        case ServiceMessageTypeSingle:
        {
            ServiceSingleMsgCell *serviceSingleMsgCell = [tableView dequeueReusableCellWithIdentifier:@"ServiceSingleMsgCell"];
            if(!serviceSingleMsgCell) {
                serviceSingleMsgCell = [[ServiceSingleMsgCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ServiceSingleMsgCell"];
            }
            serviceSingleMsgCell.message = msg;
            return serviceSingleMsgCell;
        }
            break;
        case ServiceMessageTypeMoreThanOne:
        {
            ServiceMoreThanOneMsgCell *serviceMoreThanOneMsgCell = [tableView dequeueReusableCellWithIdentifier:@"ServiceMoreThanOneMsgCell"];
            if(!serviceMoreThanOneMsgCell) {
                serviceMoreThanOneMsgCell = [[ServiceMoreThanOneMsgCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ServiceMoreThanOneMsgCell"];
            }
            serviceMoreThanOneMsgCell.message = msg;
            serviceMoreThanOneMsgCell.delegate = self;
            return serviceMoreThanOneMsgCell;
        }
            break;
        default:
            break;
    }

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ZMServiceMessage*msg = self.messages[indexPath.row];
    switch (msg.type) {
        case ServiceMessageTypePurse:
        {
            NSLog(@"红包");

        }
            break;
        case ServiceMessageTypeSingle:
        {
            NSLog(@"单条文章");

        }
            break;

        default:
            break;
    }
}

- (void)havetouchCell:(ZMServiceMessage *)message
{
    NSLog(@"messageID = %@",message.service.sid);
    [self goToWebVCWithUrlString:nil];
}

- (void)goToWebVCWithUrlString:(NSString*)urlStr
{
//    WebViewController*webVC = [[WebViewController alloc]init];
//    webVC.urlStr = @"www.baidu.com";
//    [self.navigationController pushViewController:webVC animated:YES];
    
//    CATransition *animation = [CATransition animation];
//    animation.duration = 1.0;
//    animation.timingFunction = UIViewAnimationCurveEaseInOut;
//    animation.type = @"rippleEffect";
//    animation.subtype = kCATransitionFromLeft;
//    [self.view.window.layer addAnimation:animation forKey:nil];

    ZMHalfAlphaViewController*vc = [[ZMHalfAlphaViewController alloc]init];
//    [vc setModalTransitionStyle:UIModalTransitionStylePartialCurl];
    vc.modalPresentationStyle= UIModalPresentationOverCurrentContext;
    [self presentViewController:vc animated:YES completion:^{
        vc.view.backgroundColor = [UIColor clearColor];
    }];
}

#pragma mark - lazy
- (NSMutableArray *)messages{
    if (!_messages) {
        _messages = [NSMutableArray array];
    }
    return _messages;
}

@end
