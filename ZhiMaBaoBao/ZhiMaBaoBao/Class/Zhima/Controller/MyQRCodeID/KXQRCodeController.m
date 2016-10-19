//
//  KXQRCodeController.m
//  YiIM_iOS
//
//  Created by mac on 16/8/29.
//  Copyright © 2016年 ikantech. All rights reserved.
//

#import "KXQRCodeController.h"
#import "KXActionSheet.h"
#import "UIImage+YiExtension.h"
#import "SDWebImageManager.h"

#import "SecurityUtil.h"
#import "GTMBase64.h"

@interface KXQRCodeController () <KXActionSheetDelegate>

@property (nonatomic, weak) UIView *centerView;
@property (nonatomic, weak) UIImageView *imageView; //二维码
@property (nonatomic, weak) UIImageView *userIcon;  //用户头像
@property (nonatomic, weak) UILabel *nameLabel;     //名字
@property (nonatomic, weak) UILabel *locationLabel;     //个性签名

@end

@implementation KXQRCodeController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setCustomTitle:@"二维码名片"];
    [self setupView];
    [self creatQRCode];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    self.navigationController.navigationBar.hidden = NO;
}

#pragma mark - setupView
- (void)setupView {
    self.view.backgroundColor = [UIColor colorFormHexRGB:@"2e3132"];
    CGFloat scale = (ScreenWidth - 60) / ScreenWidth;
    CGFloat centerHeigth = 392 * scale + 60;
    UIView *centerView = [[UIView alloc] initWithFrame:CGRectMake(30, 84 + 64, ScreenWidth - 60, centerHeigth)];
    centerView.backgroundColor = [UIColor whiteColor];
    centerView.layer.cornerRadius = 10;
    self.centerView = centerView;
    [self.view addSubview:centerView];
    
    
    UIImageView *userIcon = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 45, 45)];
    self.userIcon = userIcon;
    userIcon.layer.cornerRadius = 10;
    userIcon.clipsToBounds = YES;
    [userIcon sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",DFAPIURL,USERINFO.head_photo]] placeholderImage:[UIImage imageNamed:@"Image_placeHolder"]];
    [self.centerView addSubview:userIcon];
    
    UILabel *nameLabel = [[UILabel alloc] init];
    nameLabel.frame = CGRectMake(CGRectGetMaxX(userIcon.frame) + 10, CGRectGetMinY(userIcon.frame), CGRectGetWidth(centerView.frame) -CGRectGetMaxX(userIcon.frame) - 10 , 20);
    nameLabel.font = [UIFont systemFontOfSize:15];
    self.nameLabel = nameLabel;
    self.nameLabel.text = USERINFO.username;
    [self.centerView addSubview:nameLabel];
    
    
    UILabel *locationLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(userIcon.frame) + 10, CGRectGetMaxY(nameLabel.frame) + 5, CGRectGetWidth(nameLabel.frame), 20)];
    locationLabel.font = [UIFont systemFontOfSize:13];
    locationLabel.textColor = [UIColor colorFormHexRGB:@"353535"];
    self.locationLabel = locationLabel;
    self.locationLabel.text = USERINFO.area;
    [self.centerView addSubview:locationLabel];
    
    
    UIImageView *BJImage = [[UIImageView alloc] initWithFrame:CGRectMake(19, CGRectGetMaxY(userIcon.frame) + 10, CGRectGetWidth(self.centerView.frame) - 38 , 260)];
    self.imageView = BJImage;
    BJImage.userInteractionEnabled = YES;
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressDidClick:)];
    [BJImage addGestureRecognizer:longPress];
    [self.centerView addSubview:BJImage];
    
//    CGFloat imageW = 200;
//    CGFloat imageH = imageW;
//    CGFloat imageX = (CGRectGetWidth(self.centerView.frame) - imageW) * 0.5;
//    CGFloat imageY = (CGRectGetHeight(self.centerView.frame) - imageH) * 0.5;
//    UIView *QRCodeView = [[UIView alloc] initWithFrame:CGRectMake(imageX, imageY, imageW, imageH)];
//    QRCodeView.backgroundColor = [UIColor whiteColor];
//    [self.centerView addSubview:QRCodeView];
//    
//    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 20, imageW - 40, imageH - 40)];
//    self.imageView = imageView;
//    imageView.userInteractionEnabled = YES;
//    [QRCodeView addSubview:imageView];
    
    
    UILabel *invitedLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(centerView.frame) - 45, CGRectGetWidth(centerView.frame), 15)];
    invitedLabel.textAlignment = NSTextAlignmentCenter;
    invitedLabel.font = [UIFont systemFontOfSize:15];
    invitedLabel.textColor = [UIColor colorFormHexRGB:@"888888"];
    invitedLabel.text = [NSString stringWithFormat:@"我的邀请码:%@",USERINFO.invite_code];
    [self.centerView addSubview:invitedLabel];
    
    
    UILabel *tipsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(invitedLabel.frame),  CGRectGetWidth(centerView.frame), 30)];
    tipsLabel.textAlignment = NSTextAlignmentCenter;
    tipsLabel.textColor = [UIColor colorFormHexRGB:@"888888"];
    tipsLabel.font = [UIFont systemFontOfSize:15];
    tipsLabel.text = @"扫一扫上面的二维码图案，加我好友";
    [self.centerView addSubview:tipsLabel];
}


#pragma mark - 创建二维码
- (void)creatQRCode {
    
    // 1.创建过滤器
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    
    // 2.恢复默认
    [filter setDefaults];
    
    // 3.给过滤器添加数据(正则表达式/账号和密码)
    // NSString *dataString = userInfo.username;
    
    NSString *jid = USERINFO.userID;
    NSString *params = [NSString stringWithFormat:@"sessionId=%@&invite_code=%@&groupId=0&jid=%@",USERINFO.sessionId,USERINFO.invite_code,jid];
    
    //AES加密
    NSData *aesdataresult = [SecurityUtil encryptAESData:params];
    params = [SecurityUtil encodeBase64Data:aesdataresult];
    NSLog(@"params = %@",params);
    
    NSString *urlStr = [NSString stringWithFormat:@"%@/web/h5toReg.do?%@",DFAPIURL,params];
    
    NSData *data = [urlStr dataUsingEncoding:NSUTF8StringEncoding];
    
    [filter setValue:data forKeyPath:@"inputMessage"];
    // 4.获取输出的二维码
    CIImage *outputImage = [filter outputImage];
    
    
    /*================= 将二维码染色 =================*/
    /*
     // 滤镜的参数配置
     NSDictionary *falseFilterPara = @{
     @"inputColor0" : [CIColor colorWithCGColor:[UIColor greenColor].CGColor],     //前景色
     @"inputColor1" : [CIColor colorWithCGColor:[UIColor yellowColor].CGColor],  //背景色
     @"inputImage" : outputImage,
     };
     
     CIFilter *falseFilter = [CIFilter filterWithName:@"CIFalseColor" withInputParameters:falseFilterPara];
     
     outputImage = falseFilter.outputImage;
    */
    
    // 5.显示二维码
    // 模糊的二维码
    //    self.imageView.image = [UIImage imageWithCIImage:outputImage];
    // 高清的二维码
    
//    NSString * avatarPath = [YiXmppVCard getAvatarPathByJid:[userInfo getJid]];
    self.imageView.image = [self creatNonInterpolatedUIImageFormCIImage:outputImage withSize:500];
    
    UIImageView *imageViewe = [[UIImageView alloc] initWithImage:self.userIcon.image];
    CGFloat width = self.imageView.width * 0.2;
    imageViewe.layer.borderWidth = 3;
    imageViewe.layer.cornerRadius = 5;
    imageViewe.clipsToBounds = YES;
    imageViewe.layer.borderColor = [UIColor whiteColor].CGColor;
    imageViewe.frame = CGRectMake((CGRectGetWidth(self.imageView.frame) - width) * 0.5, (CGRectGetHeight(self.imageView.frame) - width) * 0.5, width, width);
    [self.imageView addSubview:imageViewe];
    
    
}

- (UIImage *)creatNonInterpolatedUIImageFormCIImage:(CIImage *)image withSize:(CGFloat)size {
    CGRect extent = CGRectIntegral(image.extent);
    CGFloat scale = MIN(size/CGRectGetWidth(extent), size/CGRectGetHeight(extent));
    
    // 1. 创建bitmap
    size_t width = CGRectGetWidth(extent) * scale;
    size_t height = CGRectGetHeight(extent) * scale;
    CGColorSpaceRef cs = CGColorSpaceCreateDeviceGray();
    CGContextRef bitmapRef = CGBitmapContextCreate(nil, width, height, 8, 0, cs, (CGBitmapInfo)kCGImageAlphaNone);
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef bitmapImage = [context createCGImage:image fromRect:extent];
    CGContextSetInterpolationQuality(bitmapRef, kCGInterpolationNone);
    CGContextScaleCTM(bitmapRef, scale, scale);
    CGContextDrawImage(bitmapRef, extent, bitmapImage);
    
    // 2.保存bitmap图片
    CGImageRef scaledImage = CGBitmapContextCreateImage(bitmapRef);
    CGContextRelease(bitmapRef);
    CGImageRelease(bitmapImage);
    return [UIImage imageWithCGImage:scaledImage];
}



#pragma mark - upDataVCard

- (void)longPressDidClick:(UILongPressGestureRecognizer *)longPress {
    
    if (longPress.state == UIGestureRecognizerStateBegan) {
        KXActionSheet *sheet = [[KXActionSheet alloc] initWithTitle:@"" cancellTitle:@"取消" andOtherButtonTitles:@[@"保存图片"]];
        sheet.delegate = self;
        [sheet show];
    }
    
}


- (void)KXActionSheet:(KXActionSheet *)sheet andIndex:(NSInteger)index {
    if (index == 0) {
        [self saveImage];
    }
}

// 保存图片
- (void)saveImage
{
    UIImageWriteToSavedPhotosAlbum(self.imageView.image, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
    
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] init];
    indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    [[UIApplication sharedApplication].keyWindow addSubview:indicator];
    [indicator startAnimating];
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo;
{
    
    UILabel *label = [[UILabel alloc] init];
    label.textColor = [UIColor whiteColor];
    label.backgroundColor = [UIColor colorWithRed:0.1f green:0.1f blue:0.1f alpha:0.90f];
    label.layer.cornerRadius = 5;
    label.clipsToBounds = YES;
    label.bounds = CGRectMake(0, 0, 150, 30);
    label.center = self.imageView.center;
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont boldSystemFontOfSize:17];
    [[UIApplication sharedApplication].keyWindow addSubview:label];
    [[UIApplication sharedApplication].keyWindow bringSubviewToFront:label];
    if (error) {
        [LCProgressHUD showSuccessText:@"图片保存失败"];
    }   else {
        [LCProgressHUD showSuccessText:@"图片保存成功"];
    }
    [label performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:1.0];
}



@end
