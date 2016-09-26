//
//  KXQRCodeController.m
//  YiIM_iOS
//
//  Created by mac on 16/8/29.
//  Copyright © 2016年 ikantech. All rights reserved.
//

#import "KXQRCodeController.h"
//#import "YiUserInfo.h"
//#import "YiIMSDK.h"
#import "UIImage+YiExtension.h"
#import "SDWebImageManager.h"

#import "SecurityUtil.h"
#import "GTMBase64.h"

@interface KXQRCodeController ()

@property (nonatomic, weak) UIImageView *imageView; //二维码
@property (nonatomic, weak) UIImageView *userIcon;  //用户头像
@property (nonatomic, weak) UILabel *nameLabel;     //名字
@property (nonatomic, weak) UILabel *signLabel;     //个性签名

@end

@implementation KXQRCodeController
//{
//    YiXmppVCard *vcard;
//}

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


#pragma mark - setupView
- (void)setupView {
    self.view.backgroundColor = [UIColor whiteColor];
    
    
    UIImageView *userIcon = [[UIImageView alloc] initWithFrame:CGRectMake(20, 30 + 64, 40, 40)];
    self.userIcon = userIcon;
    [userIcon sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",DFAPIURL,USERINFO.head_photo]] placeholderImage:[UIImage imageNamed:@"Image_placeHolder"]];
    [self.view addSubview:userIcon];
    
    UILabel *nameLabel = [[UILabel alloc] init];
    nameLabel.frame = CGRectMake(CGRectGetMaxX(userIcon.frame) + 10, CGRectGetMinY(userIcon.frame) + 10, 300, 20);
    nameLabel.font = [UIFont systemFontOfSize:15];
    self.nameLabel = nameLabel;
    self.nameLabel.text = USERINFO.username;
    [self.view addSubview:nameLabel];
    
    
    UILabel *signLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(userIcon.frame) + 10, CGRectGetMaxY(nameLabel.frame) + 5, 300, 20)];
    signLabel.font = [UIFont systemFontOfSize:14];
    signLabel.textColor = [UIColor colorFormHexRGB:@"888888"];
    self.signLabel = signLabel;
    self.signLabel.text = USERINFO.location;
    [self.view addSubview:signLabel];
    
    
    CGFloat imageW = [UIScreen mainScreen].bounds.size.width / 2;
    CGFloat imageH = imageW;
    CGFloat imageX = self.view.boundsCenter.x - imageW * 0.5;
    CGFloat imageY = 150 + 64;
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(imageX, imageY, imageW, imageH)];
    self.imageView = imageView;
    [self.view addSubview:imageView];
    
    
    UILabel *invitedLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(imageView.frame) + 20, [UIScreen mainScreen].bounds.size.width, 30)];
    invitedLabel.textAlignment = NSTextAlignmentCenter;
    invitedLabel.font = [UIFont systemFontOfSize:15];
    invitedLabel.textColor = [UIColor lightGrayColor];
    invitedLabel.text = [NSString stringWithFormat:@"我的邀请码:%@",USERINFO.invite_code];
    [self.view addSubview:invitedLabel];
    
    
    UILabel *tipsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(invitedLabel.frame) + 20, [UIScreen mainScreen].bounds.size.width, 30)];
    tipsLabel.textAlignment = NSTextAlignmentCenter;
    tipsLabel.textColor = [UIColor lightGrayColor];
    tipsLabel.font = [UIFont systemFontOfSize:15];
    tipsLabel.text = @"扫一扫上面的二维码图案，加我好友";
    [self.view addSubview:tipsLabel];
}


#pragma mark - 创建二维码
- (void)creatQRCode {
    
//    YiUserInfo * userInfo = [YiUserInfo defaultUserInfo];
//    
//    
//    if (userInfo && [userInfo.username length] > 0) {
//        if (!vcard) {
//            vcard = [[YiXmppVCard alloc] init];
//            [vcard load:[userInfo getJid] forceIntenet:NO success:^{
//                [self updateVCard];
//                [self updateNickNames];
//            } failed:nil];
//        }else {
//            [self updateVCard];
//        }
//    }
    
    // 1.创建过滤器
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    
    // 2.恢复默认
    [filter setDefaults];
    
    // 3.给过滤器添加数据(正则表达式/账号和密码)
    // NSString *dataString = userInfo.username;
    
    NSString *jid = [USERINFO.userID stringByAppendingString:@"@localHost"];
    
//    NSString *urlString = @"http://www.baidu.com";
    NSString *params = [NSString stringWithFormat:@"sessionId=%@&invite_code=%@&jid=%@",USERINFO.sessionId,USERINFO.invite_code,jid];
    
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
     @"inputColor0" : [CIColor colorWithCGColor:[UIColor greenColor].CGColor],    // 前景色
     @"inputColor1" : [CIColor colorWithCGColor:[UIColor yellowColor].CGColor], // 背景色
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
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    [manager downloadImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",DFAPIURL,USERINFO.head_photo]] options:0 progress:0 completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
        self.imageView.image = [[self creatNonInterpolatedUIImageFormCIImage:outputImage withSize:120] iconImageWithIcon:image];
    }];
    
}

- (UIImage *)creatNonInterpolatedUIImageFormCIImage:(CIImage *)image withSize:(CGFloat)size
{
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
//-(void)updateVCard {
//    YiUserInfo * userInfo = [YiUserInfo defaultUserInfo];
//    
//    NSString * avatarPath = [YiXmppVCard getAvatarPathByJid:[userInfo getJid]];
//    if ([avatarPath length]) {
//        [self.userIcon setImage:[UIImage imageWithContentsOfFile:avatarPath]];
//    }
//    
//}
//
//-(void)updateNickNames {
//    if ([vcard.nickname length]) {
//        self.nameLabel.text = vcard.nickname;
//    }
//}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
