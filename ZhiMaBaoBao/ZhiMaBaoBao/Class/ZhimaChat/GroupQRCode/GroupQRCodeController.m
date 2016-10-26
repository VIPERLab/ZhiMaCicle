//
//  GroupQRCodeController.m
//  ZhiMaBaoBao
//
//  Created by mac on 16/10/11.
//  Copyright © 2016年 liugang. All rights reserved.
//

#import "GroupQRCodeController.h"
#import "GroupChatModel.h"

#import "UIImage+YiExtension.h"
#import "SDWebImageManager.h"

#import "SecurityUtil.h"
#import "GTMBase64.h"

#import "KXActionSheet.h"

@interface GroupQRCodeController () <KXActionSheetDelegate>

@property (nonatomic, weak) UIView *centerView;
@property (nonatomic, weak) UIImageView *QRCodeView; //二维码
@property (nonatomic, weak) UIImageView *userIcon;  //用户头像

@end

@implementation GroupQRCodeController {
    UIActivityIndicatorView *_indicatorView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupNav];
    [self setupView];
    [self requestQRCode];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)requestQRCode {
    [LGNetWorking getGroupChatQRCodeWithSessionId:USERINFO.sessionId andGroupId:self.model.groupId success:^(ResponseData *responseData) {
        
        if (responseData.code != 0) {
            [LCProgressHUD showFailureText:responseData.msg];
            return ;
        }
        
        NSString *QRCodeStr = responseData.data;
        [self.QRCodeView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",DFAPIURL,QRCodeStr]] placeholderImage:[UIImage imageNamed:@"Image_placeHolder"] options:SDWebImageProgressiveDownload completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            
        }];
        
        
        
    } failure:^(ErrorData *error) {
        [self creatQRCode];
    }];
}

- (void)setupNav {
    [self setCustomTitle:@"群二维码名片"];
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"nav_more"] style:UIBarButtonItemStylePlain target:self action:@selector(rightItemClick)];
    self.navigationItem.rightBarButtonItem = rightItem;
    
}

#pragma mark - setupView
- (void)setupView {
    self.view.backgroundColor = [UIColor colorFormHexRGB:@"2e3132"];
    
    UIView *centerView = [[UIView alloc] initWithFrame:CGRectMake(30, 84 + 64, ScreenWidth - 60, 392)];
    centerView.backgroundColor = [UIColor whiteColor];
    centerView.layer.cornerRadius = 10;
    self.centerView = centerView;
    [self.view addSubview:centerView];
    
    
    UIImageView *userIcon = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 45, 45)];
    self.userIcon = userIcon;
    userIcon.layer.cornerRadius = 10;
    [userIcon sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",DFAPIURL,self.model.groupAvtar]] placeholderImage:[UIImage imageNamed:@"Image_placeHolder"]];
    [self.centerView addSubview:userIcon];
    
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(userIcon.frame) + 10, CGRectGetMinX(userIcon.frame), CGRectGetWidth(centerView.frame) - CGRectGetMaxX(userIcon.frame) - 10, CGRectGetHeight(userIcon.frame))];
    titleLabel.text = self.model.groupName;
    [self.centerView addSubview:titleLabel];
    
    CGFloat imageW = 250;
    CGFloat imageH = imageW;
    CGFloat imageX = (CGRectGetWidth(self.centerView.frame) - imageW) * 0.5;
    CGFloat imageY = (CGRectGetHeight(self.centerView.frame) - imageH) * 0.5;
    UIImageView *QRCodeView = [[UIImageView alloc] initWithFrame:CGRectMake(imageX, imageY, imageW, imageH)];
    QRCodeView.backgroundColor = [UIColor whiteColor];
    self.QRCodeView = QRCodeView;
    [self.centerView addSubview:QRCodeView];
    
//    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 20, imageW - 40, imageH - 40)];
//    self.imageView = imageView;
//    [QRCodeView addSubview:imageView];
    
}


- (void)rightItemClick {
    KXActionSheet *sheet = [[KXActionSheet alloc] initWithTitle:@"" cancellTitle:@"取消" andOtherButtonTitles:@[@"保存图片"]];
    sheet.delegate = self;
    [sheet show];
}

- (void)KXActionSheet:(KXActionSheet *)sheet andIndex:(NSInteger)index {
    if (index == 0) {
        //保存图片
        [self saveImage];
    }
    
}

// 保存图片
- (void)saveImage {
    
    UIImageWriteToSavedPhotosAlbum(self.QRCodeView.image, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
    
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] init];
    indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    indicator.center = self.centerView.center;
    _indicatorView = indicator;
    [[UIApplication sharedApplication].keyWindow addSubview:indicator];
    [indicator startAnimating];
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo;
{
    [_indicatorView removeFromSuperview];
    
    UILabel *label = [[UILabel alloc] init];
    label.textColor = [UIColor whiteColor];
    label.backgroundColor = [UIColor colorWithRed:0.1f green:0.1f blue:0.1f alpha:0.90f];
    label.layer.cornerRadius = 5;
    label.clipsToBounds = YES;
    label.bounds = CGRectMake(0, 0, 150, 30);
    label.center = self.centerView.center;
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont boldSystemFontOfSize:17];
    [[UIApplication sharedApplication].keyWindow addSubview:label];
    [[UIApplication sharedApplication].keyWindow bringSubviewToFront:label];
    if (error) {
        label.text = @"图片保存失败";
    }   else {
        label.text = @"图片保存成功";
    }
    [label performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:1.0];
}



#pragma mark - 创建二维码
- (void)creatQRCode {
    
    // 1.创建过滤器
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    
    // 2.恢复默认
    [filter setDefaults];
    
    // 3.给过滤器添加数据
    NSString *params = [NSString stringWithFormat:@"sessionId=%@&invite_code=%@&groupId=%@&jid=%@",USERINFO.sessionId,USERINFO.invite_code,self.model.groupId,USERINFO.userID];
    
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
    self.QRCodeView.image = [self creatNonInterpolatedUIImageFormCIImage:outputImage withSize:500];
    
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


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
