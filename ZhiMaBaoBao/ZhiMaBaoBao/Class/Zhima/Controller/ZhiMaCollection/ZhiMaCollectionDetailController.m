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

#import "AmrPlayerReader.h"
#import "SDPhotoBrowser.h"

@interface ZhiMaCollectionDetailController () <KXActionSheetDelegate,TQRichTextViewDelegate,SDPhotoBrowserDelegate,FileReaderForMLAudioPlayer>
@property (nonatomic, strong) AmrPlayerReader *amrReader;
@property (nonatomic, strong) MLAudioPlayer *player;
@property (nonatomic, weak) UILabel *timeLabel;
@property (nonatomic, weak) NSTimer *timer;
@end

@implementation ZhiMaCollectionDetailController {
    UIScrollView *_scrollView;
    UIView *_bottomLineView;
    UIImageView *_picView;
    UIView *_contentView;
    NSString *_voiceFilePath;
    UIProgressView *_progessView;
    UIButton *_playButton;
    
    double maxTime;
    double indexTime;
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
    indexTime = 0.00;
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
    
    UIButton *playButton = [[UIButton alloc] initWithFrame:CGRectMake(10, ((CGRectGetHeight(voiceView.frame) - 30) * 0.5), 32, 30)];
    _playButton = playButton;
    [playButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [playButton addTarget:self action:@selector(downloadButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
    [playButton setImage:[UIImage imageNamed:@"VoicePlay_Normal"] forState:UIControlStateNormal];
    [playButton setImage:[UIImage imageNamed:@"VoicePlay_Selected"] forState:UIControlStateSelected];
    [voiceView addSubview:playButton];
    
    UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(playButton.frame) + 10, (CGRectGetHeight(voiceView.frame) - 20) * 0.5, 45, 20)];
    self.timeLabel = timeLabel;
    timeLabel.font = [UIFont systemFontOfSize:14];
    timeLabel.textAlignment = NSTextAlignmentCenter;
    timeLabel.text = @"0.00";
    timeLabel.textColor = [UIColor lightGrayColor];
    [voiceView addSubview:timeLabel];
    
    CGFloat progessX = CGRectGetMaxX(timeLabel.frame) + 10;
    UIProgressView *progessView = [[UIProgressView alloc] initWithFrame:CGRectMake(progessX, (CGRectGetHeight(voiceView.frame) - 2) * 0.5, CGRectGetWidth(voiceView.frame) - progessX - 20, 2)];
    [voiceView addSubview:progessView];
    _progessView = progessView;
    progessView.trackTintColor = [UIColor colorFormHexRGB:@"e5e5e5"];
    progessView.progressTintColor = [UIColor colorFormHexRGB:@"fd686a"];
    
    
    UILabel *collectionLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(voiceView.frame) + 20, ScreenWidth - 40, 30)];
    collectionLabel.textColor = [UIColor colorFormHexRGB:@"bcbcbc"];
    collectionLabel.font = [UIFont systemFontOfSize:15];
    collectionLabel.text = [NSString stringWithFormat:@"收藏于%@",self.model.time];
    [_scrollView addSubview:collectionLabel];
    
    CGFloat height = CGRectGetMaxY(collectionLabel.frame) > ScreenHeight ? CGRectGetMaxY(collectionLabel.frame) : (ScreenHeight - 64);
    _scrollView.contentSize = CGSizeMake(ScreenWidth, height);
    
}

- (void)downloadButtonDidClick:(UIButton *)sender {
    if (sender.selected) {
        return;
    }
    if (_voiceFilePath.length) {
        sender.selected = YES;
        [self voicePlay];
        return;
    }
    
    sender.selected = YES;
    // 没有则下载文件之后播放
    [LGNetWorking downloadFileWithUrl:self.model.content success:^(ResponseData *responseData) {
        NSLog(@"%@",responseData.data);
        NSURL *filePath = responseData.data;
        _voiceFilePath = [filePath absoluteString];
        [self voicePlay];
    } failure:^(ErrorData *error) {
        
    }];
}

- (void)viewWillDisappear:(BOOL)animated {
    if (self.player.isPlaying) {
        [self.player stopPlaying];
        [_timer invalidate];
    }
}

- (void)dealloc {
    
}


#pragma mark - 播放相关
// 播放录音
- (void)voicePlay {
    if (!self.amrReader) {
        AmrPlayerReader *amrReader = [[AmrPlayerReader alloc]init];
        self.amrReader = amrReader;
    }
    if (!self.player) {
        MLAudioPlayer *player = [[MLAudioPlayer alloc]init];
        player.fileReaderDelegate = self.amrReader;
        self.player = player;
    }
    _playButton.userInteractionEnabled = NO;
    self.amrReader.filePath = _voiceFilePath;
    maxTime = self.amrReader.duration;
    [self.player startPlaying];
    
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerBlock:) userInfo:nil repeats:YES];
    self.timer = timer;
    [timer fire];
}

- (void)timerBlock:(NSTimer *)timer {
    double currentTime = indexTime;
    if (currentTime > maxTime) {
        [self.timer invalidate];
        self.timeLabel.text = [NSString stringWithFormat:@"0.00"];
        _playButton.selected = NO;
        _playButton.userInteractionEnabled = YES;
        [_progessView setProgress:0 animated:NO];
        indexTime = 0;
    } else {
        indexTime++;
        self.timeLabel.text = [NSString stringWithFormat:@"%.2f",indexTime];
        [UIView animateWithDuration:1 animations:^{
            [_progessView setProgress:(indexTime/maxTime) animated:YES];
        }];
        
    }
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
