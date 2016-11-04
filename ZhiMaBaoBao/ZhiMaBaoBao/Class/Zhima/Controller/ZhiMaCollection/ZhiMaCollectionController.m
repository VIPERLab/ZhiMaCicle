//
//  ZhiMaCollectionController.m
//  ZhiMaBaoBao
//
//  Created by mac on 16/10/7.
//  Copyright © 2016年 liugang. All rights reserved.
//

#import "ZhiMaCollectionController.h"
#import "ZhiMaCollectionHeaderView.h"
#import "ZhiMaCollectionCell.h"

#import "PKFullScreenPlayerViewController.h"
#import "ZhiMaCollectionDetailController.h"

#define ZhiMaCollectionCellReusedID @"ZhiMaCollectionCellReusedID"

@interface ZhiMaCollectionController () <UITableViewDelegate,UITableViewDataSource,ZhiMaCollectionCellDelegate>
@property (nonatomic, strong) NSMutableArray *dataArray;
@end

@implementation ZhiMaCollectionController {
    UITableView *_tableView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupView];
    
}

- (void)viewWillAppear:(BOOL)animated {
    
//    self.dataArray = [[FMDBShareManager getAllCollectionsWithUserId:USERINFO.userID] mutableCopy];
//    if (!self.dataArray.count) {
        [self getResponData];
//    } else {
//        [_tableView reloadData];
//    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)getResponData {
    [LGNetWorking getCollectionListWithSessionId:USERINFO.sessionId success:^(ResponseData *responseData) {
        
        if (responseData.code != 0) {
            [self.dataArray removeAllObjects];
            [_tableView reloadData];
            return ;
        }
        
        NSMutableArray *dataArray = [ZhiMaCollectionModel mj_objectArrayWithKeyValuesArray:responseData.data];
        self.dataArray = dataArray;
        dispatch_sync(dispatch_get_global_queue(0, 0), ^{
            [FMDBShareManager saveCollectionWithCollectionArray:dataArray];
        });
        
        [_tableView reloadData];
        
    } failure:^(ErrorData *error) {
        
    }];
}

- (void)setupView {
    [self setCustomTitle:@"收藏"];
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    [self.view addSubview:_tableView];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    [_tableView registerClass:[ZhiMaCollectionCell class] forCellReuseIdentifier:ZhiMaCollectionCellReusedID];
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ZhiMaCollectionModel *model = self.dataArray[indexPath.section];
    ZhiMaCollectionCell *cell = [tableView dequeueReusableCellWithIdentifier:ZhiMaCollectionCellReusedID forIndexPath:indexPath];
    cell.model = model;
    cell.delegate = self;
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    ZhiMaCollectionModel *model = self.dataArray[indexPath.section];
    return model.cellHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 0.1;
    }
    return 7;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.1;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    ZhiMaCollectionModel *model = self.dataArray[indexPath.section];
    ZhiMaCollectionDetailController *detail = [[ZhiMaCollectionDetailController alloc] init];
    detail.model = model;
    [self.navigationController pushViewController:detail animated:YES];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source.
        ZhiMaCollectionModel *model = self.dataArray[indexPath.section];
        // 删除
        [LGNetWorking deletedCircleCollectionWithSessionId:USERINFO.sessionId andCollectionId:model.ID success:^(ResponseData *responseData) {
            
            if (responseData.code != 0) {
                return ;
            }
            
            [LCProgressHUD showSuccessText:@"删除成功"];
            [self.dataArray removeObject:model];
            [tableView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationTop];
            
        } failure:^(ErrorData *error) {
            
        }];
    }
}


#pragma mark - vedioButtonDidClick 
- (void)vedioButtonDidClick:(ZhiMaCollectionModel *)model {
    NSArray *strArray = [model.content componentsSeparatedByString:@"/"];
    NSString *path = [NSString stringWithFormat:@"%@/%@",AUDIOPATH,[strArray lastObject]];
    if (model.isDownload) {
        PKFullScreenPlayerViewController *player = [[PKFullScreenPlayerViewController alloc] initWithVideoPath:path previewImage:[UIImage imageNamed:@"Image_placeHolder"]];
        [self presentViewController:player animated:YES completion:nil];
        return;
    } else {
        [self downloadVedio:model];
    }
}

- (void)downloadVedio:(ZhiMaCollectionModel *)model {
    NSArray *strArray = [model.content componentsSeparatedByString:@"/"];
    NSString*path = [NSString stringWithFormat:@"%@/%@",AUDIOPATH,[strArray lastObject]];
    [LCProgressHUD showLoadingText:@"下载中"];
    [LGNetWorking chatDownloadVideo:path urlStr:model.content block:^(NSDictionary *responseData) {
        [LCProgressHUD hide];
        model.isDownload = YES;
        PKFullScreenPlayerViewController *player = [[PKFullScreenPlayerViewController alloc] initWithVideoPath:path previewImage:[UIImage imageNamed:@"Image_placeHolder"]];
        [self presentViewController:player animated:YES completion:nil];
        return ;
        
    } progress:^(NSProgress *progress) {
        
        
    } failure:^(NSError *error) {
        [LCProgressHUD showFailureText:@"视频加载失败"];
    }];
}

- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

@end
