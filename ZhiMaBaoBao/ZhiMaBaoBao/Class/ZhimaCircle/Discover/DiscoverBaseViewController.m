//
//  DiscoverBaseViewController.m
//  DemoDiscover
//
//  Created by kit on 16/8/20.
//  Copyright © 2016年 kit. All rights reserved.
//

#import "DiscoverBaseViewController.h"
#import "DiscoverController.h"
#import "SDTimeLineTableViewController.h"
#import "CicleCell.h"


@interface DiscoverBaseViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *titleListArray;

@end

@implementation DiscoverBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupNav];
    
    [self setupTableView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)setupNav {
    
//    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 5, 100, 40)];
//    
//    [button setTitle:@"芝麻(1)" forState:UIControlStateNormal];
//    [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
//    
//    [self.navigationController.navigationBar addSubview:button];
//    
//    
//    CGFloat addButtonWidth = 40;
//    UIButton *addButton = [[UIButton alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width - addButtonWidth - 30, 5, addButtonWidth, addButtonWidth)];
//    [addButton setTitle:@"加号" forState:UIControlStateNormal];
//    [addButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
//    
//    [self.navigationController.navigationBar addSubview:addButton];
//    
//    
//    
//    UIButton *searchButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMinX(addButton.frame) - 30 - 40, 5, 45, 45)];
//    [searchButton setTitle:@"搜索" forState:UIControlStateNormal];
//    [searchButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
//    
//    [self.navigationController.navigationBar addSubview:searchButton];
    
}


- (void)setupTableView {
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 64) style:UITableViewStyleGrouped];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerClass:[CicleCell class] forCellReuseIdentifier:@"CicleCell"];
    
    [self.view addSubview:self.tableView];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.titleListArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    }
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *array = self.titleListArray[indexPath.section];
    CicleCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CicleCell" forIndexPath:indexPath];
    cell.titleName = array[indexPath.row];
    
    if (indexPath.section == 0) {
        //朋友圈cell
//        if (USERINFO.lastUpDataHeader) {
            UIImageView *imageView = [[UIImageView alloc] init];
            [cell addSubview:imageView];
            CGFloat imageW = 45;
            CGFloat imageH = imageW;
            CGFloat imageX = [UIScreen mainScreen].bounds.size.width - imageW - 30;
            CGFloat imageY = 7;
            imageView.frame = CGRectMake(imageX, imageY, imageW, imageH);
            imageView.backgroundColor = [UIColor redColor];
            
//            [imageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",DFAPIURL,USERINFO.lastUpDataHeader]] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
//                imageView.image = image;
//            }];
            
            
            
//        }
        
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.5;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        
        SDTimeLineTableViewController *VC = [[SDTimeLineTableViewController alloc] init];
        VC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:VC animated:YES];
    }
}


#pragma mark - lazyLoad
- (NSMutableArray *)titleListArray {
    if (!_titleListArray) {
        _titleListArray = @[@[@"朋友圈"],@[@"扫一扫",@"附近的人"]];
    }
    return _titleListArray;
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
