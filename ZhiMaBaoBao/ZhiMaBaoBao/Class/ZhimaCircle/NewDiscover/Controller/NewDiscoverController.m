//
//  NewDiscoverController.m
//  YiIM_iOS
//
//  Created by mac on 16/8/22.
//  Copyright © 2016年 ikantech. All rights reserved.
//

#import "NewDiscoverController.h"
#import "NewDiscoverNormalCell.h"    // 普通样式cell视图
#import "NewDiscoverHeaderView.h"    // 图文样式头部视图
#import "NewDiscoverLinkTypeView.h"  // 链接类型头部样式
#import "KXCurrentLocationModel.h"
#import "SDTimeLineCellModel.h"

#import "DiscoverCurrentLocationController.h" //所在位置
#import "ChooseWhoCanSeeController.h" //选择可见范围

//图片
#import "NewDiscoverPhotoPickerView.h"
#import "KXPhotoBrowersController.h"

#import "LGNetWorking.h"  //请求工具类

#import <CoreLocation/CoreLocation.h>  //定位FrameWork

//相册相关头文件
#import <AssetsLibrary/AssetsLibrary.h>
#import "DNImagePickerController.h"
#import "DNAsset.h"
#import "NSURL+DNIMagePickerUrlEqual.h"

#import "SDTimeLineCellModel.h"
#import <AVFoundation/AVFoundation.h>

// --- 重用ID
#define NewDiscoverTableViewNormalCellReuserdID @"NewDiscoverTableViewNormalCellReuserdID"
#define NewDiscoverTableViewHeaderCellReuserdID @"NewDiscoverTableViewHeaderCellReuserdID"

@interface NewDiscoverController () <UITableViewDelegate,UITableViewDataSource,UIImagePickerControllerDelegate,UINavigationControllerDelegate,DNImagePickerControllerDelegate,CLLocationManagerDelegate,KXActionSheetDelegate,UIAlertViewDelegate>

@property (nonatomic, weak) UITableView *tableView;

@property (nonatomic, weak) UITextView *textView;   //文本输入框

@property (nonatomic, weak) UIButton *currentSelectedButton; //当前选择的按钮

@property (nonatomic, weak) NewDiscoverHeaderView *headerView;
@property (nonatomic, weak) NewDiscoverLinkTypeView *linkTypeView; //- 链接类型

@property (nonatomic, assign) int headerCellHight;

@property (nonatomic, strong) NSMutableArray *imagesArray;

//上传图片队列
@property (nonatomic, assign) int imageCount;
@property (nonatomic, strong) NSMutableArray *imageItemsArray;


// -----  选择位置回调
@property (nonatomic, copy) NSString *locationTips;
@property (nonatomic, assign) BOOL isSelected;

// ------ 可见范围
@property (nonatomic, copy) NSString *privateClass; //公开程度  1.所有人公开 2.自己可见 3.朋友可见

//定位功能类
@property (nonatomic,strong) CLLocationManager *manager;
@property (nonatomic,strong) CLGeocoder *geocoder;

@end




@implementation NewDiscoverController {
    NSString *_content;   //说收内容
    NSString *_imgs;
    ALAssetsLibrary* assetLibrary;//照片的生命周期跟它有关，所以弄成全局变量在这里初始化
}


- (void)viewDidLoad {
    [super viewDidLoad];
    //全局变量
    assetLibrary = [[ALAssetsLibrary alloc]init];
    
    self.locationTips = @"所在位置";
    self.headerCellHight = 230;
    _imageCount = 0;
    _privateClass = @"1";
    [self setupNav];
    [self setupView];
    [self setCustomTitle:@""];
    self.automaticallyAdjustsScrollViewInsets = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    [self.navigationController.navigationBar setAlpha:1];
    if (self.circleType == 1) {
        // 图文类型
        [self upDataView];
    }
}

- (void)setupNav {
    
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"发送" style:UIBarButtonItemStylePlain target:self action:@selector(ReleaseButtonDidClick:)];
    self.navigationItem.rightBarButtonItem = rightBarButtonItem;
    
//    UIButton *rightButton = [[UIButton alloc] initWithFrame:CGRectMake(ScreenWidth - 100, 0, 100, 40)];
//    [rightButton setTitle:@"发送" forState:UIControlStateNormal];
//    [rightButton setTitleColor:THEMECOLOR forState:UIControlStateNormal];
//    self.navigationItem.rightBarButtonItem.customView = rightButton;
}

- (void)setupView {
    
    //图片点击通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(photoViewDidClick:) name:K_NewDiscoverPhotoClickNotifcation object:nil];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIView *fistView;
    if (self.circleType == 2) {
        // 分享朋友圈链接
        NewDiscoverLinkTypeView *linkTypeView = [[NewDiscoverLinkTypeView alloc] initWithFrame:CGRectMake(0, 64, ScreenWidth, 180)];
        _linkTypeView.linkValue = self.linkValue;
        linkTypeView.backgroundColor = [UIColor whiteColor];
        self.linkTypeView = linkTypeView;
        self.textView = linkTypeView.textView;
        [self.view addSubview:linkTypeView];
        fistView = linkTypeView;
        
        
    } else if (self.circleType == 1) {
        // 普通图文朋友圈
        NewDiscoverHeaderView *headerView = [[NewDiscoverHeaderView alloc] init];
        self.textView = headerView.textView;
        [self.view addSubview:headerView];
        self.headerView = headerView;
        headerView.frame = CGRectMake(0, 64,ScreenWidth, 240);
        fistView = headerView;
    }
    
    
    //设置TableView
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(fistView.frame), [UIScreen mainScreen].bounds.size.width, CGRectGetHeight(self.view.frame) - 240 ) style:UITableViewStyleGrouped];
    self.tableView = tableView;
    tableView.separatorStyle = UITableViewCellSelectionStyleNone;
    [self.view addSubview:tableView];

    
    tableView.delegate = self;
    tableView.dataSource = self;
    
    [tableView registerClass:[NewDiscoverNormalCell class] forCellReuseIdentifier:NewDiscoverTableViewNormalCellReuserdID];
    
    
    
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NewDiscoverNormalCell *cell = [tableView dequeueReusableCellWithIdentifier:NewDiscoverTableViewNormalCellReuserdID forIndexPath:indexPath];
    
    if (indexPath.section == 0) {
        cell.tipsName = self.locationTips;
        [cell setIconViewWithImageName:@"NewDiscover_Loaction" Status:UIControlStateNormal];
        [cell setIconViewWithImageName:@"NewDiscover_Loaction_Selected" Status:UIControlStateSelected];
        cell.isSelected = self.isSelected;
        
    } else if (indexPath.section == 1) {
        cell.tipsName = @"可见范围";
        cell.subTitleName = @"公开";
        [cell setIconViewWithImageName:@"NewDiscover_Earth" Status:UIControlStateNormal];
    }
    
    return cell;
}

#pragma mark - TableVieCellDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 54;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.5;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.5;
}

#pragma mark - Cell的点击事件
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    __weak typeof(self) weakSelf = self;
    __block NSIndexPath *index = indexPath;
    if (indexPath.section == 0) { //更新用户位置
        DiscoverCurrentLocationController *location = [[DiscoverCurrentLocationController alloc] init];
        location.complitedBlock = ^(KXCurrentLocationModel *model) {
            
            if ([model.address isEqualToString:@""] && [model.city isEqualToString:@""]) {
                if ([model.name isEqualToString:@"不显示位置"]) {
                    weakSelf.locationTips = @"所在位置";
                    self.isSelected = NO;
                } else {
                    weakSelf.locationTips = model.name;
                    self.isSelected = YES;
                }
            } else {
                weakSelf.locationTips = [NSString stringWithFormat:@"%@ · %@",model.city,model.name];
                self.isSelected = YES;
            }
            
            
            [weakSelf.tableView reloadRowsAtIndexPaths:@[index] withRowAnimation:UITableViewRowAnimationFade];
        };
        
        [self.navigationController pushViewController:location animated:YES];
        return;
        
    } else if (indexPath.section == 1) { //跳转至可见范围
        ChooseWhoCanSeeController *vc = [[ChooseWhoCanSeeController alloc] init];
        __block NewDiscoverNormalCell *cell = [weakSelf.tableView cellForRowAtIndexPath:index];
        
        if ([cell.subTitleName isEqualToString:@"公开"]) {
            vc.isPrivate = NO;
        } else vc.isPrivate = YES;
        
        
        vc.returnBlock = ^(BOOL PrivateClass) {
            if (PrivateClass) {
                weakSelf.privateClass = @"3";
                cell.subTitleName = @"朋友可见";
            } else {
                weakSelf.privateClass = @"1";
                cell.subTitleName = @"公开";
            }
        };
        
        [self.navigationController pushViewController:vc animated:YES];
    }
}



#pragma mark - 发布按钮的点击事件
- (void)ReleaseButtonDidClick:(UIBarButtonItem *)sender {
    [self.textView resignFirstResponder];
    
    if (self.circleType == 1) {  //图文类型判断
        if (!self.textView.text.length && !_imagesArray.count) {
            [LCProgressHUD showFailureText:@"说说内容或图片不能为空"];
            return;
        }
    }
    
    if (self.textView.text.length > 2000) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"你输入的内容过长，不能超过2000字符" delegate:nil cancelButtonTitle:@"我知道了" otherButtonTitles:nil];
        [alertView show];
        return;
    }
    
    sender.enabled = NO;
    [self upLoadImageCount:0 andImageArray:_imagesArray];
}

-(void)dealloc {
    self.automaticallyAdjustsScrollViewInsets = YES;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self resignFirstResponder];
    [self.textView resignFirstResponder];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self resignFirstResponder];
    [self.textView resignFirstResponder];
}







#pragma mark - 图片通知
- (void)photoViewDidClick:(NSNotification *)notification {
    [self.textView resignFirstResponder];
    UIButton *currentButton = notification.userInfo[@"currentSelectedButton"];
    
    self.currentSelectedButton = currentButton;
    
    if (self.imagesArray.count > currentButton.tag) {
        //查看照片
        KXPhotoBrowersController *borwser = [[KXPhotoBrowersController alloc] init];
        borwser.imageArray = self.imagesArray;
        borwser.currentIndex = currentButton.tag + 1;
        
        typeof(self) weakSelf = self;
        [self.navigationController pushViewController:borwser animated:YES];
        return;
    }
    
    KXActionSheet *sheet = [[KXActionSheet alloc] initWithTitle:@"" cancellTitle:@"取消" andOtherButtonTitles:@[@"拍照",@"从手机相册选择"]];
    sheet.delegate = self;
    [sheet show];
}


#pragma mark - actionSheetDelegate
- (void)KXActionSheet:(KXActionSheet *)sheet andIndex:(NSInteger)buttionIndex {
    // 点击的是拍照

    if (buttionIndex == 0) {
        
        NSString *mediaType = AVMediaTypeVideo;//读取媒体类型
        AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];//读取设备授权状态
        if(authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied){
            NSString *errorStr = @"请在iPhone的“设置 - 隐私 - 相机”选项中，允许芝麻宝宝访问你的相机";
            [[[UIAlertView alloc]initWithTitle:errorStr message:@"" delegate:self cancelButtonTitle:@"好" otherButtonTitles:nil, nil] show];
            return;
        }
        
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = NO;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self.navigationController presentViewController:picker animated:YES completion:nil];
        return;
        
    } else if (buttionIndex == 1) {
        // 点击的是相册
        int limitNum = 9 - self.imagesArray.count;
        
        //    如果是更换图片，则只能选择1张
        if (self.currentSelectedButton.tag < self.imagesArray.count) {
            limitNum = 1;
        }
        
        DNImagePickerController *imagePicker = [[DNImagePickerController alloc] init];
        imagePicker.imagePickerDelegate = self;
        imagePicker.kDNImageFlowMaxSeletedNumber = limitNum;
        imagePicker.filterType = DNImagePickerFilterTypePhotos;
        [self presentViewController:imagePicker animated:YES completion:nil];
    }
    
}



//点击回调通知
- (void)photoViewDidClickButton:(NSNotification *)notifacation {
    [self.textView resignFirstResponder];
}


#pragma mark - imagePickerDelegate
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

// ----   调整图片角度
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    UIImage *image = info[@"UIImagePickerControllerOriginalImage"];
    UIImageOrientation imageOrientation=image.imageOrientation;
    if(imageOrientation!=UIImageOrientationUp) {
        // 原始图片可以根据照相时的角度来显示，但UIImage无法判定，于是出现获取的图片会向左转９０度的现象。
        // 以下为调整图片角度的部分
        UIGraphicsBeginImageContext(image.size);
        [image drawInRect:CGRectMake(0, 0, image.size.width, image.size.height)];
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        // 调整图片角度完毕
    }
    NSData *data = UIImageJPEGRepresentation(image, 0.5);
    image = [UIImage imageWithData:data];
    
    if (self.currentSelectedButton.tag < self.imagesArray.count) {
        //如果是重选图片
        [self.imagesArray replaceObjectAtIndex:self.currentSelectedButton.tag withObject:image];
    } else {
        
        [self.imagesArray addObject:image];
    }
    [self.currentSelectedButton setImage:image forState:UIControlStateNormal];
    [self upDataView];
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - SGMAlbumViewControllerDelegate
- (void)dnImagePickerController:(DNImagePickerController *)imagePickerController sendImages:(NSArray *)imageAssets isFullImage:(BOOL)fullImage {
    
    ALAssetsLibrary *lib = [ALAssetsLibrary new];
    
    if (self.currentSelectedButton.tag < self.imagesArray.count) {
        //如果是更换图片  --- 解析图片
        for (NSInteger index = 0; index < imageAssets.count; index++) {
            DNAsset *dnasset = imageAssets[index];
            [lib assetForURL:dnasset.url resultBlock:^(ALAsset *asset) {
                UIImage *image;
                if (fullImage) {
                    image = [UIImage imageWithCGImage:asset.thumbnail];
                } else {
                    image = [UIImage imageWithCGImage:asset.defaultRepresentation.fullScreenImage];
                }
                [self.currentSelectedButton setImage:image forState:UIControlStateNormal];
                [self.imagesArray replaceObjectAtIndex:self.currentSelectedButton.tag withObject:image];
                return ;
            } failureBlock:^(NSError *error) {
                
            }];
            [imagePickerController dismissViewControllerAnimated:YES completion:^{
                self.tabBarController.tabBar.hidden = YES;
            }];
            return;
        }
    }
    
    //不是更换图片  ---  解析图片
    for (NSInteger index = 0; index < imageAssets.count; index++) {
        DNAsset *dnasset = imageAssets[index];
        [lib assetForURL:dnasset.url resultBlock:^(ALAsset *asset) {
            
            UIImage *image;
            
            if (fullImage) {
                image = [UIImage imageWithCGImage:asset.thumbnail];
            } else {
//                image = [UIImage imageWithCGImage:asset.defaultRepresentation.fullScreenImage];
                image = [UIImage imageWithCGImage:asset.defaultRepresentation.fullScreenImage scale:1 orientation:UIImageOrientationUp];
            }
            
            if (self.imagesArray.count > 8) {
                return ;
            }
            
            [self.imagesArray addObject:image];
            [self upDataView];

            
        } failureBlock:^(NSError *error) {
            
        }];
    }
    
    [imagePickerController dismissViewControllerAnimated:YES completion:^{
        self.tabBarController.tabBar.hidden = YES;
    }];
}


- (void)dnImagePickerControllerDidCancel:(DNImagePickerController *)imagePicker {
    [imagePicker dismissViewControllerAnimated:YES completion:^{
        self.tabBarController.tabBar.hidden = YES;
    }];
    
}


#pragma mark - 上传图片
- (void)upLoadImageCount:(int )imageCount andImageArray:(NSArray *)array {
    if (imageCount >= array.count || imageCount > 8) {
        [self releaseDidClick];
        return;
    }
    UIImage *image = array[imageCount];
    NSData *imageData = UIImageJPEGRepresentation(image, 0.5);
    
    [LCProgressHUD showLoadingText:@"正在上传图片"];
    
    [LGNetWorking uploadPhoto:USERINFO.sessionId image:imageData fileName:@"quan" andFuctionName:@"quan" block:^(ResponseData *obj) {
        [LCProgressHUD hide];
        if (obj.code == 0) {
            //上传成功 ，保存图片路径
            if ([_imgs isEqualToString:@""] || _imgs == nil) {  //如果没有图片则直接赋值
                _imgs = obj.data;
            } else {                                            //如果有图片则拼接起来
                _imgs = [_imgs stringByAppendingString:[NSString stringWithFormat:@",%@",obj.data]];
            }
            
            
            SDTimeLineCellPicItemModel *picModel = [[SDTimeLineCellPicItemModel alloc] init];
            
            picModel.img_url = obj.data;
            picModel.bigimg_url = obj.data_temp;
            [self.imageItemsArray addObject:picModel];
            //递归回调
            self.imageCount++;
            [self upLoadImageCount:self.imageCount andImageArray:_imagesArray];
            
        }else{
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [LCProgressHUD showFailureText:obj.msg];
            });
        }
        
        
    }];
}

- (void)releaseDidClick {
    NSString *locationStr = [NSString string];
    if ([self.locationTips isEqualToString:@"所在位置"]) {
        locationStr = @"";
    } else {
        locationStr = self.locationTips;
    }
    
    
    
    [LGNetWorking AddNewDiscoverWithSessionID:USERINFO.sessionId andOpenFirAccount:USERINFO.userID andContent_type:[NSString stringWithFormat:@"%zd",self.circleType] andContent:self.textView.text andLink:self.linkValue andType:_privateClass andCurrent_location:locationStr andImgs:_imgs block:^(ResponseData *responseData) {
        
        if (responseData.code != 0) {
            _imgs = @"";
            [LCProgressHUD showFailureText:responseData.msg];
            return;
        }
        
        //插入自己发布的朋友圈
        UserInfo *info = [UserInfo read];
        NSString *fcid = [NSString stringWithFormat:@"%zd",[responseData.data integerValue]];
        info.lastFcID = fcid;
        [info save];
        
        //插入自己发布的朋友圈
        SDTimeLineCellModel *cellModel = [SDTimeLineCellModel mj_objectWithKeyValues:responseData.data_temp];
        
        //转换数组类型
        if (cellModel.imglist.count != 0) {
            NSArray *picArray = [SDTimeLineCellPicItemModel mj_objectArrayWithKeyValuesArray:cellModel.imglist];
            cellModel.imglist = picArray;
        }
        
        
        
        
        //如果有评论，则转换评论数据类型
        if (cellModel.commentList.count !=0) {
            NSMutableArray *commentListArray = [SDTimeLineCellCommentItemModel mj_objectArrayWithKeyValuesArray:cellModel.commentList];
            
            NSMutableArray *likeItemsArray = [NSMutableArray array];
            
            //需要循环的次数
            NSInteger count = commentListArray.count -1;
            
            //拷贝一份评论数组
            NSMutableArray *copyArray = [commentListArray mutableCopy];
            
            //循环开始
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
                    [likeItemsArray insertObject:likeModel atIndex:0];
                    
                    //判断是否点赞了
                    if (!cellModel.liked) {
                        if ([likeModel.userId isEqualToString:USERINFO.userID]) {
                            cellModel.liked = YES;
                        } else {
                            cellModel.liked = NO;
                        }
                    }
                }
            }
            
            //循环结束之后，把筛选剩下的评论数赋值回去
            commentListArray = [copyArray mutableCopy];
            
            
            for (SDTimeLineCellCommentItemModel *model in commentListArray) {
                if (!model.friend_nick) {
                    model.friend_nick = @"未命名";
                }
            }
            
            cellModel.likeItemsArray = [likeItemsArray mutableCopy];
            cellModel.commentList = [commentListArray mutableCopy];
        }
        
        FMDatabaseQueue *queue = [FMDBShareManager getQueueWithType:ZhiMa_Circle_Table];
        
        NSString *optionStr = [FMDBShareManager InsertDataInTable:ZhiMa_Circle_Table];
        [queue inDatabase:^(FMDatabase *db) {
            
            BOOL success = [db executeUpdate:optionStr,info.username,fcid,info.userID,self.textView.text,locationStr,@"刚刚",info.head_photo,@(1),@""];
            if (success) {
                NSLog(@"插入朋友圈成功");
            } else {
                NSLog(@"插入朋友圈失败");
            }
        }];
        
        //插入图片
        for (SDTimeLineCellPicItemModel *picModel in cellModel.imglist) {
            FMDatabaseQueue *picQueue = [FMDBShareManager getQueueWithType:ZhiMa_Circle_Pic_Table];
            NSString *operationStr = [NSString string];
            
            operationStr = [FMDBShareManager InsertDataInTable:ZhiMa_Circle_Pic_Table];
            [picQueue inDatabase:^(FMDatabase *db) {
                
                BOOL success = [db executeUpdate:operationStr,picModel.img_url,picModel.bigimg_url,fcid,picModel.weuser_id,picModel.picId];
                if (success) {
                    NSLog(@"插入图片成功");
                } else {
                    NSLog(@"插入图片失败");
                }
                
            }];
        }
        
        self.block(cellModel);
        [self.navigationController popViewControllerAnimated:YES];
    }];
}

//更新UI
- (void)upDataView {
    CGFloat buttonWidth = ([UIScreen mainScreen].bounds.size.width - 50) / 4;
    if (self.imagesArray.count >= 4 && self.imagesArray.count < 8) {
        self.headerView.frame = CGRectMake(0, 64, [UIScreen mainScreen].bounds.size.width, 240 + buttonWidth + 5);
    } else if (self.imagesArray.count >= 8){
        self.headerView.frame = CGRectMake(0, 64, [UIScreen mainScreen].bounds.size.width, 240 + buttonWidth * 2 + 10);
    } else {
        self.headerView.frame = CGRectMake(0, 64, [UIScreen mainScreen].bounds.size.width, 240);
    }
    
    [self.headerView setContentWithImageArray:self.imagesArray];
    
    self.tableView.frame = CGRectMake(0, CGRectGetMaxY(self.headerView.frame), [UIScreen mainScreen].bounds.size.width, CGRectGetHeight(self.view.frame) - CGRectGetMaxY(self.headerView.frame));
}

#pragma mark - returnAction
- (void)backAction {
    [self.view endEditing:YES];
    if (self.imagesArray.count || self.textView.text.length) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"退出此次编辑？" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [alertView show];
        return;
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - lazyLoad


- (NSMutableArray *)imagesArray {
    if (!_imagesArray) {
        _imagesArray = [NSMutableArray array];
    }
    return _imagesArray;
}


- (CLLocationManager *)manager {
    if (!_manager) {
        _manager = [[CLLocationManager alloc] init];
        _manager.desiredAccuracy = kCLLocationAccuracyThreeKilometers;
        _manager.delegate = self;
    }
    return _manager;
}

- (CLGeocoder *)geocoder {
    if (!_geocoder) {
        _geocoder = [[CLGeocoder alloc]init];
    }
    return _geocoder;
}

- (NSMutableArray *)imageItemsArray {
    if (!_imageItemsArray) {
        _imageItemsArray = [NSMutableArray  array];
    }
    return _imageItemsArray;
}
@end
