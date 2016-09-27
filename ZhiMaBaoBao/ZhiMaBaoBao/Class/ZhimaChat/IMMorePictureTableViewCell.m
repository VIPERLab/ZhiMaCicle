//
//  IMMorePictureTableViewCell.m
//  ZhiMaBaoBao
//
//  Created by ios开发 on 16/9/27.
//  Copyright © 2016年 liugang. All rights reserved.
//

#import "IMMorePictureTableViewCell.h"


@implementation IMMorePictureTableViewCell

//+ (CGFloat)getHeightWithChat:(LGMessage *)chat TopText:(NSString *)topText nickName:(NSString *)nickName;
//{
//    CGFloat height = [self hightForRowWithChat:chat];
//    //height = [self getBaseHeightTopText:topText nick:nickName contentHeight:height];
//    
//    height = [self getBaseHeightTopText:topText nick:nickName contentHeight:height bubbleEdgeInset:UIEdgeInsetsMake(3, 3, 3, 11)];
//    
//    return height;
//}


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        //        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self createCustomViews];
    }
    return self;
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    [self.picturesView removeFromSuperview];
    [self.mainView removeFromSuperview];
    [self.botLabel removeFromSuperview];
    [self createCustomViews];
    
}

- (void)reloadData:(LGMessage *)chat isMySelf:(BOOL)isMySelf chousePicTarget:(id)target action:(SEL)action
{
    
    _isMe = isMySelf;
    [_picturesView sd_setImageWithURL:[NSURL URLWithString:chat.text]];
    
    UITapGestureRecognizer*tap = [[UITapGestureRecognizer alloc]initWithTarget:target action:action];
    [_picturesView addGestureRecognizer:tap];
    
    [self.picturesView centerAlignHorizontalForSuperView];
    
    [self resizeBubbleViewPicType:_picturesView.frame.size];
    [self repositionContentView:_picturesView];
    
}


- (BOOL)canBecomeFirstResponder{
    return YES;
}



- (void)createCustomViews
{
    //    _picturesView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kWidth - kMainDWidth - kSpace * 2, 150)];
    _picturesView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    _picturesView.backgroundColor = [UIColor lightGrayColor];
    _picturesView.userInteractionEnabled = YES;
    
//    _botLabel = [[UILabel alloc] initWithFrame:CGRectZero];
//    _botLabel.backgroundColor = [UIColor clearColor];
//    _botLabel.numberOfLines = 0;
//    _botLabel.font          = kFont;
//    _botLabel.textAlignment = NSTextAlignmentLeft;
//    
//    _mainView = [[UIButton alloc] initWithFrame:CGRectMake(kLeft - kSpace, kTop - kSpace, kWidth, 150)];
//    _mainView.backgroundColor = [UIColor clearColor];
//    
//    
//    [_mainView addSubview:_picturesView];
//    [_mainView addSubview:_botLabel];
    
    [_bubble addSubview:_picturesView];
}

@end
