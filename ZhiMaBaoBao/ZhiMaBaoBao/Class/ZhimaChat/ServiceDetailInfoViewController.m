//
//  ServiceDetailInfoViewController.m
//  ZhiMaBaoBao
//
//  Created by liugang on 16/11/1.
//  Copyright © 2016年 liugang. All rights reserved.
//

#import "ServiceDetailInfoViewController.h"
#import "DetailInfoCell.h"
#import "DetailInfoHeaderView.h"

@interface ServiceDetailInfoViewController ()<KXActionSheetDelegate,UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *titlesArr;   //标题数组
@property (nonatomic, strong) NSArray *subTitlesArr;    //副标题数组
@end

static NSString *const reuseIdentifier = @"infocell";
@implementation ServiceDetailInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.isAttention = YES;
    
    [self setCustomTitle:@"麦当劳"];
    [self setupNavRightItem];
    [self addAllSubviews];
}

//已经关注该公众号 设置导航栏右侧按钮
- (void)setupNavRightItem{
    UIButton *rightBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 35, 40)];
    [rightBtn setImage:[UIImage imageNamed:@"nav_more"] forState:UIControlStateNormal];
    [rightBtn addTarget:self action:@selector(moreOperating) forControlEvents:UIControlEventTouchUpInside];
    if (self.isAttention) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
    }
}

- (void)addAllSubviews{
    UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    [tableView registerClass:[DetailInfoCell class] forCellReuseIdentifier:reuseIdentifier];
    tableView.delegate = self;
    tableView.dataSource = self;
    [self.view addSubview:tableView];
    self.tableView = tableView;
}

#pragma mark - tableView datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.titlesArr.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [[self.titlesArr objectAtIndex:section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    DetailInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    cell.titleText = self.titlesArr[indexPath.section][indexPath.row];
    cell.indexPath = indexPath;
    if (indexPath.section == 0) {   //第一组，有副标题 （功能介绍，帐号主题）
        cell.subTitleText = self.subTitlesArr[indexPath.row];
    }
    if (indexPath.section == self.titlesArr.count - 1) {    //查看历史消息
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    if (self.isAttention && indexPath.section == 1 && indexPath.row == 0) { //接收消息
        cell.acceptMsg = YES;
    }
    if (self.isAttention && indexPath.section == 1 && indexPath.row == 1) { //置顶服务号
        cell.topChat = NO;
    }
    
    return cell;
}

#pragma mark - tableView delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0 && indexPath.row == 0) { //功能介绍 根据说明计算单元格高度
        NSString *str = self.subTitlesArr[0];
        CGFloat height = [str sizeWithFont:[UIFont systemFontOfSize:15] maxSize:CGSizeMake(DEVICEWITH - 12 * 4 - 80, MAXFLOAT)].height + 5;
        if (height < 45) {
            return 45;
        }else{
            return height;
        }
    }else{
        return 45;
    }
}

//tableView 尾试图
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    //最后一组返回按钮
    if (section == self.titlesArr.count - 1) {
        return 150;
    }else{
        return 12;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    //最后一组返回按钮
    if (section == self.titlesArr.count - 1) {
        UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, DEVICEWITH, 150)];
        footer.backgroundColor = self.tableView.backgroundColor;
        UIButton *bottomBtn = [[UIButton alloc] initWithFrame:CGRectMake(14, 30, DEVICEWITH - 28, 48)];
        bottomBtn.layer.cornerRadius = 5.f;
        bottomBtn.backgroundColor = THEMECOLOR;
        [bottomBtn setTitleColor:WHITECOLOR forState:UIControlStateNormal];
        bottomBtn.titleLabel.font = [UIFont systemFontOfSize:17];
        [bottomBtn addTarget:self action:@selector(bottomAction) forControlEvents:UIControlEventTouchUpInside];
        [footer addSubview:bottomBtn];
        if (self.isAttention) {
            [bottomBtn setTitle:@"进入服务号" forState:UIControlStateNormal];
        }else{
            [bottomBtn setTitle:@"关注" forState:UIControlStateNormal];
        }
        return footer;
    }else{
        return [[UIView alloc] init];
    }
}

//tableView头试图
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0) { //第一组
        return 100;
    }else{
        return 0.1;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    DetailInfoHeaderView *header = [[DetailInfoHeaderView alloc] initWithFrame:CGRectMake(0, 0, DEVICEWITH, 100)];
    header.backgroundColor = self.tableView.backgroundColor;
    header.nameText = @"麦当劳";
    if (section == 0) {
        return header;
    }else{
        return [[UIView alloc] init];
    }
}

#pragma mark - actionSheet delegate
- (void)KXActionSheet:(KXActionSheet *)sheet andIndex:(NSInteger)index{
    if (index == 0) {       //投诉给朋友
        
    }else if (index == 1){  //清空内容
        
    }else if (index == 2){  //不在关注
        
    }
}

#pragma mark - 按钮点击方法
//关注 、 进入服务号
- (void)bottomAction{
    if (self.isAttention) { //进入服务号
        
    }else{      //关注
        
    }
}

//更多操作
- (void)moreOperating{
    KXActionSheet *sheet = [[KXActionSheet alloc] initWithTitle:@"" cancellTitle:@"取消" andOtherButtonTitles:@[@"推荐给朋友",@"清空内容",@"不在关注"]];
    sheet.delegate = self;
    [sheet show];
}


#pragma mark - lazy
- (NSArray *)titlesArr{
    if (!_titlesArr) {
        if (self.isAttention) {
            _titlesArr = @[@[@"功能介绍",@"帐号主体"],@[@"接收消息",@"置顶服务号"],@[@"查看历史消息"]];
        }else{
            _titlesArr = @[@[@"功能介绍",@"帐号主体"],@[@"查看历史消息"]];
        }
    }
    return _titlesArr;
}

- (NSArray *)subTitlesArr{
    if (!_subTitlesArr) {
        _subTitlesArr = @[@"我是功能介绍我是功能介绍我是功能介绍我是功能介绍我是功能介绍我是功能介绍我是功能介绍我是功能介绍我是功能介绍我是功能介绍我是功能介绍我是功能介绍我是功能介绍我是功能介绍我是功能介绍我是功能介绍我是功能介绍我是功能介绍",@"我是帐号主体"];
    }
    return _subTitlesArr;
}

@end
