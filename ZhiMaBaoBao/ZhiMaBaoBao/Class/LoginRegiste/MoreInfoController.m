//
//  MoreInfoController.m
//  ZhiMaBaoBao
//
//  Created by liugang on 16/10/20.
//  Copyright © 2016年 liugang. All rights reserved.
//  更多资料

#import "MoreInfoController.h"
#import "MoreInfoCell.h"
#import "LGPickerView.h"
#import "MoreInfoModel.h"

@interface MoreInfoController ()<UITableViewDelegate,UITableViewDataSource,LGPickerViewDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIPickerView *pickView;
@property (nonatomic, strong) NSMutableArray *dataArr;
@property (nonatomic, strong) NSIndexPath *selectIndexPath;    //tableView选中行
@end

static  NSString *const reuserIdentifier = @"moreInfoCell";
@implementation MoreInfoController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setCustomTitle:@""];
    
    [self addAllsubViews];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [LGNetWorking getMoreUserInfo:USERINFO.sessionId success:^(ResponseData *responseData) {
        if (responseData.code == 0) {
            //生成个人更多信息数据模型
            [MoreInfoModel mj_setupObjectClassInArray:^NSDictionary *{
                return @{
                         @"list":@"MoreInfoModel"
                         };
            }];
            self.dataArr = [MoreInfoModel mj_objectArrayWithKeyValuesArray:responseData.data];
            [self.tableView reloadData];
            
            
        }else{
            [LCProgressHUD showFailureText:responseData.msg];
        }
    } failure:^(ErrorData *error) {
        [LCProgressHUD showFailureText:error.msg];
    }];
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
    
}

#pragma mark - tableView delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    MoreInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:reuserIdentifier];
    MoreInfoModel *model = self.dataArr[indexPath.row];
    //设置标题
    cell.titleLabel.text = model.item_name;
    
    //设置副标题
    NSArray *list = model.list;
    for (MoreInfoModel *subModel in list) {
        if ([model.selectedId integerValue] == subModel.idd) {
            cell.subTitleLabel.text = subModel.item_name;
            break;
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.selectIndexPath = indexPath;
    MoreInfoModel *model = self.dataArr[indexPath.row];
    
    LGPickerView *pickerView = [LGPickerView pickerView];
    [self.view insertSubview:pickerView aboveSubview:self.tableView];
    pickerView.delegate = self;
    pickerView.title = model.item_name;
    pickerView.dataArr = model.list;
    [pickerView show];
}

//pickview确定按钮点击方法
- (void)selectedRow:(NSInteger)row andModel:(MoreInfoModel *)model{
    MoreInfoModel *selectModel = self.dataArr[self.selectIndexPath.row];
    selectModel.selectedId = [NSString stringWithFormat:@"%ld",(long)model.idd];
    [self.tableView reloadRowsAtIndexPaths:@[self.selectIndexPath] withRowAnimation:UITableViewRowAnimationFade];
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
- (NSMutableArray *)dataArr{
    if (!_dataArr) {
        _dataArr = [NSMutableArray array];
    }
    return _dataArr;
}

@end
