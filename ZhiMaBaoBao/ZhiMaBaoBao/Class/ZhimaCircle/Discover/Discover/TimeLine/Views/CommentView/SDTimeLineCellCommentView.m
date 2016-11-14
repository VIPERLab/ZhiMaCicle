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
#import "FaceThemeModel.h"



@interface SDTimeLineCellCommentView () <MLLinkLabelDelegate,UIAlertViewDelegate>

@property (nonatomic, strong) NSArray *likeItemsArray; //点赞数组
@property (nonatomic, strong) NSArray *commentItemsArray;//评论数组

@property (nonatomic, strong) UIImageView *bgImageView;

@property (nonatomic, strong) MLLinkLabel *likeLabel;
@property (nonatomic, strong) UIView *likeLableBottomLine;

@property (nonatomic, strong) NSMutableArray *commentLabelsArray;//评论Button存放数组


@end

@implementation SDTimeLineCellCommentView {
    MLLabel *_currentLabel;
    NSString *_currentText;
}

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
        dic[@"userId"] = link.linkValue;
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
        UIButton *commentButtonView = [[UIButton alloc] init];
        [commentButtonView addTarget:self action:@selector(commentButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
        
        UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(commentViewDidLongPress:)];
        [commentButtonView addGestureRecognizer:longPressGesture];
        [self addSubview:commentButtonView];
        
        [self.commentLabelsArray addObject:commentButtonView];
        
        MLLinkLabel *label = [MLLinkLabel new]; //名字Label
        UIColor *highLightColor = [UIColor colorFormHexRGB:@"546993"];
        label.numberOfLines = 0;
        
        label.linkTextAttributes = @{NSForegroundColorAttributeName : highLightColor};
        label.font = [UIFont systemFontOfSize:14];
        label.delegate = self;
        [commentButtonView addSubview:label];
        
    }
    
    for (int i = 0; i < commentItemsArray.count; i++) {
        SDTimeLineCellCommentItemModel *model = commentItemsArray[i];
        
        UIButton *buttonView = self.commentLabelsArray[i];
        
        for (MLLinkLabel *label in buttonView.subviews) {
            
            if ([label isKindOfClass:[MLLinkLabel class]]) {
                
                if (!model.attributedContent) {
                    model.attributedContent = [self generateAttributedStringWithCommentItemModel:model];
                }
                
                label.backgroundColor = [UIColor clearColor];
                
                
                
                //清除所有链接
                [label.links removeAllObjects];
                
                [self setContentLinkText:model andLabel:label];
                
                

                MLLink *commentLink = [MLLink linkWithType:0 value:model.comment range:[self findTargetStr:model.comment inStr:[model.attributedContent string]]];
                commentLink.linkTextAttributes = @{NSForegroundColorAttributeName : [UIColor blackColor]};
                commentLink.activeLinkTextAttributes = @{NSForegroundColorAttributeName : [UIColor blackColor]};
                [commentLink setDidClickLinkBlock:^(MLLink *link, NSString *linkText, MLLinkLabel *label) {
                    [self commentButtonDidClick:buttonView];
                }];
                [label addLink:commentLink];

                
                [self setCommentURLLink:model andLabel:label];
                
                //设置文本链接
                MLLink *fistNameLink = [MLLink linkWithType:MLLinkTypeURL value:model.userId range:[self findTargetStr:model.friend_nick inStr:[model.attributedContent string]]];
                
                
                MLLink *secondNameLink;
                if (model.reply_friend_nick.length) {
                    //设置文本链接
                    secondNameLink = [MLLink linkWithType:MLLinkTypePhoneNumber value:model.reply_id range:[self findTargetStr:model.reply_friend_nick inStr:[model.attributedContent string]]];
                }
                
                if (secondNameLink) {
                    [label addLinks:@[fistNameLink,secondNameLink]];
                } else {
                    [label addLinks:@[fistNameLink]];
                }
                
                
                
                
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
    attach.image = [UIImage imageNamed:@"Discover_Like_Sel"];
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
    
    for (int i = 0; i < self.commentItemsArray.count; i++) {   //设置Label的frame
        
        //文本的最大长度
        CGFloat width = [UIScreen mainScreen].bounds.size.width - 85;
        
        UIButton *buttonView = self.commentLabelsArray[i];
        
        buttonView.sd_layout
        .leftSpaceToView(self,0)
        .rightSpaceToView(self,0)
        .topSpaceToView(lastTopView,5);
//        .heightIs(commentHight);
        
        buttonView.hidden = NO;
        lastTopView = buttonView;
        
        for (UILabel *label in buttonView.subviews) {
            if ([label isKindOfClass:[UILabel class]]) {
                //计算字符串高度

                //计算attributedText高度
                CGSize size = [self sizeLabelToFit:label.attributedText width:width height:16];
                buttonView.sd_layout.heightIs(size.height);
                label.sd_layout
                .leftSpaceToView(buttonView, 8)
                .widthIs(size.width + 1)
                .topEqualToView(buttonView)
                .heightIs(size.height);
            }
        }
    }
    
    [self setupAutoHeightWithBottomView:lastTopView bottomMargin:5];
}

- (CGSize)sizeLabelToFit:(NSAttributedString *)aString width:(CGFloat)width height:(CGFloat)height {
    UILabel *tempLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, width, height)];
    tempLabel.attributedText = aString;
    tempLabel.font = [UIFont systemFontOfSize:14]; //如果不设置字体 直接用字符串的attribute属性 计算不准确
    tempLabel.numberOfLines = 0;
    [tempLabel sizeToFit];
    CGSize size = tempLabel.frame.size;
    size = CGSizeMake((size.width), (size.height));
    return size;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
}

#pragma mark - private actions
//拼接评论以及回复信息
- (NSMutableAttributedString *)generateAttributedStringWithCommentItemModel:(SDTimeLineCellCommentItemModel *)model {
    NSString *text = model.friend_nick;
    
    UIColor *highLightColor = [UIColor colorFormHexRGB:@"576b95"];
    if (model.reply_friend_nick.length) {
        text = [text stringByAppendingString:[NSString stringWithFormat:@"回复%@", model.reply_friend_nick]];
    }
    
    //设置第一个人的字体、颜色
    text = [text stringByAppendingString:[NSString stringWithFormat:@": %@", model.comment]];
    NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:text];
    [attString setAttributes:@{NSForegroundColorAttributeName : highLightColor, NSLinkAttributeName : model.userId, NSFontAttributeName : [UIFont boldSystemFontOfSize:14]} range:[text rangeOfString:model.friend_nick]];
    
    //设置第二个人的字体、颜色
    if (model.reply_friend_nick) {
        [attString setAttributes:@{NSForegroundColorAttributeName : highLightColor,NSLinkAttributeName : model.reply_id, NSFontAttributeName : [UIFont boldSystemFontOfSize:14]} range:[text rangeOfString:model.reply_friend_nick]];
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
- (void)commentButtonDidClick:(UIButton  *)button {
    for (NSInteger index = 0; index < self.commentLabelsArray.count; index++) {
        if (button == self.commentLabelsArray[index]) {
            SDTimeLineCellCommentItemModel *model = self.commentItemsArray[index];
            if ([self.delegate respondsToSelector:@selector(SDTimeLineCellCommentViewCommentOther:andCommentView:)]) {
                
                button.backgroundColor = [UIColor colorFormHexRGB:@"c7c7c5"];
                [UIView animateWithDuration:0.3 animations:^{
                    button.backgroundColor = [UIColor colorFormHexRGB:@"f3f3f5"];
                }];
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
            if ([view isKindOfClass:[MLLabel class]]) {
                _currentLabel = (MLLabel *)view;
                _currentText = _currentLabel.text;
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"复制到粘贴板" message:@"" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
                alertView.delegate = self;
                alertView.tag = 1;
                [alertView show];
                break;
            }
        }
    
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 1) {
        if (buttonIndex == 1) {
            UIPasteboard *pboard = [UIPasteboard generalPasteboard];
            NSRange range = [_currentLabel.text rangeOfString:@":"];
            pboard.string = [_currentLabel.text substringFromIndex:range.location + 1];
            [LCProgressHUD showSuccessText:@"已复制到粘贴板"];
        }
    } else if (alertView.tag == 100) {
        if (buttonIndex == 1) {
            UIPasteboard *pboard = [UIPasteboard generalPasteboard];
            pboard.string = _currentText;
            [LCProgressHUD showSuccessText:@"已复制到粘贴板"];
        }
    }
}

//正则筛选
- (void)setContentLinkText:(UILabel *)label andModel:(SDTimeLineCellCommentItemModel *)model {
    // 正则筛选网页
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc]initWithString:model.comment];
    
    NSString *str=@"((http[s]{0,1}|ftp)://[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@;#$%^&*+?:_/=<>]*)?)|(www.[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@;#$%^&*+?:_/=<>]*)?)";
    
    NSError *error;
    
    NSRegularExpression *expression = [NSRegularExpression regularExpressionWithPattern:str options:NSRegularExpressionCaseInsensitive error:&error];
    
    NSArray *resultArray = [expression matchesInString:label.attributedText.string options:0 range:NSMakeRange(0, label.attributedText.string.length)];
    
    for (NSTextCheckingResult * match in resultArray) {
        
        NSString * subStringForMatch = [label.attributedText.string substringWithRange:match.range];
        
        NSMutableDictionary * dict = [NSMutableDictionary dictionary];
        
        dict[NSFontAttributeName] = [UIFont systemFontOfSize:14.0];
        
        dict[NSForegroundColorAttributeName] = [UIColor colorFormHexRGB:@"546993"];
        
        NSMutableAttributedString * temStr = [[NSMutableAttributedString alloc]initWithString:subStringForMatch attributes:dict];
        
        [temStr addAttribute:NSLinkAttributeName value:[NSURL URLWithString:subStringForMatch] range:NSMakeRange(0, temStr.length)];
        
        [attrStr replaceCharactersInRange:match.range withAttributedString:temStr];
        label.attributedText = attrStr;
    }
    
}


// 正则获取 网址
- (void)setContentLinkText:(SDTimeLineCellCommentItemModel *)model andLabel:(MLLinkLabel *)label {

    // 正则筛选网页
    NSMutableAttributedString *attrStr = [model.attributedContent mutableCopy];
    
    NSString *str=@"((http[s]{0,1}|ftp)://[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)|(www.[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)";
    
    NSError *error;
    
    NSRegularExpression *expression = [NSRegularExpression regularExpressionWithPattern:str options:NSRegularExpressionCaseInsensitive error:&error];
    
    NSArray *resultArray = [expression matchesInString:model.attributedContent.string options:0 range:NSMakeRange(0, model.attributedContent.string.length)];
    
    for (NSTextCheckingResult * match in resultArray) {
        
        NSString * subStringForMatch = [model.attributedContent.string substringWithRange:match.range];
        
        NSMutableDictionary * dict = [NSMutableDictionary dictionary];
        
        dict[NSFontAttributeName] = [UIFont systemFontOfSize:14.0];
        
        dict[NSForegroundColorAttributeName] = [UIColor colorFormHexRGB:@"546993"];
        
        NSMutableAttributedString *temStr = [[NSMutableAttributedString alloc] initWithString:subStringForMatch attributes:dict];
        
        [temStr addAttribute:NSLinkAttributeName value:[NSURL URLWithString:subStringForMatch] range:NSMakeRange(0, temStr.length)];
        
        [attrStr replaceCharactersInRange:match.range withAttributedString:temStr];
        label.attributedText = attrStr;
    }
    
    // 表情匹配放最后。 在前面会被网页筛选给冲掉
    label.attributedText =  [self analyzeText:model.attributedContent.string];
}

// 设置链接
- (void)setCommentURLLink:(SDTimeLineCellCommentItemModel *)model andLabel:(MLLinkLabel *)label {
    // 正则筛选网页
    NSString *str=@"((http[s]{0,1}|ftp)://[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)|(www.[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)";
    
    NSError *error;
    
    NSRegularExpression *expression = [NSRegularExpression regularExpressionWithPattern:str options:NSRegularExpressionCaseInsensitive error:&error];
    
    NSArray *resultArray = [expression matchesInString:model.attributedContent.string options:0 range:NSMakeRange(0, model.attributedContent.string.length)];
    for (NSTextCheckingResult * match in resultArray) {
        NSString * subStringForMatch = [model.attributedContent.string substringWithRange:match.range];
        MLLink *link = [MLLink linkWithType:MLLinkTypeEmail value:subStringForMatch range:[model.attributedContent.string rangeOfString:subStringForMatch]];
        [label addLink:link];
    }
}

- (void)didClickLink:(MLLink *)link linkText:(NSString *)linkText linkLabel:(MLLinkLabel *)linkLabel {
    if ([self isUrlStr:linkText]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:KDiscoverCommentURLNotification object:nil userInfo:@{@"linkValue" : link.linkValue}];
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:KUserNameLabelNotification object:nil userInfo:@{@"userId" : link.linkValue}];
    }
}

- (void)didLongPressLink:(MLLink *)link linkText:(NSString *)linkText linkLabel:(MLLinkLabel *)linkLabel {
    _currentLabel = linkLabel;
    _currentText = linkText;
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"复制到粘贴板" message:@"" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    alertView.delegate = self;
    alertView.tag = 100;
    [alertView show];
    

}

- (BOOL)isUrlStr:(NSString *)urlStr {
    
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:urlStr];
    
    NSString *str=@"((http[s]{0,1}|ftp)://[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)|(www.[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)";
    
    NSError *error;
    
    NSRegularExpression *expression = [NSRegularExpression regularExpressionWithPattern:str options:NSRegularExpressionCaseInsensitive error:&error];
    
    NSArray *resultArray = [expression matchesInString:attrStr.string options:0 range:NSMakeRange(0, attrStr.string.length)];
    
    if (resultArray.count) {
        return YES;
    }
    
    return NO;
}

- (NSMutableAttributedString *)analyzeText:(NSString *)string
{
    NSString *markL = @"[";
    NSString *markR = @"]";
    NSMutableArray *stack = [[NSMutableArray alloc] init];
    NSMutableAttributedString* muAstr = [[NSMutableAttributedString alloc]init];
    
    //偏移索引 由于会把长度大于1的字符串替换成一个空白字符。这里要记录每次的偏移了索引。以便简历下一次替换的正确索引
    int offsetIndex = 0;
    
    for (int i = 0; i < string.length; i++)
    {
        NSString *s = [string substringWithRange:NSMakeRange(i, 1)];
        
        if (([s isEqualToString:markL]) || ((stack.count > 0) && [stack[0] isEqualToString:markL]))
        {
            if (([s isEqualToString:markL]) && ((stack.count > 0) && [stack[0] isEqualToString:markL]))
            {
                for (NSString *c in stack)
                {
                    [muAstr appendAttributedString:[[NSAttributedString alloc]initWithString:c]];
                }
                [stack removeAllObjects];
            }
            
            [stack addObject:s];
            
            if ([s isEqualToString:markR] || (i == string.length - 1))
            {
                NSMutableString *emojiStr = [[NSMutableString alloc] init];
                for (NSString *c in stack)
                {
                    [emojiStr appendString:c];
                }
                
                if ([[self emojiStringArray] containsObject:emojiStr])
                {
                    
                    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"face" ofType:@"plist"];
                    NSDictionary *faceDic = [NSDictionary dictionaryWithContentsOfFile:plistPath];
                    NSString*faceName = [faceDic objectForKey:emojiStr];
                    
                    [muAstr appendAttributedString:[self replaceEmojiWithString:faceName]];
                    
                    offsetIndex += faceName.length - 1;
                }
                else
                {
                    [muAstr appendAttributedString:[[NSAttributedString alloc]initWithString:emojiStr]];
                    
                }
                
                [stack removeAllObjects];
            }
        }
        else
        {
            [muAstr appendAttributedString:[[NSAttributedString alloc]initWithString:s]];
            
        }
    }
    
    return muAstr;
}

- (NSAttributedString*)replaceEmojiWithString:(NSString*)string
{
    NSTextAttachment *attch = [[NSTextAttachment alloc] init];
    attch.image = [UIImage imageNamed:string];//@"f_static_000"];
    attch.bounds = CGRectMake(0, 0, 15, 15);
    NSAttributedString *str = [NSAttributedString attributedStringWithAttachment:attch];
    return str;
}

- (NSArray *)emojiStringArray
{
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"face" ofType:@"plist"];
    NSDictionary *faceDic = [NSDictionary dictionaryWithContentsOfFile:plistPath];
    NSArray *allkeys = faceDic.allKeys;
    
    NSMutableArray *modelsArr = [NSMutableArray array];
    
    for (int i = 0; i < allkeys.count; ++i) {
        NSString *name = allkeys[i];
        FaceModel *fm = [[FaceModel alloc] init];
        fm.faceTitle = name;
        [modelsArr addObject:fm.faceTitle];
    }
    return modelsArr;
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
