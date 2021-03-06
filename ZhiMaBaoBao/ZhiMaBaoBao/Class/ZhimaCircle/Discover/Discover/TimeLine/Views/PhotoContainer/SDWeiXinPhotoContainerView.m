//
//  SDWeiXinPhotoContainerView.m
//  SDAutoLayout 测试 Demo
//
//  Created by gsd on 15/12/23.
//  Copyright © 2015年 gsd. All rights reserved.
//



#import "SDWeiXinPhotoContainerView.h"

#import "UIView+SDAutoLayout.h"
#import "UIImageView+WebCache.h"
#import "SDPhotoBrowser.h"
#import "SDTimeLineCellModel.h"
#import "HttpTool.h"

@interface SDWeiXinPhotoContainerView () <SDPhotoBrowserDelegate>

@property (nonatomic, strong) NSArray *imageViewsArray;

@end

@implementation SDWeiXinPhotoContainerView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    return self;
}

- (void)setup
{
    NSMutableArray *temp = [NSMutableArray new];
    
    for (int i = 0; i < 9; i++) {
        UIImageView *imageView = [UIImageView new];
        [self addSubview:imageView];
        imageView.userInteractionEnabled = YES;
        imageView.tag = i;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapImageView:)];
        [imageView addGestureRecognizer:tap];
        [temp addObject:imageView];
    }
    
    self.imageViewsArray = [temp copy];
}


- (void)setPicPathStringsArray:(NSArray *)picPathStringsArray
{
    _picPathStringsArray = picPathStringsArray;
    
    CGFloat margin = 5;
    CGFloat itemW = [self itemWidthForPicPathArray:_picPathStringsArray];
    long perRowItemCount = [self perRowItemCountForPicPathArray:_picPathStringsArray];
    CGFloat itemH = [self itemHeightForPicPathArray:_picPathStringsArray];
    
    
    //设置约束
    CGFloat w = perRowItemCount * itemW + (perRowItemCount - 1) * margin;
    int columnCount = ceilf(_picPathStringsArray.count * 1.0 / perRowItemCount);
    CGFloat h = columnCount * itemH + (columnCount - 1) * margin;
    self.width = w;
    self.height = h;
    
    self.fixedHeight = @(h);
    self.fixedWidth = @(w);
    
    
    for (long i = _picPathStringsArray.count; i < self.imageViewsArray.count; i++) {
        
        UIImageView *imageView = [self.imageViewsArray objectAtIndex:i];
        imageView.hidden = YES;
    }
    
    if (_picPathStringsArray.count == 0) {
        self.height = 0;
        self.fixedHeight = @(0);
        return;
    }
    
    
//    __block CGFloat itemH = 0;
    
//    if (_picPathStringsArray.count == 1) {
//        SDTimeLineCellPicItemModel *model = _picPathStringsArray.firstObject;
        
//        __block UIImage *img = [UIImage new];
        
//        SDWebImageManager *manager = [SDWebImageManager sharedManager];
//        
//        [manager downloadImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",DFAPIURL,model.img_url]] options:0 progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
//            
//            img = image;
////            if (img.size.width) {
////                itemH = img.size.height / img.size.width * itemW;
////            }
//        }];
        
//    } else {
//        itemH = itemW;
//    }
    
    
    for (NSInteger index = 0; index< _picPathStringsArray.count; index++) {
        if (index > 8) {
            return;
        }
        SDTimeLineCellPicItemModel *model = _picPathStringsArray[index];
        long columnIndex = index % perRowItemCount;
        long rowIndex = index / perRowItemCount;
        __block UIImageView *imageView = [_imageViewsArray objectAtIndex:index];
        
        imageView.hidden = NO;
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
        imageView.userInteractionEnabled = YES;
        
        //保留长按手势
//        UILongPressGestureRecognizer *gesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(imageViewDidClick:)];
//        [imageView addGestureRecognizer:gesture];
        [imageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",DFAPIURL,model.img_url]] placeholderImage:[UIImage imageNamed:@"Image_placeHolder"] options:SDWebImageLowPriority];
        
        imageView.frame = CGRectMake(columnIndex * (itemW + margin), rowIndex * (itemH + margin), itemW, itemH);
    }
}

- (void)imageViewDidClick:(UIGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateBegan) {
        UIImageView *imageView = (UIImageView *)gesture.view;
        [[NSNotificationCenter defaultCenter] postNotificationName:KDiscoverLongPressContentNotification object:nil userInfo:@{@"contentLabel":imageView}];
    }
}

#pragma mark - private actions

- (void)tapImageView:(UITapGestureRecognizer *)tap
{
    SDTimeLineCellPicItemModel *picModel = self.picPathStringsArray[0];
    UIView *imageView = tap.view;
    SDPhotoBrowser *browser = [[SDPhotoBrowser alloc] init];
    browser.currentImageIndex = imageView.tag;
    browser.userId = picModel.weuser_id;
    browser.fcId = self.fcid;
    browser.sourceImagesContainerView = self;
    browser.imageCount = self.picPathStringsArray.count;
    browser.delegate = self;
    [browser show];
}

- (CGFloat)itemWidthForPicPathArray:(NSArray *)array
{
    if (array.count == 1) {
        return 120;
    } else {
        CGFloat w = [UIScreen mainScreen].bounds.size.width > 320 ? 80 : 70;
        return w;
    }
}

- (CGFloat)itemHeightForPicPathArray:(NSArray *)array {
    if (array.count == 1) {
        return 120;
    } else {
        CGFloat w = [UIScreen mainScreen].bounds.size.width > 320 ? 80 : 70;
        return w;
    }
}

- (NSInteger)perRowItemCountForPicPathArray:(NSArray *)array
{
    if (array.count < 3) {
        return array.count;
    } else if (array.count <= 4) {
        return 2;
    } else {
        return 3;
    }
}


#pragma mark - SDPhotoBrowserDelegate

- (NSURL *)photoBrowser:(SDPhotoBrowser *)browser highQualityImageURLForIndex:(NSInteger)index
{
    SDTimeLineCellPicItemModel *picModel = self.picPathStringsArray[index];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",DFAPIURL,picModel.bigimg_url]];
    return url;
}

- (UIImage *)photoBrowser:(SDPhotoBrowser *)browser placeholderImageForIndex:(NSInteger)index
{
    UIImageView *imageView = self.subviews[index];
    return imageView.image;
}

@end
