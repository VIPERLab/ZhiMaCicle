//
//  BaseChatTableViewCell.h
//  Diver
//
//  Created by Tony on 14-8-1.
//  Copyright (c) 2014年 Tentinet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constant.h"

@protocol BaseChatTableViewCellDelegate <NSObject>

@optional

- (void)userIconTappedWithIndexPath:(NSIndexPath *)indexPath;
- (void)deleteButtonTappedWithIndexPath:(NSIndexPath *)indexPath;
- (void)copyButtonTappedWithIndexPath:(NSIndexPath *)indexPath;

@end


@class BaseChatTableViewCell;
typedef void (^ResendBlock)(BaseChatTableViewCell *cell);


@interface BaseChatTableViewCell : UITableViewCell
{
    UIImageView *_bubble;    //气泡
    UIView *_wrapView;
    UITapGestureRecognizer *_tapGest;
    
    BOOL _isSetTopLabel;
    BOOL _isSetNickLabel;
    
    CGFloat _nickLabelOffsetY;
    CGFloat _userIconOffsetY;
    CGFloat _bubbleOffsetY;
}

@property (nonatomic, strong) UIImageView *bubble;              //气泡
@property (nonatomic, strong) UILabel *topLabel;                //顶部的label，如时间
@property (nonatomic, strong) UILabel *nickLabel;               //昵称
@property (nonatomic, strong) UIImageView *userIcon;            //头像
@property (nonatomic, strong) UIActivityIndicatorView *sending; //正在发送的,暂时不要此功能，所以注释掉
@property (nonatomic, strong) UIButton *sendAgain;              //重送按钮, 暂时不要此功能，所以注释掉

@property (nonatomic, assign) UIEdgeInsets margin;              //内容与气泡之间的间距, 默认值 DEFAULT_CHAT_CELL_BUBBLE_EDGEINTS
@property (nonatomic, strong) NSIndexPath *indexPath;
@property (nonatomic, assign) id<BaseChatTableViewCellDelegate> delegate;

@property (nonatomic, assign) BOOL isMe;                       //是否为我发的信息

@property (nonatomic, copy) ResendBlock resendBlock;

- (void)resizeBubbleView:(CGSize)contetnViewSize;               //根据内容视图的尺寸调整气泡的大小
- (void)repositionContentView:(UIView *)contentView;            //调整内容视图在气泡中的位置
- (void)resizeBubbleViewPicType:(CGSize)contetnViewSize;        //调整内容视图在气泡中的位置(图片)

+ (CGFloat)getBaseHeightTopText:(NSString *)topText nick:(NSString *)nick;
+ (CGFloat)getBaseHeightTopText:(NSString *)topText nick:(NSString *)nick contentHeight:(CGFloat)contentHeight; //获取cell高度
+ (CGFloat)getBaseHeightTopText:(NSString *)topText nick:(NSString *)nick contentHeight:(CGFloat)contentHeight bubbleEdgeInset:(UIEdgeInsets)edgeInset;

@end
