//
//  KXCommentListView.m
//  YiIM_iOS
//
//  Created by mac on 16/9/8.
//  Copyright © 2016年 ikantech. All rights reserved.
//

#import "KXCommentListView.h"

#import "UIButton+WebCache.h"
#import "NSString+FontSize.h"
#import "MLLinkLabel.h"
#import "FaceThemeModel.h"
#import "UIColor+My.h"
#import "SDAutoLayout.h"

@interface KXCommentListView () <MLLinkLabelDelegate>

@end

@implementation KXCommentListView {
    UIButton *_bjButton;
    UIButton *_iconView;
    UIButton *_userName;
    UILabel *_timeLabel;
    MLLinkLabel *_contentLabel;
    UIView *_contentBottomLineView;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupView];
    }
    return self;
}

- (void)setupView {
    
    _bjButton = [UIButton new];
    [_bjButton addTarget:self action:@selector(viewDidClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_bjButton];
    
    
    _iconView = [[UIButton alloc] init];
    [_iconView addTarget:self action:@selector(iconViewDidClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_iconView];
    
    
    _userName = [[UIButton alloc] init];
    [_userName setTitleColor:[UIColor colorFormHexRGB:@"576b95"] forState:UIControlStateNormal];
    [_userName addTarget:self action:@selector(iconViewDidClick:) forControlEvents:UIControlEventTouchUpInside];
    _userName.titleLabel.font = [UIFont boldSystemFontOfSize:14];
    _userName.titleLabel.textAlignment = NSTextAlignmentLeft;
    [self addSubview:_userName];
    
    
    _timeLabel = [UILabel new];
    _timeLabel.textAlignment = NSTextAlignmentRight;
    _timeLabel.textColor = [UIColor colorFormHexRGB:@"737373"];
    _timeLabel.font = [UIFont systemFontOfSize:13];
    _timeLabel.userInteractionEnabled = NO;
    [self addSubview:_timeLabel];
    
    _contentLabel = [MLLinkLabel new];
    _contentLabel.font = [UIFont systemFontOfSize:15];
    _contentLabel.numberOfLines = 0;
    _contentLabel.delegate = self;
    [self addSubview:_contentLabel];
    
    _contentBottomLineView = [UIView new];
    _contentBottomLineView.backgroundColor = [UIColor colorFormHexRGB:@"e1e1e1"];
    [self addSubview:_contentBottomLineView];
    
}

- (void)setModel:(SDTimeLineCellCommentItemModel *)model {
    _model = model;
    
#warning 需要优化由于autoLayout导致的线程阻塞问题
    
    [_iconView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",DFAPIURL,model.head_photo]] forState:UIControlStateNormal];
    
    [_userName setTitle:model.friend_nick forState:UIControlStateNormal];
    
    
    model.attributedContent = [self generateAttributedStringWithCommentItemModel:model];
    _contentLabel.attributedText = model.attributedContent;
    
    //清除所有链接
    [_contentLabel.links removeAllObjects];
    
    [self setContentLinkText:model andLabel:_contentLabel];
    
    //设置文本链接
    MLLink *fistNameLink = [MLLink linkWithType:MLLinkTypeURL value:model.userId range:[self findTargetStr:model.friend_nick inStr:[model.attributedContent string]]];
    MLLink *secondNameLink;
    if (model.reply_friend_nick.length) {
        //设置文本链接
        secondNameLink = [MLLink linkWithType:MLLinkTypePhoneNumber value:model.reply_id range:[self findTargetStr:model.reply_friend_nick inStr:[model.attributedContent string]]];
    }
    if (secondNameLink) {
        [_contentLabel addLinks:@[fistNameLink,secondNameLink]];
    } else {
        [_contentLabel addLinks:@[fistNameLink]];
    }
    
    
    
    _timeLabel.text = model.create_time;
    
    CGFloat maxWidth = [UIScreen mainScreen].bounds.size.width - 95;
    CGSize size = [[self.model.attributedContent string] sizeWithFont:[UIFont systemFontOfSize:15] maxSize:CGSizeMake(maxWidth, MAXFLOAT)];
    
    
    _bjButton.sd_layout
    .topEqualToView(self)
    .leftEqualToView(self)
    .rightEqualToView(self)
    .bottomEqualToView(self);
    
    _iconView.sd_layout
    .topSpaceToView(self,5)
    .leftSpaceToView(self,0)
    .widthIs(35)
    .heightIs(35);
    
    CGFloat timeWidth = [model.create_time sizeWithFont:[UIFont systemFontOfSize:13] maxSize:CGSizeMake(MAXFLOAT, 15)].width;
    
    _timeLabel.sd_layout
    .topEqualToView(_iconView)
    .rightSpaceToView(self,10)
    .widthIs(timeWidth)
    .autoHeightRatio(0);
    
    
    _userName.sd_layout
    .topEqualToView(_iconView)
    .leftSpaceToView(_iconView,10)
    .widthIs([model.friend_nick sizeWithFont:[UIFont boldSystemFontOfSize:15] maxSize:CGSizeMake(ScreenWidth - timeWidth - 100, 17)].width)
    .heightIs(17);
    
    _contentLabel.sd_layout
    .topSpaceToView(_userName,5)
    .leftEqualToView(_userName)
    .widthIs(size.width)
    .heightIs(size.height);
    
    
    _contentBottomLineView.sd_layout
    .leftEqualToView(_iconView)
    .rightSpaceToView(self,10)
    .topSpaceToView(_contentLabel,10)
    .heightIs(0.5);
    
    [self setupAutoHeightWithBottomView:_contentBottomLineView bottomMargin:0];
    
}

#pragma mark - 富文本代理
- (void)didClickLink:(MLLink*)link linkText:(NSString*)linkText linkLabel:(MLLinkLabel*)linkLabel {
    if ([self isUrlStr:linkText]) {
        //网址
        if ([self.delegate respondsToSelector:@selector(DidClickLinkeWithLinkValue:andType:)]) {
            [self.delegate DidClickLinkeWithLinkValue:link.linkValue andType:1];
        }
    } else {
        //个人
        if ([self.delegate respondsToSelector:@selector(DidClickLinkeWithLinkValue:andType:)]) {
            [self.delegate DidClickLinkeWithLinkValue:link.linkValue andType:0];
        }
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


#pragma mark - private actions
//拼接评论以及回复信息
- (NSMutableAttributedString *)generateAttributedStringWithCommentItemModel:(SDTimeLineCellCommentItemModel *)model {
    NSString *text = model.friend_nick;
    
    UIColor *highLightColor = [UIColor colorFormHexRGB:@"576b95"];
    if (model.reply_friend_nick.length) {
        text = [NSString stringWithFormat:@"回复%@: %@", model.reply_friend_nick,model.comment];
    } else {
        //设置第一个人的字体、颜色
        text = [NSString stringWithFormat:@"%@", model.comment];
    }
    
    NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:text];
    [attString setAttributes:@{NSForegroundColorAttributeName : highLightColor, NSLinkAttributeName : model.userId, NSFontAttributeName : [UIFont boldSystemFontOfSize:14]} range:[text rangeOfString:model.friend_nick]];
    
    //设置第二个人的字体、颜色
    if (model.reply_friend_nick) {
        [attString setAttributes:@{NSForegroundColorAttributeName : highLightColor,NSLinkAttributeName : model.reply_id, NSFontAttributeName : [UIFont boldSystemFontOfSize:14]} range:[text rangeOfString:model.reply_friend_nick]];
    }
    
    return attString;
}

- (NSRange)findTargetStr:(NSString *)TargetStr inStr:(NSString *)str {
    
    return [str rangeOfString:TargetStr];
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
        
        dict[NSForegroundColorAttributeName] = [UIColor blueColor];
        
        NSMutableAttributedString *temStr = [[NSMutableAttributedString alloc] initWithString:subStringForMatch attributes:dict];
        
        [temStr addAttribute:NSLinkAttributeName value:[NSURL URLWithString:subStringForMatch] range:NSMakeRange(0, temStr.length)];
        
        [attrStr replaceCharactersInRange:match.range withAttributedString:temStr];
        label.attributedText = attrStr;
        
        MLLink *link = [MLLink linkWithType:MLLinkTypeEmail value:subStringForMatch range:[model.attributedContent.string rangeOfString:subStringForMatch]];
        [label addLink:link];
        
    }
    
    // 表情匹配放最后。 在前面会被网页筛选给冲掉
    label.attributedText =  [self analyzeText:model.attributedContent.string];
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

- (NSArray *) emojiStringArray {
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

#pragma mark - 头像、名字的点击事件
- (void)iconViewDidClick:(UIButton *)sender {
    sender.backgroundColor = [UIColor lightGrayColor];
    [UIView animateWithDuration:0.3 animations:^{
        sender.backgroundColor = [UIColor clearColor];
    }];
    if ([self.delegate respondsToSelector:@selector(DidClickLinkeWithLinkValue:andType:)]) {
        [self.delegate DidClickLinkeWithLinkValue:self.model.userId andType:0];
    }
}

#pragma mark - 背景点击
- (void)viewDidClick:(UIButton *)button {
    self.backgroundColor = [UIColor colorFormHexRGB:@"c7c7c5"];
    [UIView animateWithDuration:0.3 animations:^{
        self.backgroundColor = [UIColor clearColor];
    }];
    [[NSNotificationCenter defaultCenter] postNotificationName:KCommentOtherNotification object:nil userInfo:@{@"commentView" : self,@"commentModel" : self.model}];
}


@end
