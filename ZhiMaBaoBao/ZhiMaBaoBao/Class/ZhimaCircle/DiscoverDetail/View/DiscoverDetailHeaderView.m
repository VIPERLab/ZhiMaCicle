//
//  DiscoverDetailHeaderView.m
//  DemoDiscover
//
//  Created by kit on 16/8/21.
//  Copyright © 2016年 kit. All rights reserved.
//

#import "DiscoverDetailHeaderView.h"
#import "SDWeiXinPhotoContainerView.h"

#import "SDTimeLineCellCommentView.h"

#import "SDTimeLineCellOperationMenu.h"
#import "UIColor+My.h"
#import "UIView+SDAutoLayout.h"

#import "KXDiscoverDetailCommentView.h"

NSString *const kDiscoverDetailOperationButtonClickedNotification = @"DiscoverDetailOperationButtonClickedNotification";

@interface DiscoverDetailHeaderView () <KXDiscoverDetailCommentViewDelegate> {
    SDTimeLineCellOperationMenu *_operationMenu;
    UIButton *_operationButton;
}

@property (nonatomic, weak) UIImageView *userIcon; //用户头像

@property (nonatomic, weak) UILabel *user_name;  //用户名字

@property (nonatomic, weak) UILabel *user_contentView; //朋友圈内容

@property (nonatomic, weak) UILabel *timeLabel;  //时间戳

@property (nonatomic, weak) UIButton *deleteButton;

@property (nonatomic, weak) SDWeiXinPhotoContainerView *picContainerView;  //图片存放的View;

//@property (nonatomic, weak) SDTimeLineCellCommentView *commentView;  //评论和点赞View

@property (nonatomic, weak) KXDiscoverDetailCommentView *commentView;


@end

@implementation DiscoverDetailHeaderView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupView];
    }
    return self;
}



- (void)setupView {
    self.backgroundColor = [UIColor whiteColor];
    
    UIImageView *userIcon = [[UIImageView alloc] init];
    self.userIcon = userIcon;
    [self addSubview:userIcon];
    
    
    UILabel *user_name = [[UILabel alloc] init];
    self.user_name = user_name;
    user_name.font = [UIFont boldSystemFontOfSize:16];
    user_name.textColor = [UIColor colorFormHexRGB:@"576b95"];
    [self addSubview:user_name];
    
    UILabel *user_contentView = [[UILabel alloc] init];
    self.user_contentView = user_contentView;
    self.user_contentView.font = [UIFont systemFontOfSize:14];
    [self addSubview:user_contentView];
    
    UIButton *deleteButton = [[UIButton alloc] init];
    self.deleteButton = deleteButton;
    [deleteButton setTitle:@"删除" forState:UIControlStateNormal];
    [deleteButton setTitleColor:[UIColor colorFormHexRGB:@"576b95"] forState:UIControlStateNormal];
    deleteButton.titleLabel.font = [UIFont systemFontOfSize:11];
    [self addSubview:deleteButton];
    [deleteButton addTarget:self action:@selector(deleteButtonDidClick) forControlEvents:UIControlEventTouchUpInside];
    
    SDWeiXinPhotoContainerView *picContainerView = [[SDWeiXinPhotoContainerView alloc] init];
    self.picContainerView = picContainerView;
    [self addSubview:picContainerView];
    
    UILabel *timeLabel = [UILabel new];
    self.timeLabel = timeLabel;
    self.timeLabel.textColor = [UIColor colorFormHexRGB:@"737373"];
    timeLabel.font = [UIFont systemFontOfSize:11];
    [self addSubview:timeLabel];
    
    
//    SDTimeLineCellCommentView *commentView = [SDTimeLineCellCommentView new];
//    commentView.delegate = self;
//    self.commentView = commentView;
//    [self addSubview:commentView];
    
    KXDiscoverDetailCommentView *commentView = [KXDiscoverDetailCommentView new];
    commentView.delegate = self;
    self.commentView = commentView;
    [self addSubview:commentView];
    
    
    _operationButton = [UIButton new];
    [_operationButton setImage:[UIImage imageNamed:@"Discover_Comment"] forState:UIControlStateNormal];
    [_operationButton addTarget:self action:@selector(operationButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_operationButton];
    
    _operationMenu = [SDTimeLineCellOperationMenu new];
    __weak typeof(self) weakSelf = self;
    [_operationMenu setLikeButtonClickedOperation:^(SDTimeLineCellOperationMenu *menu) {
        if ([weakSelf.delegate respondsToSelector:@selector(DiscoverDetailOperationButtonDidClickLike:)]) {
            [weakSelf.delegate DiscoverDetailOperationButtonDidClickLike:weakSelf];
        }
    }];
    
    [_operationMenu setCommentButtonClickedOperation:^{
        if ([weakSelf.delegate respondsToSelector:@selector(DiscoverDetailOperationButtonDidClickComment:)]) {
            [weakSelf.delegate DiscoverDetailOperationButtonDidClickComment:weakSelf];
        }
    }];
    [self addSubview:_operationMenu];
    
    
    //添加约束
    _userIcon.sd_layout
    .leftSpaceToView(self,10)
    .topSpaceToView(self,10)
    .widthIs(50)
    .heightIs(50);
    
    _user_name.sd_layout
    .leftSpaceToView(_userIcon,10)
    .topSpaceToView(self,10)
    .rightSpaceToView(self,0)
    .heightIs(18);
    
    _user_contentView.sd_layout
    .leftEqualToView(_user_name)
    .rightSpaceToView(self,50)
    .topSpaceToView(_user_name,5)
    .autoHeightRatio(0);
    
    _picContainerView.sd_layout
    .leftEqualToView(_user_contentView)
    .topSpaceToView(_user_contentView,10);
    
    
    _timeLabel.sd_layout
    .leftEqualToView(_picContainerView)
    .topSpaceToView(_picContainerView,5)
    .heightIs(15);
    [_timeLabel setSingleLineAutoResizeWithMaxWidth:200];
    
    _deleteButton.sd_layout
    .leftSpaceToView(_timeLabel,5)
    .topEqualToView(_timeLabel)
    .widthIs(30)
    .heightRatioToView(_timeLabel,1);
    
    _operationButton.sd_layout
    .centerYEqualToView(_timeLabel)
    .rightSpaceToView(self, 10)
    .heightIs(25)
    .widthIs(25);
    
    _operationMenu.sd_layout
    .rightSpaceToView(_operationButton, 0)
    .heightIs(36)
    .centerYEqualToView(_operationButton)
    .widthIs(0);

    _commentView.sd_layout
    .leftSpaceToView(self,10)
    .rightSpaceToView(self,10)
    .topSpaceToView(_timeLabel,10);
    
    
}


#pragma mark - 删除事件
- (void)deleteButtonDidClick {
    if ([self.delegate respondsToSelector:@selector(DiscoverDetailDeletedButtonDidClick:)]) {
        [self.delegate DiscoverDetailDeletedButtonDidClick:self];
    }
}

#pragma mark - 菜单点击事件
- (void)operationButtonClicked
{
    [self postOperationButtonClickedNotification];
    _operationMenu.show = !_operationMenu.isShowing;
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    [self postOperationButtonClickedNotification];
    if (_operationMenu.isShowing) {
        _operationMenu.show = NO;
    }
}

- (void)postOperationButtonClickedNotification {
    [[NSNotificationCenter defaultCenter] postNotificationName:kDiscoverDetailOperationButtonClickedNotification object:_operationButton];
}


#pragma mark - 评论别人点击事件
- (void)SDTimeLineCellCommentViewCommentOther:(SDTimeLineCellCommentItemModel *)model andCommentView:(UIView *)commentView{
    if ([self.delegate respondsToSelector:@selector(DidClickOtherComment:andCommentItems:andCommentView:)]) {
        [self.delegate DidClickOtherComment:self andCommentItems:model andCommentView:commentView];
    }
}

- (void)KXDiscoverDetailCommentViewDidClickLikeView:(UIView *)likeView andLikeModel:(SDTimeLineCellLikeItemModel *)likeItemModel {
    if ([self.delegate respondsToSelector:@selector(DidClickLikeItemButton:)]) {
        [self.delegate DidClickLikeItemButton:likeItemModel];
    }
}




#pragma mark - 模型赋值
- (void)setModel:(SDTimeLineCellModel *)model {
    _model = model;
    
    [self.userIcon sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",DFAPIURL,model.head_photo]] placeholderImage:[UIImage imageNamed:@"userIcon"]];
        
    if ([USERINFO.openfireaccount isEqualToString:model.openfireaccount]) {
        _deleteButton.hidden = NO;
    } else  _deleteButton.hidden = YES;
    
    self.user_contentView.text = model.content;
    self.user_name.text = model.friend_nick;
    self.timeLabel.text = model.create_time;
    
    for (SDTimeLineCellLikeItemModel *likeModel in model.likeItemsArray) {
        if ([likeModel.userId isEqualToString:USERINFO.openfireaccount]) {
            _operationMenu.isLike = YES;
        } else {
            _operationMenu.isLike = NO;
        }
    }
    
    _picContainerView.picPathStringsArray = model.imglist;
    [_commentView setupWithLikeItemsArray:model.likeItemsArray commentItemsArray:model.commentList];
    
    
    [self setupAutoHeightWithBottomView:_commentView bottomMargin:15];
    
    
    
}


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
