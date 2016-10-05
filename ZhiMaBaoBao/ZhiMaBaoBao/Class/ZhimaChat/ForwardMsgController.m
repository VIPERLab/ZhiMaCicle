//
//  ForwardMsgController.m
//  ZhiMaBaoBao
//
//  Created by liugang on 16/10/5.
//  Copyright © 2016年 liugang. All rights reserved.
//  转发消息

#import "ForwardMsgController.h"
#import "AvtarAndNameCell.h"
#import "CreateGroupChatController.h"

@interface ForwardMsgController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) NSMutableArray *containArray;     //拷贝一份数据源，用作搜索匹配
@end

static NSString *const headerReuseIdentifier = @"headerReuseIdentifier";
static NSString *const reuseIdentifier = @"AvtarAndNameCell";

@implementation ForwardMsgController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setNavBackItem];
    [self addAllSubviews];
    [self getDataFormSqlist];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(searchMatchResult) name:UITextFieldTextDidChangeNotification object:nil];
}

//设置导航栏取消按钮
- (void)setNavBackItem{
    UIButton *cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 40)];
    cancelBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    [cancelBtn setTitleColor:THEMECOLOR forState:UIControlStateNormal];
    [cancelBtn addTarget:self action:@selector(navBackAction) forControlEvents:UIControlEventTouchUpInside];
    cancelBtn.titleLabel.font = MAINFONT;
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:cancelBtn];
}

- (void)addAllSubviews{
    //顶部搜索栏
    UIView *searchView = [[UIView alloc] initWithFrame:CGRectMake(0, 64, DEVICEWITH, 50)];
    searchView.backgroundColor = WHITECOLOR;
    [self.view addSubview:searchView];
    
    //搜索图片
    UIImageView *seachImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"lsearch"]];
    seachImage.frame = CGRectMake(14, 15, 19, 21);
    [searchView addSubview:seachImage];
    
    //输入框
    UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(40, 10, 200, 30)];
    textField.font = MAINFONT;
    textField.placeholder = @"搜索";
    self.textField = textField;
    [searchView addSubview:textField];
    
    //分割线
    UIView *separtor = [[UIView alloc] initWithFrame:CGRectMake(0, 49, DEVICEWITH, 1)];
    separtor.backgroundColor = SEPARTORCOLOR;
    [searchView addSubview:separtor];
    
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(searchView.frame), DEVICEWITH, DEVICEHIGHT - searchView.height) style:UITableViewStylePlain];
    [tableView registerNib:[UINib nibWithNibName:@"AvtarAndNameCell" bundle:nil] forCellReuseIdentifier:reuseIdentifier];
    [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:headerReuseIdentifier];
    tableView.delegate = self;
    tableView.dataSource = self;
    [self.view addSubview:tableView];
    self.tableView = tableView;

}

#pragma mark - 从数据库加载会话列表
- (void)getDataFormSqlist {
    //先清空会话数组
    [self.dataArray removeAllObjects];
    
    NSArray *dataArray = [FMDBShareManager getChatConverseDataInArray];
    self.dataArray = [dataArray mutableCopy];
    self.containArray = [dataArray mutableCopy];
    [_tableView reloadData];
}

//搜索框匹配
- (void)searchMatchResult{
    [self.dataArray removeAllObjects];
    if (!self.textField.hasText) {
        self.dataArray = [self.containArray mutableCopy];
    }else{
        for (ConverseModel *model in self.containArray) {
            if ([model.converseName containsString:self.textField.text]) {
                [self.dataArray addObject:model];
            }
        }
    }
    [self.tableView reloadData];
}

#pragma mark - tableView delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return 1;
    }else{
        return self.dataArray.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:headerReuseIdentifier];
        cell.textLabel.text = @"创建新的聊天";
        cell.textLabel.font = MAINFONT;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        return cell;
    }else{
        AvtarAndNameCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
        ConverseModel *conversion = self.dataArray[indexPath.row];
        cell.conversion = conversion;
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {   //跳转到选择好友控制器
        CreateGroupChatController *vc = [[CreateGroupChatController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    }else{  //转发消息
        
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 53;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return 0.1f;
    }else{
        return 20;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.1f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        
        return [UIView new];
    }else{
        UIView *headerView  = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICEWITH, 20)];
        headerView.backgroundColor = RGB(229, 229, 229);
        
        UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(14, 0, DEVICEWITH - 14, 20)];
        titleLabel.text = @"最近聊天";
        titleLabel.font = [UIFont systemFontOfSize:15.0];
        titleLabel.textColor = RGB(147, 147, 147);
        titleLabel.backgroundColor = [UIColor clearColor];
        [headerView addSubview:titleLabel];
        return headerView;
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [self.textField resignFirstResponder];
}

- (void)navBackAction{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - lazy
- (NSMutableArray *)dataArray{
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

- (NSMutableArray *)containArray{
    if (!_containArray) {
        _containArray = [NSMutableArray array];
    }
    return _containArray;
}

@end
