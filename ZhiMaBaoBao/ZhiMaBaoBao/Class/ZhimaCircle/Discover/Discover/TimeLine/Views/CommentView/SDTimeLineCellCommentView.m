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
//                label.attributedText = model.attributedContent;
                
                label.backgroundColor = [UIColor clearColor];
                label.userInteractionEnabled = YES;
                
                //清除所有链接
                [label.links removeAllObjects];
                
                [self setContentLinkText:model andLabel:label];
                
                //设置文本链接
                MLLink *fistNameLink = [MLLink linkWithType:MLLinkTypeURL value:model.userId range:[self findTargetStr:model.friend_nick inStr:[model.attributedContent string]]];
                
                
                MLLink *secondNameLink;
                if (model.reply_friend_nick.length) {
                    //设置文本链接
                    secondNameLink = [MLLink linkWithType:MLLinkTypePhoneNumber value:model.reply_id range:[self findTargetStr:model.reply_friend_nick inStr:[model.attributedContent string]]];
//                    [label addLink:secondNameLink];
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
        
        //文本的最大长度
        CGFloat width = [UIScreen mainScreen].bounds.size.width - 79;
        CGFloat commentHight = [self changeStationWidth:commentItem.attributedContent.string anWidthTxtt:width anfont:15];
        
        UIButton *buttonView = self.commentLabelsArray[i];
        
        buttonView.sd_layout
        .leftSpaceToView(self,0)
        .rightSpaceToView(self,margin)
        .topSpaceToView(lastTopView,5)
        .heightIs(commentHight);
        
        buttonView.hidden = NO;
        lastTopView = buttonView;
        
        for (UILabel *label in buttonView.subviews) {
            if ([label isKindOfClass:[UILabel class]]) {
                CGSize size = [label.text sizeWithFont:[UIFont boldSystemFontOfSize:14] maxSize:CGSizeMake(width, MAXFLOAT)];
                label.sd_layout
                .leftSpaceToView(buttonView, 8)
                .widthIs(size.width)
                .topEqualToView(buttonView)
                .heightIs(size.height);
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
- (void)commentButtonDidClick:(UIButton *)sender {
    
    for (NSInteger index = 0; index < self.commentLabelsArray.count; index++) {
        if (sender == self.commentLabelsArray[index]) {
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
        
        dict[NSForegroundColorAttributeName] = [UIColor blueColor];
        
        NSMutableAttributedString * temStr = [[NSMutableAttributedString alloc]initWithString:subStringForMatch attributes:dict];
        
        [temStr addAttribute:NSLinkAttributeName value:[NSURL URLWithString:subStringForMatch] range:NSMakeRange(0, temStr.length)];
        
        [attrStr replaceCharactersInRange:match.range withAttributedString:temStr];
        label.attributedText = attrStr;
    }
    
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

// 正则获取 网址
- (void)setContentLinkText:(SDTimeLineCellCommentItemModel *)model andLabel:(MLLinkLabel *)label {
    // 正则筛选网页
    label.attributedText = model.attributedContent;
    
    NSMutableAttributedString *attrStr = [model.attributedContent mutableCopy];
    
    NSString *str=@"((http[s]{0,1}|ftp)://[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)|(www.[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)";
    
    NSError *error;
    
    NSRegularExpression *expression = [NSRegularExpression regularExpressionWithPattern:str options:NSRegularExpressionCaseInsensitive error:&error];
    
    NSArray *resultArray = [expression matchesInString:model.attributedContent.string options:0 range:NSMakeRange(0, model.attributedContent.string.length)];
    
    for (NSTextCheckingResult * match in resultArray) {
        
        NSString * subStringForMatch = [model.attributedContent.string substringWithRange:match.range];
        
        NSMutableDictionary * dict = [NSMutableDictionary dictionary];
        
        dict[NSFontAttributeName] = [UIFont systemFontOfSize:14.0];
        
        dict[NSForegroundColorAttributeName] = [UIColor blueColor];
        
        NSMutableAttributedString *temStr = [[NSMutableAttributedString alloc] initWithString:subStringForMatch attributes:dict];
        
        [temStr addAttribute:NSLinkAttributeName value:[NSURL URLWithString:subStringForMatch] range:NSMakeRange(0, temStr.length)];
        
        [attrStr replaceCharactersInRange:match.range withAttributedString:temStr];
        label.attributedText = attrStr;
        
        MLLink *link = [MLLink linkWithType:MLLinkTypeEmail value:subStringForMatch range:[model.attributedContent.string rangeOfString:subStringForMatch]];
        [label addLink:link];
//
//        
//        [label setDidClickLinkBlock:^(MLLink *link, NSString *linkText, MLLinkLabel *label) {
//            NSLog(@"%@",linkText);
//        }];
    }
}

- (void)didClickLink:(MLLink *)link linkText:(NSString *)linkText linkLabel:(MLLinkLabel *)linkLabel {
    if ([self isUrlStr:linkText]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:KDiscoverCommentURLNotification object:nil userInfo:@{@"linkValue" : link.linkValue}];
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:KDiscoverCommenterNotification object:nil userInfo:@{@"userId" : link.linkValue}];
    }
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
