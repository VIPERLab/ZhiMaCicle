//
//  NewDiscoverDetailCommentListView.m
//  ZhiMaBaoBao
//
//  Created by mac on 16/10/21.
//  Copyright © 2016年 liugang. All rights reserved.
//

#import "NewDiscoverDetailCommentListView.h"
#import "UIButton+WebCache.h"
#import "SDTimeLineCellModel.h"

@interface NewDiscoverDetailCommentListView ()

@property (nonatomic, strong) NSMutableArray *buttonArray;
@property (nonatomic, assign) NSInteger tempRow;
@end

@implementation NewDiscoverDetailCommentListView {
    UIImageView *_likeImageView;
    UIView *_bottomLineView;
    
}


- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupView];
    }
    return self;
}

- (void)setupView {
    self.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    _likeImageView = [UIImageView new];
    _likeImageView.image = [UIImage imageNamed:@"Discover_Like"];
    [self addSubview:_likeImageView];
    
    _bottomLineView = [UIView new];
    _bottomLineView.backgroundColor = [UIColor colorFormHexRGB:@"f3f3f5"];
    [self addSubview:_bottomLineView];
}

- (void)setLikeItemArray:(NSArray *)likeItemArray {
    _likeItemArray = likeItemArray;
    
    for (UIButton *button in self.subviews) {
        if ([button isKindOfClass:[UIButton class]]) {
            [button removeFromSuperview];
        }
    }
    
    [self.buttonArray removeAllObjects];
    for (NSInteger index = 0; index < likeItemArray.count; index++) {
        UIButton *button = [UIButton new];
        button.tag = index;
        [self.buttonArray addObject:button];
        [self addSubview:button];
    }
    
}

- (void)layoutSubviews {
    
    CGFloat likeIconW = 15;
    CGFloat likeIconH = 13;
    CGFloat likeIconX = 10;
    CGFloat likeIconY = (55 - likeIconH) * 0.5;
    _likeImageView.frame = CGRectMake(likeIconX, likeIconY, likeIconW, likeIconH);
    
    //每行最多显示数
    NSInteger maxButtonInScreen = (CGRectGetWidth(self.frame) - CGRectGetMaxX(_likeImageView.frame) - 10) / 35;
    
    UIView *lastButton;
    for (NSInteger index = 0; index < self.buttonArray.count; index++) {
        
        //第N行
        CGFloat row = index / maxButtonInScreen;
        //是否换行
        BOOL isNext = row == self.tempRow ? NO : YES;
        CGFloat buttonW = 35;
        CGFloat buttonH = buttonW;
        
        UIButton *button = self.buttonArray[index];
        if (!lastButton) {
            button.frame = CGRectMake( CGRectGetMaxX(_likeImageView.frame) + 10 , 10 , buttonW, buttonH);
        } else if (isNext) {  //需要换行
            self.tempRow = row;
            
            //取出第N行第一个元素
            NSInteger buttonIndex = row * maxButtonInScreen ;
            UIButton *fistButton = self.buttonArray[buttonIndex-maxButtonInScreen];
            button.frame = CGRectMake(CGRectGetMinX(fistButton.frame), CGRectGetMaxY(fistButton.frame) + 5, buttonW, buttonH);
            
        }  else  { //不需要换行
            button.frame = CGRectMake(CGRectGetMaxX(lastButton.frame) + 5, CGRectGetMinY(lastButton.frame), buttonW, buttonH);
            
        }
        
        button.hidden = NO;
        
        SDTimeLineCellLikeItemModel *model = self.likeItemArray[index];
        [button sd_setBackgroundImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",DFAPIURL,model.userPhoto]] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"Image_placeHolder"]];
        
        lastButton = button;
    }
    
    _bottomLineView.frame = CGRectMake(0, CGRectGetHeight(self.frame) - 0.5, CGRectGetWidth(self.frame), 0.5);
    
}


- (NSMutableArray *)buttonArray {
    if (!_buttonArray) {
        _buttonArray = [NSMutableArray array];
    }
    return _buttonArray;
}


@end
