//
//  KXDiscoverDetailCommentView.m
//  YiIM_iOS
//
//  Created by mac on 16/9/8.
//  Copyright © 2016年 ikantech. All rights reserved.
//

#import "KXDiscoverDetailCommentView.h"

#import "SDTimeLineCellModel.h"
#import "KXCommentListView.h"
// ----  第三方
#import "UIButton+WebCache.h"
#import "SDAutoLayout.h"
#import "UIColor+My.h"

@interface KXDiscoverDetailCommentView () <KXCommentListViewDelegate>

// --- 控件存放数组
@property (nonatomic, strong) NSMutableArray *likeButtonArray;
@property (nonatomic, strong) NSMutableArray *commentViewArray;

// ---  数据存放数组
@property (nonatomic, strong) NSMutableArray *likeItemArray;
@property (nonatomic, strong) NSMutableArray *commentItemArray;

@property (nonatomic, assign) NSInteger tempRow;

@end

@implementation KXDiscoverDetailCommentView {
    UIImageView *_bigBjImage;
    UIImageView *_commentIcon;
    UIImageView *_likeImage;
    UIView *_likeBottomLikeView;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupView];
    }
    return self;
}

- (void)setupView {
    
    
    _bigBjImage = [[UIImageView alloc] init];
    [self addSubview:_bigBjImage];
    _bigBjImage.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    
    _bigBjImage.sd_layout.spaceToSuperView(UIEdgeInsetsMake(0, 0, 0, 0));
    
}


- (void)setLikeItemArray:(NSMutableArray *)likeItemArray {
    _likeItemArray = likeItemArray;
    
    for (NSInteger index = 0; index < likeItemArray.count; index++) {
        UIButton *likeItemButton = [UIButton new];
        likeItemButton.tag = index;
        [self.likeButtonArray  addObject:likeItemButton];
        [self addSubview:likeItemButton];
        [likeItemButton addTarget:self action:@selector(likeItemButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
    }
}

- (void)setCommentItemArray:(NSMutableArray *)commentItemArray {
    _commentItemArray = commentItemArray;
    
    for (NSInteger index = 0; index < commentItemArray.count; index++) {
        KXCommentListView *commentView = [KXCommentListView new];
        commentView.delegate = self;
        commentView.tag = index;
        [self.commentViewArray addObject:commentView];
        [self addSubview:commentView];
    }
}


//设置模型
- (void)setupWithLikeItemsArray:(NSArray *)likeItemsArray commentItemsArray:(NSArray *)commentItemsArray {
    //初始化属性
    self.tempRow = 0;
    
    //初始化点赞和评论
    self.likeItemArray = [likeItemsArray mutableCopy];
    self.commentItemArray = [commentItemsArray mutableCopy];
    
    if (self.commentViewArray.count) {
        [self.commentViewArray enumerateObjectsUsingBlock:^(UIView *commentView, NSUInteger idx, BOOL * _Nonnull stop) {
            commentView.hidden = YES;
        }];
    }
    
    if (self.likeButtonArray.count) {
        [self.likeButtonArray enumerateObjectsUsingBlock:^(UIButton *likeButton, NSUInteger idx, BOOL * _Nonnull stop) {
            likeButton.hidden = YES;
        }];
    }
    
#warning 需要优化由于autoLayout导致的线程阻塞问题
    if (!self.commentItemArray.count && !self.likeItemArray.count) {
        //如果没有评论和点赞，则直接返回
        self.fixedWidth = @(0);
        self.fixedHeight = @(0);
        return;
    } else {
        //取消高度和宽度约束
        self.fixedHeight = nil;
        self.fixedWidth = nil;
    }
    
    
    CGFloat margin = 5;
    
    UIView *lastTopView = nil;
    
    //💕号
    if (self.likeItemArray.count) {
        if (!_likeImage) {
            _likeImage = [[UIImageView alloc] init];
            _likeImage.image = [UIImage imageNamed:@"Discover_Like_Sel"];
            [self addSubview:_likeImage];
        }
        _likeImage.hidden = NO;
        _likeImage.sd_layout
        .topSpaceToView(self,20)
        .leftSpaceToView(self,7.5)
        .widthIs(15)
        .heightIs(13);
    } else {
        _likeImage.hidden = YES;
    }
    
    
    //每行最多显示数
    NSInteger maxButtonInScreen = ([UIScreen mainScreen].bounds.size.width - 100) / 35;
    
    UIView *lastButton;
    for (NSInteger index = 0; index < self.likeItemArray.count; index++) {
        
        
        //第N行
        CGFloat row = index / maxButtonInScreen;
        //是否换行
        BOOL isNext = row == self.tempRow ? NO : YES;
        
        
        UIButton *button = self.likeButtonArray[index];
        if (!lastButton) {
            button.sd_layout
            .topSpaceToView(self,7)
            .leftSpaceToView(self,30)
            .widthIs(35)
            .heightIs(35);
        } else if (isNext) {  //需要换行
            self.tempRow = row;
            
            //取出第N行第一个元素
            NSInteger buttonIndex = row * maxButtonInScreen ;
            UIButton *fistButton = self.likeButtonArray[buttonIndex-maxButtonInScreen];
            
            button.sd_layout
            .topSpaceToView(fistButton,5)
            .leftEqualToView(fistButton)
            .widthIs(40)
            .heightIs(40);
            
        }  else  { //不需要换行
            button.sd_layout
            .topEqualToView(lastButton)
            .leftSpaceToView(lastButton,margin)
            .widthIs(35)
            .heightIs(35);
        }
        button.hidden = NO;
        
        SDTimeLineCellLikeItemModel *model = self.likeItemArray[index];
        [button sd_setBackgroundImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",DFAPIURL,model.userPhoto]] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"Image_placeHolder"]];
        
        lastButton = button;
    }
    
    lastTopView = lastButton;
    
    
    //点赞下面的细线
    if (self.likeItemArray.count) {
        if (!_likeBottomLikeView) {
            _likeBottomLikeView= [UIView new];
            [self addSubview:_likeBottomLikeView];
            _likeBottomLikeView.backgroundColor = [UIColor colorFormHexRGB:@"e1e1e1"];
        }
        _likeBottomLikeView.hidden = NO;
        _likeBottomLikeView.sd_layout
        .topSpaceToView(lastButton,5)
        .leftEqualToView(self)
        .rightEqualToView(self)
        .heightIs(0.5);
        
        lastTopView = _likeBottomLikeView;
    } else {
        _likeBottomLikeView.hidden = YES;
    }
    
    
    
    //设置评论view
    if (self.commentItemArray.count) {
        if (!_commentIcon) {
            _commentIcon = [[UIImageView alloc] init];
            _commentIcon.image = [UIImage imageNamed:@"Discover_Detail_Comment"];
            [self addSubview:_commentIcon];
        }
        _commentIcon.hidden = NO;
        _commentIcon.sd_layout
        .topSpaceToView(lastTopView,20)
        .leftSpaceToView(self,6)
        .widthIs(15)
        .heightIs(15);
    } else {
        _commentIcon.hidden = YES;
    }
    
    for (NSInteger index = 0; index<self.commentItemArray.count; index++) {
        
        KXCommentListView *commentView = self.commentViewArray[index];
        SDTimeLineCellCommentItemModel *commentModel = self.commentItemArray[index];
        commentView.hidden = NO;
        
        if (!lastTopView) {
            commentView.sd_layout
            .topSpaceToView(self,0)
            .leftSpaceToView(_commentIcon,10)
            .rightSpaceToView(self,0);
        } else {
            commentView.sd_layout
            .topSpaceToView(lastTopView,5)
            .leftSpaceToView(_commentIcon,10)
            .rightSpaceToView(self,0);
        }
        
        commentView.model = commentModel;
        
        lastTopView = commentView;
        
    }
    
    [self setupAutoHeightWithBottomView:lastTopView bottomMargin:0];
    
}

#pragma mark - 点击方法
- (void)likeItemButtonDidClick:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(KXDiscoverDetailCommentViewDidClickLikeView:andLikeModel:)]) {
        [self.delegate KXDiscoverDetailCommentViewDidClickLikeView:self.likeButtonArray[sender.tag] andLikeModel:self.likeItemArray[sender.tag]];
    }
}


- (void)DidClickLinkeWithLinkValue:(NSString *)linkValue andType:(int)type {
    if ([self.delegate respondsToSelector:@selector(commentViewDidClickMLLink:andLinkType:)]) {
        [self.delegate commentViewDidClickMLLink:linkValue andLinkType:type];
    }
}

#pragma mark - lazyLoad
- (NSMutableArray *)likeButtonArray {
    if (!_likeButtonArray) {
        _likeButtonArray = [NSMutableArray array];
    }
    return _likeButtonArray;
}

- (NSMutableArray *)commentViewArray {
    if (!_commentViewArray) {
        _commentViewArray = [NSMutableArray array];
    }
    return _commentViewArray;
}

@end
