//
//  LGSearchController.m
//  YiIM_iOS
//
//  Created by liugang on 16/8/11.
//  Copyright © 2016年 ikantech. All rights reserved.
//  搜索好友

#import "LGSearchController.h"
#import "LGSearchResultController.h"
#import "LGSearchResultCell.h"
#import "pinyin.h"

@interface LGSearchController ()<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate>

@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic,strong) NSMutableArray *nameAry;       //排序好的总好友数据
@property (nonatomic,strong) NSMutableArray *sectionAry;    //存放匹配的好友数据
@property (nonatomic,strong) NSMutableArray *numberAry;
@property (nonatomic,strong) NSMutableArray *dataArr;

@end

@implementation LGSearchController

- (NSMutableArray *)dataArr{
    if (!_dataArr) {
        _dataArr = [NSMutableArray array];
    }
    return _dataArr;
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
    
    self.navigationController.navigationBar.hidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated{
    self.navigationController.navigationBar.hidden = NO;

}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = WHITECOLOR;
    [self setUI];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 70, DEVICEWITH, DEVICEHIGHT - 70) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.tableView.backgroundColor = WHITECOLOR;
    [self.view addSubview:self.tableView];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChange:) name:UITextFieldTextDidChangeNotification object:nil];
    
    [self.view becomeFirstResponder];
}

//设置顶部搜索框UI
- (void)setUI{
    UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0, 20, DEVICEWITH, 50)];
    topView.backgroundColor = BGCOLOR;
    [self.view addSubview:topView];
    
    UIView *whiteView = [[UIView alloc] initWithFrame:CGRectMake(14, 10, DEVICEWITH - 70, 30)];
    whiteView.backgroundColor = WHITECOLOR;
    whiteView.layer.cornerRadius = 5;
    [topView addSubview:whiteView];
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    [btn setImage:[UIImage imageNamed:@"lsearch"] forState:UIControlStateNormal];
    [whiteView addSubview:btn];
    [btn addTarget:self action:@selector(searchAction) forControlEvents:UIControlEventTouchUpInside];
    
    UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(41, 0, DEVICEWITH - 80, 30)];
    textField.borderStyle = UITextBorderStyleNone;
    textField.font = MAINFONT;
    [whiteView addSubview:textField];
    textField.delegate = self;
    self.textField = textField;
    
    //取消按钮
    UIButton *cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(DEVICEWITH - 55, 5, 50, 40)];
    [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    [cancelBtn setTitleColor:THEMECOLOR forState:UIControlStateNormal];
    [topView addSubview:cancelBtn];
    [cancelBtn addTarget:self action:@selector(cancelAction) forControlEvents:UIControlEventTouchUpInside];
}

//搜索好友
- (void)searchAction{
    
}

//好友排序
- (void)setSequenceOfAgentName{
    

}


- (void)cancelAction{
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return self.sectionAry.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    LGSearchResultCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SearchCell"];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"LGSearchResultCell" owner:nil options:nil] firstObject];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 53;
}



@end
