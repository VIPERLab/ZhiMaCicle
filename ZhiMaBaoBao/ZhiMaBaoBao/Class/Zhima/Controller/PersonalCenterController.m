//
//  PersonalCenterController.m
//  ZhiMaBaoBao
//
//  Created by liugang on 16/9/18.
//  Copyright © 2016年 liugang. All rights reserved.
//  芝麻（个人中心）

#import "PersonalCenterController.h"
#import "KXPersonalCenterCell.h"

#import "KXSettingController.h"        //设置
#import "LGFeedBackViewController.h"   //意见反馈
#import "MyAccountViewController.h"    //我的账户
#import "KXPersonalMessageSettingController.h" //个人信息设置
#import "ZhiMaCollectionController.h"  //收藏
#import "PesonalDiscoverController.h"

#import "ViciterLoginView.h"
#define PersonalCellHeight 45
#define PersonalCenterCellReusedId @"PersonalCenterCellReusedId"

@interface PersonalCenterController () <UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) NSArray *titleArray;
@property (nonatomic, strong) NSArray *imageArray;
@property (nonatomic, assign) BOOL hidePurse;       //隐藏钱包

@end

@implementation PersonalCenterController {
    UITableView *_tableView;
    ViciterLoginView *_viciterView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setNaviTitle:@"芝麻"];

    [self setCustomRightItems];
    [self setupView];
    [self setupVisiterView];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:YES];
    
    UserInfo *info = [UserInfo read];
    self.hidePurse = info.hidePurse;
    
    if (![USERINFO.sessionId isEqualToString:@"0"]) {
        _viciterView.hidden = YES;
        _tableView.hidden = NO;
    } else {
        _viciterView.hidden = NO;
        _tableView.hidden = YES;
    }
    
    [_tableView reloadData];
}


- (void)setupVisiterView {
    ViciterLoginView *viciter = [[ViciterLoginView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
    _viciterView = viciter;
    [viciter setLoginBlock:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:kPressentLoginRegiste object:nil];
    }];
    [self.view addSubview:viciter];
    
    
}


- (void)setupView {
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.backgroundColor = BGCOLOR;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.backgroundColor = [UIColor colorFormHexRGB:@"efeff4"];
    [self.view addSubview:_tableView];
    
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
        cell.name = USERINFO.username;
        cell.imageName = USERINFO.head_photo;
        cell.subName = USERINFO.signature;
        cell.Sex = USERINFO.sex;
        return cell;
    }
    
    if (indexPath.section == 1) {
        UITableViewCell *Normalcell = [tableView dequeueReusableCellWithIdentifier:PersonalCenterCellReusedId forIndexPath:indexPath];
        Normalcell.textLabel.text = self.titleArray[indexPath.row];
        Normalcell.imageView.image = [UIImage imageNamed:self.imageArray[indexPath.row]];
        Normalcell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        UIView *bottomLineView = [[UIView alloc] initWithFrame:CGRectMake(20, PersonalCellHeight - 0.5, ScreenWidth - 10, 0.5)];
        bottomLineView.backgroundColor = [UIColor colorFormHexRGB:@"dcdcdc"];
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
        KXPersonalMessageSettingController *setting = [[KXPersonalMessageSettingController alloc] init];
        setting.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:setting animated:YES];
    }
    
    if (indexPath.section == 1 && indexPath.row == 0) {
        //我的相册
        PesonalDiscoverController *VC = [[PesonalDiscoverController alloc] init];
        VC.sessionID = USERINFO.sessionId;
        VC.userID = USERINFO.userID;
        VC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:VC animated:YES];
        
    } else if (indexPath.section == 1 && indexPath.row == 1 && !self.hidePurse) {
        //钱包
        MyAccountViewController *MeAccVC = [[MyAccountViewController alloc]init];
        MeAccVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:MeAccVC animated:YES];
        
    } else if (indexPath.section == 1 && indexPath.row == self.titleArray.count - 3) {
        // 收藏
        ZhiMaCollectionController *collection = [[ZhiMaCollectionController alloc] init];
        collection.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:collection animated:YES];
        
    } else if (indexPath.section == 1 && indexPath.row == self.titleArray.count - 2) {
        //意见反馈
        LGFeedBackViewController *feedBack = [[LGFeedBackViewController alloc] init];
        feedBack.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:feedBack animated:YES];
        
    } else if (indexPath.section == 1 && indexPath.row == self.titleArray.count - 1) {
        //设置中心
        KXSettingController *setting = [[KXSettingController alloc] init];
        setting.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:setting animated:YES];
    }
}


- (void)loginButtonDidClick:(UIButton *)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:Show_Login object:nil];
}


#pragma mark - lazyLoad 
- (NSArray *)titleArray {
    if (!_titleArray) {
        if (self.hidePurse) {
            _titleArray = @[@"相册",@"收藏",@"意见",@"设置"];
        }else{
            _titleArray = @[@"相册",@"钱包",@"收藏",@"意见",@"设置"];
        }
    }
    return _titleArray;
}

- (NSArray *)imageArray {
    if (!_imageArray) {
        if (self.hidePurse) {
            _imageArray = @[@"PersonalCenter_Album",@"ZhiMa_Collection_Icon",@"PersonalCenter_Suggest",@"PersonalCenter_Setting"];
        }else{
            _imageArray = @[@"PersonalCenter_Album",@"Personal_MyMoney",@"ZhiMa_Collection_Icon",@"PersonalCenter_Suggest",@"PersonalCenter_Setting"];
        }
    }
    return _imageArray;
}



@end
