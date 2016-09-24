//
//  ChangeSexController.m
//  ZhiMaBaoBao
//
//  Created by mac on 16/9/24.
//  Copyright © 2016年 liugang. All rights reserved.
//

#import "ChangeSexController.h"

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
    
    [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"sexCell"];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.sexArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *title = self.sexArray[indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"sexCell" forIndexPath:indexPath];
    cell.textLabel.text = title;
    
    if ([title isEqualToString:self.selectedSex]) {
        cell.selected = YES;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UserInfo *info = [UserInfo read];
    if (indexPath.row == 0) {
        info.sex = @"男";
    } else if (indexPath.row == 1) {
        info.sex = @"女";
    }
    [info save];
    [self.navigationController popViewControllerAnimated:YES];
    
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
