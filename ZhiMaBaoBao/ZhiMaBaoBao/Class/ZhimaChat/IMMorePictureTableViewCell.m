//
//  IMMorePictureTableViewCell.m
//  ZhiMaBaoBao
//
//  Created by ios开发 on 16/9/27.
//  Copyright © 2016年 liugang. All rights reserved.
//

#import "IMMorePictureTableViewCell.h"
#import <AssetsLibrary/AssetsLibrary.h>


@interface IMMorePictureTableViewCell ()

{
    CALayer      *_contentLayer;
    CAShapeLayer *_maskLayer;
}

@end

@implementation IMMorePictureTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
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
    
    _picturesView.backImage = isMySelf ? [UIImage imageNamed:@"1111"]: [UIImage imageNamed:@"2222"];
    
    if (chat.text) {
//        [_picturesView sd_setImageWithURL:[NSURL URLWithString:chat.text]];
        [_picturesView sd_setImageWithURL:[NSURL URLWithString:chat.text] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            
            _picturesView.zmImage = _picturesView.image;
            _picturesView.image = nil;
            
//            _picturesView.frameSize = [self pictureSizeToImage:_picturesView.image];
//            [self.picturesView centerAlignHorizontalForSuperView];
//            [self resizeBubbleView:_picturesView.frame.size];
//            [self repositionContentViewTypePic:_picturesView];
//            
//            if (self.pDelegate && [self.pDelegate respondsToSelector:@selector(pictureCellHeightChange:indexPath:)]) {
//                [self.pDelegate pictureCellHeightChange:_picturesView.frameSize.height indexPath:self.indexPath];
//            }

        }];

    }else{

        _picturesView.zmImage = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@%@",AUDIOPATH,chat.picUrl]];
        
//        _picturesView.zmImage = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@%@",AUDIOPATH,chat.picUrl]];

//        _picturesView.frameSize = [self pictureSizeToImage:_picturesView.image];
//        [self.picturesView centerAlignHorizontalForSuperView];
//        [self resizeBubbleView:_picturesView.frame.size];
//        [self repositionContentViewTypePic:_picturesView];
        
//        if (self.pDelegate && [self.pDelegate respondsToSelector:@selector(pictureCellHeightChange:indexPath:)]) {
//            [self.pDelegate pictureCellHeightChange:_picturesView.frameSize.height indexPath:self.indexPath];
//        }

    }
    

    
    [self.picturesView centerAlignHorizontalForSuperView];
    [self imageResizeBubbleView:_picturesView.frame.size];
    [self repositionContentViewTypePic:_picturesView];
    
    
//    ZMImageView *shapedImageView = [[ZMImageView alloc] initWithFrame:_picturesView.bounds];
//    shapedImageView.image =_picturesView.image;
//    [self addSubview:shapedImageView];

    UITapGestureRecognizer*tap = [[UITapGestureRecognizer alloc]initWithTarget:target action:action];
    [_picturesView addGestureRecognizer:tap];
    
}

- (CGSize)pictureSizeToImage:(UIImage*)image
{

    CGSize  imageViewSize = CGSizeMake(120, 120);
    CGSize imgSize = image.size;
    if (imgSize.width >= imgSize.height) {
        
        imageViewSize.height = 100 * imgSize.height/imgSize.width;
    }else{
        imageViewSize.width = 100 * imgSize.width/imgSize.height;

    }
    
    return imageViewSize;
}


- (void)createCustomViews
{
    _picturesView = [[ZMImageView alloc] initWithFrame:CGRectMake(0, 0, 120, 120)];
    _picturesView.userInteractionEnabled = YES;
//    _picturesView.contentMode =  UIViewContentModeScaleAspectFill;
//    _picturesView.clipsToBounds  = YES;
    
    [_bubble addSubview:_picturesView];
    
    //添加长按手势
    UILongPressGestureRecognizer *longGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressAction:)];
    [_bubble addGestureRecognizer:longGesture];
}

//长按弹出功能栏
- (void)longPressAction:(UIGestureRecognizer *)gesture{
    
    if (gesture.state == UIGestureRecognizerStateBegan) {
        [self becomeFirstResponder];
        
        UIMenuController *menu = [UIMenuController sharedMenuController];
        
        UIMenuItem *copyItem = [[UIMenuItem alloc] initWithTitle:@"复制" action:@selector(copyItemClicked:)];
        UIMenuItem *transItem = [[UIMenuItem alloc] initWithTitle:@"转发" action:@selector(transItemClicked:)];
        UIMenuItem *keepItem = [[UIMenuItem alloc] initWithTitle:@"收藏" action:@selector(keepItemClicked:)];
        UIMenuItem *deleteItem = [[UIMenuItem alloc] initWithTitle:@"删除" action:@selector(deleteItemClicked:)];
        UIMenuItem *undoItem = [[UIMenuItem alloc] initWithTitle:@"撤回" action:@selector(undoItemClicked:)];
        
        [menu setMenuItems:[NSArray arrayWithObjects:copyItem,transItem,keepItem,deleteItem,undoItem,nil]];
        
        [menu setTargetRect:_bubble.frame inView:self];
        
        [menu setMenuVisible:YES animated:YES];
    }
}

#pragma mark 处理action事件

//返回什么方法，则显示什么按钮
-(BOOL)canPerformAction:(SEL)action withSender:(id)sender{
    
    if(action ==@selector(copyItemClicked:)){
        return NO;
        
    }else if (action==@selector(transItemClicked:)){
        return YES;
    }
    else if (action == @selector(keepItemClicked:)){
        return YES;
    }
    else if (action == @selector(deleteItemClicked:)){
        return YES;
    }
    else if (action == @selector(undoItemClicked:)){   //撤回 - 是我发的消息（时间间隔不超过两分钟）时展示撤回按钮
        //判断是不是两分钟之内
        NSInteger currentStamp = [NSDate currentTimeStamp];
        BOOL canUndo = (currentStamp - self.message.timeStamp) < 120;
        return self.isMe && canUndo;
    }
    
    return [super canPerformAction:action withSender:sender];
}

#pragma mark 实现成为第一响应者方法

-(BOOL)canBecomeFirstResponder{
    
    return YES;
    
}



@end
