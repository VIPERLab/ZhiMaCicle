//
//  KXPersonalMessageSettingController.m
//  ZhiMaBaoBao
//
//  Created by mac on 16/9/20.
//  Copyright © 2016年 liugang. All rights reserved.
//

#import "KXPersonalMessageSettingController.h"
#import "PersonalSettingCell.h"

#import "KXLocationController.h"
#import "KXQRCodeController.h"
#import "SettingInvitedCodeController.h"
#import "ChangeUerNameController.h"
#import "ModifySignController.h"
#import "ChangeSexController.h"

#define KXPersonalSettingCellReusedID @"KXPersonalSettingCellReusedID"

@interface KXPersonalMessageSettingController () <UITableViewDelegate,UITableViewDataSource,UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIAlertViewDelegate>

@property (nonatomic, strong) NSArray *titleArray;
@property (nonatomic, strong) NSArray *subTitleArray;

@end

@implementation KXPersonalMessageSettingController {
    UITableView *_tableView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setCustomTitle:@"个人信息"];
    [self setupView];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    _subTitleArray = @[@[@"编辑",USERINFO.username],@[USERINFO.sex,@"深圳 南山区",USERINFO.signature],@[@"",@""]];
    [_tableView reloadData];
}

- (void)setupView {
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    [self.view addSubview:_tableView];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    [_tableView registerClass:[PersonalSettingCell class] forCellReuseIdentifier:KXPersonalSettingCellReusedID];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSArray *titleArray = self.titleArray[section];
    if (section == 2) {
        if ([USERINFO.is_self_reg isEqualToString:@"1"]) {
            if (USERINFO.passingBy) {
                return 2;
            }
#warning 这里要记得设置为1
            return 1;
        }
#warning 这里要记得设置为1
        return 1;
    }
    return titleArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *nameArray = self.titleArray[indexPath.section];
    NSArray *subArray = self.subTitleArray[indexPath.section];
    PersonalSettingCell *cell = [tableView dequeueReusableCellWithIdentifier:KXPersonalSettingCellReusedID forIndexPath:indexPath];
    if (indexPath.section == 0 && indexPath.row == 0) {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.imageName = USERINFO.head_photo;
    } else {
        cell.titleName = nameArray[indexPath.row];
    }
    
    if (indexPath.section == 2 && indexPath.row == 0) {
        cell.showQRCode = YES;
    }
    
    cell.subTitle = subArray[indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && indexPath.row == 0) {
        return 100;
    }
    return 50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 20;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0 && indexPath.row == 0) {
        // -----    修改头像
        UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"拍照" otherButtonTitles:@"从相册中选择", nil];
        [sheet showInView:self.view];
        
        
    } else if (indexPath.section == 0 && indexPath.row == 1) {
        // -----    修改用户名
        ChangeUerNameController *changeName = [[ChangeUerNameController alloc] init];
        [self.navigationController pushViewController:changeName animated:YES];
        
    } else if (indexPath.section == 1 && indexPath.row == 0) {
        // -----    修改性别
        ChangeSexController *sex = [[ChangeSexController alloc] init];
        sex.selectedSex = USERINFO.sex;
        [self.navigationController pushViewController:sex animated:YES];
        
    } else if (indexPath.section == 1 && indexPath.row == 1) {
        // -----    修改地区
        KXLocationController *location = [[KXLocationController alloc] init];
        [self.navigationController pushViewController:location animated:YES];
    } else if (indexPath.section == 1 && indexPath.row == 2) {
        // -----    修改个性签名
        ModifySignController *modifySign = [[ModifySignController alloc] init];
        [self.navigationController pushViewController:modifySign animated:YES];
        
    } else if (indexPath.section == 2 && indexPath.row == 0) {
        // -----    我的二维码名片
        KXQRCodeController *QRCode = [[KXQRCodeController alloc] init];
        [self.navigationController pushViewController:QRCode animated:YES];
    } else if (indexPath.section == 2 && indexPath.row == 1) {
        // -----    设置邀请码
        SettingInvitedCodeController *setting = [[SettingInvitedCodeController alloc] init];
        //创建参数对象
        LBXScanViewStyle *style = [[LBXScanViewStyle alloc]init];
        
        //矩形区域中心上移，默认中心点为屏幕中心点
        style.centerUpOffset = 44;
        
        //扫码框周围4个角的类型,设置为外挂式
        style.photoframeAngleStyle = LBXScanViewPhotoframeAngleStyle_Outer;
        
        //扫码框周围4个角绘制的线条宽度
        style.photoframeLineW = 6;
        
        //扫码框周围4个角的宽度
        style.photoframeAngleW = 24;
        
        //扫码框周围4个角的高度
        style.photoframeAngleH = 24;
        
        //扫码框内 动画类型 --线条上下移动
        style.anmiationStyle = LBXScanViewAnimationStyle_LineMove;
        
        //线条上下移动图片
        style.animationImage = [UIImage imageNamed:@"qrcode_scan_light_green"];
        
        //SubLBXScanViewController继承自LBXScanViewController
        //添加一些扫码或相册结果处理
        //    SubLBXScanViewController *vc = [SubLBXScanViewController new];
        setting.style = style;
        
        setting.isQQSimulator = YES;
        setting.isVideoZoom = YES;
        
        [self.navigationController pushViewController:setting animated:YES];
    }
}

// --- 更换头像actionSheet
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    
    if (buttonIndex == 0) {
        //拍照
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        
    } else if (buttonIndex == 1) {
        //相册中选择
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary | UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        
    } else {
        [actionSheet setHidden:YES];
        return;
    }
    
    [self.navigationController presentViewController:picker animated:YES completion:nil];
    return;
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    [LCProgressHUD showLoadingText:@"正在上传头像"];
    UIImage *image = info[@"UIImagePickerControllerEditedImage"];
    NSData *imageData = UIImageJPEGRepresentation(image, 1);
    [LGNetWorking uploadPhoto:USERINFO.sessionId image:imageData fileName:@"headPhoto" andFuctionName:@"headPhoto" block:^(ResponseData *obj) {
        [LCProgressHUD hide];
        
        if (obj.code == 0) {
            //上传成功 ，保存图片路径
            UserInfo *userinfo = [UserInfo read];
            userinfo.head_photo = obj.data;
            [userinfo save];
            
        }else{
#warning 由于循环引用导致ProgressHUD 无法释放
//            [LCProgressHUD showFailureText:obj.msg];
        }
        
        [picker dismissViewControllerAnimated:YES completion:nil];
    }];
}


- (void)changeSex {
    
}




#pragma mark - lazyLoad
- (NSArray *)titleArray {
    if (!_titleArray) {
        _titleArray = @[@[@"",@"昵称"],@[@"性别",@"地区",@"个性签名"],@[@"二维码名片",@"设置邀请码"]];
    }
    return _titleArray;
}




@end
