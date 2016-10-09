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

#define DEFAULT_CHAT_FONT_SIZE      14  //聊天cell中默认的字体为14
#define DEFAULT_CHAT_MESSAGE_MAX_WIDTH      150.0 //聊天cell,文字内容最大宽度

@interface IMChatTableViewCell()<KXCopyViewDelegate> {

}

@end

@implementation IMChatTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _chatMessageView = [[TQRichTextView alloc] initWithFrame:CGRectZero];
        _chatMessageView.backgroundColor = [UIColor clearColor];
        _chatMessageView.font = SUBFONT;
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

//    CGRect frame = 
//    KXCopyView *copyView = [[KXCopyView alloc] initWithFrame:CGRectMake(<#CGFloat x#>, <#CGFloat y#>, <#CGFloat width#>, <#CGFloat height#>)];
//    copyView.titleArray = @[@"复制",@"转发",@"收藏",@"撤回",@"删除"];
//    [copyView setImage:[UIImage imageNamed:@"Discovre_Copy"] andInsets:UIEdgeInsetsMake(30, 40, 30, 40)];
//    copyView.delegate = self;
//    [copyView showAnimation];
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

//复制
//- (void)copyItemClicked:(id)sender{
//    [super copyItemClicked:sender];
//}

//转发
//- (void)transItemClicked:(id)sender{
//    
//}

//收藏
//- (void)keepItemClicked:(id)sender{
//    
//}

//删除
//- (void)deleteItemClicked:(id)sender{
//    
//}

//撤回
//- (void)undoItemClicked:(id)sender{
//    
//}


#pragma mark 实现成为第一响应者方法

-(BOOL)canBecomeFirstResponder{
    
    return YES;
    
}


- (void)prepareForReuse
{
    [_chatMessageView removeFromSuperview];
    
    _chatMessageView = [[TQRichTextView alloc] initWithFrame:CGRectZero];
    _chatMessageView.backgroundColor = [UIColor clearColor];
    _chatMessageView.font = SUBFONT;
    _chatMessageView.textColor = [UIColor blackColor];
    [_bubble addSubview:_chatMessageView];
}

- (void)setIsMe:(BOOL)isMe
{
    [super setIsMe:isMe];
    
    UIColor *textColor = BLACKCOLOR;
    
    _chatMessageView.textColor = textColor;
}

#pragma mark override

//- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
//{
//    return (action == @selector(copy:) || action == @selector(delete:));
//}
//
//- (void)copy:(id)sender
//{
//    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(copyButtonTappedWithIndexPath:)])
//    {
//        [self.delegate copyButtonTappedWithIndexPath:self.indexPath];
//    }
//}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat  realContentViewHeight = 0;
    float  realWidth = 0;

        
    realContentViewHeight = [TQRichTextView getRechTextViewHeightWithText:_chatMessageView.text
                                                               viewWidth:DEFAULT_CHAT_MESSAGE_MAX_WIDTH
                                                                    font:[UIFont systemFontOfSize:DEFAULT_CHAT_FONT_SIZE]
                                                             lineSpacing:1.5
                                                               realWidth:&realWidth];

    [_chatMessageView setFrameSize:CGSizeMake(realWidth, realContentViewHeight)];
    
    [self resizeBubbleView:_chatMessageView.frameSize];
    
    [self repositionContentView:_chatMessageView];
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
