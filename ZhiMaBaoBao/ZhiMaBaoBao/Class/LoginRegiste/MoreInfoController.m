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
#import "JPUSHService.h"


@interface MoreInfoController ()<UITableViewDelegate,UITableViewDataSource,LGPickerViewDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIPickerView *pickView;
@property (nonatomic, strong) NSMutableArray *dataArr;
@property (nonatomic, strong) NSIndexPath *selectIndexPath;    //tableView选中行
@property (nonatomic, strong) NSMutableDictionary *parmas;      //上传参数
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
    
    //存选择参数
    NSString *key = selectModel.item_code;
    NSInteger value = model.idd;
    self.parmas[key] = @(value);
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (self.isResgiste) {
        return 40;
    }
    return .1f;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, DEVICEWITH, 40)];
    footer.backgroundColor = [UIColor clearColor];
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(DEVICEWITH - 14 - 80, 0, 80, 40)];
    [btn setTitle:@"跳过>>" forState:UIControlStateNormal];
    [btn setTitleColor:GRAYCOLOR forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(jumpNext) forControlEvents:UIControlEventTouchUpInside];
    btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [footer addSubview:btn];
    
    if (self.isResgiste) {
        return footer;
    }
    return [[UIView alloc] init];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 10;
}

//保存更多资料
- (void)saveMoreInfo{
    [LCProgressHUD showLoadingText:@"请稍等..."];
    NSString *jsonStr = [self.parmas mj_JSONString];
    [LGNetWorking saveMoreUserInfo:USERINFO.sessionId moreData:jsonStr success:^(ResponseData *responseData) {
        if (responseData.code == 0) {
            if (self.isResgiste) {  //执行登录操作
                [self loginAction];
            }else{  //保存数据，跳转回上衣界面
                [LCProgressHUD showSuccessText:@"保存成功"];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self.navigationController popViewControllerAnimated:YES];
                });
            }
        }else{
            [LCProgressHUD showFailureText:responseData.msg];
        }
    } failure:^(ErrorData *error) {
        [LCProgressHUD showFailureText:error.msg];
    }];
    
}

//跳过 -> 执行登录操作
- (void)jumpNext{
    [self loginAction];
}

- (void)loginAction{
    [LCProgressHUD showLoadingText:@"正在登录..."];
    
    [self.view endEditing:YES];
    [LGNetWorking loginWithPhone:USERINFO.uphone password:self.password success:^(ResponseData *responseData) {
        if (responseData.code == 0) {
            [LCProgressHUD hide];
            UserInfo *info = [UserInfo read];
            info.hasLogin = YES;
            [info save];
            
            [JPUSHService setTags:[NSSet setWithObject:info.userID] alias:info.userID callbackSelector:nil object:nil];
            
            
            [LCProgressHUD hide];
            if (info.isVisitor) {

                [self dismissViewControllerAnimated:YES completion:nil];
            }else{
                [[SocketManager shareInstance] connect];
                [[NSNotificationCenter defaultCenter] postNotificationName:LOGIN_SUCCESS object:nil];
            }
            
        }else{
            [LCProgressHUD showFailureText:responseData.msg];
        }
    } failure:^(ErrorData *error) {
        [LCProgressHUD showFailureText:error.msg];
    }];
}


#pragma mark - lazy
- (NSMutableArray *)dataArr{
    if (!_dataArr) {
        _dataArr = [NSMutableArray array];
    }
    return _dataArr;
}

- (NSMutableDictionary *)parmas{
    if (!_parmas) {
        _parmas = [NSMutableDictionary dictionary];
    }
    return _parmas;
}

@end
