//
//  newDiscoverDetailMenu.m
//  ZhiMaBaoBao
//
//  Created by mac on 16/10/24.
//  Copyright © 2016年 liugang. All rights reserved.
//

#import "newDiscoverDetailMenu.h"
#import "GlobalDefines.h"

@implementation newDiscoverDetailMenu {
    UIButton *_likeButton;
    UIView *_centerLine;
    UIButton *_commentButton;
    CGRect _originRect;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    return self;
}


- (void)setup
{
    self.clipsToBounds = YES;
    self.layer.cornerRadius = 5;
    self.backgroundColor = SDColor(69, 74, 76, 1);
    
    _likeButton = [self creatButtonWithTitle:@"赞" image:[UIImage imageNamed:@"Discover_Like"] selImage:[UIImage imageNamed:@""] target:self selector:@selector(likeButtonClicked:)];
    [_likeButton setTitle:@"取消" forState:UIControlStateSelected];
    
    _commentButton = [self creatButtonWithTitle:@"评论" image:[UIImage imageNamed:@"Operation_Comment"] selImage:[UIImage imageNamed:@""] target:self selector:@selector(commentButtonClicked:)];
    
    _centerLine = [UIView new];
    _centerLine.backgroundColor = [UIColor lightGrayColor];
    
    [self addSubview:_likeButton];
    [self addSubview:_commentButton];
    [self addSubview:_centerLine];
}


- (UIButton *)creatButtonWithTitle:(NSString *)title image:(UIImage *)image selImage:(UIImage *)selImage target:(id)target selector:(SEL)sel
{
    UIButton *btn = [UIButton new];
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setImage:image forState:UIControlStateNormal];
    [btn setImage:selImage forState:UIControlStateSelected];
    [btn addTarget:target action:sel forControlEvents:UIControlEventTouchUpInside];
    btn.titleLabel.font = [UIFont systemFontOfSize:14];
    btn.titleEdgeInsets = UIEdgeInsetsMake(0, 3, 0, 0);
    return btn;
}

- (void)likeButtonClicked:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (self.likeButtonClickedOperation) {
        self.likeButtonClickedOperation(self);
    }
    self.show = NO;
}

- (void)commentButtonClicked:(UIButton *)sender {
    if (self.commentButtonClickedOperation) {
        self.commentButtonClickedOperation();
    }
    self.show = NO;
}

- (void)setShow:(BOOL)show
{
    _show = show;
    
//    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionLayoutSubviews | UIViewAnimationOptionTransitionFlipFromLeft animations:^{
//        if (show) {
//            self.frame = CGRectMake(_originRect.origin.x , _originRect.origin.y, _originRect.size.width, _originRect.size.height);
//        } else {
//            self.frame = CGRectMake(_originRect.origin.x + _originRect.size.width , _originRect.origin.y, _originRect.size.width , _originRect.size.height);
//        }
//    } completion:^(BOOL finished) {
//        self.hidden = !show;
//    }];
    
    [UIView animateWithDuration:0.2 animations:^{
        if (show) {
            self.frame = CGRectMake(_originRect.origin.x , _originRect.origin.y, _originRect.size.width, _originRect.size.height);
        } else {
            self.frame = CGRectMake(_originRect.origin.x , _originRect.origin.y, 0 , _originRect.size.height);
        }
    } completion:^(BOOL finished) {
        self.hidden = !show;
    }];
}

- (void)setIsLike:(BOOL)isLike {
    _isLike = isLike;
    
    _likeButton.selected = isLike;
}


- (void)layoutSubviews {
    
    if (!_originRect.size.height) {
        _originRect = self.frame;
    }
    
    
    _likeButton.frame = CGRectMake(5, 0, 80, CGRectGetHeight(self.frame));
    
    _centerLine.frame = CGRectMake(CGRectGetMaxX(_likeButton.frame), 0, 1, CGRectGetHeight(self.frame));
    
    _commentButton.frame = CGRectMake(CGRectGetMaxX(_centerLine.frame), 0, CGRectGetWidth(_likeButton.frame), CGRectGetHeight(self.frame));
    
    
    
}

@end
