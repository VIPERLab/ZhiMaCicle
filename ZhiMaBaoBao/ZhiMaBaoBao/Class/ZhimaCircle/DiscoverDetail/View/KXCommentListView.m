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
#import "UIColor+My.h"
#import "SDAutoLayout.h"

@implementation KXCommentListView {
    UIButton *_iconView;
    UILabel *_userName;
    UILabel *_timeLabel;
    UILabel *_contentLabel;
    UIView *_contentBottomLineView;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupView];
    }
    return self;
}

- (void)setupView {
    UITapGestureRecognizer* singleRecognizer;
    singleRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewDidClick:)];
    [self addGestureRecognizer:singleRecognizer];
    
    _iconView = [[UIButton alloc] init];
    [self addSubview:_iconView];
    
    
    _userName = [[UILabel alloc] init];
    _userName.textColor = [UIColor colorFormHexRGB:@"576b95"];
    _userName.font = [UIFont boldSystemFontOfSize:14];
    _userName.userInteractionEnabled = NO;
    [self addSubview:_userName];
    
    _timeLabel = [UILabel new];
    _timeLabel.textAlignment = NSTextAlignmentRight;
    _timeLabel.textColor = [UIColor colorFormHexRGB:@"737373"];
    _timeLabel.font = [UIFont systemFontOfSize:13];
    _timeLabel.userInteractionEnabled = NO;
    [self addSubview:_timeLabel];
    
    _contentLabel = [UILabel new];
    _contentLabel.textColor = [UIColor blackColor];
    _contentLabel.font = [UIFont systemFontOfSize:15];
    _contentLabel.numberOfLines = 0;
    _contentLabel.userInteractionEnabled = NO;
    [self addSubview:_contentLabel];
    
    _contentBottomLineView = [UIView new];
    _contentBottomLineView.backgroundColor = [UIColor colorFormHexRGB:@"e1e1e1"];
    [self addSubview:_contentBottomLineView];
    
}

- (void)setModel:(SDTimeLineCellCommentItemModel *)model {
    _model = model;
    
#warning 需要优化由于autoLayout导致的线程阻塞问题
    
    [_iconView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",DFAPIURL,model.head_photo]] forState:UIControlStateNormal];
    _userName.text = model.friend_nick;
    
    NSString *contentText = [NSString string];
    if (![model.reply_friend_nick isEqualToString:@""]) {
        contentText = [NSString stringWithFormat:@"回复%@:%@",model.reply_friend_nick,model.comment];
    } else {
        contentText = model.comment;
    }
    
    _contentLabel.text = contentText;
    
    _timeLabel.text = model.create_time;
    
    CGFloat maxWidth = [UIScreen mainScreen].bounds.size.width - 95;
    CGSize size = [contentText sizeWithFont:[UIFont systemFontOfSize:15] maxSize:CGSizeMake(maxWidth, MAXFLOAT)];
    
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
    .rightSpaceToView(_timeLabel,3)
    .heightIs(17);
    
    _contentLabel.sd_layout
    .topSpaceToView(_userName,5)
    .leftEqualToView(_userName)
    .rightSpaceToView(self,5)
    .heightIs(size.height);
    
    
    _contentBottomLineView.sd_layout
    .leftEqualToView(_iconView)
    .rightSpaceToView(self,10)
    .topSpaceToView(_contentLabel,10)
    .heightIs(0.5);
    
    [self setupAutoHeightWithBottomView:_contentBottomLineView bottomMargin:0];
    
}

- (void)viewDidClick:(UIView *)commentView {
    [[NSNotificationCenter defaultCenter] postNotificationName:KCommentOtherNotification object:nil userInfo:@{@"commentView" : self,@"commentModel" : self.model}];
}


@end
