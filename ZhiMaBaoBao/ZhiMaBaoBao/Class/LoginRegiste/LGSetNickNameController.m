//
//  LGSetNickNameController.m
//  YiIM_iOS
//
//  Created by liugang on 16/8/5.
//  Copyright © 2016年 ikantech. All rights reserved.
//

#define USERNAME_REGEX @"^[a-z0-9]{5,}$"
#define PASSWD_REGEX @"^[a-z0-9_\\.]{5,}$"
#define EMAIL_REGEX @"^\\w+([-+.]\\w+)*@\\w+([-.]\\w+)*\\.\\w+([-.]\\w+)*$"

#import "LGSetNickNameController.h"
#import "KXActionSheet.h"
#import "LGLoginController.h"
#import "JPUSHService.h"
#import "MoreInfoController.h"

@interface LGSetNickNameController ()<UITextFieldDelegate,KXActionSheetDelegate,UINavigationControllerDelegate, UIImagePickerControllerDelegate>
@property (nonatomic, strong) UITextField *nickNameField;
@property (nonatomic, strong) UITextField *codeField;
@property (nonatomic, strong) UIButton *nextBtn;
@property (nonatomic, strong) UIImageView *avtarImage;
@end

@implementation LGSetNickNameController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self hiddenBackBtn];
    [self setUI];
}

- (void)setUI{
    
    UILabel *prompt = [[UILabel alloc] init];
    prompt.text = @"请完善你的个人资料，方便朋友认出你。";
    prompt.textAlignment = NSTextAlignmentCenter;
    prompt.textColor = BLACKCOLOR;
    prompt.font = [UIFont systemFontOfSize:17];
    prompt.numberOfLines = 0;
    [self.view addSubview:prompt];
    [prompt mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.view);
        make.top.mas_equalTo(100);
        make.left.mas_equalTo(15);
        make.right.mas_equalTo(-15);
    }];
    
    UIImageView *avatarImage = [[UIImageView alloc] init];
    avatarImage.userInteractionEnabled = YES;
    avatarImage.image = [UIImage imageNamed:@"select_avtar"];
    avatarImage.layer.cornerRadius = 5.f;
    [self.view addSubview:avatarImage];
    self.avtarImage = avatarImage;
    [avatarImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.view);
        make.top.mas_equalTo(prompt.mas_bottom).mas_offset(16);
        make.width.mas_equalTo(80);
        make.height.mas_equalTo(80);
    }];
    //添加手势，上传头像
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectAvtar)];
    [avatarImage addGestureRecognizer:tap];
    
    
    UILabel *phone = [[UILabel alloc] init];
    phone.text = @"昵称";
    phone.textColor = BLACKCOLOR;
    phone.font = MAINFONT;
    [self.view addSubview:phone];
    [phone mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.top.mas_equalTo(avatarImage.mas_bottom).mas_offset(25);
    }];
    
    UITextField *phontField = [[UITextField alloc] init];
    phontField.placeholder = @"例如：陈晨";
    phontField.delegate = self;
    phontField.keyboardType = UIKeyboardTypeDefault;
    phontField.font = MAINFONT;
    [self.view addSubview:phontField];
    self.nickNameField = phontField;
    [phontField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(phone.mas_centerY);
        make.left.mas_equalTo(phone.mas_right).mas_offset(50);
        make.width.mas_equalTo(150);
        make.height.mas_equalTo(40);
    }];
    
    UIView *separtor1 = [[UIView alloc] init];
    separtor1.backgroundColor = SEPARTORCOLOR;
    [self.view addSubview:separtor1];
    [separtor1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(phone.mas_bottom).mas_offset(16);
        make.left.mas_equalTo(15);
        make.height.mas_equalTo(1);
        make.right.mas_equalTo(-15);
    }];
    
//    UILabel *verCode = [[UILabel alloc] init];
//    verCode.text = @"邀请码";
//    verCode.textColor = BLACKCOLOR;
//    verCode.font = MAINFONT;
//    [self.view addSubview:verCode];
//    [verCode mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.mas_equalTo(15);
//        make.top.mas_equalTo(separtor1.mas_bottom).mas_offset(16);
//    }];
    
//    UITextField *verField = [[UITextField alloc] init];
//    verField.placeholder = @"可填可不填";
//    phontField.delegate = self;
//    verField.keyboardType = UIKeyboardTypePhonePad;
//    verField.font = MAINFONT;
//    [self.view addSubview:verField];
//    self.codeField = verField;
//    [verField mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.centerY.mas_equalTo(verCode.mas_centerY);
//        make.left.mas_equalTo(self.nickNameField.mas_left);
//        make.width.mas_equalTo(150);
//        make.height.mas_equalTo(40);
//    }];
    
//    UIView *separtor2 = [[UIView alloc] init];
//    separtor2.backgroundColor = SEPARTORCOLOR;
//    [self.view addSubview:separtor2];
//    [separtor2 mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.mas_equalTo(verCode.mas_bottom).mas_offset(16);
//        make.left.mas_equalTo(15);
//        make.height.mas_equalTo(1);
//        make.right.mas_equalTo(-15);
//    }];
    
    UIButton *submitBtn = [[UIButton alloc] init];
    submitBtn.backgroundColor = THEMECOLOR;
    submitBtn.layer.cornerRadius = 5.f;
    [submitBtn setTitle:@"下一步" forState:UIControlStateNormal];
    [submitBtn setTintColor:WHITECOLOR];
    submitBtn.titleLabel.font = MAINFONT;
    [submitBtn addTarget:self action:@selector(nextAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:submitBtn];
    self.nextBtn = submitBtn;
    [submitBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.right.mas_equalTo(-15);
        make.height.mas_equalTo(48);
        make.top.mas_equalTo(separtor1.mas_bottom).mas_offset(20);
    }];
}
/**
 *  下一步按钮点击方法 -->  更多信息页面
 */
- (void)nextAction{
    [self.view endEditing:YES];
    if (!self.nickNameField.hasText) {
        [LCProgressHUD showFailureText:@"请填写昵称"];

        return;
    }
    
    [LCProgressHUD showLoadingText:@"请稍等"];
    
    //保存昵称，头像，邀请码
    [LGNetWorking saveUserInfo:USERINFO.sessionId headUrl:USERINFO.head_photo nickName:self.nickNameField.text inviteCode:self.codeField.text block:^(ResponseData *obj) {
        if (obj.code == 0) {
            
            [LCProgressHUD hide];
            
            UserInfo *info = [UserInfo read];
            info.username = self.nickNameField.text;
            [info save];
            
            //新需求-> 跳转到更多信息页
//            MoreInfoController *vc = [[MoreInfoController alloc] init];
//            vc.password = self.password;
//            vc.isResgiste = YES;
//            [self.navigationController pushViewController:vc animated:YES];
            
            //直接执行登录操作
            [self loginAction];
            
        }else{
            [LCProgressHUD showFailureText:obj.msg]; 
        }
    }];

}

- (void)loginAction{
    [self.view endEditing:YES];
    [LGNetWorking loginWithPhone:self.phoneNumber password:self.password success:^(ResponseData *responseData) {
        if (responseData.code == 0) {
            UserInfo *info = [UserInfo read];
            info.hasLogin = YES;
            [info save];
            
            [JPUSHService setTags:[NSSet setWithObject:info.userID] alias:info.userID callbackSelector:nil object:nil];
            
            [LCProgressHUD hide];
            
            [[SocketManager shareInstance] connect];

            if (info.isVisitor) {

                [self dismissViewControllerAnimated:YES completion:nil];

            }else{
                [[NSNotificationCenter defaultCenter] postNotificationName:LOGIN_SUCCESS object:nil];
            }

        }else{
            [LCProgressHUD showFailureText:responseData.msg];
        }
    } failure:^(ErrorData *error) {
        [LCProgressHUD showFailureText:error.msg];
    }];
}

/**
 *  选择图片上传头像
 */
- (void)selectAvtar{
    KXActionSheet *sheet;
    // 判断是否支持相机
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        sheet  = [[KXActionSheet alloc] initWithTitle:@"选择操作" cancellTitle:@"取消" andOtherButtonTitles:@[@"拍照上传",@"从相册选择"]];
//                  initWithTitle:@"选择操作"
//                                             delegate:self
//                                    cancelButtonTitle:@"取消"
//                               destructiveButtonTitle:nil
//                                    otherButtonTitles:@"拍照上传", @"从相册选择", nil];
    }
    else {
        sheet  = [[KXActionSheet alloc] initWithTitle:@"选择操作" cancellTitle:@"取消" andOtherButtonTitles:@[@"从相册选择"]];
    }
    sheet.tag = 200;
    sheet.delegate = self;
    [sheet show];

}

#pragma mark - action sheet delegte
- (void)KXActionSheet:(KXActionSheet *)sheet andIndex:(NSInteger)buttonIndex {
    if (sheet.tag == 200) {
        
        NSUInteger sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        // 判断是否支持相机
        if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            switch (buttonIndex) {
                case 0: //相机
                    sourceType = UIImagePickerControllerSourceTypeCamera;
                    break;
                case 1: //相册
                    sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                    break;
                default:
                    return;
            }
        }
        else {
            if (buttonIndex == 0) {
                sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            } else {
                return;
            }
        }
        
        // 跳转到相机或相册页面
        UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
        imagePickerController.navigationBar.tintColor = [UIColor blackColor];
        imagePickerController.delegate = self;
        imagePickerController.allowsEditing = YES;
        imagePickerController.sourceType = sourceType;
        
        [self presentViewController:imagePickerController animated:YES completion:^{}];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - image picker delegte
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    UIImage *image = [info objectForKey:@"UIImagePickerControllerEditedImage"];
    NSData *imageData = UIImageJPEGRepresentation(image, 1);

    
    [LCProgressHUD showLoadingText:@"正在上传头像..."];
    UserInfo *userInfo = [UserInfo read];

    [LGNetWorking uploadPhoto:userInfo.sessionId image:imageData fileName:@"headPhoto" andFuctionName:@"headPhoto" block:^(ResponseData *obj) {
//        [LCProgressHUD hide];
        if (obj.code == 0) {
            [LCProgressHUD hide];
            //上传成功 ，保存图片路径
            userInfo.head_photo = obj.data;
            [userInfo save];
            self.avtarImage.image = image;
        }else{
            [LCProgressHUD showFailureText:obj.msg];
        }
    }];
    
}



@end
