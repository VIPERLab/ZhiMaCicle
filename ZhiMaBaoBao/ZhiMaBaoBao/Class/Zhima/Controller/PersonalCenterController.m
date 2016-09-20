//
//  PersonalCenterController.m
//  ZhiMaBaoBao
//
//  Created by liugang on 16/9/18.
//  Copyright © 2016年 liugang. All rights reserved.
//  芝麻（个人中心）

#import "PersonalCenterController.h"
#import "KXPersonalCenterCell.h" 


#import "KXSettingController.h"  //个人设置
#import "LGFeedBackViewController.h" //意见反馈

#define PersonalCellHeight 45
#define PersonalCenterCellReusedId @"PersonalCenterCellReusedId"

@interface PersonalCenterController () <UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) NSArray *titleArray;
@property (nonatomic, strong) NSArray *imageArray;

@end

@implementation PersonalCenterController {
    UITableView *_tableView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupView];
    
}

- (void)setupView {
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    [self.view addSubview:_tableView];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:PersonalCenterCellReusedId];
    [_tableView registerClass:[KXPersonalCenterCell class] forCellReuseIdentifier:@"PersonalCenterCell"];
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    }
    return self.titleArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        KXPersonalCenterCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PersonalCenterCell" forIndexPath:indexPath];
        cell.name = @"kit";
        cell.imageName = @"userIcon";
        cell.subName = @"我就是我";
        return cell;
    }
    
    if (indexPath.section == 1) {
        UITableViewCell *Normalcell = [tableView dequeueReusableCellWithIdentifier:PersonalCenterCellReusedId forIndexPath:indexPath];
        Normalcell.textLabel.text = self.titleArray[indexPath.row];
        Normalcell.imageView.image = [UIImage imageNamed:self.imageArray[indexPath.row]];
        Normalcell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        UIView *bottomLineView = [[UIView alloc] initWithFrame:CGRectMake(20, PersonalCellHeight - 0.5, ScreenWidth - 10, 0.5)];
        bottomLineView.backgroundColor = [UIColor colorFormHexRGB:@"e1e1e1"];
        [Normalcell addSubview:bottomLineView];
        return Normalcell;
    }
    
    
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return 100;
    }
    return PersonalCellHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 20;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 1;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 0) {
        //个人信息
    }
    
    if (indexPath.section == 1 && indexPath.row == 0) {
        //我的相册
    } else if (indexPath.section == 1 && indexPath.row == 1) {
        //我的账户
    } else if (indexPath.section == 1 && indexPath.row == 2) {
        //意见反馈
        LGFeedBackViewController *feedBack = [[LGFeedBackViewController alloc] init];
        feedBack.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:feedBack animated:YES];
    } else if (indexPath.section == 1 && indexPath.row == 3) {
        //设置中心
        KXSettingController *setting = [[KXSettingController alloc] init];
        setting.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:setting animated:YES];
    }
    
}


#pragma mark - lazyLoad 
- (NSArray *)titleArray {
    if (!_titleArray) {
        _titleArray = @[@"相册",@"钱包",@"意见",@"设置"];
    }
    return _titleArray;
}

- (NSArray *)imageArray {
    if (!_imageArray) {
        _imageArray = @[@"PersonalCenter_Album",@"Personal_MyMoney",@"PersonalCenter_Suggest",@"PersonalCenter_Setting"];
    }
    return _imageArray;
}



@end
