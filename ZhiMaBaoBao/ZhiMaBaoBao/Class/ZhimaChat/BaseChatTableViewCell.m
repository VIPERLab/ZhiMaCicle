//
//  BaseChatTableViewCell.m
//  Diver
//
//  Created by Tony on 14-8-1.
//  Copyright (c) 2014年 Tentinet. All rights reserved.
//

#import "BaseChatTableViewCell.h"

#define TopLabelFontSize    13
#define NickNameFontSize    12

#define DEFAULT_CHAT_CELL_CONTENT_PADDING   5   //聊天cell上下的间距
#define DEFAULT_CHAT_CELL_NICK_PADDING      5   //聊天cell昵称与topLabel的上下间距
#define DEFAULT_CHAT_CELL_USER_ICON_PADDING 5   //聊天cell头像与昵称的上下间距
#define DEFAULT_CHAT_CELL_BUBBLE_PADDING    5   //聊天cell气泡与昵称的上下间距(有昵称时)
#define DEFAULT_CHAT_CELL_BUBBLE_PADDING_T  3   //聊天cell气泡与图片的上下间距(无昵称时)
#define DEFAULT_CHAT_CELL_H_PADDING         5   //聊天cell头像，气泡，昵称的左右间距
#define DEFAULT_CHAT_CELL_BUBBLE_EDGEINTS   UIEdgeInsetsMake(12, 10, 10, 17)    //聊天的内容与气泡的间距
#define DEFAULT_CHAT_CELL_USER_ICON_SIZE    CGSizeMake(45, 45)  //聊天cell,默认的用户图标尺寸

#define DEFAULT_CHAT_CELL_BUBBLE_RIGHT_NORMAL_IMAGE     @"chat_bg_sender"     //我的聊天气泡正常色
#define DEFAULT_CHAT_CELL_BUBBLE_LEFT_NORMAL_IMAGE      @"chat_bg_reciever"   //他人聊天气泡正常色


@interface BaseChatTableViewCell (private)

- (void)customInit;
- (void)onSendAgain:(id)sender;
- (void)onUserIconTap:(UITapGestureRecognizer *)gest;

- (void)addToFavouriteCustomEmotion:(id)sender;

@end

@implementation BaseChatTableViewCell

@synthesize bubble = _bubble;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {

        [self customInit];
        
        self.userInteractionEnabled = YES;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = WHITECOLOR;
    }
    return self;
}

- (void)awakeFromNib
{
    [self customInit];
    
    self.userInteractionEnabled = YES;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.backgroundColor = WHITECOLOR;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

}

#pragma mark override

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    return (action == @selector(delete:));
}

- (void)delete:(id)sender
{
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(deleteButtonTappedWithIndexPath:)]) {
        
        [self.delegate deleteButtonTappedWithIndexPath:self.indexPath];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    _wrapView.frame = UIEdgeInsetsInsetRect(self.contentView.bounds, UIEdgeInsetsMake(DEFAULT_CHAT_CELL_CONTENT_PADDING, 0, DEFAULT_CHAT_CELL_CONTENT_PADDING, 0));
    _topLabel.lineBreakMode = NSLineBreakByCharWrapping;
    [_topLabel sizeToFit];
    [_topLabel centerAlignHorizontalForSuperView];
    
    _isSetTopLabel  = ![_topLabel.text isBlank];
    _isSetNickLabel = ![_nickLabel.text isBlank];
    
    _userIconOffsetY = _isSetTopLabel ? DEFAULT_CHAT_CELL_USER_ICON_PADDING : 0;
    _bubbleOffsetY = _isSetNickLabel ? DEFAULT_CHAT_CELL_BUBBLE_PADDING : DEFAULT_CHAT_CELL_BUBBLE_PADDING_T;
    [_nickLabel sizeToFit];
    
    [_userIcon setFrameOriginYBelowView:_topLabel offset:_userIconOffsetY];
    [_nickLabel topAlignForView:_userIcon];
    
    if (self.isMe) {
        [_userIcon rightAlignForSuperViewOffset:DEFAULT_CHAT_CELL_H_PADDING];
        [_nickLabel setFrameOriginXLeftOfView:_userIcon offset:DEFAULT_CHAT_CELL_H_PADDING];
        [_bubble setFrameOriginXLeftOfView:_userIcon offset:DEFAULT_CHAT_CELL_H_PADDING];
        [_sendAgain setFrameOriginXLeftOfView:_bubble offset:10];
       // [_sendAgain centerAlignVerticalForSuperView];
        [_sendAgain topAlignForView:_bubble offset:((_bubble.frameSizeHeight - _sendAgain.frameSizeHeight) / 2)];
        _sending.center = _sendAgain.center;
    } else {
        [_userIcon leftAlignForSuperViewOffset:DEFAULT_CHAT_CELL_H_PADDING];
        [_nickLabel setFrameOriginXRightOfView:_userIcon offset:DEFAULT_CHAT_CELL_H_PADDING];
        [_bubble setFrameOriginXRightOfView:_userIcon offset:DEFAULT_CHAT_CELL_H_PADDING];
        _sendAgain.hidden = YES;
        [_sending stopAnimating];
    }
    
    [_bubble setFrameOriginYBelowView:_nickLabel offset:_bubbleOffsetY];
    
}


#pragma mark custom

- (void)setIsMe:(BOOL)isMe
{
    _isMe = isMe;
    
    UIImage *oldImage;
    if (isMe){
        oldImage = [UIImage imageNamed:DEFAULT_CHAT_CELL_BUBBLE_RIGHT_NORMAL_IMAGE];
    }else{
        oldImage = [UIImage imageNamed:DEFAULT_CHAT_CELL_BUBBLE_LEFT_NORMAL_IMAGE];
    }
    
    
    //聊天气泡
//    UIImage *bgImage = [oldImage stretchableImageWithLeftCapWidth:15 topCapHeight:20];
    
    _bubble.image = oldImage;
}

- (void)resizeBubbleView:(CGSize)contetnViewSize
{
    [_bubble setFrameSize:CGSizeMake(contetnViewSize.width + _margin.left + _margin.right, contetnViewSize.height + _margin.top + _margin.bottom)];
    
    if (self.isMe) {
        
        [_bubble setFrameOriginXLeftOfView:_userIcon offset:DEFAULT_CHAT_CELL_H_PADDING];
//暂时不要此功能，所以注释掉。不要删除此代码
//        [_sending setFrameOriginXLeftOfView:_bubble offset:10];
        [_sendAgain setFrameOriginXLeftOfView:_bubble offset:10];
    }
    else
    {
        [_bubble setFrameOriginXRightOfView:_userIcon offset:DEFAULT_CHAT_CELL_H_PADDING];
//暂时不要此功能，所以注释掉。不要删除此代码
//        [_sending setFrameOriginXRightOfView:_bubble offset:10];
        [_sendAgain setFrameOriginXRightOfView:_bubble offset:10];
    }
 //暂时不要此功能，所以注释掉。不要删除此代码
//    [_sending topAlignForView:_bubble offset:((_bubble.frameSizeHeight - _sending.frameSizeHeight) / 2)];
    [_sendAgain topAlignForView:_bubble offset:((_bubble.frameSizeHeight - _sendAgain.frameSizeHeight) / 2)];
    _sending.center = _sendAgain.center;
    
}

- (void)repositionContentView:(UIView *)contentView
{
    CGFloat offsetX = self.isMe ? _margin.left : _margin.right;
    
    contentView.frame = CGRectMake(offsetX, _margin.top, contentView.frame.size.width, contentView.frame.size.height);
}

// 图片的上下间距
- (void)repositionContentViewTypePic:(UIView *)contentView
{
    CGFloat offsetX = self.isMe ? _margin.left : _margin.right+1;
    
    contentView.frame = CGRectMake(offsetX, _margin.top-5, contentView.frame.size.width, contentView.frame.size.height+8);
}

+ (CGFloat)getBaseHeightTopText:(NSString *)topText nick:(NSString *)nick
{
    return [BaseChatTableViewCell getBaseHeightTopText:topText nick:nick contentHeight:0];
}

+ (CGFloat)getBaseHeightTopText:(NSString *)topText nick:(NSString *)nick contentHeight:(CGFloat)contentHeight
{
    return [BaseChatTableViewCell getBaseHeightTopText:topText nick:nick contentHeight:contentHeight bubbleEdgeInset:DEFAULT_CHAT_CELL_BUBBLE_EDGEINTS];
}

+ (CGFloat)getBaseHeightTopText:(NSString *)topText nick:(NSString *)nick contentHeight:(CGFloat)contentHeight bubbleEdgeInset:(UIEdgeInsets)edgeInset
{
    CGFloat height = 0;
    
    BOOL isSetTop  = topText != nil;
    BOOL isSetNick  = nick != nil;
    
    if (isSetTop) {
        
        height += [UIFont systemFontOfSize:TopLabelFontSize].lineHeight;
        height += DEFAULT_CHAT_CELL_USER_ICON_PADDING;
    }
    
    height += DEFAULT_CHAT_CELL_CONTENT_PADDING * 2;    //cell上padding + 下padding，所以*2
    
    CGFloat bubbleHeight = edgeInset.top + edgeInset.bottom + contentHeight;
    
    if (isSetNick) {
        
        CGFloat nickHeight = [UIFont systemFontOfSize:NickNameFontSize].lineHeight;
        CGFloat mixHeight = nickHeight + DEFAULT_CHAT_CELL_BUBBLE_PADDING + bubbleHeight;
        height += MAX(DEFAULT_CHAT_CELL_USER_ICON_SIZE.height, mixHeight);
    }
    else
    {
        
        height += MAX(DEFAULT_CHAT_CELL_USER_ICON_SIZE.height, bubbleHeight + DEFAULT_CHAT_CELL_BUBBLE_PADDING_T);
    }
    
    return height;
}

#pragma mark private

- (void)customInit
{
    _margin = DEFAULT_CHAT_CELL_BUBBLE_EDGEINTS;

    
    _topLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _topLabel.textColor = [UIColor lightGrayColor];
    _topLabel.font = SUBFONT;
    _topLabel.backgroundColor=[UIColor clearColor];

    _nickLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _nickLabel.font = SUBFONT;
    _nickLabel.backgroundColor=[UIColor clearColor];
    

    _userIcon = [[UIImageView alloc] initWithSize:DEFAULT_CHAT_CELL_USER_ICON_SIZE];
    _userIcon.backgroundColor = [UIColor lightGrayColor];
    _userIcon.userInteractionEnabled = YES;
    [_userIcon isCornerRadius];
    _tapGest    = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onUserIconTap:)];
    _tapGest.numberOfTapsRequired = 1;
    _tapGest.numberOfTouchesRequired = 1;
    
    [_userIcon addGestureRecognizer:_tapGest];
    
    _bubble = [[UIImageView alloc] init];
    _bubble.userInteractionEnabled = YES;

    _sending = [[UIActivityIndicatorView alloc] initWithSize:CGSizeMake(20, 20)];
    [_sending setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
    
    _sendAgain = [[UIButton alloc] initWithFrame:CGRectZero];
    [_sendAgain addTarget:self action:@selector(onSendAgain:) forControlEvents:UIControlEventTouchUpInside];
    [_sendAgain setImage:[UIImage imageNamed:@"faileIcon"] forState:UIControlStateNormal];
    [_sendAgain setImage:[UIImage imageNamed:@"faileIcon"] forState:UIControlStateHighlighted];
    [_sendAgain setFrameSize:CGSizeMake(45, 45)];
    

    _wrapView = [[UIView alloc] init];
    [_wrapView addSubview:_topLabel];
    [_wrapView addSubview:_nickLabel];
    [_wrapView addSubview:_userIcon];
    [_wrapView addSubview:_bubble];
    [_wrapView addSubview:_sending];
    [_wrapView addSubview:_sendAgain];
    [self.contentView addSubview:_wrapView];
}

- (void)onSendAgain:(id)sender
{
    NSLog(@"send again");
    
    if (self.resendBlock) {
        self.resendBlock(self);
    }
}

- (void)onUserIconTap:(UITapGestureRecognizer *)gest
{
    //判断 如果不是自己 点击头像就查看详情
    if (!_isMe)
    {
        if (self.delegate != nil && [self.delegate respondsToSelector:@selector(userIconTappedWithIndexPath:)]) {
            [self.delegate userIconTappedWithIndexPath:self.indexPath];
        }
    }
}

@end
