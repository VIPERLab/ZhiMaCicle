//
//  IMChatVideoTableViewCell.m
//  ZhiMaBaoBao
//
//  Created by ios开发 on 16/10/19.
//  Copyright © 2016年 liugang. All rights reserved.
//

#import "IMChatVideoTableViewCell.h"
#import "UIImage+PKShortVideoPlayer.h"


@implementation IMChatVideoTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        [self createCustomViews];
    }
    return self;
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    [self.playView removeFromSuperview];
    [self createCustomViews];
}

- (void)reloadData:(LGMessage *)chat isMySelf:(BOOL)isMySelf tapVideoTarget:(id)target action:(SEL)action
{
    _isMe = isMySelf;
    
    self.playView.videoPath = chat.text;

    self.playBtn.hidden = NO;
    
    UIImage *image = [UIImage pk_previewImageWithVideoURL:[NSURL fileURLWithPath:chat.text]];
    self.playView.frameSize = [self pictureSizeToImage:image];

    
    [self.playView centerAlignHorizontalForSuperView];
    [self resizeBubbleView:self.playView.frame.size];
    [self repositionContentViewTypeVideo:self.playView];
    self.playBtn.center = self.playView.center;
    
    UITapGestureRecognizer*tap = [[UITapGestureRecognizer alloc]initWithTarget:target action:action];
    [_playView addGestureRecognizer:tap];
}

- (CGSize)pictureSizeToImage:(UIImage*)image
{
    
    CGSize  imageViewSize = CGSizeMake(160, 160);
    CGSize imgSize = image.size;
//    if (imgSize.width >= imgSize.height) {
    
//        imageViewSize.height = 100 * imgSize.height/imgSize.width;
//    }else{
        imageViewSize.width = 160 * imgSize.width/imgSize.height;
//
//    }
    
    return imageViewSize;
}

- (void)createCustomViews
{
    _playView = [[PKFullScreenPlayerView alloc] initWithFrame:CGRectMake(0, 0, 160, 160)];
    _playView.isMuted = YES;
    _playView.contentMode =  UIViewContentModeScaleAspectFill;
    _playView.layer.cornerRadius = 3;
    _playView.layer.masksToBounds = YES;
    [_bubble addSubview:_playView];
    
    _playBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 40, 40)];
    [_playBtn setImage:[UIImage imageNamed:@"PK_Play"] forState:UIControlStateNormal];
    _playBtn.hidden = YES;
    [_playBtn addTarget:self action:@selector(btnAction_play) forControlEvents:UIControlEventTouchUpInside];
    [_bubble addSubview:_playBtn];

    
    //添加长按手势
    UILongPressGestureRecognizer *longGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressAction:)];
    [_bubble addGestureRecognizer:longGesture];
}

- (void)btnAction_play
{
    self.playBtn.hidden = YES;
    [self.playView play];
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
        BOOL canUndo = (currentStamp - self.message.timeStamp) < 120;
        return self.isMe && canUndo;
    }
    
    return [super canPerformAction:action withSender:sender];
}

#pragma mark 实现成为第一响应者方法

-(BOOL)canBecomeFirstResponder{
    
    return YES;
    
}

@end
