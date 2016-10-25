//
//  KXDiscoverNewMessageView.m
//  YiIM_iOS
//
//  Created by mac on 16/9/7.
//  Copyright © 2016年 ikantech. All rights reserved.
//

#import "KXDiscoverNewMessageView.h"
#import "UIColor+My.h"
#import "SDAutoLayout.h"

@implementation KXDiscoverNewMessageView {
    // ---  提示框
    UIView *_tipsView;
    UILabel *_unReadCountLabel;
    UIImageView *_unReadIcon;
    UIImageView *_arrowView;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupView];
    }
    return self;
}

- (void)setupView {
    
    _tipsView = [[UIView alloc] init];
    _tipsView.backgroundColor = [UIColor colorFormHexRGB:@"383a39"];
    _tipsView.layer.cornerRadius = 5;
    [self addSubview:_tipsView];
    
    //为消息提示框添加手势
    UITapGestureRecognizer* singleRecognizer;
    singleRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tipsViewDidClick:)];
    [_tipsView addGestureRecognizer:singleRecognizer];
    
    _unReadIcon = [[UIImageView alloc] init];
    _unReadIcon.backgroundColor = [UIColor clearColor];
    _unReadIcon.layer.cornerRadius = 4;
    _unReadIcon.clipsToBounds = YES;
    [_tipsView addSubview:_unReadIcon];
    
    _unReadCountLabel = [UILabel new];
    _unReadCountLabel.textColor = [UIColor whiteColor];
    _unReadCountLabel.font = [UIFont systemFontOfSize:13];
    _unReadCountLabel.textAlignment = NSTextAlignmentCenter;
    _unReadCountLabel.userInteractionEnabled = NO;
    [_tipsView addSubview:_unReadCountLabel];
    
    
    _arrowView = [UIImageView new];
    _arrowView.image = [UIImage imageNamed:@"Discover_newMessage_arrow"];
    [_tipsView addSubview:_arrowView];
    
    
    _tipsView.sd_layout
    .centerXEqualToView(self)
    .centerYEqualToView(self)
    .heightRatioToView(self,1)
    .widthIs(160);
    
    
    _unReadIcon.sd_layout
    .topSpaceToView(_tipsView, 5)
    .leftSpaceToView(_tipsView,5)
    .bottomSpaceToView(_tipsView,5)
    .widthIs(33);
    
    _unReadCountLabel.sd_layout
    .leftSpaceToView(_unReadIcon,5)
    .rightSpaceToView(_tipsView,5)
    .topSpaceToView(_tipsView,0)
    .bottomSpaceToView(_tipsView,0);
    
    _arrowView.sd_layout
    .topSpaceToView(_tipsView,10)
    .rightSpaceToView(_tipsView,5)
    .bottomSpaceToView(_tipsView,10)
    .widthIs(20);

    
}


// ------  消息栏的点击手势
- (void)tipsViewDidClick:(UIPanGestureRecognizer *)gesture {
    if ([self.delegate respondsToSelector:@selector(SDTimeLineTableHeaderViewTipsViewDidClick:)]) {
        [self.delegate SDTimeLineTableHeaderViewTipsViewDidClick:self];
    }
}


// -------   展示消息提示框
- (void)showNewMessageViewWith:(NSString *)iconURL andNewMessageCount:(int)count {
    
    [_unReadIcon sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",DFAPIURL,iconURL]] placeholderImage:[UIImage imageNamed:@"Image_placeHolder"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        _unReadIcon.image = image;
    }];
    
    
    _unReadCountLabel.text = [NSString stringWithFormat:@"%zd条新消息",count];
    [UIView animateWithDuration:0.3 animations:^{
        _unReadCountLabel.hidden = NO;
        _unReadIcon.hidden = NO;
        _arrowView.hidden = NO;
        self.sd_layout.heightIs(40);
    }];
}


- (void)setShow:(BOOL)show
{
    _show = show;
    
    [UIView animateWithDuration:2 animations:^{
        if (!show) {
            [self clearAutoWidthSettings];
            self.sd_layout
            .heightIs(40);
        } else {
            self.fixedWidth = nil;
            [self setupAutoHeightWithBottomView:_arrowView bottomMargin:5];
        }
        [self updateLayoutWithCellContentView:self.superview];
    }];
}

@end
