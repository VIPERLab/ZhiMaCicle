//
//  DiscoverDetailController.m
//  DemoDiscover
//
//  Created by kit on 16/8/21.
//  Copyright © 2016年 kit. All rights reserved.
//

#import "DiscoverDetailController.h"

#import "DiscoverDetailHeaderView.h"

#import "SDTimeLineCellModel.h"
#import "WebViewController.h"
#import "PesonalDiscoverController.h"

#import "LGNetWorking.h"
#import "SDAutoLayout.h"
#import "ChatKeyBoard.h" //键盘工具条
#import "FaceSourceManager.h"

@interface DiscoverDetailController () <DiscoverDetailDelegete,UIAlertViewDelegate,ChatKeyBoardDelegate, ChatKeyBoardDataSource,UIScrollViewDelegate>

@property (nonatomic, weak) UIScrollView *scrollView;

@property (nonatomic, strong) SDTimeLineCellModel *model;
@property (nonatomic, weak) DiscoverDetailHeaderView *headerView;
@property (nonatomic, strong) NSMutableArray *picArray;

@property (nonatomic, copy) NSString *commentUserID;
@property (nonatomic, strong) ChatKeyBoard *chatKeyBoard; //富文本键盘

@property (nonatomic, weak) SDTimeLineCellCommentItemModel *tempCommentItemModel;

@property (nonatomic, strong) NSMutableArray *cellHightArray;
@end

@implementation DiscoverDetailController

- (void)loadView {
    [super loadView];
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 64, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 64)];
    self.scrollView = scrollView;
    self.scrollView.delegate = self;
    self.scrollView.contentOffset = CGPointMake(0, 0);
    self.scrollView.contentSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    self.view = scrollView;
    
    //成为评论框的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(commentViewDidClick:) name:KCommentOtherNotification object:nil];
    
    [self setupKeyBoard];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [self getDetail];
    [self setupView];
    [self setCustomTitle:@"详情"];
    self.view.backgroundColor = [UIColor whiteColor];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self updataScrollViewContentSize];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)setupView {
    DiscoverDetailHeaderView *headerView = [[DiscoverDetailHeaderView alloc] init];
    self.headerView = headerView;
    headerView.delegate = self;
    [self.scrollView addSubview:headerView];
    
    headerView.sd_layout
    .leftEqualToView(self.scrollView)
    .topEqualToView(self.scrollView)
    .rightEqualToView(self.scrollView);
    
}


#pragma mark - 网络请求
- (void)getDetail {
    
    __weak typeof(self) weakSelf = self;
    
    [LGNetWorking loadDiscoverDetailWithSessionID:self.sessionId andDetailID:self.ID block:^(ResponseData *responseData) {
        if (responseData.code != 0) {
            NSLog(@"调用失败");
            return ;
        }
        
        [self setupModelWithResponseData:responseData];
        
        
        //更新数据库
        [FMDBShareManager deletedCircleCommentItemsAndLikeItemsByCircleID:self.model.circle_ID];
        [FMDBShareManager saveCircleDataWithDataArray:@[self.model]];
        
        //通知朋友圈页面更新数据
        [[NSNotificationCenter defaultCenter] postNotificationName:K_ReFreshCircleDataNotification object:nil userInfo:@{ @"circleModel" : self.model}];
        
        
        weakSelf.headerView.model = self.model;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakSelf updataScrollViewContentSize];
        });
        
        
    }];
    
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
                    [likeItemsArray insertObject:likeModel atIndex:0];
                }
            }
            model.likeItemsArray = likeItemsArray;
            model.commentList = commentListArray;
            
            
        }
        
    
    self.model = model;

}

#pragma makr - 更新scrollView的可滑动范围
- (void)updataScrollViewContentSize {
    CGFloat headerHeight = CGRectGetMaxY(_headerView.frame) + 15;
    
    headerHeight = headerHeight > ([UIScreen mainScreen].bounds.size.height - 64) ? headerHeight : ([UIScreen mainScreen].bounds.size.height - 64);
    self.scrollView.contentSize = CGSizeMake(0, headerHeight);
}



#pragma mark - 事件传递(评论、删除)
- (void)commentViewDidClickMLLink:(NSString *)linkValue andLinkType:(int)type {
    if (type == 0) { //个人
        PesonalDiscoverController *person = [[PesonalDiscoverController alloc] init];
        person.userID = linkValue;
        person.sessionID = USERINFO.sessionId;
        [self.navigationController pushViewController:person animated:YES];
    } else if (type == 1) { //链接
        WebViewController *web = [[WebViewController alloc] init];
        web.urlStr = linkValue;
        [self.navigationController pushViewController:web animated:YES];
    }
    
}



// -----    删除朋友圈按钮
- (void)DiscoverDetailDeletedButtonDidClick:(DiscoverDetailHeaderView *)view {
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"是否确认删除" message:@"" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"删除", nil];
    alertView.tag = 0;
    [alertView show];
}

// ---- 点击别人的头像
- (void)DidClickLikeItemButton:(SDTimeLineCellLikeItemModel *)likeModel {
    PesonalDiscoverController *person = [[PesonalDiscoverController alloc] init];
    person.userID = likeModel.userId;
    person.sessionID = USERINFO.sessionId;
    [self.navigationController pushViewController:person animated:YES];
}


// ------   评论按钮
- (void)DiscoverDetailOperationButtonDidClickComment:(DiscoverDetailHeaderView *)view {
    self.commentUserID = @"0";
    self.chatKeyBoard.placeHolder = @"";
    [self.chatKeyBoard keyboardUpforComment];
}


- (void)commentViewDidClick:(NSNotification *)notification {
    UIView *commentView = notification.userInfo[@"commentView"];
    SDTimeLineCellCommentItemModel *commentModel = notification.userInfo[@"commentModel"];
    
    if ([commentModel.userId isEqualToString:USERINFO.userID]) {
        //删除自己的评论
        self.tempCommentItemModel = commentModel;
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"是否要删除评论" message:@"" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        alertView.tag = 10;
        [alertView show];
        
        return;
    }
    
    self.commentUserID = commentModel.userId;
    self.chatKeyBoard.placeHolder = [NSString stringWithFormat:@"回复:%@",commentModel.friend_nick];
    [self adjustTableViewToFitKeyboard:commentView];
    
}



#pragma mark - alertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    //删除朋友圈
    if (alertView.tag == 0) {
        if (buttonIndex == 1) {
            [self DeleteMyDiscover];
        }
    }
    
    //删除自己的评论
    if (alertView.tag == 10) {
        if (buttonIndex != 0) {
            [self deleteMyComment:self.tempCommentItemModel andDiscoverCellIndex:nil];
        }
    }
    
}

#pragma mark - 删除自己的评论
- (void)deleteMyComment:(SDTimeLineCellCommentItemModel *)commentModel andDiscoverCellIndex:(NSIndexPath *)indexPath {
    
    [LGNetWorking DeletedMyCommentWithSessionID:USERINFO.sessionId andOpenFirAccount:USERINFO.userID andFcid:commentModel.ID block:^(ResponseData *responseData) {
        
        if (responseData.code != 0 || responseData == nil) {
            [LCProgressHUD showFailureText:@"删除评论失败"];
            return ;
        }
        [LCProgressHUD showSuccessText:@"删除成功"];
        [self getDetail];
        
    }];
}

#pragma mark - 发送按钮回调
- (void)chatKeyBoardSendText:(NSString *)text {
    [LGNetWorking LikeOrCommentDiscoverWithSessionID:USERINFO.sessionId andFcId:self.headerView.model.circle_ID andComment:text andReply_userId:self.commentUserID block:^(ResponseData *responseData) {
        
        if (responseData.code != 0) {
            return ;
        }
        
        [self.chatKeyBoard keyboardDownForComment];
        [self getDetail];
        
    }];
}


// -------   点赞按钮 网络请求
- (void)DiscoverDetailOperationButtonDidClickLike:(DiscoverDetailHeaderView *)view {
    SDTimeLineCellModel *model = view.model;
    [LGNetWorking LikeOrCommentDiscoverWithSessionID:USERINFO.sessionId andFcId:model.circle_ID andComment:@"" andReply_userId:@"0" block:^(ResponseData *responseData) {
        if (responseData.code != 0) {
            return ;
        }
        [self getDetail];
    }];
}


#pragma mark - 设置键盘
- (void)setupKeyBoard {
    self.chatKeyBoard = [ChatKeyBoard keyBoard];
    self.chatKeyBoard.delegate = self;
    self.chatKeyBoard.dataSource = self;
    self.chatKeyBoard.keyBoardStyle = KeyBoardStyleComment;
    self.chatKeyBoard.allowVoice = NO;
    self.chatKeyBoard.placeHolder = @"请输入消息";
    //    [self.view addSubview:self.chatKeyBoard];
    [[UIApplication sharedApplication].keyWindow addSubview:self.chatKeyBoard];
}


#pragma mark - 调整界面位置
- (void)adjustTableViewToFitKeyboard:(UIView *)targetView;
{
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    //获取cell 相对于window 的frame
    CGRect rect = [targetView.superview convertRect:targetView.frame toView:window];
    NSLog(@"cell.Frame = %@",NSStringFromCGRect(rect));
    
    [self adjustTableViewToFitKeyboardWithRect:rect];
}

- (void)adjustTableViewToFitKeyboardWithRect:(CGRect)rect {
    
    
    
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    CGFloat restHeight = window.bounds.size.height - 262 - 49;
    CGFloat cellMaxY = CGRectGetMaxY(rect);
    CGFloat offsetY;
    
    //不超过屏幕一半，就不让移动
    if (cellMaxY < window.bounds.size.height * 0.5) {
        [self.chatKeyBoard keyboardUpforComment];
        return;
    }
    
    //当前的偏移值
    CGPoint offset = self.scrollView.contentOffset;
    if (cellMaxY > restHeight) {
        //Cell的MAXY 大于剩余高度， Cell需要往上
        offsetY = cellMaxY - restHeight;
        offset.y += offsetY;
    } else if (cellMaxY < restHeight) {
        //Cell的MaxY 小于剩余高度, Cell需要往下
        offsetY = restHeight - cellMaxY;
        offset.y -= offsetY;
    }
    
    [self.scrollView setContentOffset:offset animated:YES];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.chatKeyBoard keyboardUpforComment];
    });
    
}


#pragma mark - ChatKeyBoardDataSource

- (NSArray<ChatToolBarItem *> *)chatKeyBoardToolbarItems
{
    ChatToolBarItem *item1 = [ChatToolBarItem barItemWithKind:kBarItemFace normal:@"face" high:@"face_HL" select:@"keyboard"];
    
    ChatToolBarItem *item2 = [ChatToolBarItem barItemWithKind:kBarItemVoice normal:@"voice" high:@"voice_HL" select:@"keyboard"];
    
    ChatToolBarItem *item3 = [ChatToolBarItem barItemWithKind:kBarItemMore normal:@"more_ios" high:@"more_ios_HL" select:nil];
    
    ChatToolBarItem *item4 = [ChatToolBarItem barItemWithKind:kBarItemSwitchBar normal:@"switchDown" high:nil select:nil];
    
    return @[item1, item2, item3, item4];
}


- (NSArray<FaceThemeModel *> *)chatKeyBoardFacePanelSubjectItems
{
    return [FaceSourceManager loadFaceSource];
}


#pragma mark - 删除请求
- (void)DeleteMyDiscover {
    [LGNetWorking DeletedMyDiscoverWithSessionID:USERINFO.sessionId andOpenFirAccount:USERINFO.userID andFcid:self.ID block:^(ResponseData *responseData) {
        
        if (responseData.code != 0) {
            NSLog(@"请求失败");
            [LCProgressHUD showFailureText:responseData.msg];
            return ;
        }
        
        if ([self.delegate respondsToSelector:@selector(DiscoverDetailControllerDeletedButtonDidClick:)]) {
            [self.delegate DiscoverDetailControllerDeletedButtonDidClick:self.indexPath];
        }
        
        [FMDBShareManager deleteCircleDataWithCircleID:self.model.circle_ID];
        if (self.deletedBlock) {
            self.deletedBlock(self.indexPath,self.ID);
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:K_DelMyCircleNotification object:nil userInfo:@{ @"circleId" : self.ID }];
        
        [self.navigationController popViewControllerAnimated:YES];
        
    }];
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.chatKeyBoard keyboardDownForComment];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.chatKeyBoard keyboardDownForComment];
}

#pragma mark - 清除键盘
- (void)viewWillDisappear:(BOOL)animated {
    [self.chatKeyBoard removeFromSuperview];
    _chatKeyBoard = nil;
}

- (void)dealloc {
    [self.chatKeyBoard removeFromSuperview];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    _chatKeyBoard = nil;
}

#pragma mark - lazyLoad
- (NSMutableArray *)picArray {
    if (!_picArray) {
        _picArray = [NSMutableArray array];
        for (NSInteger index = 0; index< 3; index++) {
            SDTimeLineCellPicItemModel *model = [[SDTimeLineCellPicItemModel alloc] init];
            model.img_url = @"userIcon";
            [_picArray addObject:model];
        }
    }
    return _picArray;
}

- (NSMutableArray *)cellHightArray {
    if (!_cellHightArray) {
        _cellHightArray = [NSMutableArray array];
    }
    return _cellHightArray;
}
@end
