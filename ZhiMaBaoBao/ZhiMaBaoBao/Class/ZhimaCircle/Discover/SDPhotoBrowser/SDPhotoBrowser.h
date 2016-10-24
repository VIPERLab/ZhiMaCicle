//
//  SDPhotoBrowser.h
//  photobrowser
//
//  Created by aier on 15-2-3.
//  Copyright (c) 2015年 aier. All rights reserved.
//

#import <UIKit/UIKit.h>


@class SDButton, SDPhotoBrowser;

@protocol SDPhotoBrowserDelegate <NSObject>

@required

- (UIImage *)photoBrowser:(SDPhotoBrowser *)browser placeholderImageForIndex:(NSInteger)index;

- (void)finishedWatch;

@optional

- (NSURL *)photoBrowser:(SDPhotoBrowser *)browser highQualityImageURLForIndex:(NSInteger)index;


@end


@interface SDPhotoBrowser : UIView <UIScrollViewDelegate>

@property (nonatomic, weak) UIView *sourceImagesContainerView;
@property (nonatomic, assign) NSInteger currentImageIndex;
@property (nonatomic, assign) NSInteger imageCount;
@property (nonatomic, copy) NSString *userId;
@property (nonatomic, assign) BOOL isChat;

//收藏图片专用属性
@property (nonatomic, assign) int type;


@property (nonatomic, weak) id<SDPhotoBrowserDelegate> delegate;

- (void)show;

@end
