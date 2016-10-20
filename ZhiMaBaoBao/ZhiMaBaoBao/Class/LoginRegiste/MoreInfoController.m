//
//  MoreInfoController.m
//  ZhiMaBaoBao
//
//  Created by liugang on 16/10/20.
//  Copyright © 2016年 liugang. All rights reserved.
//  更多资料

#import "MoreInfoController.h"
#import "MoreInfoCell.h"

@interface MoreInfoController ()<UITableViewDelegate,UITableViewDataSource,UIPickerViewDelegate,UIPickerViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *titleArr;
@property (nonatomic, strong) NSMutableArray *subTitleArr;
@property (nonatomic, strong) UIPickerView *pickView;
@end

static  NSString *const reuserIdentifier = @"moreInfoCell";
@implementation MoreInfoController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setCustomTitle:@""];
    
    [self addAllsubViews];
}

- (void)addAllsubViews{
    UIButton *rightBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    rightBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [rightBtn setTitle:@"保存" forState:UIControlStateNormal];
    [rightBtn setTitleColor:THEMECOLOR forState:UIControlStateNormal];
    rightBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [rightBtn addTarget:self action:@selector(saveMoreInfo) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    [tableView registerNib:[UINib nibWithNibName:@"MoreInfoCell" bundle:nil] forCellReuseIdentifier:reuserIdentifier];
    tableView.delegate = self;
    tableView.dataSource = self;
    [self.view addSubview:tableView];
    self.tableView = tableView;
    
    
    UIPickerView *pickView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, DEVICEHIGHT - 150, DEVICEWITH, 150)];
    pickView.delegate = self;
    pickView.dataSource = self;
    [self.view addSubview:pickView];
    self.pickView = pickView;
}

#pragma mark - pickView delegate
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return self.titleArr.count;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component{
    return 44;
}

- (nullable UIView *)viewForRow:(NSInteger)row forComponent:(NSInteger)component{
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, DEVICEWITH, 44)];
    view.backgroundColor = WHITECOLOR;
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, DEVICEWITH, 44)];
    label.backgroundColor = [UIColor clearColor];
    label.text = self.titleArr[component];
    label.font = MAINFONT;
    label.textAlignment = NSTextAlignmentCenter;
    [view addSubview:label];
    
    return view;
}


#pragma mark - tableView delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.titleArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    MoreInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:reuserIdentifier];
    cell.titleLabel.text = self.titleArr[indexPath.row];
    cell.subTitleLabel.text = self.subTitleArr[indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return .1f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 10;
}

//保存更多资料
- (void)saveMoreInfo{
    
}


#pragma mark - lazy
- (NSArray *)titleArr{
    if (!_titleArr) {
        _titleArr = @[@"出生年月",@"收入",@"工作类型",@"兴趣",@"情感状况",@"星座"];
    }
    return _titleArr;
}

- (NSMutableArray *)subTitleArr{
    if (!_subTitleArr) {
        _subTitleArr = [NSMutableArray arrayWithObjects:@"",@"",@"",@"",@"",@"", nil];
    }
    return _subTitleArr;
}
@end
