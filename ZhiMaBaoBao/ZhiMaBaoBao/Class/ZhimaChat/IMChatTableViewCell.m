//
//  ChatCell.m
//  BYD
//
//  Created by YuanFromTentinet on 13-10-15.
//  Copyright (c) 2013年 Tentinet. All rights reserved.
//

#import "IMChatTableViewCell.h"
#import "TQRichTextView.h"
#import "UIImageView+WebCache.h"
#import "KXCopyView.h"

#define DEFAULT_CHAT_FONT_SIZE      15  //聊天cell中默认的字体为14
#define DEFAULT_CHAT_MESSAGE_MAX_WIDTH      DEVICEWITH - 170 //聊天cell,文字内容最大宽度

@interface IMChatTableViewCell()<KXCopyViewDelegate,TQRichTextViewDelegate> {

}

@end

@implementation IMChatTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _chatMessageView = [[TQRichTextView alloc] initWithFrame:CGRectZero];
        _chatMessageView.backgroundColor = [UIColor clearColor];
        _chatMessageView.font = [UIFont systemFontOfSize:DEFAULT_CHAT_FONT_SIZE];
        _chatMessageView.delegage = self;
        _chatMessageView.textColor = [UIColor blackColor];
        [_bubble addSubview:_chatMessageView];
        
        //添加长按手势
        UILongPressGestureRecognizer *longGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressAction:)];
        [_bubble addGestureRecognizer:longGesture];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
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
        return YES;
        
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


- (void)prepareForReuse
{
    [_chatMessageView removeFromSuperview];
    
    _chatMessageView = [[TQRichTextView alloc] initWithFrame:CGRectZero];
    _chatMessageView.backgroundColor = [UIColor clearColor];
    _chatMessageView.font = [UIFont systemFontOfSize:DEFAULT_CHAT_FONT_SIZE];
    _chatMessageView.textColor = [UIColor blackColor];
    _chatMessageView.delegage = self;
    [_bubble addSubview:_chatMessageView];
}

- (void)setIsMe:(BOOL)isMe
{
    [super setIsMe:isMe];
    
    UIColor *textColor = BLACKCOLOR;
    
    _chatMessageView.textColor = textColor;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    float  realContentViewHeight = 0;
    float  realWidth = 0;

        
    realContentViewHeight = [TQRichTextView getRechTextViewHeightWithText:_chatMessageView.text
                                                               viewWidth:DEFAULT_CHAT_MESSAGE_MAX_WIDTH
                                                                    font:[UIFont systemFontOfSize:DEFAULT_CHAT_FONT_SIZE]
                                                             lineSpacing:1.5
                                                               realWidth:&realWidth];

    realWidth = realContentViewHeight<20 ? realWidth+1: realWidth; //单行如果有表情的时候最后的表情可能显示不下，so +1
    [_chatMessageView setFrameSize:CGSizeMake(realWidth, realContentViewHeight)];
    
    [self resizeBubbleView:_chatMessageView.frameSize];
    
    [self repositionContentView:_chatMessageView];
}

- (void)richTextView:(TQRichTextView *)view touchBeginRun:(TQRichTextBaseRun *)run
{
    NSLog(@"lianjie = %@",run.originalText);
    if ([self.cdDelegate respondsToSelector:@selector(jumpToWebViewWithUrlStr:)]) {
        [self.cdDelegate jumpToWebViewWithUrlStr:run.originalText];
    }

}


+ (CGFloat)getHeightWithMessage:(NSString *)message topText:(NSString *)topText nickName:(NSString *)nickName
{

    float realWidth = 0.0;
    CGFloat realContentViewHeight= [TQRichTextView getRechTextViewHeightWithText:message
                                                                       viewWidth:DEFAULT_CHAT_MESSAGE_MAX_WIDTH
                                                                            font:[UIFont systemFontOfSize:DEFAULT_CHAT_FONT_SIZE]
                                                                     lineSpacing:1.5
                                                                       realWidth:&realWidth];
    
    CGFloat height = [BaseChatTableViewCell getBaseHeightTopText:topText nick:nickName contentHeight:realContentViewHeight];
    
    return height;
}

@end
