//
//  SDTimeLineCellCommentView.m
//  GSD_WeiXin(wechat)
//
//  Created by gsd on 16/2/25.
//  Copyright © 2016年 GSD. All rights reserved.
//

/*
 
 *********************************************************************************
 *
 * GSD_WeiXin
 *
 * QQ交流群: 459274049
 * Email : gsdios@126.com
 * GitHub: https://github.com/gsdios/GSD_WeiXin
 * 新浪微博:GSD_iOS
 *
 * 此“高仿微信”用到了很高效方便的自动布局库SDAutoLayout（一行代码搞定自动布局）
 * SDAutoLayout地址：https://github.com/gsdios/SDAutoLayout
 * SDAutoLayout视频教程：http://www.letv.com/ptv/vplay/24038772.html
 * SDAutoLayout用法示例：https://github.com/gsdios/SDAutoLayout/blob/master/README.md
 *
 *********************************************************************************
 
 */

#import "SDTimeLineCellCommentView.h"
#import "UIView+SDAutoLayout.h"
#import "SDTimeLineCellModel.h"
#import "MLLinkLabel.h"
#import "UIColor+My.h"
#import "KXCodingManager.h"

@interface SDTimeLineCellCommentView () <MLLinkLabelDelegate>

@property (nonatomic, strong) NSArray *likeItemsArray; //点赞数组
@property (nonatomic, strong) NSArray *commentItemsArray;//评论数组

@property (nonatomic, strong) UIImageView *bgImageView;

@property (nonatomic, strong) MLLinkLabel *likeLabel;
@property (nonatomic, strong) UIView *likeLableBottomLine;

@property (nonatomic, strong) NSMutableArray *commentLabelsArray;//评论Button存放数组


@end

@implementation SDTimeLineCellCommentView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        [self setupViews];
    

    }
    return self;
}

- (void)setupViews {
    
    _bgImageView = [UIImageView new];
    [self addSubview:_bgImageView];
    
    self.backgroundColor = [UIColor colorFormHexRGB:@"f3f3f5"];
    
    _likeLabel = [MLLinkLabel new];
    _likeLabel.font = [UIFont systemFontOfSize:14];
    _likeLabel.linkTextAttributes = @{NSForegroundColorAttributeName : [UIColor colorFormHexRGB:@"576b95"]};
    _likeLabel.isAttributedContent = YES;
    
    
    [_likeLabel setDidClickLinkBlock:^(MLLink *link, NSString *linkText, MLLinkLabel *label) {
        // -----    发送富文本点击通知
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        dic[@"openFirAccount"] = link.linkValue;
        NSNotification *notif = [NSNotification notificationWithName:KUserNameLabelNotification object:nil userInfo:dic];
        [[NSNotificationCenter defaultCenter] postNotification:notif];
        
    }];
    
    
    [self addSubview:_likeLabel];
    
    _likeLableBottomLine = [UIView new];
    _likeLableBottomLine.backgroundColor = [UIColor colorFormHexRGB:@"dddedf"];
    [self addSubview:_likeLableBottomLine];
    
    _bgImageView.sd_layout.spaceToSuperView(UIEdgeInsetsMake(0, 0, 0, 0));
}


- (void)setCommentItemsArray:(NSArray *)commentItemsArray
{
    _commentItemsArray = commentItemsArray;
    
    long originalLabelsCount = self.commentLabelsArray.count;
    long needsToAddCount = commentItemsArray.count > originalLabelsCount ? (commentItemsArray.count - originalLabelsCount) : 0;
    
    for (int i = 0; i < needsToAddCount; i++) {
        //添加手势
        UIView *commentButtonView = [[UIView alloc] init];
        UITapGestureRecognizer* singleRecognizer;
        singleRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(commentButtonDidClick:)];
        [commentButtonView addGestureRecognizer:singleRecognizer];
        
        
        UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(commentViewDidLongPress:)];
        [commentButtonView addGestureRecognizer:longPressGesture];
        [self addSubview:commentButtonView];
        
        [self.commentLabelsArray addObject:commentButtonView];
        
        MLLinkLabel *label = [MLLinkLabel new]; //名字Label
        UIColor *highLightColor = [UIColor colorFormHexRGB:@"546993"];
        label.userInteractionEnabled = NO;
        
        label.linkTextAttributes = @{NSForegroundColorAttributeName : highLightColor};
        label.font = [UIFont systemFontOfSize:14];
        label.delegate = self;
        [commentButtonView addSubview:label];
    }
    
    for (int i = 0; i < commentItemsArray.count; i++) {
        SDTimeLineCellCommentItemModel *model = commentItemsArray[i];
        
        UIView *buttonView = self.commentLabelsArray[i];
        
        for (MLLinkLabel *label in buttonView.subviews) {
            
            if ([label isKindOfClass:[MLLinkLabel class]]) {
                
//                NSString *deCodingStr = [CodingManager UTF8DecodeString:model.comment];
//                label.text = [model.friend_nick stringByAppendingString:];
                if (!model.attributedContent) {
                    model.attributedContent = [self generateAttributedStringWithCommentItemModel:model];
                }
                label.attributedText = model.attributedContent;
            }
        }
        
        
        
    }
}

- (void)setLikeItemsArray:(NSArray *)likeItemsArray
{
    _likeItemsArray = likeItemsArray;
    
    if (likeItemsArray.count == 0) {
        _likeLabel.hidden = YES;
        return;
    }
    
    _likeLabel.hidden = NO;
    
    NSTextAttachment *attach = [NSTextAttachment new];
    attach.image = [UIImage imageNamed:@"Discover_Like"];
    attach.bounds = CGRectMake(0, -3, 15, 14);
    NSAttributedString *likeIcon = [NSAttributedString attributedStringWithAttachment:attach];
    
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithAttributedString:likeIcon];
    
    NSMutableArray *linksArray = [NSMutableArray array];
    
    for (int i = 0; i < likeItemsArray.count; i++) {
        
        SDTimeLineCellLikeItemModel *model = likeItemsArray[i];
        if (i == 0) {
            [attributedText appendAttributedString:[[NSAttributedString alloc] initWithString:@" "]];
        }
        
        if (i > 0) {
            [attributedText appendAttributedString:[[NSAttributedString alloc] initWithString:@", "]];
        }
        if (!model.attributedContent) {
            model.attributedContent = [self generateAttributedStringWithLikeItemModel:model];
        }
        
        
        [attributedText appendAttributedString:model.attributedContent];
        MLLink *link = [MLLink linkWithType:1 value:model.userId range:[self findTargetStr:model.userName inStr:[attributedText string]]];
        [linksArray addObject:link];
        
    }
    _likeLabel.attributedText = [attributedText copy];
    [_likeLabel addLinks:linksArray];
}



- (NSRange)findTargetStr:(NSString *)TargetStr inStr:(NSString *)str {
    
    return [str rangeOfString:TargetStr];
}

- (void)setupWithLikeItemsArray:(NSArray *)likeItemsArray commentItemsArray:(NSArray *)commentItemsArray
{
    self.likeItemsArray = likeItemsArray;
    self.commentItemsArray = commentItemsArray;
    
    if (self.commentLabelsArray.count) {
        [self.commentLabelsArray enumerateObjectsUsingBlock:^(UIView *buttonView, NSUInteger idx, BOOL *stop) {
            [buttonView sd_clearAutoLayoutSettings];
            buttonView.hidden = YES; //重用时先隐藏所以评论label，然后根据评论个数显示label
        }];
    }
    
    if (!commentItemsArray.count && !likeItemsArray.count) {
        self.fixedWidth = @(0); // 如果没有评论或者点赞，设置commentview的固定宽度为0（设置了fixedWith的控件将不再在自动布局过程中调整宽度）
        self.fixedHeight = @(0); // 如果没有评论或者点赞，设置commentview的固定高度为0（设置了fixedHeight的控件将不再在自动布局过程中调整高度）
        return;
    } else {
        _likeLabel.hidden = YES;
        self.fixedHeight = nil; // 取消固定宽度约束
        self.fixedWidth = nil; // 取消固定高度约束
    }
    
    CGFloat margin = 5;
    
    UIView *lastTopView = nil;
    
    if (likeItemsArray.count) {
        _likeLabel.hidden = NO;
        _likeLabel.sd_resetLayout
        .leftSpaceToView(self, margin)
        .rightSpaceToView(self, margin)
        .topSpaceToView(lastTopView, margin)
        .autoHeightRatio(0);
        
        lastTopView = _likeLabel;
    } else {
        _likeLabel.hidden = YES;
        _likeLabel.attributedText = nil;
        _likeLabel.sd_resetLayout
        .heightIs(0);
    }
    
    
    if (self.commentItemsArray.count && self.likeItemsArray.count) {
        _likeLableBottomLine.sd_resetLayout
        .leftSpaceToView(self, 0)
        .rightSpaceToView(self, 0)
        .heightIs(0.5)
        .topSpaceToView(lastTopView, 3);
        
        lastTopView = _likeLableBottomLine;
    } else {
        _likeLableBottomLine.sd_resetLayout.heightIs(0);
    }
    
    for (int i = 0; i < self.commentItemsArray.count; i++) {   //设置Label的fram
        
        SDTimeLineCellCommentItemModel *commentItem = self.commentItemsArray[i];
        //获取文本的高度
        NSString *commentContent = [NSString string];
        if (![commentItem.reply_friend_nick isEqualToString:@""]) {
            commentContent = [commentItem.friend_nick stringByAppendingString:[NSString stringWithFormat:@"回复%@:%@",commentItem.reply_friend_nick,commentItem.comment]];
        } else {
            commentContent = [commentItem.friend_nick stringByAppendingString:[NSString stringWithFormat:@":%@",commentItem.comment]];
        }
        
        //文本的最大长度
        CGFloat width = [UIScreen mainScreen].bounds.size.width - 79;
        CGFloat commentHight = [self changeStationWidth:commentContent anWidthTxtt:width anfont:15];
        
        UIView *buttonView = self.commentLabelsArray[i];

        buttonView.sd_layout
        .leftSpaceToView(self,0)
        .rightSpaceToView(self,margin)
        .topSpaceToView(lastTopView,5)
        .heightIs(commentHight);
        
        buttonView.hidden = NO;
        lastTopView = buttonView;
        
        for (UILabel *label in buttonView.subviews) {
            if ([label isKindOfClass:[UILabel class]]) {
                label.backgroundColor = [UIColor colorFormHexRGB:@"f3f3f5"];
                label.sd_layout
                .leftSpaceToView(buttonView, 8)
                .rightEqualToView(buttonView)
                .topEqualToView(buttonView)
                .autoHeightRatio(0);
            }
        }
    }
    
    [self setupAutoHeightWithBottomView:lastTopView bottomMargin:5];
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
}

#pragma mark - private actions
//拼接评论以及回复信息
- (NSMutableAttributedString *)generateAttributedStringWithCommentItemModel:(SDTimeLineCellCommentItemModel *)model {
    NSString *text = model.friend_nick;
    if (model.reply_friend_nick.length) {
        text = [text stringByAppendingString:[NSString stringWithFormat:@"回复%@", model.reply_friend_nick]];
    }
    
    text = [text stringByAppendingString:[NSString stringWithFormat:@":%@", model.comment]];
    NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:text];
    [attString setAttributes:@{NSLinkAttributeName : model.userId} range:[text rangeOfString:model.friend_nick]];
    if (model.reply_friend_nick) {
        [attString setAttributes:@{NSLinkAttributeName : model.reply_id} range:[text rangeOfString:model.reply_friend_nick]];
    }
    return attString;
}

//点赞的名字
- (NSMutableAttributedString *)generateAttributedStringWithLikeItemModel:(SDTimeLineCellLikeItemModel *)model {
    NSString *text = model.userName;
    if (text == nil || [text isEqualToString:@""]) {
        NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:text];
        return attString;
    }
    
    NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:text];
    UIColor *highLightColor = [UIColor colorFormHexRGB:@"576b95"];
    [attString setAttributes:@{NSForegroundColorAttributeName : highLightColor, NSLinkAttributeName : model.userId , NSFontAttributeName : [UIFont boldSystemFontOfSize:14]} range:[text rangeOfString:model.userName]];
    
    return attString;
}

#pragma mark - 评论框点击按钮
- (void)commentButtonDidClick:(UITapGestureRecognizer*)recognizer {
    UIView *commentButtonView = recognizer.self.view;
    for (NSInteger index = 0; index < self.commentLabelsArray.count; index++) {
        if (commentButtonView == self.commentLabelsArray[index]) {
            SDTimeLineCellCommentItemModel *model = self.commentItemsArray[index];
            if ([self.delegate respondsToSelector:@selector(SDTimeLineCellCommentViewCommentOther:andCommentView:)]) {
                [self.delegate SDTimeLineCellCommentViewCommentOther:model andCommentView:self.commentLabelsArray[index]];
            }
        }
    }
}

#pragma makr - 长按点击事件
- (void)commentViewDidLongPress:(UIGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateBegan) {
        UIView *commentView = gesture.view;
        for (UIView *view in commentView.subviews) {
            if ([view isKindOfClass:[UILabel class]]) {
                [[NSNotificationCenter defaultCenter] postNotificationName:KDiscoverCommentViewClickNotification object:nil userInfo:@{@"contentLabel" : view}];
                break;
            }
        }
    
    }
}

#pragma mark - MLLinkLabelDelegate
// ---  富文本回调
- (void)didClickLink:(MLLink *)link linkText:(NSString *)linkText linkLabel:(MLLinkLabel *)linkLabel {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"openFirAccount"] = link.linkValue;
    NSNotification *notif = [NSNotification notificationWithName:KUserNameLabelNotification object:nil userInfo:dic];
    [[NSNotificationCenter defaultCenter] postNotification:notif];
}

//计算文字高度
-(CGFloat)changeStationWidth:(NSString *)string anWidthTxtt:(CGFloat)widthText anfont:(CGFloat)fontSize{
    
    UIFont * tfont = [UIFont systemFontOfSize:fontSize];
    
    //高度估计文本大概要显示几行，宽度根据需求自己定义。 MAXFLOAT 可以算出具体要多高
    
    CGSize size =CGSizeMake(widthText,MAXFLOAT);
    
    //    获取当前文本的属性
    
    NSDictionary * tdic = [NSDictionary dictionaryWithObjectsAndKeys:tfont,NSFontAttributeName,nil];
    
    //ios7方法，获取文本需要的size，限制宽度
    
    CGSize  actualsize =[string boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin  attributes:tdic context:nil].size;
    
    return actualsize.height;
    
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (NSMutableArray *)commentLabelsArray
{
    if (!_commentLabelsArray) {
        _commentLabelsArray = [NSMutableArray new];
    }
    return _commentLabelsArray;
}

@end
