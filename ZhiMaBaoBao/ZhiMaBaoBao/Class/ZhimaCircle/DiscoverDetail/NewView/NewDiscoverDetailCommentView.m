//
//  NewDiscoverDetailCommentView.m
//  ZhiMaBaoBao
//
//  Created by mac on 16/10/22.
//  Copyright © 2016年 liugang. All rights reserved.
//

#import "NewDiscoverDetailCommentView.h"
#import "MLLinkLabel.h"
#import "SDTimeLineCellModel.h"

@interface NewDiscoverDetailCommentView () <MLLinkLabelDelegate>

@end

@implementation NewDiscoverDetailCommentView {
    UIImageView *_commentImageView;
    UIImageView *_userIcon;
    UILabel *_userNameLabel;
    MLLinkLabel *_commentLabel;
    UILabel *_timeLabel;
    UIView *_bottomLineView;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupView];
    }
    return self;
}





- (void)setupView {
    _commentImageView = [UIImageView new];
    [self addSubview:_commentImageView];
    
    _userIcon = [UIImageView new];
    [self addSubview:_userIcon];
    
    _userNameLabel = [UILabel new];
    [self addSubview:_userNameLabel];
    
    _commentLabel = [MLLinkLabel new];
    _commentLabel.delegate = self;
    [self addSubview:_commentLabel];
    
    _timeLabel = [UILabel new];
    [self addSubview:_timeLabel];
    
    _bottomLineView = [UIView new];
    [self addSubview:_bottomLineView];
    
}

- (void)setModel:(SDTimeLineCellCommentItemModel *)model {
    
    _model = model;
    [_userIcon sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",DFAPIURL,model.head_photo]] placeholderImage:[UIImage imageNamed:@"Image_placeHolder"]];
    
    _userNameLabel.text = model.friend_nick;
    _timeLabel.text = model.create_time;
    
    
    //设置评论信息
    if (!model.attributedContent) {
        model.attributedContent = [self generateAttributedStringWithCommentItemModel:model];
    }
    
    _commentLabel.backgroundColor = [UIColor clearColor];
    
    if ([self isUrlStr:model.comment]) {
        _commentLabel.userInteractionEnabled = YES;
    } else {
        _commentLabel.userInteractionEnabled = NO;
    }
    
    //清除所有链接
    [_commentLabel.links removeAllObjects];
    
    [self setContentLinkText:model andLabel:_commentLabel];
    
    
    //设置文本链接
    MLLink *fistNameLink = [MLLink linkWithType:MLLinkTypeURL value:model.userId range:[self findTargetStr:model.friend_nick inStr:[model.attributedContent string]]];
    
    
    MLLink *secondNameLink;
    if (model.reply_friend_nick.length) {
        //设置文本链接
        secondNameLink = [MLLink linkWithType:MLLinkTypePhoneNumber value:model.reply_id range:[self findTargetStr:model.reply_friend_nick inStr:[model.attributedContent string]]];
        //                    [label addLink:secondNameLink];
    }
    
    if (secondNameLink) {
        [_commentLabel addLinks:@[fistNameLink,secondNameLink]];
    } else {
        [_commentLabel addLinks:@[fistNameLink]];
    }
    
}


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
    }
}

- (NSRange)findTargetStr:(NSString *)TargetStr inStr:(NSString *)str {
    
    return [str rangeOfString:TargetStr];
}


- (void)didClickLink:(MLLink*)link linkText:(NSString*)linkText linkLabel:(MLLinkLabel*)linkLabel {
    
}


- (void)layoutSubviews {
    
    
    
}
@end
