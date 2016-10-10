//
//  IMChatVoiceTableViewCell.m
//  ZhiMaBaoBao
//
//  Created by ios开发 on 16/9/27.
//  Copyright © 2016年 liugang. All rights reserved.
//

#import "IMChatVoiceTableViewCell.h"

#define DefaultVoiceButtonHeight    25.0
#define DEFAULT_CHAT_CELL_VOICE_PLAY_IMAGE_PRE_MINE     @"chat_voice_reciever"     //播放他人语音时语音图片的前缀
#define DEFAULT_CHAT_CELL_VOICE_PLAY_IMAGE_PRE_OTHER    @"chat_voice_sender"       //播放我的语音时语音图片的前缀

@interface IMChatVoiceTableViewCell (PrivateMethods)

- (CGFloat)bubbleWithVoiceLength:(NSString*)voiceLength;    //通过语音时长计算聊天气泡的宽度
- (void)onBtn:(id)sender;

@end

@implementation IMChatVoiceTableViewCell

@synthesize playVoiceBtn;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self) {
        
        _btnBg=[UIButton buttonWithType:UIButtonTypeCustom];
        [_btnBg addTarget:self action:@selector(onBtn:) forControlEvents:UIControlEventTouchUpInside];
        _btnBg.frame=CGRectZero;
        [_bubble addSubview:_btnBg];
        
        
        _voiceLengthLabel = [[UILabel alloc] init];
        _voiceLengthLabel.lineBreakMode = NSLineBreakByCharWrapping;
        _voiceLengthLabel.backgroundColor = ClearColor;
        _voiceLengthLabel.font = [UIFont systemFontOfSize:13];
        //[_bubble addSubview:_voiceLengthLabel];
        [self addSubview:_voiceLengthLabel];
        
        
        
        _badgedView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 6, 6)];
        _badgedView.layer.cornerRadius = 3;
        _badgedView.backgroundColor = [UIColor redColor];
        _badgedView.hidden = YES;
        [self addSubview:_badgedView];
        
        
        
        playVoiceBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        playVoiceBtn.backgroundColor = ClearColor;
        [playVoiceBtn addTarget:self action:@selector(playVoiceAction:) forControlEvents:UIControlEventTouchUpInside];
        [_bubble addSubview:playVoiceBtn];
        
        //添加长按手势
        UILongPressGestureRecognizer *longGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressAction:)];
        [_bubble addGestureRecognizer:longGesture];
    }
    return self;
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
        return NO;
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



- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (void)setIsMe:(BOOL)isMe
{
    [super setIsMe:isMe];
    
    
    UIImage  *imgVoice=nil;
    UIEdgeInsets imageViewEdgeInsets;
    
    //如果是自己
    if(isMe) {
        
        imgVoice=[UIImage imageNamed:[NSString stringWithFormat:@"%@",DEFAULT_CHAT_CELL_VOICE_PLAY_IMAGE_PRE_OTHER]];
        
        self.btnBg.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        imageViewEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
        
        self.voiceLengthLabel.textColor = GRAYCOLOR;
        self.voiceLengthLabel.textAlignment = NSTextAlignmentRight;
        
    } else {
        
        imgVoice=[UIImage imageNamed:[NSString stringWithFormat:@"%@",DEFAULT_CHAT_CELL_VOICE_PLAY_IMAGE_PRE_MINE]];
        self.btnBg.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        imageViewEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
        
        self.voiceLengthLabel.textColor = GRAYCOLOR;
        self.voiceLengthLabel.textAlignment = NSTextAlignmentLeft;
    }
    
    [self.btnBg setImage:imgVoice forState:UIControlStateNormal];
    [self.btnBg setImageEdgeInsets:imageViewEdgeInsets];
}

- (void)setVoiceTimeLength:(NSString *)voiceTimeLength
{
    _voiceTimeLength = voiceTimeLength;
    NSString *lengthStr = [self formatVoiceLength:voiceTimeLength];
    if (voiceTimeLength == nil || [voiceTimeLength isBlank]) {
        
        self.voiceLengthLabel.text = nil;
    }
    else
    {
        self.voiceLengthLabel.text = lengthStr;
    }
}

- (NSString *)formatVoiceLength:(NSString *)length
{
    NSInteger timeLength = [length floatValue] * 1000;
    NSString *lengthStr = nil;
    
    if (timeLength < 1000) {
        lengthStr = @"1\"";
    }
    else
    {
        if (timeLength >= 1000) {    //转换成秒数
            
            timeLength = timeLength / 1000;
            lengthStr = [NSString stringWithFormat:@"%li\"",(long)timeLength];
        }
        
        if (timeLength > 60) { //转换成分钟
            
            timeLength = timeLength / 60; //分钟
            NSInteger mm = timeLength % 60; //秒
            lengthStr = [NSString stringWithFormat:@"%li'%li\"",(long)timeLength,(long)mm];
        }
    }
    
    return lengthStr;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
//    CGFloat  height = DefaultVoiceButtonHeight;
    
    //CGFloat  realWidth = [self bubbleWithVoiceLength:self.voiceTimeLength.integerValue];
    CGFloat bubbleWidth = [self bubbleWithVoiceLength:_voiceTimeLength];
    
    
    [self.btnBg setFrameSize:CGSizeMake(26/2, 40/2)];  //CGSizeMake(bubbleWidth, height)
    
    
    [self.voiceLengthLabel sizeToFit];
    
    
    [self resizeBubbleView:_btnBg.frameSize];
    
    
    [self repositionContentView:_btnBg];
    
    self.bubble.frameSizeHeight += 2; // 因为高度低于9切片之前的高度，下边有点切边  所以加2

    
    self.bubble.frameSizeWidth = bubbleWidth;
    
    
    
    self.voiceLengthLabel.frameSize = CGSizeMake(50, 50/2);
    
    
    if (self.isMe) {
        
        self.bubble.frameOriginX = self.userIcon.frameOriginX - 10/2 - self.bubble.frameSizeWidth;
        self.btnBg.frameOriginX = self.bubble.frameSizeWidth - (10 + 26 + 26)/2;
        
        //_bubble.frameOriginY + (_bubble.frameSizeHeight - self.voiceLengthLabel.frameSizeHeight)
        self.voiceLengthLabel.frameOrigin = CGPointMake(_bubble.frameOriginX - self.voiceLengthLabel.frameSizeWidth - 10/2, _bubble.frameMaxY - self.voiceLengthLabel.frameSizeHeight);
        
        _badgedView.hidden = YES;
        
        playVoiceBtn.frame = CGRectMake(0, 0, self.bubble.frameSizeWidth - 10, self.bubble.frameSizeHeight);
    }
    else
    {
        //_bubble.frameOriginY + (_bubble.frameSizeHeight - self.voiceLengthLabel.frameSizeHeight)/2
        self.voiceLengthLabel.frameOrigin = CGPointMake(_bubble.frameMaxX + 10/2, _bubble.frameMaxY - self.voiceLengthLabel.frameSizeHeight);
        
        
        //_badgedView.hidden = NO;
        
        //未读红点
        if (self.isReadVoice) {
            _badgedView.hidden = YES;
        } else {
            _badgedView.hidden = NO;
            [_badgedView setFrameOrigin:CGPointMake(_bubble.frameMaxX + 10/2, _bubble.frameMaxY - self.voiceLengthLabel.frameSizeHeight - 5)];
            //[_badgedView centerAlignVerticalForSuperView];
        }
        [_badgedView showDebugFrame];
        
        playVoiceBtn.frame = CGRectMake(10, 0, self.bubble.frameSizeWidth, self.bubble.frameSizeHeight);
    }
}

#pragma mark private

- (CGFloat)bubbleWithVoiceLength:(NSString *) voiceLength
{
    NSLog(@"------------- %@",voiceLength);
    CGFloat width = 60;
    NSInteger m = [voiceLength integerValue];
    
    CGFloat minWW = (DEVICEWITH/2 - 80)/60;
    
    width += m*minWW;
    
//    if (m < 10) {
//        width = 136/2;
//    }else if (m >= 10 && m <= 30){
//        width = 186/2;
//    }else{
//        width = 286/2;
//    }
    
    //    CGFloat percent = m / 60.0f;
    //    NSLog(@"voiceLength:%i,m:%i,percent:%f",voiceLength,m,percent);
    //    CGFloat add = BubbleMaxWidth * percent;    //气泡长度的增量
    //    width = MIN(BubbleMaxWidth, width + add);
    
    return width;
}

- (void)onBtn:(id)sender
{
    if (self.voiceDelegate != nil && [self.voiceDelegate respondsToSelector:@selector(onPlayBtn:)]) {
        
        [self.voiceDelegate onPlayBtn:sender];
    }
}

- (void)playVoiceAction:(id)sender
{
    if (self.voiceDelegate != nil && [self.voiceDelegate respondsToSelector:@selector(onPlayBtn:)]) {
        
        [self.voiceDelegate onPlayBtn:sender];
    }
}

#pragma mark custom

+ (CGFloat)getHeightWithTopText:(NSString *)topText nickName:(NSString *)nickName
{
    
    CGFloat realContentViewHeight = DefaultVoiceButtonHeight;
    
    CGFloat height = [BaseChatTableViewCell getBaseHeightTopText:topText nick:nickName contentHeight:realContentViewHeight];
    
    
    
    return height;
}


@end
