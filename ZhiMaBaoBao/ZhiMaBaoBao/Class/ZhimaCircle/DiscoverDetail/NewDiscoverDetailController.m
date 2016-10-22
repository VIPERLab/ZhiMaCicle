//
//  NewDiscoverDetailController.m
//  ZhiMaBaoBao
//
//  Created by mac on 16/10/21.
//  Copyright © 2016年 liugang. All rights reserved.
//

#import "NewDiscoverDetailController.h"
#import "SDTimeLineCellModel.h"

#import "NewDiscoverDetailHeaderView.h"
#import "NewDiscoverDetailCommentListView.h"

@interface NewDiscoverDetailController ()

@end

@implementation NewDiscoverDetailController {
    UIScrollView *_scrollView;
    SDTimeLineCellModel *_model;
    NewDiscoverDetailHeaderView *_headerView;
    NewDiscoverDetailCommentListView *_likeItemView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupNav];
    [self getDataFormSQL];
    [self setupView];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dataRequest {
//    __weak typeof(self) weakSelf = self;
    
    [LGNetWorking loadDiscoverDetailWithSessionID:self.sessionId andDetailID:self.ID block:^(ResponseData *responseData) {
        if (responseData.code != 0) {
            NSLog(@"调用失败");
            return ;
        }
        
        [self setupModelWithResponseData:responseData];
        
        [self setupView];
        
    }];
}



- (void)setupNav {
    self.view.backgroundColor = [UIColor whiteColor];
    [self setCustomTitle:@"详情"];
}

- (void)getDataFormSQL {
    _model = [FMDBShareManager getCircleContentWithCircleID:self.ID];
    [self dataRequest];
}

- (void)setupView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
        [self.view addSubview:_scrollView];
    }
    
    if (!_headerView) {
        _headerView = [[NewDiscoverDetailHeaderView alloc] init];
        [_scrollView addSubview:_headerView];
    }
    CGFloat headerHeight = [self headerViewHeight];
    _headerView.frame = CGRectMake(0, 0, ScreenWidth, headerHeight);
    _headerView.model = _model;
    
    
    if (!_likeItemView) {
        _likeItemView = [[NewDiscoverDetailCommentListView alloc] init];
        [_scrollView addSubview:_likeItemView];
    }
    
    if (_model.likeItemsArray.count == 0) {
        [_likeItemView removeFromSuperview];
    }
    
    _likeItemView.likeItemArray = _model.likeItemsArray;
    _likeItemView.frame = CGRectMake(10, CGRectGetMaxY(_headerView.frame) + 10, ScreenWidth - 20, 55);
    
    
    _scrollView.contentSize = CGSizeMake(ScreenWidth, CGRectGetMaxY(_likeItemView.frame));
    
    
}


#pragma mark - 设置模型
- (void)setupModelWithResponseData:(ResponseData *)responseData {
    
    SDTimeLineCellModel *model = [SDTimeLineCellModel mj_objectWithKeyValues:responseData.data];
    
    //转换数组类型
    if (model.imglist.count != 0) {
        NSArray *picArray = [SDTimeLineCellPicItemModel mj_objectArrayWithKeyValuesArray:model.imglist];
        model.imglist = picArray;
    }
    
    if (model.commentList.count !=0) {
        NSMutableArray *commentListArray = [SDTimeLineCellCommentItemModel mj_objectArrayWithKeyValuesArray:model.commentList];
        
        NSMutableArray *likeItemsArray = [NSMutableArray array];
        for (NSInteger index = commentListArray.count - 1; index >= 0 ; index--) {
            SDTimeLineCellCommentItemModel *model = commentListArray[index];
            if (model.type) {
                [commentListArray removeObject:model];
                
                SDTimeLineCellLikeItemModel *likeModel = [[SDTimeLineCellLikeItemModel alloc] init];
                likeModel.userName = model.friend_nick;
                likeModel.userId = model.userId;
                likeModel.userPhoto = model.head_photo;
                [likeItemsArray addObject:likeModel];
            }
        }
        model.likeItemsArray = likeItemsArray;
        model.commentList = commentListArray;
        
        
    }
    
    
    _model = model;
    
}



// 计算上部分的高度
- (CGFloat)headerViewHeight {
    CGFloat height = 0;
    
    if (_model.content.length > 0) {
        height = [_model.content sizeWithFont:[UIFont systemFontOfSize:15] maxSize:CGSizeMake(ScreenWidth - 100, MAXFLOAT)].height + 35;
    }
    height = height > 50 ? height : 50;
    
    CGFloat imageCount = _model.imglist.count;
    if (imageCount == 1) {
        height += 120;
    } else if (imageCount > 1 && imageCount <= 3) {
        height += 80;
    } else if (imageCount >= 4 && imageCount <= 6) {
        height += 160;
    } else if (imageCount >= 7 && imageCount <= 9) {
        height += 240;
    }
    
    height += 35;
    
    return height;
}

@end
