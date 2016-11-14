//
//  IMChatVideoTableViewCell.m
//  ZhiMaBaoBao
//
//  Created by ios开发 on 16/10/19.
//  Copyright © 2016年 liugang. All rights reserved.
//

#import "IMChatVideoTableViewCell.h"
#import "UIImage+PKShortVideoPlayer.h"
#import <AVFoundation/AVFoundation.h>

@interface IMChatVideoTableViewCell ()

@property (nonatomic, assign)CGFloat lastProgress; //上次更新到是值
@property (nonatomic, assign)BOOL isDownload; //是否已下载

@end

@implementation IMChatVideoTableViewCell

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        [self createCustomViews];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerError) name:UIApplicationDidEnterBackgroundNotification object:nil];
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playVideo) name:UIApplicationWillEnterForegroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerError) name:kChatViewControllerPopOut object:nil];

    }
    return self;
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    [self.playView removeFromSuperview];
    [self.playBtn removeFromSuperview];
    [self.progressView removeFromSuperview];
    [self.holderIV removeFromSuperview];
    [_sendFailBtn removeFromSuperview];
    [self createCustomViews];
}

- (void)reloadData:(LGMessage *)chat isMySelf:(BOOL)isMySelf tapVideoTarget:(id)target action:(SEL)action
{
    _isMe = isMySelf;
    _isDownload = chat.isDownLoad;
    
    if (chat.isSending) {
        self.progressView.hidden = NO;
        self.holderIV.hidden = YES;
    }else{
        self.progressView.hidden = YES;
        self.holderIV.hidden = NO;
    }
    
    // 是否有holder图片的路径，没有则代表是正在发送中的视频
    if (chat.holderImageUrlString.length) {
        
        [self.holderIV sd_setImageWithURL:[NSURL URLWithString:chat.holderImageUrlString] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {

            self.playView.frameSize = [self pictureSizeToImage:self.holderIV.image];
            [self upDateUI:chat];

        }];
        
    }else{
        self.holderIV.image = chat.holderImage;
        self.playView.frameSize = [self pictureSizeToImage:chat.holderImage];
        [self upDateUI:chat];
    }

    UITapGestureRecognizer*tap = [[UITapGestureRecognizer alloc]initWithTarget:target action:action];
    [_playView addGestureRecognizer:tap];
}

- (void)upDateUI:(LGMessage*)chat
{
    [self.playView centerAlignHorizontalForSuperView];
    [self resizeBubbleView:self.playView.frame.size];
    [self repositionContentViewTypeVideo:self.playView];
    
    self.playBtn.center = self.playView.center;
    self.progressView.center = self.playView.center;
    self.holderIV.frame = self.playView.frame;
    self.sendFailBtn.center = self.playView.center;
    
    // 是否已下载 已下载就直接播放
    if (_isDownload) {
        self.holderIV.hidden = YES;
        self.playBtn.hidden = NO;
        self.playView.videoPath = [NSString stringWithFormat:@"%@%@",AUDIOPATH,chat.text];
//        [self.playView play];
        
    }else{
        if (_isMe) {
            if (self.progressView.hidden) {
                self.playBtn.hidden = NO;
                
            }else{
                self.playBtn.hidden = YES;
            }
        }else{
            self.playBtn.hidden = NO;
        }
        self.holderIV.hidden = NO;
        
    }
    
}

- (void)playVideo
{
}

- (void)playerError
{
    NSLog(@"暂停了");
    if (self.playBtn.hidden && self.isDownload) {
        self.playBtn.hidden = NO;
    }
    
    [self.playView pause];

}

- (CGSize)pictureSizeToImage:(UIImage*)image
{
    
    CGSize  imageViewSize = CGSizeMake(170, 170);
    CGSize imgSize = image.size;
//    if (imgSize.width >= imgSize.height) {
    
//        imageViewSize.height = 100 * imgSize.height/imgSize.width;
//    }else{ // DEVICEWITH - 120
        CGFloat width = 170 * imgSize.width/imgSize.height;
        imageViewSize.width = width > DEVICEWITH - 120 ? DEVICEWITH - 120 : width;
//
//    }
    
    return imageViewSize;
}

- (void)createCustomViews
{
    _playView = [[PKFullScreenPlayerView alloc] initWithFrame:CGRectMake(0, 0, 170, 170)];
    _playView.isMuted = YES;
    _playView.contentMode =  UIViewContentModeScaleAspectFill;
    _playView.layer.cornerRadius = 3;
    _playView.layer.masksToBounds = YES;
    [_bubble addSubview:_playView];
    
    _holderIV = [[UIImageView alloc]initWithFrame:CGRectZero];
    _holderIV.contentMode =  UIViewContentModeScaleAspectFill;
    _holderIV.layer.cornerRadius = 3;
    _holderIV.layer.masksToBounds = YES;
    [_bubble addSubview:_holderIV];
    
    _playBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 50, 50)];
    [_playBtn setImage:[UIImage imageNamed:@"PK_PlayBtn"] forState:UIControlStateNormal];
    _playBtn.hidden = YES;
    [_playBtn addTarget:self action:@selector(btnAction_play) forControlEvents:UIControlEventTouchUpInside];
    [_bubble addSubview:_playBtn];

    _progressView = [[HKPieChartView alloc]initWithFrame:CGRectMake(0, 0, 50, 50)];
    [_bubble addSubview:_progressView];
    
    _sendFailBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 50, 50)];
    [_sendFailBtn setImage:[UIImage imageNamed:@"sendFail"] forState:UIControlStateNormal];
    [_sendFailBtn addTarget:self action:@selector(reloadViewAction) forControlEvents:UIControlEventTouchUpInside];
    _sendFailBtn.hidden = YES;
    [_bubble addSubview:_sendFailBtn];
    
    
    self.lastProgress = 0.0;
    
    //添加长按手势
    UILongPressGestureRecognizer *longGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressAction:)];
    [_bubble addGestureRecognizer:longGesture];
}

- (void)btnAction_play
{
    self.playBtn.hidden = YES;
    if (_isDownload) {
        [self.playView play];

    }else{
    
        if ([self.VDelegate respondsToSelector:@selector(goToDownloadVideo:)]) {
            [self.VDelegate goToDownloadVideo:self.indexPath];
        }
    }
}

- (void)reloadViewAction
{
    if (self.isMe) {
        if ([self.VDelegate respondsToSelector:@selector(reloadVideo:)]) {
            self.sendFailBtn.hidden = YES;
            self.progressView.hidden = NO;
            [self.VDelegate reloadVideo:self.indexPath];
        }
    }else{
        
        if ([self.VDelegate respondsToSelector:@selector(goToDownloadVideo:)]) {
            self.sendFailBtn.hidden = YES;
            self.progressView.hidden = NO;
            [self.VDelegate goToDownloadVideo:self.indexPath];
        }
    }
    
}

- (void)setProgressWithContent:(CGFloat)progress
{
    if (progress >= 0.99) {
        progress = 0.99;
    }
    [self.progressView updatePercent:progress*100 lastProgress:self.lastProgress animation:NO];
    
    self.lastProgress = progress;
    
    NSLog(@"progress = %lf",progress);
//    if (progress == 1.0) {
////        self.playBtn.hidden = NO;
//        self.progressView.hidden = YES;
//        [self.progressView removeFromSuperview];
//        [self.playView play];
//    }

}

//长按弹出功能栏
- (void)longPressAction:(UIGestureRecognizer *)gesture{
    
    if (gesture.state == UIGestureRecognizerStateBegan) {
        [self becomeFirstResponder];
        
        UIMenuController *menu = [UIMenuController sharedMenuController];
        
        UIMenuItem *copyItem = [[UIMenuItem alloc] initWithTitle:@"复制" action:@selector(copyItemClicked:)];
        UIMenuItem *transItem = [[UIMenuItem alloc] initWithTitle:@"转发" action:@selector(transItemClicked:)];
        UIMenuItem *keepItem = [[UIMenuItem alloc] initWithTitle:@"收藏" action:@selector(keepItemClicked:)];
        UIMenuItem *deleteItem = [[UIMenuItem alloc] initWithTitle:@"删除" action:@selector(deleteItemClicked:)];
        UIMenuItem *undoItem = [[UIMenuItem alloc] initWithTitle:@"撤回" action:@selector(undoItemClicked:)];
        
        [menu setMenuItems:[NSArray arrayWithObjects:copyItem,transItem,keepItem,deleteItem,undoItem,nil]];
        
        [menu setTargetRect:_bubble.frame inView:self];
        
        [menu setMenuVisible:YES animated:YES];
    }
}

#pragma mark 处理action事件

//返回什么方法，则显示什么按钮
-(BOOL)canPerformAction:(SEL)action withSender:(id)sender{
    
    if(action ==@selector(copyItemClicked:)){
        return NO;
        
    }else if (action==@selector(transItemClicked:)){
        return YES;
    }
    else if (action == @selector(keepItemClicked:)){
        return YES;
    }
    else if (action == @selector(deleteItemClicked:)){
        return YES;
    }
    else if (action == @selector(undoItemClicked:)){   //撤回 - 是我发的消息（时间间隔不超过两分钟）时展示撤回按钮
        //判断是不是两分钟之内
        NSInteger currentStamp = [NSDate currentTimeStamp];
        BOOL canUndo = (currentStamp - self.message.timeStamp)/1000 < 120;
        return self.isMe && canUndo;
    }
    
    return [super canPerformAction:action withSender:sender];
}

#pragma mark 实现成为第一响应者方法

-(BOOL)canBecomeFirstResponder{
    
    return YES;
    
}

@end
