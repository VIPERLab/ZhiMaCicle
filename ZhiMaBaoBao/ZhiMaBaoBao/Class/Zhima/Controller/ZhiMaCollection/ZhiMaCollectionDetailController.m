//
//  ZhiMaCollectionDetailController.m
//  ZhiMaBaoBao
//
//  Created by mac on 16/10/7.
//  Copyright © 2016年 liugang. All rights reserved.
//

#import "ZhiMaCollectionDetailController.h"
#import "ZhiMaCollectionModel.h"
#import "SDWebImageManager.h"
#import "KXActionSheet.h"

#import "WebViewController.h"
//富文本
#import "TQRichTextView.h"

#import "ForwardMsgController.h"

#import "SDPhotoBrowser.h"

@interface ZhiMaCollectionDetailController () <KXActionSheetDelegate,TQRichTextViewDelegate,SDPhotoBrowserDelegate>

@end

@implementation ZhiMaCollectionDetailController {
    UIScrollView *_scrollView;
    UIView *_bottomLineView;
    UIImageView *_picView;
    UIView *_contentView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupNav];
    [self setupView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupNav {
    [self setCustomTitle:@"详情"];
    
    UIBarButtonItem *right = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"nav_more"] style:UIBarButtonItemStylePlain target:self action:@selector(rightItemDidClick)];
    self.navigationItem.rightBarButtonItem = right;
}

- (void)setupView {
    _scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:_scrollView];
    _scrollView.backgroundColor = [UIColor colorFormHexRGB:@"efeff4"];
    
    UIImageView *iconView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 18, 45, 45)];
    iconView.layer.cornerRadius = 5;
    iconView.clipsToBounds = YES;
    [iconView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",DFAPIURL,self.model.head]] placeholderImage:[UIImage imageNamed:@"Image_placeHolder"]];
    [_scrollView addSubview:iconView];
    
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(iconView.frame) + 8, CGRectGetMinY(iconView.frame) + 3, ScreenWidth - CGRectGetMaxX(iconView.frame) - 8, 20)];
    nameLabel.text = self.model.name;
    nameLabel.font = [UIFont systemFontOfSize:17];
    [_scrollView addSubview:nameLabel];
    
    UIView *bottomLineView = [[UIView alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(iconView.frame) + 11, ScreenWidth - 40, 0.5)];
    bottomLineView.backgroundColor = [UIColor colorFormHexRGB:@"d9d9d9"];
    _bottomLineView = bottomLineView;
    [_scrollView addSubview:bottomLineView];
    
    
    if (self.model.type == 1) { // 纯文字
        
        [self setTextType];
    } else if (self.model.type == 3) { // 图片
        SDWebImageManager *manager = [SDWebImageManager sharedManager];
        [manager downloadImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",self.model.photoUrl]] options:0 progress:0 completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
            [self setupPicWithImage:image];
        }];
    } else if (self.model.type == 5) { //语音类型
        [self setVoiceType];
    }
}

// 设置文本类型
- (void)setTextType {
    TQRichTextView *contentLabel = [[TQRichTextView alloc] init];
    contentLabel.delegage = self;
    contentLabel.backgroundColor = [UIColor clearColor];
    contentLabel.textColor = [UIColor blackColor];
    contentLabel.lineSpacing = 1.5;
    contentLabel.text = self.model.content;
    
    CGFloat contentW = ScreenWidth - 20;
    CGFloat contentH = [TQRichTextView getRechTextViewHeightWithText:contentLabel.text viewWidth:contentW font:[UIFont systemFontOfSize:15] lineSpacing:1.5].height;
    [contentLabel setFrame:CGRectMake(20, CGRectGetMaxY(_bottomLineView.frame) + 11, contentW, contentH)];
    [_scrollView addSubview:contentLabel];
    
    
    UILabel *collectionLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(contentLabel.frame) + 20, ScreenWidth - 40, 30)];
    collectionLabel.textColor = [UIColor colorFormHexRGB:@"bcbcbc"];
    collectionLabel.font = [UIFont systemFontOfSize:12];
    collectionLabel.text = [NSString stringWithFormat:@"收藏于%@",self.model.time];
    [_scrollView addSubview:collectionLabel];
    _scrollView.contentSize = CGSizeMake(ScreenWidth, CGRectGetMaxY(collectionLabel.frame));
}

// 设置图片类型布局
- (void)setupPicWithImage:(UIImage *)image {
    if (image == nil) {
        return;
    }
    CGFloat scale = image.size.width / (ScreenWidth - 40);
    CGFloat picW = image.size.width > (ScreenWidth - 40) ? (ScreenWidth - 40) : image.size.width;
    CGFloat picH = image.size.width > (ScreenWidth - 40) ? image.size.height / scale : image.size.height;
    CGFloat picX = (ScreenWidth - picW) * 0.5;
    CGFloat picY = CGRectGetMaxY(_bottomLineView.frame) + 11;
    
    _contentView = [[UIView alloc] initWithFrame:CGRectMake(picX, picY, picW, picH)];
    [_scrollView addSubview:_contentView];
    
    UIImageView *picView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, picW, picH)];
    picView.userInteractionEnabled = YES;
    [_contentView addSubview:picView];
    picView.image = image;
    _picView = picView;
    
    
    UITapGestureRecognizer *tapGestuer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageDidClick:)];
    [picView addGestureRecognizer:tapGestuer];
    
    
    UILabel *collectionLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(_contentView.frame) + 20, ScreenWidth - 40, 30)];
    collectionLabel.textColor = [UIColor colorFormHexRGB:@"bcbcbc"];
    collectionLabel.font = [UIFont systemFontOfSize:15];
    collectionLabel.text = [NSString stringWithFormat:@"收藏于%@",self.model.time];
    [_scrollView addSubview:collectionLabel];
    
    CGFloat height = CGRectGetMaxY(collectionLabel.frame) > ScreenHeight ? CGRectGetMaxY(collectionLabel.frame) : (ScreenHeight - 64);
    _scrollView.contentSize = CGSizeMake(ScreenWidth, height);
}


// 设置语音类型布局
- (void)setVoiceType {
    
    UIView *voiceView = [[UIView alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(_bottomLineView.frame) + 11, ScreenWidth - 40, 60)];
    voiceView.backgroundColor = [UIColor whiteColor];
    [_scrollView addSubview:voiceView];
    
//    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
//    [button setTitle:@"点我下载" forState:UIControlStateNormal];
//    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//    [button addTarget:self action:@selector(downloadButtonDidClick) forControlEvents:UIControlEventTouchUpInside];
//    [voiceView addSubview:button];
    
    UIProgressView *progessView = [[UIProgressView alloc] initWithFrame:CGRectMake(10, (CGRectGetHeight(voiceView.frame) - 30) * 0.5, CGRectGetWidth(voiceView.frame) - 100, 30)];
    [voiceView addSubview:progessView];
    progessView.trackTintColor = [UIColor colorFormHexRGB:@"e5e5e5"];
    progessView.progressTintColor = [UIColor colorFormHexRGB:@"fd686a"];
//    progessView.progress;
    [progessView setProgress:0.5 animated:NO];
    
}

- (void)downloadButtonDidClick {
    [LGNetWorking downloadFileWithUrl:self.model.content success:^(ResponseData *responseData) {
        
        NSLog(@"%@",responseData.data);
        NSString *filePath = responseData.data;
        
        
    } failure:^(ErrorData *error) {
        
    }];
}

- (void)rightItemDidClick {
    KXActionSheet *sheet = [[KXActionSheet alloc] initWithTitle:@"" cancellTitle:@"取消" andOtherButtonTitles:@[@"发给朋友",@"删除"]];
    sheet.delegate = self;
    [sheet show];
}


#pragma mark - TQRichTextViewDelegate
- (void)richTextView:(TQRichTextView *)view touchBeginRun:(TQRichTextBaseRun *)run {
    if (run.type == richTextURLRunType) {
        NSString *url = run.originalText;
        WebViewController *webView = [[WebViewController alloc] init];
        webView.urlStr = url;
        [self.navigationController pushViewController:webView animated:YES];
    }
    
}

#pragma mark - 点击手势事件
- (void)imageDidClick:(UIGestureRecognizer *)gesture {
    NSLog(@"跳转大图");
    SDPhotoBrowser *browser = [[SDPhotoBrowser alloc] init];
    browser.currentImageIndex = 0;
    browser.userId = USERINFO.userID;
    browser.sourceImagesContainerView = _contentView;
    browser.imageCount = 1;
    browser.delegate = self;
    browser.type = 1;
    [browser show];
    
}

- (UIImage *)photoBrowser:(SDPhotoBrowser *)browser placeholderImageForIndex:(NSInteger)index {
    return  _picView.image;
}

- (NSURL *)photoBrowser:(SDPhotoBrowser *)browser highQualityImageURLForIndex:(NSInteger)index {
    return  [NSURL URLWithString:self.model.photoUrl];
}




- (void)KXActionSheet:(KXActionSheet *)sheet andIndex:(NSInteger)index {
    if (index == 0) {
        // 发给朋友
        LGMessage *message = [[LGMessage alloc] init];
        message.msgid = [NSString generateMessageID];
        
        if (self.model.content.length) {
            message.type = MessageTypeText;
            message.text = self.model.content;
        } else {
            message.type = MessageTypeImage;
            message.text = [NSString stringWithFormat:@"%@",self.model.photoUrl];
            message.picUrl = [NSString stringWithFormat:@"%@",self.model.photoUrl];
        }
        
        ForwardMsgController *vc = [[ForwardMsgController alloc] init];
        vc.message = message;
        BaseNavigationController *nav = [[BaseNavigationController alloc] initWithRootViewController:vc];
        [self presentViewController:nav animated:YES completion:nil];
    } else if (index == 1) {
        // 删除
        [LGNetWorking deletedCircleCollectionWithSessionId:USERINFO.sessionId andCollectionId:self.model.ID success:^(ResponseData *responseData) {
            
            if (responseData.code != 0) {
                return ;
            }
            
            [LCProgressHUD showSuccessText:@"删除成功"];
            [self.navigationController popViewControllerAnimated:YES];
            
        } failure:^(ErrorData *error) {
            
        }];
    }
}



@end
