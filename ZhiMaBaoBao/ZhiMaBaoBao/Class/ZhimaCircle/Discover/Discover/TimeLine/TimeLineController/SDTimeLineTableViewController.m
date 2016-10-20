//
//  SDTimeLineTableViewController.m
//  GSD_WeiXin(wechat)
//
//  Created by gsd on 16/2/25.
//  Copyright © 2016年 GSD. All rights reserved.
//


#import "SDTimeLineTableViewController.h"

//#import "SDRefresh.h"
#import "MJRefresh.h"

#import "SDTimeLineTableHeaderView.h"
#import "SDTimeLineRefreshHeader.h"
#import "SDTimeLineCell.h"
#import "SDTimeLineCellModel.h"

#import "UITableView+SDAutoTableViewCellHeight.h"
#import "SDTimeLineCellOperationMenu.h"
#import "UIView+SDAutoLayout.h"

#import "SDWebImagePrefetcher.h"
#import "GlobalDefines.h"
#import "UIColor+My.h"


#import "MJExtension.h"
#import "DiscoverDetailController.h"  //朋友圈详情
#import "NewDiscoverController.h"  //发布新说说
#import "UserMessageController.h"  //查看新消息
#import "PesonalDiscoverController.h"  //查看某朋友或自己的朋友圈
#import "ComplainViewController.h" //投诉页面
#import "SetupCircleLimitController.h" //设置朋友圈权限

#import "ChatKeyBoard.h" //键盘工具条
#import "FaceSourceManager.h"  
#import "LGNetWorking.h" //请求工具类
#import "WebViewController.h"

// 复制功能View
#import "KXCopyView.h"

// -----  新消息提示View
#import "KXDiscoverNewMessageView.h"

#define kTimeLineTableViewCellId @"SDTimeLineCell"


@interface SDTimeLineTableViewController () <SDTimeLineCellDelegate,SDTimeLineTableHeaderViewDelegate,ChatKeyBoardDelegate, ChatKeyBoardDataSource,UIActionSheetDelegate,UIImagePickerControllerDelegate,UIAlertViewDelegate,KXDiscoverNewMessageViewDelegate,UITableViewDelegate,UITableViewDataSource,KXCopyViewDelegate,KXActionSheetDelegate>
@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, weak) SDTimeLineTableHeaderView *headerView;  //头部视图

// -----  回复别人的评论
@property (nonatomic, copy) NSString *commentToUser;  //回复人的名字
@property (nonatomic, copy) NSString *currentCommenterUserID;   //回复人的id
@property (nonatomic, assign) BOOL isReplayingComment;
@property (nonatomic, strong) NSIndexPath *currentEditingIndexthPath;

// -----  删除自己的评论
@property (nonatomic, weak) SDTimeLineCellCommentItemModel *tempCommentItemModel; //
@property (nonatomic, strong) NSIndexPath *tempIndexPath; //


// ------ 数据源
@property (nonatomic, strong) NSArray *modelDataArray;  //数据数组
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, assign) int pageNumber;  //页数

// ------ 键盘
@property (nonatomic, strong) ChatKeyBoard *chatKeyBoard; //富文本键盘

// ------ 新消息提示
@property (nonatomic, weak) KXDiscoverNewMessageView *tipsNewMessage;


// ------ 投诉专用中间变量
@property (nonatomic, weak) SDTimeLineCellModel *complainModel;
@property (nonatomic, weak) SDTimeLineCell *tempCell;

// ------ 复制、收藏中间变量
@property (nonatomic, weak) UILabel *contentLabel;

@end

@implementation SDTimeLineTableViewController

{
    CGFloat _lastScrollViewOffsetY;
    CGFloat _totalKeybordHeight;
    SDTimeLineRefreshHeader * _refreshHeader;
    KXCopyView *_copyView;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [self setCustomTitle:@"朋友圈"];
    self.pageNumber = 1;
    [self setupNav];
    [self setupView];
    [self notification];
    [self getDataFromSQL];
}


- (void)viewDidAppear:(BOOL)animated {
    [self setupKeyBoard];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.chatKeyBoard removeFromSuperview];
    _chatKeyBoard = nil;
}

- (void)dealloc {
    _refreshHeader = nil;
    [self.chatKeyBoard removeFromSuperview];
    _chatKeyBoard = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setupNav {
    UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Discover_AddDiscover"] style:UIBarButtonItemStyleDone target:self action:@selector(rightBarButtonItemAction:)];
    self.navigationItem.rightBarButtonItem = rightBarButton;
}



#pragma mark - 初始化view
- (void)setupView {
    UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    self.tableView = tableView;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSelectionStyleNone;
    self.tableView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.tableView];
    
    //设置头部
    SDTimeLineTableHeaderView *headerView = [SDTimeLineTableHeaderView new];
    headerView.delegate = self;
    self.headerView = headerView;
    
    self.headerView.signName = USERINFO.signature;
    self.headerView.BJImage = USERINFO.backgroundImg;
    self.headerView.userImage = USERINFO.head_photo;
    self.headerView.userName = USERINFO.username;
    self.headerView.sessionID = USERINFO.sessionId;
    self.headerView.openFirAccount = USERINFO.userID;
    headerView.frame = CGRectMake(0, 0, 0, 260); //260
    self.tableView.tableHeaderView = headerView;
    
    [self.tableView registerClass:[SDTimeLineCell class] forCellReuseIdentifier:kTimeLineTableViewCellId];
}

#pragma mark - 注册通知
- (void)notification {
    
    
    // 长按文字、图片回调
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(longPressContentLabel:) name:KDiscoverLongPressContentNotification object:nil];
    
    //接收未读消息通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(upLoadUnReadMessage:) name:K_UpDataUnReadCountNotification object:nil];
    
    //更新朋友圈数据通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getDataFromSQL) name:K_UpDataCircleDataNotification object:nil];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(commentViewDidClick:) name:KDiscoverCommentViewClickNotification object:nil];
    
    
    //点击了评论人 或者 被评论人 的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(UserNameLabelDidClick:) name:KDiscoverCommenterNotification object:nil];
    
    //点击点赞人的名字
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(UserNameLabelDidClick:) name:KUserNameLabelNotification object:nil];
    
    //点击了评论链接通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(commentURLDidClick:) name:KDiscoverCommentURLNotification object:nil];
}


// 右栏目按钮点击事件
#pragma mark - 新增说说
- (void)rightBarButtonItemAction:(UIBarButtonItem *)sender{
    //新增说说
    __weak typeof(self) weakSelf = self;
    
    NewDiscoverController *new = [[NewDiscoverController alloc] init];
    new.block = ^() {
        [weakSelf.tableView.mj_header beginRefreshing];
    };
    [self.navigationController pushViewController:new animated:YES];
    
}

#pragma mark - 设置下拉和上啦刷新控件
- (void)setupKeyBoardAndRefreshHeader {
    
    __weak typeof(self) weakSelf = self;
    
    //下拉刷新
    if (!self.tableView.mj_header) {
        self.tableView.mj_header = [MJRefreshHeader headerWithRefreshingBlock:^{
            //加载未读消息数
            [[NSNotificationCenter defaultCenter] postNotificationName:K_UpdataUnReadNotification object:nil];
            //下拉页数置1
            weakSelf.pageNumber = 1;
            NSString *pageNumber = [NSString stringWithFormat:@"%zd",weakSelf.pageNumber];
            NSString *sectionID = USERINFO.sessionId;
            NSString *userID = USERINFO.userID;
            
            [LGNetWorking loadMyDiscoverWithSectionID:sectionID andMyCheatAcount:userID andPageCount:pageNumber block:^(ResponseData *responseData) {
                if (responseData == nil || responseData.data == nil) {
                    return ;
                }
                if (responseData.code != 0) {
                    [self.tableView.mj_header endRefreshing];
                    return;
                }
                [self.tableView.mj_header endRefreshing];
                
                [weakSelf.dataArray removeAllObjects];
                
                NSArray *delCircleIDArray = [NSString mj_objectArrayWithKeyValuesArray:responseData.data_temp[@"dataList"]];
                
                
                for (NSString *circleID in delCircleIDArray) {
                    [FMDBShareManager deleteCircleDataWithCircleID:circleID];
                }
                
                
                NSArray *dataArray = [SDTimeLineCellModel getModelArrayWithJsonData:responseData andIsUpdata:YES];
                self.dataArray = [dataArray mutableCopy];
                // 异步 存数据 到朋友圈数据库
                dispatch_async(dispatch_queue_create(0, 0), ^{
                    //存数据到朋友圈表
                    [FMDBShareManager saveCircleDataWithDataArray:dataArray];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.tableView reloadDataWithExistedHeightCache];
                        [self.tableView reloadData];
                    });
                    
                });
 
            } failure:^(ErrorData *error) {
                
            }];
        }];
        //只有第一次进来且数据库无任何数据, 或者有新的未读消息需要加载的时候才会主动去刷新
        if (!self.dataArray.count || self.unReadCount != 0 || ![self.circleheadphoto isEqualToString:@""]) {
            [self.tableView.mj_header beginRefreshing];
        }
        
    }
    
    //上啦刷新
    if (!self.tableView.mj_footer) {
        self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
            self.pageNumber++;
            NSString *pageNumber = [NSString stringWithFormat:@"%zd",self.pageNumber];
            
            NSString *sectionID = USERINFO.sessionId;
            NSString *userID = USERINFO.userID;
            
            
            [LGNetWorking loadMyDiscoverWithSectionID:sectionID andMyCheatAcount:userID andPageCount:pageNumber block:^(ResponseData *responseData) {
                if (responseData.code != 0) {
                    // 失败则展示数据库中下一页的数据  异步获取下一页数据
                    dispatch_async(dispatch_queue_create(0, 0), ^{
                        //存数据到朋友圈表
                        NSArray *newDataArray = [FMDBShareManager getCirCleDataInArrayWithPage:self.pageNumber];
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if (newDataArray.count != 0) {
                                [self.dataArray addObjectsFromArray:newDataArray];
                                [self.tableView.mj_footer endRefreshing];
                                [self.tableView reloadData];
                                [self.tableView reloadDataWithExistedHeightCache];
                            }else{
                                [self.tableView.mj_footer endRefreshing];
                                self.tableView.mj_footer.state = MJRefreshStateNoMoreData;
                            }

                        });
                        
                    });
                    
                    return;
                }
                
                NSArray *dataArray = [SDTimeLineCellModel getModelArrayWithJsonData:responseData andIsUpdata:NO];
                
                if (dataArray.count) {
                    [self.dataArray addObjectsFromArray:dataArray];
                } else {
                    self.tableView.mj_footer.state = MJRefreshStateNoMoreData;
                    [self.tableView.mj_footer endRefreshingWithNoMoreData];
                    return;
                    
                }
                
                // 异步 存数据 到朋友圈数据库
                dispatch_async(dispatch_queue_create(0, 0), ^{
                    //存数据到朋友圈表
                    [FMDBShareManager saveCircleDataWithDataArray:dataArray];
                    
                });
                
                
                [self.tableView.mj_footer endRefreshing];
                [self.tableView reloadData];
                [self.tableView reloadDataWithExistedHeightCache];
                
            } failure:^(ErrorData *error) {
                // 失败则展示数据库中下一页的数据
                NSArray *newDataArray = [FMDBShareManager getCirCleDataInArrayWithPage:self.pageNumber];
                if (newDataArray.count != 0) {
                    [self.dataArray addObjectsFromArray:newDataArray];
                    [self.tableView.mj_footer endRefreshing];
                    [self.tableView reloadData];
                    [self.tableView reloadDataWithExistedHeightCache];
                }
                return;
                
            }];

            
        }];
    }
}

#pragma mark - 加载未读消息数
- (void)upLoadUnReadMessage:(NSNotification *)notification {
    //进入前台的时候请求未读消息
    int unReadCount = [notification.userInfo[@"count"] intValue];
    NSString *headphoto = notification.userInfo[@"headphoto"];
    if (![headphoto isEqualToString:@""] && unReadCount) {
        self.headPhoto = headphoto;
        self.unReadCount = unReadCount;
    }
}


#pragma mark - 从数据库取出数据
- (void)getDataFromSQL {
    [self.dataArray removeAllObjects];
    
    // 异步获取数据库
    dispatch_async(dispatch_queue_create(0, 0), ^{
        
        self.dataArray = [[FMDBShareManager getCirCleDataInArrayWithPage:self.pageNumber] mutableCopy];
        
        //返回主线程更新ui
        dispatch_async(dispatch_get_main_queue(), ^{
            // 获取所有朋友圈的数据
            
            [self setupKeyBoardAndRefreshHeader];
            
            [self.tableView reloadDataWithExistedHeightCache];
            [self.tableView reloadData];
        });
        
    });
    
    
    
}




#pragma mark - 设置键盘
- (void)setupKeyBoard {
    self.chatKeyBoard = [ChatKeyBoard keyBoard];
    self.chatKeyBoard.delegate = self;
    self.chatKeyBoard.dataSource = self;
    self.chatKeyBoard.keyBoardStyle = KeyBoardStyleComment;
    self.chatKeyBoard.allowVoice = NO;
    self.chatKeyBoard.placeHolder = @"请输入消息";
    self.chatKeyBoard.allowMore = NO;
    [[UIApplication sharedApplication].keyWindow addSubview:self.chatKeyBoard];
}


#pragma mark -- ChatKeyBoardDataSource
- (NSArray<ChatToolBarItem *> *)chatKeyBoardToolbarItems {
    ChatToolBarItem *item1 = [ChatToolBarItem barItemWithKind:kBarItemFace normal:@"face" high:@"face_HL" select:@"keyboard"];
    
    ChatToolBarItem *item2 = [ChatToolBarItem barItemWithKind:kBarItemVoice normal:@"voice" high:@"voice_HL" select:@"keyboard"];
    
    ChatToolBarItem *item3 = [ChatToolBarItem barItemWithKind:kBarItemMore normal:@"more_ios" high:@"more_ios_HL" select:nil];
    
    ChatToolBarItem *item4 = [ChatToolBarItem barItemWithKind:kBarItemSwitchBar normal:@"switchDown" high:nil select:nil];
    
    return @[item1, item2, item3, item4];
}


- (NSArray<FaceThemeModel *> *)chatKeyBoardFacePanelSubjectItems {
    return [FaceSourceManager loadFaceSource];
}

#pragma mark - tableViewDatasouce
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SDTimeLineCellModel *model = self.dataArray[indexPath.row];
    
    SDTimeLineCell *cell = [tableView dequeueReusableCellWithIdentifier:kTimeLineTableViewCellId];
    cell.indexPath = indexPath;
    __weak typeof(self) weakSelf = self;
    
    
    if (!cell.moreButtonClickedBlock) {
        [cell setMoreButtonClickedBlock:^(NSIndexPath *indexPath) {
            SDTimeLineCellModel *model = weakSelf.dataArray[indexPath.row];
            model.isOpening = !model.isOpening;
            [weakSelf.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }];
        cell.delegate = self;
    }
    
    //缓存行高
#warning 下一步优化：如果tableView快速滑动，则不加载图片,以及离屏渲染优化
    cell.model = model;
    
    [cell useCellFrameCacheWithIndexPath:indexPath tableView:tableView];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.chatKeyBoard keyboardDownForComment];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    // >>>>>>>>>>>>>>>>>>>>> * cell自适应 * >>>>>>>>>>>>>>>>>>>>>>>>
    id model = self.dataArray[indexPath.row];
    return [self.tableView cellHeightForIndexPath:indexPath model:model keyPath:@"model" cellClass:[SDTimeLineCell class] contentViewWidth:[self cellContentViewWith]];
}


- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.chatKeyBoard keyboardDownForComment];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        if (self.unReadCount != 0 && ![self.headPhoto isEqualToString:@""]) {
            //有图片且有未读消息
            KXDiscoverNewMessageView *newMessage = [[KXDiscoverNewMessageView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 40 )];
            [newMessage showNewMessageViewWith:self.headPhoto andNewMessageCount:self.unReadCount];
            newMessage.delegate = self;
            self.tipsNewMessage = newMessage;
            return self.tipsNewMessage;
        }
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        if (self.unReadCount != 0 && ![self.headPhoto isEqualToString:@""]) {
            //有图片且有未读消息
            return 40;
        }
    }
    return 0.1;
}


- (CGFloat)cellContentViewWith
{
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    
    // 适配ios7横屏
    if ([UIApplication sharedApplication].statusBarOrientation != UIInterfaceOrientationPortrait && [[UIDevice currentDevice].systemVersion floatValue] < 8) {
        width = [UIScreen mainScreen].bounds.size.height;
    }
    return width;
}

#pragma mark - 打开网页
- (void)didClickContentLink:(NSString *)urlStr {
    [self.view endEditing:YES];
    WebViewController *web = [[WebViewController alloc] init];
    web.urlStr = urlStr;
    [self.navigationController pushViewController:web animated:YES];
}


#pragma mark - SDTimeLineCellDelegate 点赞和评论
// -----  评论
- (void)didClickcCommentButtonInCell:(SDTimeLineCell *)cell
{
    self.isReplayingComment = NO;
    self.currentEditingIndexthPath = [self.tableView indexPathForCell:cell];
    self.currentCommenterUserID = @"";
    self.commentToUser = @"";
    self.chatKeyBoard.placeHolder = @"请输入消息";
    
    [self.view bringSubviewToFront:self.chatKeyBoard];
    
    [self adjustTableViewToFitKeyboard:cell];
    
}

// -----  点赞
- (void)didClickLikeButtonInCell:(SDTimeLineCell *)cell andMenu:(SDTimeLineCellOperationMenu *)menu
{
    
    [self DiscoverLikeOrComment:cell andComment:@""];
    
    NSIndexPath *index = [self.tableView indexPathForCell:cell];
    SDTimeLineCellModel *model = self.dataArray[index.row];
    NSMutableArray *temp = [NSMutableArray arrayWithArray:model.likeItemsArray];
    
    if (!model.isLiked) {  //未赞
        menu.isLike = NO;
        SDTimeLineCellLikeItemModel *likeModel = [SDTimeLineCellLikeItemModel new];
        likeModel.userName = USERINFO.username;
        likeModel.userId = USERINFO.userID;
        [temp addObject:likeModel];
        model.liked = YES;
    } else {               //已赞
        menu.isLike = YES;
        SDTimeLineCellLikeItemModel *tempLikeModel = nil;
        for (SDTimeLineCellLikeItemModel *likeModel in model.likeItemsArray) {
            if ([likeModel.userId isEqualToString:USERINFO.userID]) {
                tempLikeModel = likeModel;
                break;
            }
        }
        [temp removeObject:tempLikeModel];
        model.liked = NO;
    }
    model.likeItemsArray = [temp copy];
}

#pragma mark - 回复别人的评论
- (void)DidClickCommentOtherButton:(SDTimeLineCell *)cell andCommentItem:(SDTimeLineCellCommentItemModel *)commentModel andCommentView:(UIView *)commentView {
    
    if ([commentModel.userId isEqualToString:USERINFO.userID]) {
        //删除自己的评论
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        self.tempCommentItemModel = commentModel;
        self.tempIndexPath = indexPath;
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"是否要删除评论" message:@"" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        alertView.tag = 100;
        [alertView show];
        
        return;
    }
    
    self.isReplayingComment = YES;
    self.currentEditingIndexthPath = [self.tableView indexPathForCell:cell];
    self.currentCommenterUserID = commentModel.userId;
    self.commentToUser = commentModel.friend_nick;
    self.chatKeyBoard.placeHolder = [NSString stringWithFormat:@"回复%@:",commentModel.friend_nick];
    
    [self adjustTableViewToFitKeyboard:commentView];
}


#pragma mark - alertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 100) {
        if (buttonIndex != 0) {
            [self deleteMyComment:self.tempCommentItemModel andDiscoverCellIndex:self.tempIndexPath];
        }
    } else if (alertView.tag == 1) {
        if (buttonIndex != 0) {
            
            [LGNetWorking DeletedMyDiscoverWithSessionID:USERINFO.sessionId andOpenFirAccount:USERINFO.userID andFcid:_tempCell.model.circle_ID block:^(ResponseData *responseData) {
                
                if (responseData.code != 0) {
                    [LCProgressHUD showFailureText:responseData.msg];
                }
                
                [FMDBShareManager deleteCircleDataWithCircleID:_tempCell.model.circle_ID];
                for (SDTimeLineCellModel *model in self.dataArray) {
                    if ([model.circle_ID isEqualToString:_tempCell.model.circle_ID]) {
                        [self.dataArray removeObject:model];
                        break;
                    }
                }
                
                [self.tableView reloadData];
                
            }];

        }
    } else if (alertView.tag == 1000) {
        self.contentLabel.backgroundColor = [UIColor colorFormHexRGB:@"f3f3f5"];
        if (buttonIndex != 0) {
            // 点击了复制
            UIPasteboard *pboard = [UIPasteboard generalPasteboard];
            NSRange range = [self.contentLabel.text rangeOfString:@":"];
            pboard.string = [self.contentLabel.text substringFromIndex:range.location + 1];
            [LCProgressHUD showSuccessText:@"已复制到粘贴板"];
        }
    }
    
}

#pragma mark - 发送评论信息
- (void)chatKeyBoardSendText:(NSString *)text {
    [self DiscoverLikeOrComment:[self.tableView cellForRowAtIndexPath:_currentEditingIndexthPath] andComment:text];
}

#pragma mark - 点赞或者评论网络请求
- (void)DiscoverLikeOrComment:(SDTimeLineCell *)cell andComment:(NSString *)comment {
    
    SDTimeLineCellModel *model = cell.model;
    _currentEditingIndexthPath = [self.tableView indexPathForCell:cell];
    
    if ([_currentCommenterUserID isEqualToString:@""]) {
        _currentCommenterUserID = @"0";
    }
    
    [LGNetWorking LikeOrCommentDiscoverWithSessionID:USERINFO.sessionId andFcId:model.circle_ID andComment:comment andReply_userId:_currentCommenterUserID block:^(ResponseData *responseData) {
        
        if (responseData.code != 0) {
            [LCProgressHUD showFailureText:responseData.msg];
            [self.chatKeyBoard keyboardDownForComment];
            return;
        }
        
        NSArray *commentListArray = [SDTimeLineCellCommentItemModel mj_objectArrayWithKeyValuesArray:responseData.data_temp];
        NSMutableArray *likeItemsArray = [NSMutableArray array];
        NSInteger count = commentListArray.count -1;
        NSMutableArray *copyArray = [commentListArray mutableCopy];
        for (NSInteger index = count; index >= 0; index--) {
            
            //获取原始数据Model
            SDTimeLineCellCommentItemModel *model = commentListArray[index];
            if (model.type) {
                //如果是点赞，则把MODEL移出拷贝数组，放到like数组
                [copyArray removeObjectAtIndex:index];
                
                SDTimeLineCellLikeItemModel *likeModel = [[SDTimeLineCellLikeItemModel alloc] init];
                if (!model.friend_nick) {
                    model.friend_nick = @"未命名";
                }
                
                likeModel.userName = model.friend_nick;
                likeModel.userId = model.userId;
                [likeItemsArray addObject:likeModel];
                
            }
        }
        
        //循环结束之后，把筛选剩下的评论数赋值回去
        commentListArray = [copyArray mutableCopy];
        
        for (SDTimeLineCellCommentItemModel *model in commentListArray) {
            if (!model.friend_nick) {
                model.friend_nick = @"未命名";
            }
        }
        
        //得到最新的Model
        model.likeItemsArray = [likeItemsArray mutableCopy];
        model.commentList = [commentListArray mutableCopy];
        
        // 删除点赞和评论
        [FMDBShareManager deletedCircleCommentItemsAndLikeItemsByCircleID:model.circle_ID];
        
        // 保存新的评论
        [FMDBShareManager saveCommentItemsInCommentTable:model.commentList andCircleID:model.circle_ID];
        
        // 保存新的点赞
        [FMDBShareManager saveLikeItemsInLikeTable:model.likeItemsArray andCircleID:model.circle_ID];
        
        [self.tableView reloadRowsAtIndexPaths:@[_currentEditingIndexthPath] withRowAnimation:UITableViewRowAnimationNone];
        self.currentCommenterUserID = @"";
        [self.chatKeyBoard keyboardDownForComment];
    }];
    
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

- (void)adjustTableViewToFitKeyboardWithRect:(CGRect)rect
{
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    CGFloat restHeight = window.bounds.size.height - 262 - 49;
    CGFloat cellMaxY = CGRectGetMaxY(rect);
    CGFloat offsetY;
    
    //当前的偏移值
    CGPoint offset = self.tableView.contentOffset;
    if (cellMaxY > restHeight) {
        //Cell的MAXY 大于剩余高度， Cell需要往上
        offsetY = cellMaxY - restHeight;
        offset.y += offsetY;
    } else if (cellMaxY < restHeight) {
        //Cell的MaxY 小于剩余高度, Cell需要往下
        offsetY = restHeight - cellMaxY;
        offset.y -= offsetY;
    }
    
    [self.tableView setContentOffset:offset animated:YES];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.chatKeyBoard keyboardUpforComment];
    });
    
}

#pragma mark - 用户头像点击事件
// ----      点击自己的头像
- (void)SDTimeLineTableHeaderViewHeaderViewDidClick:(SDTimeLineTableHeaderView *)headerView {
    PesonalDiscoverController *personal = [[PesonalDiscoverController alloc] init];
    personal.sessionID = headerView.sessionID;
    personal.userID = headerView.openFirAccount;
    [self.navigationController pushViewController:personal animated:YES];
}

// -----    点击了背景
- (void)SDTimeLineTableHeaderViewBackGroundViewDidClick:(SDTimeLineTableHeaderView *)header andBackGround:(UIButton *)backGround {
    KXActionSheet *sheet = [[KXActionSheet alloc] initWithTitle:@"" cancellTitle:@"取消" andOtherButtonTitles:@[@"拍一张",@"从相册选择"]];
    sheet.delegate = self;
    sheet.tag = 100;
    [sheet show];
}


// ------   点击了新消息提示框
- (void)SDTimeLineTableHeaderViewTipsViewDidClick:(KXDiscoverNewMessageView *)newMessage {
    self.unReadCount = 0;
    self.headPhoto = @"";
    [self.tableView reloadDataWithExistedHeightCache];
    
    UserMessageController *message = [[UserMessageController alloc] init];
    message.unReadCount = USERINFO.unReadCount;
    [self.navigationController pushViewController:message animated:YES];
}


// ----      点击别人的头像
- (void)didClickUserIconInCell:(SDTimeLineCell *)cell {
    UserInfo *info = [UserInfo read];
    SDTimeLineCellModel *model = cell.model;
    PesonalDiscoverController *personal = [[PesonalDiscoverController alloc] init];
    personal.sessionID = info.sessionId;
    personal.userID = model.userId;
    [self.navigationController pushViewController:personal animated:YES];
}

// ----      点击了投诉按钮
- (void)didClickComplainButton:(SDTimeLineCell *)cell {
    if ([cell.model.userId isEqualToString:USERINFO.userID]) {
        self.tempCell = cell;
        // 删除自己的朋友圈
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"确认删除吗？" message:@"" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        alertView.tag = 1;
        [alertView show];
        return;
    }
    [self didLongPressUserIconWithCell:cell];
}

// -----    长按头像
- (void)didLongPressUserIconWithCell:(SDTimeLineCell *)cell {
    SDTimeLineCellModel *model = cell.model;
    self.complainModel = model;
    if ([model.userId isEqualToString:USERINFO.userID]) {
        //如果是自己发的朋友圈，则不处理
        return;
    }
    
    NSLog(@"长按了");
    KXActionSheet *sheet = [[KXActionSheet alloc] initWithTitle:@"" cancellTitle:@"取消" andOtherButtonTitles:@[@"投诉",@"设置朋友圈权限"]];
    sheet.delegate = self;
    sheet.tag = 1000;
    [sheet show];
}


#pragma mark - 用户名的点击
// ----      点击别人的名字
- (void)UserNameLabelDidClick:(NSNotification *)notification {
    NSLog(@"%@",notification.userInfo);
    PesonalDiscoverController *personal = [[PesonalDiscoverController alloc] init];
    personal.userID = notification.userInfo[@"userId"];
    personal.sessionID = USERINFO.sessionId;
    [self.navigationController pushViewController:personal animated:YES];
}

// 点击了评论的网址
- (void)commentURLDidClick:(NSNotification *)notification {
    WebViewController *webView = [[WebViewController alloc] init];
    webView.urlStr = notification.userInfo[@"linkValue"];
    [self.navigationController pushViewController:webView animated:YES];
}


#pragma mark - 删除自己的评论
- (void)deleteMyComment:(SDTimeLineCellCommentItemModel *)commentModel andDiscoverCellIndex:(NSIndexPath *)indexPath {
    __block NSIndexPath *index = indexPath;
    [LGNetWorking DeletedMyCommentWithSessionID:USERINFO.sessionId andOpenFirAccount:USERINFO.userID andFcid:commentModel.ID block:^(ResponseData *responseData) {
        
        if (responseData.code != 0 || responseData == nil) {
            [LCProgressHUD showFailureText:@"删除失败"];
            return ;
        }
        [LCProgressHUD showSuccessText:@"删除成功"];
        
        SDTimeLineCellModel *cellModel = self.dataArray[index.row];
        
        //删除对应的评论
        FMDatabaseQueue *queue = [FMDBShareManager getQueueWithType:ZhiMa_Circle_Comment_Table];
        NSString *opeartionStr = [FMDBShareManager deletedTableData:ZhiMa_Circle_Comment_Table withOption:[NSString stringWithFormat:@"circle_ID = %@ and fcid = %@",cellModel.circle_ID, commentModel.ID]];
        [queue inDatabase:^(FMDatabase *db) {
            
            BOOL success = [db executeUpdate:opeartionStr];
            if (success) {
                NSLog(@"删除成功");
            } else {
                NSLog(@"删除失败");
            }
            
        }];
        
        
        
        for (SDTimeLineCellCommentItemModel *model in cellModel.commentList) {
            if ([model.ID isEqualToString:commentModel.ID]) {
                [cellModel.commentList removeObject:model];
                break;
            }
        }
        
        [self.tableView reloadRowsAtIndexPaths:@[index] withRowAnimation:UITableViewRowAnimationNone];
        
    }];
}

#pragma mark - 长按内容文本回调
- (void)longPressContentLabel:(NSNotification *)notification {
    UILabel *contentLabel = notification.userInfo[@"contentLabel"];
    SDTimeLineCell *cell = notification.userInfo[@"cell"];
    NSIndexPath *indexPath = [_tableView indexPathForCell:cell];
    self.currentEditingIndexthPath = indexPath;
    self.contentLabel = contentLabel;
    if (!_copyView) {
        CGRect controlFrame = [contentLabel convertRect:contentLabel.frame toView:[UIApplication sharedApplication].keyWindow];
        _copyView = [[KXCopyView alloc] initWithFrame:CGRectMake(controlFrame.origin.x, controlFrame.origin.y - 80, 50, 40)];
        _copyView.delegate = self;
        _copyView.titleArray = @[@"复制",@"收藏"];
        [_copyView setImage:[UIImage imageNamed:@"Discovre_Copy"] andInsets:UIEdgeInsetsMake(30, 40, 30, 40)];
        [self.view addSubview:_copyView];
    }
    
    [_copyView showAnimation];
    
    contentLabel.backgroundColor = [UIColor colorFormHexRGB:@"c7c7c5"];

}

- (void)commentViewDidClick:(NSNotification *)notification {
    if ([notification.name isEqualToString:KDiscoverCommentViewClickNotification]) {
        UILabel *contentLabel = notification.userInfo[@"contentLabel"];
        self.contentLabel = contentLabel;
        contentLabel.backgroundColor = [UIColor colorFormHexRGB:@"c7c7c5"];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"复制到粘贴板" message:@"" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        alertView.tag = 1000;
        [alertView show];
    }
    
}

#pragma mark - copyView回调
- (void)KXCopyViewDidClickWithIndex:(NSInteger)index {
    if (index == 0) {
        // 点击了复制
        UIPasteboard *pboard = [UIPasteboard generalPasteboard];
        pboard.string = self.contentLabel.text;
        [LCProgressHUD showSuccessText:@"已复制到粘贴板"];
    } else if (index == 1) {
        //点击了收藏
        NSLog(@"点击了收藏");
        // 调用收藏接口
        SDTimeLineCellModel *model = self.dataArray[self.currentEditingIndexthPath.row];
        NSLog(@"%@",self.contentLabel.text);
        [LGNetWorking collectionCircleListWithCollectionType:1 andSessionId:USERINFO.sessionId andConent:self.contentLabel.text andSmallImg:@"" andBigImage:@"" andSource:@"" andAccount:model.userId success:^(ResponseData *responseData) {
            if (responseData.code != 0) {
                [LCProgressHUD showFailureText:@"收藏失败"];
                return ;
            }
            
            [LCProgressHUD showSuccessText:@"收藏成功"];
        } failure:^(ErrorData *error) {
            
        }];
    }
    
    [UIView animateWithDuration:0.3 animations:^{
        self.currentEditingIndexthPath = nil;
        _copyView.alpha = 0.0;
        _copyView = nil;
        _contentLabel.backgroundColor = [UIColor whiteColor];
    }];
    
}


#pragma mark - userInterFace
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (_copyView) {
        [UIView animateWithDuration:0.3 animations:^{
            _copyView.alpha = 0.0;
            _copyView = nil;
            _contentLabel.backgroundColor = [UIColor whiteColor];
        }];
    }
    [self.chatKeyBoard keyboardDownForComment];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (_copyView) {
        [UIView animateWithDuration:0.3 animations:^{
            _copyView.alpha = 0.0;
            _copyView = nil;
            _contentLabel.backgroundColor = [UIColor whiteColor];
        }];
    }
}




#pragma mark - actionSheet代理
- (void)KXActionSheet:(KXActionSheet *)sheet andIndex:(NSInteger)buttonIndex {
    if (sheet.tag == 1000) {
        if (buttonIndex == 0) {
            ComplainViewController *complain = [[ComplainViewController alloc] init];
            complain.userId = self.complainModel.userId;
            complain.circleId = self.complainModel.circle_ID;
            complain.type = 1;
            complain.dataArray = @[@"发布不适当内容对我造成骚扰",@"发布带诱导分享性质的内容",@"传播谣言信息",@"存在侵权行为",@"发布仿冒品信息"];
            [self.navigationController pushViewController:complain animated:YES];
        }else if (buttonIndex == 1){
            //设置朋友圈权限
            SetupCircleLimitController *vc = [[SetupCircleLimitController alloc] init];
            vc.model = self.complainModel;
            [self presentViewController:vc animated:YES completion:nil];
        }
        return;
    } else if (sheet.tag == 100) {
        //打开图片相册
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        switch (buttonIndex) {
            case 0:
                picker.sourceType = UIImagePickerControllerSourceTypeCamera;
                break;
            case 1:
                picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                break;
            default:
                return;
                break;
        }
        [self.navigationController presentViewController:picker animated:YES completion:nil];
    }
}


#pragma mark - imagePicker回调
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    
    UIImage *image = info[@"UIImagePickerControllerOriginalImage"];
    NSData *imageData = UIImageJPEGRepresentation(image, 1);
    
    [LGNetWorking uploadPhoto:USERINFO.sessionId image:imageData fileName:@"backgroundImg" andFuctionName:@"backgroundImg" block:^(ResponseData *responseData) {
        
        if (responseData.code != 0) {
            return ;
        }
        UserInfo *info = [UserInfo read];
        info.backgroundImg = responseData.data;
        [info save];
        [self.headerView.backgroundImageView setImage:image forState:UIControlStateNormal];
        
    }];
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}



#pragma mark - lazyLoad
- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

@end
