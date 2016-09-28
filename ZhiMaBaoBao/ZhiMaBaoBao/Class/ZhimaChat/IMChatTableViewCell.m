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

#define DEFAULT_CHAT_FONT_SIZE      14  //聊天cell中默认的字体为14
#define DEFAULT_CHAT_MESSAGE_MAX_WIDTH      150.0 //聊天cell,文字内容最大宽度

@interface IMChatTableViewCell() {

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
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
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

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    return (action == @selector(copy:) || action == @selector(delete:));
}

- (void)copy:(id)sender
{
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(copyButtonTappedWithIndexPath:)])
    {
        [self.delegate copyButtonTappedWithIndexPath:self.indexPath];
    }
}

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
