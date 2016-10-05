//
//  SDTimeLineCell.m
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
#import <UIKit/UIKit.h>
#import "SDTimeLineCell.h"

#import "SDTimeLineCellModel.h"
#import "UIView+SDAutoLayout.h"
#import "UIColor+My.h"
#import "SDTimeLineCellCommentView.h"

#import "SDWeiXinPhotoContainerView.h"

#import "SDTimeLineCellOperationMenu.h"
#import "UIImageView+WebCache.h"
#import "UIButton+WebCache.h"

#import "NSString+FontSize.h"

const CGFloat contentLabelFontSize = 14;
CGFloat maxContentLabelHeight = 45; // 根据具体font而定

NSString *const kSDTimeLineCellOperationButtonClickedNotification = @"SDTimeLineCellOperationButtonClickedNotification";

@interface SDTimeLineCell () <SDTimeLineCellCommentViewDelegate>

@property (nonatomic, assign,getter=isShowCopyView) BOOL showCopyView;

@end


@implementation SDTimeLineCell

{
    
    UIButton *_nameLable;
    UILabel *_contentLabel;
    SDWeiXinPhotoContainerView *_picContainerView;
    UILabel *_timeLabel;
    UILabel *_areaLabel;
    UIButton *_moreButton;
    UIButton *_operationButton;
    UIView *_bottomLineView;
    SDTimeLineCellCommentView *_commentView;
    SDTimeLineCellOperationMenu *_operationMenu;
    UIImageView *_copyView;
    UIButton *_complainButton;
}


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setup];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)setup
{
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveOperationButtonClickedNotification:) name:kSDTimeLineCellOperationButtonClickedNotification object:nil];
    
    _iconView = [UIButton new];
    _iconView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGresture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userIconViewDidClick)];
    [_iconView addGestureRecognizer:tapGresture];
    
    UILongPressGestureRecognizer *longPressGresture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(userIconViewDidLongPress:)];
    longPressGresture.minimumPressDuration = 1.0f;
    [_iconView addGestureRecognizer:longPressGresture];
    
    
    _nameLable = [UIButton new];
    _nameLable.titleLabel.font = [UIFont systemFontOfSize:16];
    [_nameLable setTitleColor:[UIColor colorFormHexRGB:@"576b95"] forState:UIControlStateNormal];
    [_nameLable addTarget:self action:@selector(userNameDidClick) forControlEvents:UIControlEventTouchUpInside];
    
    
    _contentLabel = [UILabel new];
    _contentLabel.font = [UIFont systemFontOfSize:contentLabelFontSize];
    _contentLabel.numberOfLines = 0;
    _contentLabel.textColor = [UIColor colorFormHexRGB:@"000000"];
    _contentLabel.userInteractionEnabled = YES;
    UILongPressGestureRecognizer *labelLongPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressContentLabel:)];
    labelLongPressGesture.minimumPressDuration = 0.8f;
    [_contentLabel addGestureRecognizer:labelLongPressGesture];
    
    
    _moreButton = [UIButton new];
    [_moreButton setTitle:@"全文" forState:UIControlStateNormal];
    [_moreButton setTitleColor:TimeLineCellHighlightedColor forState:UIControlStateNormal];
    [_moreButton addTarget:self action:@selector(moreButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    _moreButton.titleLabel.font = [UIFont systemFontOfSize:14];
    
    _operationButton = [UIButton new];
    [_operationButton setImage:[UIImage imageNamed:@"Discover_Comment"] forState:UIControlStateNormal];
    [_operationButton addTarget:self action:@selector(operationButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    
    _picContainerView = [SDWeiXinPhotoContainerView new];
    
    _commentView = [SDTimeLineCellCommentView new];
    _commentView.delegate = self;
    
    _timeLabel = [UILabel new];
    _timeLabel.textColor = [UIColor colorFormHexRGB:@"737373"];
    _timeLabel.font = [UIFont systemFontOfSize:12];
    
    _complainButton = [UIButton new];
    [_complainButton setTitle:@"投诉" forState:UIControlStateNormal];
    [_complainButton setTitleColor:[UIColor colorFormHexRGB:@"576b95"] forState:UIControlStateNormal];
    _complainButton.titleLabel.font = [UIFont systemFontOfSize:11];
    [_complainButton addTarget:self action:@selector(complainButtonDidClick) forControlEvents:UIControlEventTouchUpInside];
    
    _operationMenu = [SDTimeLineCellOperationMenu new];
    __weak typeof(self) weakSelf = self;
    [_operationMenu setLikeButtonClickedOperation:^(SDTimeLineCellOperationMenu *menu){
        if ([weakSelf.delegate respondsToSelector:@selector(didClickLikeButtonInCell:andMenu:)]) {
            [weakSelf.delegate didClickLikeButtonInCell:weakSelf andMenu:menu];
        }
    }];
    [_operationMenu setCommentButtonClickedOperation:^{
        if ([weakSelf.delegate respondsToSelector:@selector(didClickcCommentButtonInCell:)]) {
            [weakSelf.delegate didClickcCommentButtonInCell:weakSelf];
        }
    }];
    
    _areaLabel = [[UILabel alloc] init];
    _areaLabel.font = [UIFont systemFontOfSize:11];
    _areaLabel.textColor = [UIColor colorFormHexRGB:@"65779e"];
    
    
    _bottomLineView = [[UIView alloc] init];
    _bottomLineView.backgroundColor = [UIColor colorFormHexRGB:@"e1e1df"];
    [self addSubview:_bottomLineView];
    
    
    NSArray *views = @[_iconView, _nameLable, _contentLabel, _moreButton, _picContainerView, _timeLabel,_complainButton,_areaLabel, _operationButton, _operationMenu, _commentView];
    
    [self.contentView sd_addSubviews:views];
    
    UIView *contentView = self.contentView;
    CGFloat margin = 10;
    
    _iconView.sd_layout
    .leftSpaceToView(contentView, margin)
    .topSpaceToView(contentView, margin + 5)
    .widthIs(43)
    .heightIs(43);
    
    _nameLable.sd_layout
    .leftSpaceToView(_iconView, margin)
    .topEqualToView(_iconView)
    .heightIs(18);
    
    _contentLabel.sd_layout
    .leftEqualToView(_nameLable)
    .topSpaceToView(_nameLable, margin * 0.5)
    .rightSpaceToView(contentView, margin)
    .autoHeightRatio(0);
    
    // morebutton的高度在setmodel里面设置
    _moreButton.sd_layout
    .leftEqualToView(_contentLabel)
    .topSpaceToView(_contentLabel, 0)
    .widthIs(30);
    
    _picContainerView.sd_layout
    .leftEqualToView(_contentLabel); // 已经在内部实现宽度和高度自适应所以不需要再设置宽度高度，top值是具体有无图片在setModel方法中设置
    
    _timeLabel.sd_layout
    .leftEqualToView(_contentLabel)
    .topSpaceToView(_picContainerView, margin * 0.5)
    .heightIs(15);
    [_timeLabel setSingleLineAutoResizeWithMaxWidth:200];
    
    _complainButton.sd_layout
    .leftSpaceToView(_timeLabel,10)
    .topEqualToView(_timeLabel)
    .bottomEqualToView(_timeLabel)
    .widthIs(25);
    
    _operationButton.sd_layout
    .rightSpaceToView(contentView, margin)
    .centerYEqualToView(_timeLabel)
    .heightIs(25)
    .widthIs(25);
    
    _operationMenu.sd_layout
    .rightSpaceToView(_operationButton, 0)
    .heightIs(36)
    .centerYEqualToView(_operationButton)
    .widthIs(0);
    
    _areaLabel.sd_layout
    .leftEqualToView(_timeLabel)
    .topSpaceToView(_timeLabel,3)
    .rightSpaceToView(_operationButton, 10)
    .autoHeightRatio(0);
    
    
    _commentView.sd_layout
    .leftEqualToView(_contentLabel)
    .rightSpaceToView(self.contentView, margin)
    .topSpaceToView(_areaLabel, margin ); // 已经在内部实现高度自适应所以不需要再设置高度
    
}


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setModel:(SDTimeLineCellModel *)model
{
    _model = model;
    
    if (_copyView) {
        [_copyView removeFromSuperview];
        _copyView = nil;
        self.showCopyView = NO;
    }
    
    [_commentView setupWithLikeItemsArray:model.likeItemsArray commentItemsArray:model.commentList];
    
    [_iconView sd_setBackgroundImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",DFAPIURL,model.head_photo]] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"Image_placeHolder"]];

    CGFloat labelHight = [model.content sizeWithFont:[UIFont systemFontOfSize:14] maxSize:CGSizeMake([UIScreen mainScreen].bounds.size.width - 100, MAXFLOAT)].height;
    if (labelHight > 45) {
        model.shouldShowMoreButton = YES;
    }
    
    
    //设置名字的长度
    [_nameLable setTitle:model.friend_nick forState:UIControlStateNormal];
    CGFloat nameW = [model.friend_nick sizeWithFont:[UIFont systemFontOfSize:16] maxSize:CGSizeMake(MAXFLOAT, 20)].width;
    _nameLable.sd_layout.widthIs(nameW);
    
    
    _contentLabel.text = model.content;
    _areaLabel.text = model.current_location;
    _picContainerView.picPathStringsArray = model.imglist;
    _timeLabel.text = model.create_time;
    
    if (model.shouldShowMoreButton) { // 如果文字高度超过60
        _moreButton.sd_layout.heightIs(20);
        _moreButton.hidden = NO;
        if (model.isOpening) { // 如果需要展开
            _contentLabel.sd_layout.maxHeightIs(MAXFLOAT);
            [_moreButton setTitle:@"收起" forState:UIControlStateNormal];
        } else {
            _contentLabel.sd_layout.maxHeightIs(maxContentLabelHeight);
            [_moreButton setTitle:@"全文" forState:UIControlStateNormal];
        }
    } else {
        _moreButton.sd_layout.heightIs(0);
        _moreButton.hidden = YES;
    }
    
    CGFloat picContainerTopMargin = 0;
    if (model.imglist.count) {
        picContainerTopMargin = 10;
    }
    _picContainerView.sd_layout.topSpaceToView(_moreButton, picContainerTopMargin);
    
    
    //设置bottomView
    UIView *bottomView;
    if (!model.commentList.count && !model.likeItemsArray.count) {
        if (model.current_location.length) {
            bottomView = _areaLabel;
        } else {
            bottomView = _timeLabel;
        }
    } else {
        bottomView = _commentView;
    }
    
    for (SDTimeLineCellLikeItemModel *model in _model.likeItemsArray) {
        if ([model.userId isEqualToString:USERINFO.userID]) {
            _operationMenu.isLike = YES;
        }
    }
    
    [self setupAutoHeightWithBottomView:bottomView bottomMargin:15];
    
    
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    if (_operationMenu.isShowing) {
        _operationMenu.show = NO;
    }
}

#pragma mark - 评论别人代理
- (void)SDTimeLineCellCommentViewCommentOther:(SDTimeLineCellCommentItemModel *)model andCommentView:(UIView *)commentView {
    if ([self.delegate respondsToSelector:@selector(DidClickCommentOtherButton:andCommentItem:andCommentView:)]) {
        [self.delegate DidClickCommentOtherButton:self andCommentItem:model andCommentView:commentView];
    }
}


#pragma mark - private actions
// ----  全文按钮
- (void)moreButtonClicked
{
    if (self.moreButtonClickedBlock) {
        self.moreButtonClickedBlock(self.indexPath);
    }
}

- (void)operationButtonClicked
{
    [self postOperationButtonClickedNotification];
    _operationMenu.show = !_operationMenu.isShowing;
}

- (void)receiveOperationButtonClickedNotification:(NSNotification *)notification
{
    UIButton *btn = [notification object];
    
    if (btn != _operationButton && _operationMenu.isShowing) {
        _operationMenu.show = NO;
    }
}


#pragma mark - 长按文本、图片
- (void)longPressContentLabel:(UIGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateBegan) {
            
        [[NSNotificationCenter defaultCenter] postNotificationName:KDiscoverLongPressContentNotification object:nil userInfo:@{@"contentLabel":_contentLabel}];

        
    }
}


#pragma mark - userInterFace
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    [self postOperationButtonClickedNotification];
    if (_operationMenu.isShowing) {
        _operationMenu.show = NO;
    }
}

- (void)postOperationButtonClickedNotification {
    [[NSNotificationCenter defaultCenter] postNotificationName:kSDTimeLineCellOperationButtonClickedNotification object:_operationButton];
}

- (void)layoutSubviews {
    _bottomLineView.frame = CGRectMake(0, CGRectGetHeight(self.frame) - 0.5, CGRectGetWidth(self.frame), 0.5);
}

#pragma mark - 点击了发朋友圈人的名字
- (void)userNameDidClick {
    if ([self.delegate respondsToSelector:@selector(didClickUserIconInCell:)]) {
        [self.delegate didClickUserIconInCell:self];
    }
}

#pragma mark - 用户头像的点击事件
- (void)userIconViewDidClick {
    if ([self.delegate respondsToSelector:@selector(didClickUserIconInCell:)]) {
        [self.delegate didClickUserIconInCell:self];
    }
}

#pragma mark - 长按用户头像
- (void)userIconViewDidLongPress:(UILongPressGestureRecognizer *)gresture {
    if (gresture.state == UIGestureRecognizerStateBegan) {
        if ([self.delegate respondsToSelector:@selector(didLongPressUserIconWithCell:)]) {
            [self.delegate didLongPressUserIconWithCell:self];
        }
    }
}

#pragma mark - 投诉按钮
- (void)complainButtonDidClick {
    if ([self.delegate respondsToSelector:@selector(didClickComplainButton:)]) {
        [self.delegate didClickComplainButton:self];
    }
}

@end

