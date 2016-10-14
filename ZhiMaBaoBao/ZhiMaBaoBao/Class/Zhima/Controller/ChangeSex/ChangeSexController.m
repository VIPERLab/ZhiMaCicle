//
//  ChangeSexController.m
//  ZhiMaBaoBao
//
//  Created by mac on 16/9/24.
//  Copyright © 2016年 liugang. All rights reserved.
//

#import "ChangeSexController.h"
#import "ChangeSexCell.h"

@interface ChangeSexController () <UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) NSArray *sexArray;
@end

@implementation ChangeSexController {
    UITableView *_tableView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setCustomTitle:@"性别"];
    [self setupView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupView {
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    [self.view addSubview:_tableView];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    [_tableView registerClass:[ChangeSexCell class] forCellReuseIdentifier:@"sexCell"];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.sexArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *title = self.sexArray[indexPath.row];
    ChangeSexCell *cell = [tableView dequeueReusableCellWithIdentifier:@"sexCell" forIndexPath:indexPath];
    cell.titleName = title;
    if (indexPath.row == 0) {
        if ([self.selectedSex isEqualToString:@"男"]) {
            cell.isSelected = YES;
        }
    } else if (indexPath.row == 1) {
        if ([self.selectedSex isEqualToString:@"女"]) {
            cell.isSelected = YES;
        }
    }
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 0) {
        ChangeSexCell *cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        cell.isSelected = YES;
        
        ChangeSexCell *cell2 = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
        cell2.isSelected = NO;
    } else {
        ChangeSexCell *cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        cell.isSelected = NO;
        
        ChangeSexCell *cell2 = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
        cell2.isSelected = YES;
    }
    
    
    
    NSString *value = [NSString string];
    if (indexPath.row == 0) {
        value = @"男";
    } else {
        value = @"女";
    }
    
    
    [LGNetWorking upLoadUserDataWithSessionID:USERINFO.sessionId andOpenFirAccount:USERINFO.userID andFunctionName:@"sex" andChangeValue:value block:^(ResponseData *responseData) {
        [LCProgressHUD hide];
        if (responseData.code != 0) {
            [LCProgressHUD showFailureText:@"修改失败"];
            return ;
        }
        
        UserInfo *info = [UserInfo read];
        info.sex = value;
        [info save];
        [LCProgressHUD showSuccessText:@"修改成功"];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [LCProgressHUD hide];
            [self.navigationController popViewControllerAnimated:YES];
        });
        
    }];
    
    
    
}





- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 10;
}


- (NSArray *)sexArray {
    if (!_sexArray) {
        _sexArray = @[@"男",@"女"];
    }
    return _sexArray;
}

@end
